# Ideas parking lot

New ideas land here, never in the current milestone (stop rule 2).

- openai/math (Oct 2026): reference for Phase 6 Comparator configs and the challenge/solution layout; its formalization.yaml is a model for a machine-readable layer map that CI could check. Certificate-style results are relevant to the Certificates option. Anything borrowed enters the layer map as "statement unreviewed".
- Test the gate on that release: grade each result on axes such as "formal proof checked", "statement reviewed against the paper" and "novelty checked". Unknown axes must REJECT. A real-world must-pass/must-fail test set.

## Before any statements-v2

- **Overspent residual.** `statements-v1`'s `residual` truncates at 0. Once stage one overspends (x > θ), the residual is 0, and `residual_spec` covers only x ≤ θ (its `hx`). Past that point, the stage-two check `y ≤ residual θ x` still accepts y = 0, though x + y > θ. SCp2 §7.4 (`archive/SirusSC/papers/SCp2.pdf`, p. 13) clamps an overspent residual at ⊥ instead: "b − a (clamped at ⊥ if a > b)". It calls a ⊥ residual fail-closed. That holds only behind its guard, because SCp2's order puts ⊥ below every value (the known defect "Unknown sits below every value"). Revisit before any statements-v2.

## Certificates

- Reach's `check_positive_real` (`archive/Reach/jsg-lab/src/jsg/control/pr_checks.py`) reports positive realness without a certificate in two ways. It returns PR whenever the KYP LMI solve ends `optimal_inaccurate` (`if prob.status in (cp.OPTIMAL, cp.OPTIMAL_INACCURATE): return True, float(eps_min)`, lines 40–41), reporting the requested `eps_min` as the margin; an inaccurate solve is not a witness. Otherwise, even when the solver reports the LMI infeasible, it falls back to a 256-point frequency grid on the band (`margin = _phase_grid_margin(sys, band)`, then `return bool(margin >= eps_min), …`, lines 43–44), and a grid samples finitely many frequencies. An exact-rational checker in Lean, the Certificates option, should reject both: a ready-made negative control. Its test asserts only `ok in (True, False)`.
