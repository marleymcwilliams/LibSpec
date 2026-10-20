from __future__ import annotations
import json, os, pandas as pd
from jinja2 import Template

TEMPLATE = """
# Experiment Report

## Table A: Configuration Summary
{{ config_md }}

## Table C: Statistical Layer Audit
{{ stats_md }}

## Table D: Control and Stability Layer Audit
{{ ctrl_md }}
"""


def load_jsonl(path):
    with open(path) as f:
        for line in f:
            yield json.loads(line)


def main(run_dir: str = "runs"):
    # discover latest run
    cand = sorted([os.path.join(run_dir, d) for d in os.listdir(run_dir)], key=os.path.getmtime)[-1]
    jsonl = os.path.join(cand, "events.jsonl")
    rows = list(load_jsonl(jsonl))
    windows = [r for r in rows if r.get("type") == "window"]
    headers = [r for r in rows if r.get("type") == "header"]

    # theory constants for ISS terms (if present)
    C0 = None; tau_min = None
    if headers:
        theory = headers[0].get("theory", {})
        consts = theory.get("C", {}) if isinstance(theory, dict) else {}
        C0 = consts.get("C0", None)
        tau_min = consts.get("tau_min", None)

    # A: config (Hydra copies config; here just echo)
    cfg_rows = [{"Parameter": "run_dir", "Value": cand}]
    config_md = pd.DataFrame(cfg_rows).to_markdown(index=False)

    # C: stats (prefer top-level convenience keys)
    stats_rows = []
    for w in windows:
        stats_rows.append({
            "Window ID": w.get("w", -1),
            "||kappa_mix||_FIM^-1": w.get("kappa_fim_norm", w.get("stats", {}).get("norm_FIM", 0.0)),
            "chi(t)": w.get("ef_chi", w.get("EF", {}).get("chi", 0.0)),
            "EF radius r": w.get("ef_r", 0.0),
            "L^t": w.get("dro_L_hat", w.get("dro", {}).get("drift", 0.0)),
            "rho_t": w.get("dro_rho_t", w.get("dro", {}).get("rho_t", 0.0)),
            "eta*": w.get("dro_eta_star", w.get("dro", {}).get("eta_star", 0.0)),
        })
    stats_df = pd.DataFrame(stats_rows).sort_values("Window ID")
    stats_md = stats_df.to_markdown(index=False)

    # D: control
    ctrl_rows = []
    for w in windows:
        n_cross = w.get("frontier", {}).get("n_cross", 0)
        iss_switch = w.get("frontier_iss_switch")
        iss_linear = w.get("frontier_iss_linear")
        if iss_switch is None and C0 is not None:
            iss_switch = C0 * n_cross
        if iss_linear is None and C0 is not None and tau_min is not None:
            t_val = w.get("frontier", {}).get("t", 0)
            iss_linear = C0 * (t_val / max(1, tau_min))
        ctrl_rows.append({
            "Window ID": w.get("w", -1),
            "PR margin eps (cert)": w.get("pr_margin", 0.0),
            "SVD gap": w.get("svd_gap", w.get("degeneracy_gaps", {}).get("gap", 0.0)),
            "max principal angle (rad)": w.get("svd_max_angle", 0.0),
            "% k-plane": 100.0 if w.get("k_plane", 2) == 4 else 0.0,
            "N_cross": n_cross,
            "ISS frontier switch": iss_switch if iss_switch is not None else 0.0,
            "ISS frontier linear": iss_linear if iss_linear is not None else 0.0,
        })
    ctrl_df = pd.DataFrame(ctrl_rows).sort_values("Window ID")
    ctrl_md = ctrl_df.to_markdown(index=False)

    report = Template(TEMPLATE).render(config_md=config_md, stats_md=stats_md, ctrl_md=ctrl_md)
    out = os.path.join(cand, "report.md")
    with open(out, "w") as f:
        f.write(report)
    print(out)


if __name__ == "__main__":
    main()
