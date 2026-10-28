# Ideas parking lot

New ideas land here, never in the current milestone (stop rule 2).

- openai/math (Oct 2026): reference for Phase 6 Comparator configs and the challenge/solution layout; its formalization.yaml is a model for a machine-readable layer map that CI could check. Certificate-style results are relevant to the Certificates option. Anything borrowed enters the layer map as "statement unreviewed".
- Test the gate on that release: grade each result on axes such as "formal proof checked", "statement reviewed against the paper" and "novelty checked". Unknown axes must REJECT. A real-world must-pass/must-fail test set. Now proposed in [EXECUTABLE_GATE.md](EXECUTABLE_GATE.md), with its decisions queued as Q11–Q13.

## Found while drafting statements-v2

- **SCp3's dwell counter is circular.** Definition 4.1 makes the dwell counter r4 a component of the rank r, then sets r4 by comparing r′ with r: "r′ ◁lex r ⇒ r4′ := Tmax and r′ = r ⇒ r4′ := max{0, r4 − 1}". With the other four components unchanged and r4 > 0, the decrement itself makes r′ ◁lex r, which resets r4 to Tmax. So the window never closes, or the law is undefined. A candidate for the master guide's known-defects table. v2's Loader measures progress by what is pending instead, stage tickets included (`LoaderStep.progress`).
- **JSG V's overrides block every window.** OverrideActive is Global-scoped and leaves Σ only on expiry or revocation (§3, Overrides), and a window passes only if Σ_final = ∅. So unless a window's Σ leaves Global obligations out, no window passes while an override is active. `Passes` takes the obligations a window carries in as `carried`, so whoever builds that multiset decides. A question for the version that states overrides.
- **No accept rule or halt certificate yet.** Core object 3 says a halt with rejection carries the remaining obligations and the axes still unknown as its certificate. v2's `LoaderStep` has neither T-Accept nor a halt. A later version could state that a Loader run from `bootState` that reaches a state with no enabled step either passes (`Passes`) or carries what is still pending as the certificate.
- **Stage order isn't enforced.** `LoaderStep` runs any stage whose ticket is pending, in any order, while JSG V's pipeline runs EF → DRO → PR → CBF → Ω. The order still shows through authorities: a stage that runs too early leaves the obligations it should discharge pending, and the window fails. A later version can add an order as a step relation contained in `LoaderStep`. Both Loader theorems carry over to it unchanged.
- **SirusSC's pipeline can skip guards silently.** `run_pipeline` loops over `zip(guards, inputs)` (`archive/SirusSC/specchain/loader/loader.py`, line 415), so with fewer inputs than guards the rest never run, and nothing halts. This is a ready-made must-fail control for any executable Loader.

## Found while drafting statements-v3

- **A sharper KL–Fisher constant.** The proof gives 1 ± ε/2 to first order. A ray along which ψ'' falls linearly shows the best first-order constant is ε/3, where JSG I's remark claims ε is sharp. A later version could state the sharper form.
- **Strong duality for the KL-DRO.** Weak duality follows from `llr_tilted_right`: E\_Q[ℓ] − η KL(Q‖P) ≤ η log E\_P[e^{ℓ/η}]. Attainment needs the tilted measure P^{ℓ/η\*} to have KL exactly ρ. With both, the envelope identity would hold for the worst-case risk itself, not just its dual (QUEUE.md, Q10).
- **Defining the Jacobi defect.** A statement first needs Δ\_fr defined, say as the jump of the Schouten–Nijenhuis bracket across Σ, and a bound whose terms have the same units. For example, ‖∇S‖∞ could carry a factor of r\_tube (QUEUE.md, Q8).
- **`hint` could go.** It follows from `kl_fisher_local`'s other hypotheses, through a domain argument: the natural parameter space is convex, and ψ jumps at its boundary. A later version could drop it at the cost of that argument.
- **jsg-lab's DRO is loss-free.** `DRO.step` (`archive/Reach/jsg-lab/src/jsg/dro/soft_transport.py`) takes η\* from a soft-transport cost that never reads the loss, and never computes the dual value. It's a ready-made must-fail control for any executable envelope check.
- **Hypothesis counterexamples in Lean.** STATEMENTS_REVIEW gives a counterexample for each v3 hypothesis in prose. The DRO ones (S = {1, 2}) are cheap to prove, and would make the review's claims checked ones.

## Certificates

- Reach's `check_positive_real` (`archive/Reach/jsg-lab/src/jsg/control/pr_checks.py`) reports positive realness without a certificate in two ways. It returns PR whenever the KYP LMI solve ends `optimal_inaccurate` (`if prob.status in (cp.OPTIMAL, cp.OPTIMAL_INACCURATE): return True, float(eps_min)`, lines 40–41), reporting the requested `eps_min` as the margin; an inaccurate solve is not a witness. Otherwise, even when the solver reports the LMI infeasible, it falls back to a 256-point frequency grid on the band (`margin = _phase_grid_margin(sys, band)`, then `return bool(margin >= eps_min), …`, lines 43–44), and a grid samples finitely many frequencies. An exact-rational checker in Lean, the Certificates option, should reject both: a ready-made negative control. Its test asserts only `ok in (True, False)`.
