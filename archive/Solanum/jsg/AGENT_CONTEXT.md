# JSG Agent Context Pack
This pack composes the minimal shared context needed by an agent to reason across Parts 1 and 2 without duplication.

## Shared Tenets (single source)
The following are included once and apply to all parts.
- Decision space $\Gamma$ is smooth/connected; symmetry by Lie group when needed.
  - $G$ is Whitney-stratified; dynamics specified per stratum and prolonged (Filippov) at frontiers.
  - Classical identities hold stratumwise; frontier crossings induce a defect budget per crossing.
  - Evaluation functionals are Borel and $L^2$ under invariant/windowed laws.
  - EF neighborhood at independence with Fisher $F\!\succ\!0$ and Hessian-Lipschitz $L_\psi$.
  - Controllers are Dirac-projected and band-limited PR on $[\omega_L,\omega_H]$ with margin $\epsilon$.

## Symbol Registry (Standing Constants)
Code | Symbols | Meaning
--- | --- | ---
C1 | $\kappa_{\max}$,\ $\theta_{\min}$,\ $r_{\mathrm{tube}}$ | Frontier geometry: curvature, minimal incidence, tube radius.
C2 | $S_{\max}$,\ $G_{\max}$ | Uniform bounds on strategic fields / first derivatives near frontiers.
C3 | $L_{\mathrm F}$,\ $\tau_{\min}$ | One-sided Lipschitz per stratum; No-Zeno dwell time.
C4 | $\tau$,\ $\rho$ | Window length and DRO radius.
C5 | $F$,\ $\chi$,\ $L_\psi$ | Fisher objects and Lipschitz constant for EF Hessian.
C6 | $\epsilon$ | Positive-real margin on controller band.
C7 | $\eta^\star$ | Inner dual optimizer for soft-transport DRO.

## Label Conventions
- Part 1 labels: `*1` suffix (e.g., `sec:calc1`)
- Part 2 labels: `*2` suffix (e.g., `sec:calc2`)
- Cross-part references: use `\xref{sec:...}` to keep PDFs portable

## Sections (Part 1)
- `sec:adv-structures1`: Advanced Algebraic and Categorical Structures
- `app:alignment1`: Alignment \& Normative Contracts for Joint Strategic Geometry
- `sec:bench1`: Benchmarks and Application Domains
- `sec:calc1`: State Spaces and Hybrid Exterior Algebra
- `sec:closure1`: Hierarchical Closure: BBGKY Analogy and DRO
- `sec:conclusion1`: Conclusion
- `sec:control1`: Entropy-Aware Projected Control
- `sec:entropy1`: Entropy and Mixed Information Flow
- `sec:intro1`: Introduction and Motivation
- `sec:kernels1`: Computable Kernels: Plane Selection and Structural Derivatives
- `sec:stats1`: Computational Statistics and Practicalities
- `sec:stoch1`: Strategic Series and Cross-Cumulants

## Sections (Part 2)
- `sec:adv-structures2`: Advanced Structures
- `sec:calc2`: Calculus of Structures
- `sec:closure2`: Closure Properties
- `sec:ctrl2`: Control Interfaces
- `sec:entropy2`: Entropy Bounds
- `sec:kernels2`: Kernels
- `sec:stats2`: Statistical Reporting
- `sec:stoch2`: Stochastic Elements
