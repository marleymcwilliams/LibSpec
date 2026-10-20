from __future__ import annotations
import os, jax
from omegaconf import DictConfig
import hydra, jax.numpy as jnp
from jsg.io.logging import RunLogger
from jsg.io.registry import TheoryRegistry
from jsg.runtime.frontier_manager import FrontierManager
from jsg.runtime.frontier_scan import frontier_diagnostics
from jsg.calculus.filippov import blended_field
from jsg.stats.fisher import FisherContext
from jsg.stats.cumulants import estimate_cumulants
from jsg.algebra.plane_selection import select_planes, j_aligned_basis
from jsg.algebra.hopf import hopf_residual_norm, hopf_project
from jsg.structure.dirac import build_dirac_projection
from jsg.control.oustaloup import oustaloup_ss, ControllerState
from jsg.control.pr_checks import check_positive_real
from jsg.control.gain_policy import entropy_aware_gain
from jsg.iss.budget import ISSBudget
from jsg.dro.soft_transport import DRO
from jsg.dro.radius_policy import radius_from_drift
from jsg.envs.ph_port_hamiltonian import PHPlant

def _phi_list_from_cfg(cfg):
    return [lambda x: x[0]]

@hydra.main(version_base=None, config_path="../configs", config_name="defaults")
def main(cfg: DictConfig) -> None:
    run_dir = cfg.logging.run_dir; os.makedirs(run_dir, exist_ok=True)
    log = RunLogger(cfg, run_dir)
    theory = TheoryRegistry.from_cfg(cfg); log.write_header(theory.model_dump())

    plant = PHPlant(seed=cfg.data.seed)
    ctrl = ControllerState()
    fm = FrontierManager(cfg.calculus.r_tube, cfg.calculus.tau_min, _phi_list_from_cfg(cfg))
    fm.register_freeze_handler(ctrl.freeze); fm.register_unfreeze_handler(ctrl.unfreeze)

    fisher = FisherContext(cfg); dro = DRO(cfg); iss = ISSBudget(cfg)

    # Controller once; scale C by entropy-aware rule each window
    A, B, C, D = oustaloup_ss(cfg.control.alpha, cfg.control.N, cfg.control.band, gains={"k": 1.0})
    ctrl.x = jnp.zeros((A.shape[0],))

    x_prev = plant.state()
    key = jax.random.PRNGKey(0)
    prev_Q = None  # for principal-angle logging across windows

    for w_idx in range(0, 20):
        window = plant.window(cfg.data.windows.size)

        # Stats with sketching
        key, sk = jax.random.split(key)
        stats = estimate_cumulants(window, order=cfg.data.order_K, sketch_dim=32, key=sk)
        fisher.update(window)

        # Algebra → Hopf truncation diagnostics
        Aop = plant.A_operator()
        U, V, gaps = select_planes(Aop, cfg.control.degeneracy_gap)
        Jbasis = j_aligned_basis(Aop, U, V)
        # Orthonormal basis for principal-angle comparison
        try:
            Q, _ = jnp.linalg.qr(Jbasis)
        except Exception:
            Q = Jbasis
        Pi = build_dirac_projection(Jbasis)

        # Entropy-aware gain
        g = entropy_aware_gain(stats["norm_FIM"], cfg.control.gain.g_nom,
                               cfg.control.gain.phi_scale, cfg.control.gain.g_min, cfg.control.gain.g_max)
        A_, B_, C_, D_ = A, B, C * g, D

        # PR certification
        pr_ok, margin = check_positive_real((A_, B_, C_, D_), cfg.control.band, cfg.control.pr_margin_min)
        if not pr_ok:
            log.event({"type": "pr_reject", "w": w_idx, "margin": margin})
            continue

        # Inner loop with Filippov blending to exercise hybrid calculus
        phi = lambda x: x[0]
        f1 = lambda x: (plant._J - plant._R1) @ (plant._M @ x)  # demo; use plant internals
        f2 = lambda x: (plant._J - plant._R2) @ (plant._M @ x)
        eps = cfg.calculus.r_tube

        xs = []
        for t in range(cfg.data.windows.size):
            e = plant.error().reshape(1, 1)
            u = Pi @ (ctrl.step((A_, B_, C_, D_), e))
            # Blend dynamics near frontier; then use plant.step to update state
            x = plant.state()
            xdot = blended_field(x, phi, f1, f2, eps)
            plant._x = plant._x + 0.01 * xdot + jnp.array([u[0,0], 0.0])
            xs.append(plant._x)
            fm.update(plant._x, x_prev)
            x_prev = plant._x
        xs = jnp.stack(xs)
        fd = frontier_diagnostics(xs, phi, cfg.calculus.r_tube)

        # DRO step with adaptive radius
        drift = dro.estimate_w1_drift(window)
        rho_t = radius_from_drift(drift, cfg.dro.radius_policy)
        dro.step(window, fisher, rho_t, log)

        iss.log_window(w_idx, margin, gaps, fm.state.n_cross, cfg.calculus.tau_min)

        # Frontier ISS terms (explicit) for acceptance checks and triggers
        C0 = iss.C0
        frontier_switch = C0 * fm.state.n_cross
        frontier_linear = C0 * (fm.state.t / max(1, cfg.calculus.tau_min))

        # Principal angles to previous plane (max angle)
        svd_max_angle = None
        if prev_Q is not None and Q is not None:
            try:
                M = prev_Q.T @ Q
                s = jnp.linalg.svd(M, compute_uv=False)
                s = jnp.clip(s, 0.0, 1.0)
                ang = jnp.arccos(s)
                svd_max_angle = float(jnp.max(ang))
            except Exception:
                svd_max_angle = None
        prev_Q = Q

        log.window({
            "w": w_idx,
            # PR metrics
            "pr_margin": margin,
            "pr_margin_eps": margin,
            "degeneracy_gaps": gaps,
            "k_plane": 4 if gaps.get("near_degenerate", False) else 2,
            "svd_gap": gaps.get("gap", 0.0),
            "svd_max_angle": svd_max_angle if svd_max_angle is not None else 0.0,
            "frontier": {
                "n_cross": fm.state.n_cross,
                "dwell_ok": fm.dwell_ok(),
                "freeze_ratio": fm.freeze_time_ratio(),
                "tube_frac": fd["tube_frac"],
                "dwell": fd["dwell"],
            },
            "EF": fisher.snapshot(),
            "stats": {"norm_FIM": stats["norm_FIM"], "k3_norm": stats["k3_norm"]},
            # Top-level stats and DRO for triggers
            "kappa_fim_norm": stats["norm_FIM"],
            "ef_chi": fisher.chi,
            "ef_r": fisher.r,
            "dro_eta_star": dro.last_eta,
            "dro_rho_t": rho_t,
            "dro_L_hat": drift,
            "dro": dro.snapshot(),
            # ISS frontier terms
            "frontier_iss_switch": frontier_switch,
            "frontier_iss_linear": frontier_linear,
            "uses": ["Alg:Lem11","Ctrl:KYP","ISS:Thm3","Stat:Thm2","Alg:Hopf"],
        })

if __name__ == "__main__":
    main()
