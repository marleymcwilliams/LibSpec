# Dissipative Model (Forward)

## Windowed, Audit-Ready Proof Program
- Treat dissipative PDE proofs as replayable programs: evidence arrives as Raw data, adapters lift it into the graded acceptance algebra `Q = Q_max x Q_sum`, and a typed effect system `Sigma` tracks obligations.
- The composition rule `compose_ev` is lax: it upper-bounds order effects so replaying steps in the canonical schedule preserves safety invariants.
- The determinism envelope (`EnvLock`, `ReplayPlan`) pins floating point, RNG, and serialization; recomputation from the Transport Pack reproduces every byte.

## Spine Specialized to 3D Navier-Stokes
- The auditable spine reduces regularity to five lemmas: 
  1. Frequency-local energy inequality under frozen Littlewood-Paley architecture.
  2. Priced commutator interchange bound linking reassociations.
  3. `CVaR -> CKN` bridge for epsilon-regularity.
  4. Closure in `L^infty_t L^3_x` (discharging `Sigma`).
  5. Rigidity of ancient limits.
- Ledgered frontiers ensure that crossing tubes (time <-> frequency <-> patch <-> mesh) spend only on sum-axes; max-axes remain invariant.

## Priced Frontiers and Hybrid Space
- Frontier crossings are encoded as priced edges with norm families `Delta_fr,p = ||F^+ - F^-||_{A,p}` and optional group budgets to prevent micro-spends from hiding.
- Non-commuting reassociations trigger the Hybrid-Space layer: Dirac freeze/reproject, No-Zeno dwell, and a geometry-priced defect that lands in `Q_sum`.
- The ledger exports `C_fr` (frontier defect) into `JSG` and `SCp4` policies.

## Bridge Library and Tail Interfaces
- The Bridge Library generalizes the `CVaR -> CKN` bridge with radius-binned constants `epsilon_CKN[rb] = C0 NV C_CZ[rb] C_LEI[rb] epsilon`.
- `BridgeCert` artifacts bind metric id, risk parameters, derivation hash, and digest hooks; they are byte-replayable and referenced by `I4a` guards.
- Unknowns follow the beta-ledger: absorbing bottoms are ledgered per axis and cannot be cancelled by aggregation.

## Strengthened Sigma Safety
- Clamp FSM gains hysteresis (promote above `thetaup`, demote below `thetadown`), a digest-bound `ShockCap` for large `||DeltaQ_sum||_1`, and `RateLimiter` caps on retunes.
- Acceptance shocks classify rapid changes (Humor, Radicalism, Emotion) with replay recipes and required ledger slices.
- Frontier spend, leakage metrics, and holonomy budgets are logged with bootstrap CIs so auditors can replay policy compliance.

## Exported Interfaces
- Hands `JSG` the formal definitions for hybrid calculus, frontier budgeting, and the Bridge Library constants used in Parts II-III.
- Supplies `SCp3` with canonical guard shapes, saltation constants, and the No-Zeno dwell hooks needed for the Loader rank.
- Feeds `SCp4` tail contracts with extensional witnesses and priced work bounds over admissible evaluation trees.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).
- [Discovery of Unstable Singularities](../../Research/2509.14185v1.pdf): Fluid dynamics study motivating the dissipative-side modeling in the process duality (2025).


# Generative Model (Inverse)

## Reverse via Acceptance Algebra
- The inverse model rebuilds admissible trajectories by replaying the dissipative ledger in reverse: sum-axes track conserved spends, max-axes guard canonical invariants.
- Generation operates inside the acceptance algebra `Q` and its uncertainty lift `Q'`, so synthetic states are only admitted when their projected debits remain within the frontier budgets recorded during the forward run.
- Abstract interpretation operators (intervals, sub-Gaussian envelopes, robust sets) in `Q'` allow envelopes to remain sound when replayed under stochastic perturbations.

## Tail-Driven Replay
- Tail contracts (I11-I13) anchor generation: each replay step references a TailReceipt that proves the witness bytes, progress rank, and work counters match the recorded `proof_surface`.
- The TailContract interface enforces extensional acceptance-identical tail bytes imply identical replay decisions-so the inverse run is deterministic under `EnvLock`.
- Progress ranks couple to the Loader rank, guaranteeing that generative exploration terminates within the Part 3 No-Zeno dwell budget.

## Evidence Surfaces and Loader Hooks
- Every generated frame emits the same canonical CrossingPacket structure used in the forward pass, enabling `SCp3` guards to replay debits without special cases.
- Unknowns ledgers carry forward: any attempt to generate with `perp` evidence halts with the same `C_UNK_PRICED` receipts as the forward model.
- Bridge certificates and holonomy diagnostics are re-verified; regenerations that violate saltation or coupling budgets revert to the last accepted forward snapshot.

## Outputs to SpecChain
- Supplies `SCp4` with replayable witnesses for the contraction, ISS/tube, and WSTS families when they synthesize conservative tails.
- Provides `SCp5` governance with symmetric audit bundles-forward and inverse receipts share manifest structure so auditors can diff runs byte-for-byte.
- Enables scenario tooling (`03_implementation`) to synthesize counterfactuals while staying within the priced acceptance envelope established by the dissipative proof program.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).
- [General Modal Model specification](../../Research/General Modal Model.pdf): Formal generative mechanism that inverts dissipative PDE flows inside SpecChain.


# JSG I - Hybrid Calculus & Frontier Defect

## Program Overview
- Establishes a stratified calculus for coupled decision (`Gamma`) and objective (`G`) spaces so analytic results are replayable and attach directly to SpecChain evidence.
- Commits to Whitney stratifications with Filippov extensions to handle sliding modes while enforcing a hard No-Zeno dwell `tau_min`.
- Tags each statement with layer indicators ([Rep/Alg/Stoch/Inf/Clos/Ctrl/Comp]) and cross-references standing constants `C1-C7`.

## Hybrid Calculus
- Builds a bigraded exterior algebra on `TGamma oplus TG`; hybrid differential forms inherit smooth identities per stratum and include a geometry-scaled frontier defect term.
- Frontier crossings charge the defect via the Hybrid-Space layer and are compatible with discrete exterior calculus (DEC) so lattice computations can reuse the same budgets.
- Introduces a priced holonomy budget to bound rotational mass when switching planes.

## Strategic Series and Statistical Layer
- Defines strategic series with evaluation functionals that remain Borel/L2 under windowed laws and relates mixed cumulants to entropy via the Fisher metric.
- Supplies windowing guarantees: existence of cumulant laws, drift tolerances, and stability of mixed cumulants under adaptive windows.

## DRO Closure and Hierarchical Budgets
- Solves a soft-transport DRO objective whose KKT system is logged (`eta*`, dual gaps, sensitivity) and links adaptive radius policies to finite-sample rates.
- Splits error into modeling, sampling, and truncation components; leakage is controlled by the Fisher-conditioned radius r = epsilon / L_psi.

## Entropy-Aware Projected Control
- Models plants as port-Hamiltonian systems with Dirac projections; positive-real fractional controllers are certified on a band `[omega_L, omega_H]` with margin `epsilon`.
- ISS under switching is proven using frontier-aware supply rates and holonomy budgets.

## Computable Kernels and Structural Derivatives
- Details SVD-based plane selection with degeneracy sentinels (Davis-Kahan/Wedin gaps) and algorithms for structure-preserving updates.
- Shape derivatives are computed with finite-difference estimators whose variance bounds are shipped for replay.

## Algebraic & Categorical Structures
- Adopts a quasi-shuffle Hopf algebra over `(p, q)` words, defines characters/cumulants, and introduces a degree-3 bridge for mixed moments.
- Computes functor Lipschitz constants so categorical morphisms remain non-expansive in the Fisher norm.

## Operational Interfaces
- Publishes HAC/block-bootstrap recipes, simultaneous inference controls (BY/FDR), and reporting templates for benchmarks.
- Exports axis catalog hooks, hybrid axioms, and geometry-priced frontier defect definitions to Parts II-IV and to the Spec (`SCp2`, `SCp3`).

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).
- [SSM blueprint](../../Research/SSMblueprint.md): Project structure notes aligning derivations, specs, and implementation surfaces.


# JSG II - Operational Contracts

## Proof-Carrying Governor
- Converts the Part I geometry into falsifiable runtime contracts: every claim about coupling `M_t`, decision range `R_t`, and safety (`I1-I5`) ships with byte-replayable witnesses.
- New commitments include saltation calibration replays, grazing detection with adaptive dwell, and decision-range conservativity residuals with confidence intervals.

## Sensing & Identification
- Windowed sensing logs mixed cumulants with BY/FDR control, instrument maps, and Minimum Transfer Condition (MTC) badges.
- KL-Fisher radii become runtime guards: the locality clamp shrinks `r` or freezes discoveries when leakage metric `chi(t)` drifts.
- Sequential tests (SPRT) are preconditioned by DRO sensitivity checks (`partialrho` vs `eta*`) to avoid stale envelopes.

## Control & Certification
- CLF/CBF-QP controller projected by the Dirac map `Pi` ensures barrier invariance while PR certificates (GKYP/LMI) cover uncertainty sets with logged band endpoints and margins.
- Switching stability uses holonomy budgets and plane-gap CIs; lever selection is a conservative UCB constrained by CBF feasibility.
- Rights-plane tail protection guards CVaR budgets; failures trigger deterministic degrade rather than heuristic overrides.

## Evidence Packs & KPIs
- Ships a four-tier artifact stack: Transport Pack, Provenance Ladder, Coupling ID Sheet (with power statistics), and Automata Evidence.
- KPIs include coupling regret, holonomy per crossing, provenance latency, and dual-gap trends; alarms are defined for plateaued gaps or FDR drift.
- Replay tooling is pinned: a single container hash plus script must reproduce automata verdicts exactly.

## Interfaces to SpecChain
- Provides `SCp3` with normative guard recipes, leakage clamps, and liveness ranks.
- Supplies `SCp4`/`SCp5` with ledger shapes, ThresholdChange VC requirements, and Governance prompts for normalization-of-deviance audits.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).


# JSG III - Control & Evidence Pipeline

## Guard Topology and Rule Index
- Instantiates the guard order `EF -> DRO -> PR -> CBF -> Omega` with explicit acceptance checks, reason codes, and evidence IDs.
- Extends the Loader rank with geometric diagnosis (DEC/Hodge split, holonomy, Fisher continuity), sensing plans, control plans, certificate packs, and KPI targets.

## Reused Guarantees and Closures
- Binds No-Zeno dwell, geometry-scaled frontier defect, holonomy budgets, KL-Fisher neighborhoods, and DRO envelope identities to explicit replay checks.
- PR certificates are linked to ISS proofs; failures on any guard produce deterministic degradations and updated obligations.

## Sensing and Identification
- Windowing pipelines compute Fisher objects and whitening transforms, enforce coverage policies for coupling space `E_t`, and run leakage clamp FSMs.
- Promotions obey the Minimum Transfer Condition with instrument verification badges and sequential tests that honor DRO envelope preconditions.
- Numerical APIs specify power calculations, bootstrap parameters, and canonical JSON fields for sensing receipts.

## Control Synthesis and Reporting
- Describes the CLF/CBF-QP with frontier-aware relaxations, PR retune protocol, mixed-plane switching stability, and decision-range computation.
- Provides a normative lever catalog and safe-UCB selection logic; acceptance checks ensure zero CBF violations and verified retune hitmaps.

## Evidence Architecture and Benchmarks
- Tiered artifacts (Transport Pack, Provenance Ladder, CIS, Automata Evidence) have strict schemas and deterministic replay hooks.
- Automata enforce safety and bounded-response liveness; KPI schemas support replay monitors.
- Benchmark suite covers negative controls, degeneracy stress, and formal spec acceptance with pinned reference runs.

## Failure Cookbook & Ops Runbook
- Enumerates runtime triggers, freeze windows, dwell management, quick-reference actions, and operator verification steps.
- Provides bring-up phases, environment pinning, self-scaling loops, and resource sizing guidance for deployment.

## Exported Interfaces
- Serves `SCp3` with rank components, guard receipts, and failure codes.
- Supplies `SCp5` with provenance ladder structure and governance workflows.
- Informs implementation pipelines about deterministic replay requirements and numerical tolerances.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).


# JSG IV - Compositional Safety via Applied Category Theory

## Map & Build Philosophy
- Fixes a single-threaded logical pipeline per KPI window with the guard order `EF -> DRO -> PR -> CBF -> Omega -> omega-automata`.
- Clamp policy is leakage-aware (Green/Amber/Red) and tied to Fisher leakage `chi`; state transitions and evidence are deterministic under `EnvLock`.
- Acceptance is fail-closed: any breach of clock discipline, dwell bounds, saltation replay, ledger feasibility, or rights-plane CVaR rejects the window.

## ACT -> JSG Compiler Surface
- Defines semantic substrate objects and rules `R1-R9` that map categorical constructs (spans, operads, lenses) into executable Loader stages.
- Section-local acceptance slices guarantee that each compiled subgraph carries explicit guards and receipts.
- Worked wiring diagrams show how pushouts correspond to frontier crossings with priced ledger hooks.

## Runtime Layers and Omega Contract
- Layer stack: sensing/locality, DRO envelope, PR witness, CBF tube audit, omega-automata replay, determinism checks.
- The Omega stage requires ledger closure, budget compliance, and tail-contract receipts (if enabled) before committing the bundle to `proof_surface`.

## Evidence Architecture
- Compliance Bundle must contain attestation, ordered guard receipts, omega receipt, bundle manifest, axis catalog digest, and policy digests.
- CrossingPackets, GuardReceipts, and OmegaTrace entries have canonical JSON schemas and BLAKE3 digests; monitors rerun automata on hashed KPI rows.
- Deterministic replay requires matching seeds, library hashes, tolerances, and KPI row hashes; mismatches trigger hard failure codes.

## Governance as Code
- Threshold changes require structured memos, dual approvals, limited lifespan, and ThresholdChange VC entries; blinded first-pass reviews resist bias.
- LegacyRebindCert binds any non-BLAKE3 artifacts or `proof_print` names back into the canonical digest discipline.
- Clamp-policy FDR audits and normalization-of-deviance prompts are codified as periodic governance jobs.

## Verification & Benchmarking
- Provides V&V roadmap: replay harnesses, negative controls, stress tests, and omega-automata examples (bounded-response liveness monitors with explicit counters and latency bounds).
- Appendix supplies deterministic monitor stubs, acceptance traces, and privacy notes for Tier-4 evidence.

## Interfaces to SpecChain Parts
- Binds directly to `SCp5` uniform receipts and compliance bundle schemas.
- Supplies `SCp3` and `SCp4` with rule elaborations so Loader updates remain compositional and guard-first.
- Guides implementation teams on how to extend the compiler surface without weakening safety invariants.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).


# Stochastic Games as Canonical Substrate

## Canonical Expectiminimax Graph
- Model the game as a finite directed acyclic graph `G = (V, E)` whose vertices are full game states and edges are admissible transitions.
- Each state is encoded as the tuple `(U, p, C)` with player utility vector `U`, active player identifier `p`, and chance context `C` (for example remaining rounds or shuffled deck).
- Vertex types partition `V` into terminal, decision, and chance nodes; the partition is part of the canonical artifact and determines how values are computed.

## Node Evaluation Rules
- **Terminal nodes** carry fixed outcome vectors, for example `[1, 0, 0]` for a Player 1 victory.
- **Chance nodes** average over children with logged probabilities `P(v_i)`, yielding `E(v) = sum_i P(v_i) * E(v_i)`.
- **Decision nodes** apply generalized expectiminimax: the active player chooses the successor maximizing their component of `E`. Ties are broken by a deterministic policy so replay is byte identical.

## Backward Solution Procedure
- Solve `G` by backward induction starting at terminal leaves. Existence and uniqueness follow because `G` is a finite DAG.
- The solved values annotate every edge and vertex with an expected utility vector. These annotations feed later path analytics and Loader checks.
- Determinism is enforced by replay pinning the traversal order and random seeds; recomputation from the `proof_surface` replays the same walk.

## Canonical Quotient Graph (CQG)
- To keep the state space tractable, apply two equivalence reductions before evaluation:
  - **Symmetric equivalence** normalizes states that differ only by player relabelings (for example swapping utilities when players are interchangeable).
  - **Behavioral equivalence** merges nodes that induce identical successor distributions (type, probability mass, and downstream equivalence classes). The refinement terminates because it is monotone on a finite lattice of partitions.
- The CQG is logged with node identifiers, expected utility vectors, and the quotient witness showing which original states were merged.

## Path Diagnostics and Strategic Vorticity Hook
- Solved paths record alternating decisions `D` and chance events `P`. Example excerpt for the 142 health triad:
  - `142,1 -> 142,2 -> 141,3 -> ... -> 100` with alternating `D` and `P` annotations and the running victory probabilities.
- Differences between candidate paths `D_path_alt` and `D_path_in` expose how perturbations shift win odds. The antisymmetric part of these matrices is used later as the "strategic vorticity" tensor (curl of strategic tension).
- Logging includes the cumulative ledger of decision spreads, enabling downstream analytics on circulation and posture.

## Interfaces to SpecChain Parts
- Supplies the Loader with canonical predicates for CQG admissibility and row ordering.
- Provides frontier and path artifacts consumed by `SCp3` liveness proofs and `SCp4` tail contracts.
- Establishes the terminology used in Part 2 for frontier pricing (`I"_fr`) and in the JSG series for hybrid calculus over decision manifolds.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).
- [SSM blueprint](../../Research/SSMblueprint.md): Project structure notes aligning derivations, specs, and implementation surfaces.


# Strategic Vorticity: Curl of Potential Tension

## Motivation
- The solved expectiminimax graph induces a strategic tension field `v` over decision manifolds; deviations between optimistic and conservative paths manifest as circulation in that field.
- Strategic vorticity measures how momentum circulates when players perturb optimal play-capturing posture, bluffs, and irrational shocks that classic equilibrium ignores.

## Decision Spread Tensors
- For each path family `D`, record the decision spreads relative to a canonical path `d_ref`:
  - `D_path-alt` compares an alternative path against the canonical optimum.
  - `D_path-in` contrasts a prospective path with the incident path through the same nodes.
- Differences `D_path-alt = D_path-in - D_alt-in` isolate how perturbations redistribute win probability mass across players.
- The collection `W_Dis = span{d - d_ref}` spans admissible perturbations; its orthogonal complement captures novel strategy directions worth exploration.

## Curl / Vorticity Construction
- Map decision spreads into antisymmetric matrices `M = Y X^T - X Y^T = (D_i P_j - P_i D_j) e_ij`.
- Interpreting `v = nabla x` (strategic tension) yields a curl that highlights cycles where pressure builds; large entries signal regions where posture can reverse expected outcomes.
- Stratified DEC tooling around frontiers lets us approximate the curl on discretized simplices without losing the ledgered frontier defect.

## Diagnostics and Posture Analysis
- Track scalar summaries (`chi, gamma`) of strategic potential; when players are disadvantaged they can exploit non-zero vorticity to shift game momentum.
- Monitor the shock ledger: acceptance shocks classify narratives as Humor (quick repair), Radicalism (Red lock, overshoot), or Emotion (tail-risk surprise). Each class emits auditable receipts.
- Iteratively compute `D[alpha, n]` over depth `n` to build a linear system of desired decisions; limits define `INT = lim_{n->infty} D[0,n]`, the steady-state posture catalogue.

## Artifacts and Hand-offs
- Provides toy worked examples on a 2-simplex policy space for calibration.
- Exports the priced frontier crossings used by `I"_fr` and downstream safety budgets.
- Supplies vorticity metrics to `JSG` parts for hybrid calculus (curl terms) and to `SCp5` for governance diagnostics around normalization-of-deviance.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).
- [SSM blueprint](../../Research/SSMblueprint.md): Project structure notes aligning derivations, specs, and implementation surfaces.


# SCp1 - Global Conventions & Terminology (normative)

## Naming and symbols
- **Run fingerprint**: The JSON field `proof_surface` is the canonical run digest. The legacy term `proof_print` is forbidden in new outputs.
- **Genesis constant**: `root_print` denotes the fixed digest for the genesis run.
- **EnvLock / ReplayPlan**: pin the deterministic replay envelope (floating-point modes, RNGs, library hashes, traversal order).
- **Execution order**: All parts adopt the guard order `EF → DRO → PR → CBF → Ω`.

## Algebraic defaults
- Acceptance states live in the typed product `Q = Q_max × Q_sum`, with coordinatewise aggregation (`max` on max-axes, `+` on sum-axes).
- Runtime operators: `⊎` (heterogeneous join: `max` on `M`, `+` on `S`) and `⋆` (sequential: `+` on both). Cross-part aliases `⊙ ≡ ⊎`, `∧ ≡ ⋆` match the implementation surface.
- Unknowns are absorbing bottoms `⊥_i`: once ledgered on an axis they propagate under both operators and cannot be cancelled.
- Axis policies and budgets are pinned by the axis catalog digest; adapters are monotone homomorphisms on their declared axes.

## Thin-category semantics
- Posets are treated as thin categories; feasibility schedules compose as functors, ensuring that local ordering constraints lift to global ones.
- Products, projections, and diagonals are monotone maps; strengthening policies corresponds to precomposition with a functor that preserves adapter monotonicity.

## Guard-first discipline
- All guards operate under the fail-closed rule: if any priced input is `⊥`, the row is rejected before reaching pricing kernels.
- Unknowns presented in user interfaces must normalize to `⊥` prior to guard evaluation so the ledger reflects real exposure.

## Evidence vocabulary
- Canonical receipts carry `predicate_id`, `inputs_digest`, `checker_hash`, `verdict ∈ {PASS, FAIL}`, and deterministic `reason_code` on failure.
- `AttestationReceipt`, `TailReceipt`, `UpdateCert`, `RetuneCert`, and `RejectionCert` are named uniformly; their digests are always BLAKE3-256 (`b3:...`).
- Compliance bundles bind their Merkle roots into `proof_surface`, ensuring audit diffs compare canonical bytes.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).
- [SSM blueprint](../../Research/SSMblueprint.md): Project structure notes aligning derivations, specs, and implementation surfaces.


# SCp1 - Canonicalization (canon/v1) & Hash Discipline

## canon/v1 Encoding
- JSON is serialized as UTF-8 with sorted keys, minimal-decimal numbers, no superfluous whitespace, and escaped strings per RFC 8259.
- Numbers influencing priced outputs are finite IEEE-754 doubles rendered without `+` signs or avoidable exponents.
- Non-canonical inputs are rejected upstream; canonicalization failures emit `C_CANON_MISMATCH` receipts.

## Hashing & Digests
- All digests use BLAKE3-256 and render as strings `b3:<hex>`. The run bundle binds its Merkle root, guard receipts, and witness hashes into `proof_surface` before commit.
- Legacy hashes (e.g., SHA-256) must be rebound via `LegacyRebindCert` that records both the legacy digest and the new BLAKE3 binding.

## Seed & Replay Discipline
- Seeds derive from `root_print`, protocol suite, sorted parent digests, and provisional `proof_surface` using `HKDF-BLAKE3`. Stage-local RNGs use domain-separated derivations.
- `EnvLock` and `ReplayPlan` fix floating-point modes, library hashes, RNG families, and canonical traversal orders; deterministic replay is a hard invariant.

## Proof Binding & Bundles
- `proof_surface` binds the Transport Pack, Compliance Bundle, policy digests, and tail receipts; modifications after `Omega` are violations.
- Attestation at boot records loader hash, environment descriptors, and identity graph root; its digest is included in every bundle.

## Unknowns Hygiene
- Absorbing bottoms `perp` must be ledgered with explicit byte counts; attempts to price `perp` reject before reaching kernels.
- Unknown billing reports remaining headroom in policy-defined beta-ledgers and prevents "cap nibbling" across windows.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).


# SCp2 - Acceptance Algebra `Q`

## Typed product over S/M axes
- Partition acceptance axes into sum-like `S` and max-like `M`; each axis `i` carries `(Q_i, ≤_i)` with identity `e_i` and absorbing bottom `⊥_i`.
- Aggregation is defined by two runtime operators:
  - **Heterogeneous join** `q ⊎ r = ( q_M ⊕ r_M , q_S + r_S )` (`⊕` is componentwise `max` on `M`).
  - **Sequential aggregation** `q ⋆ r = ( q_M + r_M , q_S + r_S )` (componentwise `+` on both partitions).
- The product order `≤_Q` is coordinatewise; `e` is the all-identity vector and `⊥(J)` marks absorbing coordinates on subset `J ⊆ S ∪ M`.

## Operator laws and aliases
- `⊎` is associative, commutative, and idempotent on `M`; `⋆` is associative with unit `e`. Both operators are monotone in each coordinate.
- Cross-part aliases match the implementation surface: `⊙ ≡ ⊎` (horizontal aggregation) and `∧ ≡ ⋆` (vertical/temporal aggregation).
- Completeness upgrades (needed for residuation policies) lift axes to quantales; proofs ship with lattice witnesses pinned in the axis catalog.

## Unknowns and fail-closed behaviour
- Unknowns are represented by the absorbing bottom `⊥`; if any coordinate is `⊥`, both `⊎` and `⋆` absorb and the value propagates.
- Guard-first discipline rejects any priced row that would write `⊥` into `Q`; once ledgered, `⊥` cannot be cancelled by later aggregation.
- UI/front-end collectors must normalize “missing/top” states to `⊥` before they enter the algebra so priced kernels never observe stale unknowns.

## Guard-first integration
- Loader adapters are monotone homomorphisms over their declared axes, preserving axis isolation and the product structure.
- Ledger entries record realized `⊥` contributions per axis so governance can audit fail-closed decisions.

## Mechanization hooks
- Lean-style signatures define the product structure, residuation operators on complete slices, and builder functions that read canon/v1 axis catalog JSON.
- Executable kernels output receipts containing predicate ids, checker hashes, and digest-pinned parameters for deterministic replay.

## Interfaces
- Exposes `Q` to `SCp3` (Loader guards), `SCp4` (tail-contract axis bindings), and `JSG` (frontier debit accounting and holonomy ledgers).

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).


# SCp2 - Uncertainty Lift `Q'`

## Carriers and orders
- Each axis optionally lifts into uncertainty-aware carriers: intervals for cumulative quantities, sub-Gaussian envelopes for stochastic bounds, and robust sets for adversarial tolerance.
- Orders are pointwise (interval inclusion, convex order, set containment) with absorbing `⊥` mirroring the base algebra; `⊥` remains the fail-closed bottom.

## Abstract interpretation interface
- Provides monotone abstractions `α` and concretizations `γ` so adapters can reason about uncertain evidence while preserving acceptance guarantees.
- Lifted operators (`⊎′`, `⋆′`) are sound over the abstractions and collapse to the base operators when envelopes degenerate to singletons.

## Acceptance stance
- Defines upward-closed acceptance predicates so guards accept whenever all concretizations satisfy the policy; failing proof obligations produce deterministic rejection receipts.
- Worked example: sub-Gaussian lift publishes variance proxy, radius, and achieved tail bound with receipts verifying the inequality.

## Guard lifting and receipts
- Loader guards lift by composing base kernels with abstraction-aware contracts; receipts include the carrier type, parameters, and checker hash.
- Minimal checker specifications ensure Lean/Coq-extractable witnesses for the lifted operations.

## Interoperability
- Tail contracts and pricing kernels consume the same lift definitions, enabling uncertainty-aware work pricing and Loader audits without bespoke code paths.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).


# SCp2 - Frontier Debit `Δ_fr`

## Canonical construction
- Frontier evaluation trees enumerate admissible reassociation sequences; edges carry priced deltas derived from frontier kernels and guard placements.
- Debits accrue only on sum-axes; max-axes remain invariant so reassociations do not alter hard gates.
- Frontier rows are normalized and dimensionless before pricing; unit rescalings leave `Δ_fr` unchanged.
- Group budgets keep dispersed micro-crossings from hiding material spend; ledger entries include crossing ids, kernels, and digest-pinned parameters.

## Axioms and guards
- `Δ_fr` satisfies monotonicity, subadditivity over disjoint frontiers, and compatibility with Loader guards.
- Guard-first rule rejects rows with unknown inputs; canonical receipts log the kernel id, inputs digest, `Δ_fr`, and resulting ledger state.

## Complexity and safe evaluation
- Exact evaluation (`FRM-Dec`) is strongly NP-hard via reductions from 3-Partition; the decision version stays hard under unary encodings.
- Deployments rely on sound upper bounds (greedy heuristics, bounded-width DP, relax-and-round) with verifiable receipts; tightness regimes are documented in policy.

## Loader and tail integration
- Loader checks replay minimal data: `CrossingPacket` sequence, inputs digest, kernel hash, and price delta. Tail receipts reuse the same kernel outputs for work pricing.
- Axis catalog bridge ensures policy updates propagate to pricing kernels without code changes; `UpdateCert` must show bisimulation on evaluation trees.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).


# SCp3 - Normative Loader (Verifiable Automaton)

## Role & scope
- Sole arbiter of runtime transitions for the fixed pipeline `EF → DRO → PR → CBF → Ω`; enforces the safety-or-halt contract and emits canonical receipts for every outcome.
- Implements guard-first semantics: any priced unknown `⊥` causes a deterministic rejection before pricing kernels execute.

## Baseline invariants (I1–I10)
1. Raw digest match and Transport Pack integrity.
2. Config certificate validity under the governance keys.
3. `EnvLock` pinned (floating-point modes, RNGs, library hashes).
4. `ReplayPlan` validity and determinized traversal order.
5. Seed discipline / HKDF-BLAKE3 derivations per stage.
6. Axis isolation (adapters write only declared coordinates).
7. Adapter monotonicity across declared axes.
8. Rounding guard within policy tolerances.
9. Frontier budget check against `Δ_fr` receipts.
10. Audit bundle completeness with canonical manifest.
Each invariant emits a canon/v1 receipt whose digest is bound into the run’s `proof_surface`.

## Automaton structure
- Loader state consists of acceptance vector `q ∈ Q`, obligation multiset `Σ`, lexicographic rank tuple `r`, and compliance bundle accumulator.
- Each automaton transition consumes a guard receipt, updates `q`, discharges obligations, and decreases `r` lexicographically; otherwise it halts with `RejectionCert`.

## Evidence & TCB boundary
- Boot rule `T-Boot` emits `AttestationReceipt` binding loader binary hash, environment descriptors, and identity graph root; the receipt sits in every compliance bundle.
- All receipts (`GuardReceipt`, `CrossingPacket`, `TailReceipt`, `ΩReceipt`) are canon/v1 JSON with BLAKE3 digests; the Loader never emits opaque blobs.

## Interfaces
- Consumes axis catalog from `SCp2`, tail contracts from `SCp4`, and governance receipts from `SCp5`.
- Provides the Implementation part with deterministic replay expectations and checker hashes for verification tooling.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).


# SCp3 - Liveness

## Lexicographic rank
- Rank signature `r = (r0, r1, r2, r3, r4) ∈ ℕ^5` enforces progress:
  1. `r0`: baseline invariant debt (I1–I10 failures).
  2. `r1`: discretized frontier slack derived from `Δ_fr` and policy budgets.
  3. `r2`: outstanding adapter obligations (attestations, receipts, promised discharges).
  4. `r3`: audit backlog (evidence bindings required for `I10`).
  5. `r4`: dwell counter tied to the No-Zeno timer.
- Any transition must strictly decrease the most significant differing component; increases are forbidden.
- Every step emits a `DwellReceipt` threading the current rank so auditors can replay the monotone descent.

## Frontier slack discretization
- Policy supplies minimal quantum `δ`; deficits aggregated per group map to `r1 = ceil(max(0, deficit) / δ)`.
- Guarantees that at least `δ` of progress is recorded before `r1` drops; otherwise the dwell counter forces a halt.

## No-Zeno discipline
- Dwell budget `T_max` bounds steps without rank decrease; when `r4` reaches zero the Loader must halt via `RejectionCert`.
- Crossing audits verify dwell ≥ `τ_min`, symmetric hysteresis, saltation replay ≤ `C_salt`, and ISS ledger feasibility.

## Liveness conclusion
- Combined rank and dwell rules yield the safety-or-halt theorem: every run either accepts with the required receipts or halts in finite steps with a deterministic failure code.
- Rank components are exposed via receipts so auditors can replay the monotone descent and verify compliance.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).


# SCp3 - UpdateCert

## Purpose
- Mediates dynamic updates to loader kernels, policies, or axis catalogs while preserving deterministic replay and acceptance semantics.
- Each UpdateCert applies atomically; failure emits a canonical `RejectionCert` and leaves prior state intact.

## Obligations
- **Step-preserving bisimulation**: updated loader must simulate old behavior on all admissible traces; proof includes witness of paired states and receipts showing identical guard outcomes.
- **Sigma-non-expansion**: obligation multiset cannot shrink; updates may add obligations but never erase undischarged entries.
- **Axis isolation invariants**: updated adapters preserve whitelists; new axis bindings require policy digests and replay tests.

## Evidence Shape
- Canonical JSON with fields `update_id`, `scope`, `old_hash`, `new_hash`, `bisimulation_witness_digest`, `sigma_nonexpansion_digest`, `policy_digests`, and optional migration scripts (hashed).
- Includes a replay script hash that third parties execute to validate bisimulation and ledger preservation.

## Loader Integration
- Loader pauses state transitions during UpdateCert evaluation, runs the witness harness under `EnvLock`, and only swaps binaries on success.
- Post-update guard receipts reference the new checker hash while `proof_surface` captures both old and new digests for audit continuity.

## Interfaces
- UpdateCert is referenced by `SCp4` tail families when they upgrade kernels and by `SCp5` governance when thresholds change; all depend on the same certificate schema.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).


# SCp4 - TailContract Interface

## Family-neutral contract
- `TailContract = (Witness, Hyp, Obl, Exec, Step, Accept, ρ, Work)` defines how tail obligations are proven under `EnvLock`.
- Witness bytes are canon/v1 JSON embedded in `proof_surface`; acceptance is extensional—identical tail-witness bytes under the same environment yield identical verdicts.
- Hypotheses verify preconditions (e.g., contraction factors, tube invariance, WQO certificates); failures produce deterministic rejection receipts.

## Execution & progress
- `Exec` enumerates replay states with determinized traversal (BFS/DFS with canonical tie-breakers). `Step` is total and pinned by `EnvLock`.
- Progress rank `ρ` is lexicographic and decreases on every permitted step; stagnation consumes the Loader's No-Zeno dwell budget, guaranteeing termination.
- `Work` reports expected effort (`iters_upper`, `steps_upper`, or `nodes_upper`) for pricing `Δ_fr`.

## Axis bindings & unknowns
- Witness declares `axis_bindings` mapping evidence to `Q` deltas; adapters are monotone so stronger evidence never worsens acceptance.
- Unknowns discipline is explicit: `β`-unknowns bytes are ledgered per policy, and guard-first rejects any priced `⊥` before evaluation.

## Receipts & integration
- TailReceipt includes family id, witness digest, verdict, failure reason, work counters, `Δ_fr` debit, and unknowns ledger; bytes enter `proof_surface`.
- Uniform receipt shape (`predicate_id, inputs_digest, checker_hash, verdict, reason_code`) matches `SCp5`, making audit diffs mechanical.
- Loader couples `ρ` to its global rank (`r2` component) and requires TailReceipt before `Ω` acceptance.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).


# SCp4 - Families I11-I13 (Specs)

## I11 - Contraction Tail
- Witness records norm id, center digest, ball radius, effective FP contraction factor `gamma_fp`, invariance proofs, and residual bounds.
- Obligations: prove forward invariance of the ball under EnvLock arithmetic, certify contraction factor (including rounding), and show initial state lies inside the ball.
- Step kernel iterates the operator with deterministic ordering; progress rank counts remaining contraction steps; work pricing uses `iters_upper`.

## I12 - ISS / Tube Tail
- Witness encodes CLF/CBF certificates (GKYP or SDP digests), tube geometry, residual lower bounds, and uncertainty sets.
- Obligations: maintain barrier invariance, enforce No-Zeno dwell and hysteresis, log CVaR budgets for rights-plane slack, and certify GKYP margins on the declared band.
- Progress ranks track tube residual slack and dwell credits; failure triggers deterministic degrade receipts.

## I13 - WSTS Tail
- Witness supplies WQO/monotonicity certificates, acceleration proofs, and search-order commitments for the upward-closed set exploration.
- Obligations: deterministic exploration (e.g., canonical BFS over state hashes), acceleration correctness, and monotone adapters that write only declared axes.
- Progress rank counts pending frontier nodes; work counter `nodes_upper` prices exploration.

## Shared Guarantees
- All families inherit acceptance extensionality, work pricing, axis bindings, and unknowns ledger discipline from the TailContract interface.
- Receipts bind family id, witness digest, verdict, work counters, `Delta_fr` debit, and realized unknown bytes so the Loader and auditors replay the same tail semantics.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).
- [Contraction Tail contract schema](../../Research/ContractionTail.json): JSON schema for the SpecChain tail contract I11 Banach-ball witness.
- [ISS Tail contract schema](../../Research/ISSTail.json): JSON schema for the SpecChain tail contract I12 ISS and tube witness.
- [WSTS Tail contract schema](../../Research/WSTSTail.json): JSON schema for the SpecChain tail contract I13 well-structured transition systems witness.


# SCp5 - Uniform Receipts

## Canonical shape
- Every guard, kernel, or certificate emits canon/v1 JSON with fields:
  - `predicate_id`: stable identifier for the check.
  - `inputs_digest`: BLAKE3-256 hash (`b3:` prefix) of the canonical input view.
  - `checker_hash`: BLAKE3-256 of the executable or proof script.
  - `verdict`: `PASS` or `FAIL`; on failure, `reason_code` records the deterministic policy code (e.g., `C_UNK_PRICED`, `C_AXIS_LEAK`).
- Optional fields include `witness_digests`, `power`, `confidence_interval`, or `ledger_delta` depending on the predicate.

## Guard order integration
- Receipts are logged in the fixed pipeline order `EF → DRO → PR → CBF → Ω` and stored in the Compliance Bundle manifest.
- Tail receipts (I11–I13), UpdateCert evidence, and Loader dwell receipts reuse the same shape so auditors can diff runs without bespoke tooling.

## Deterministic replay
- Each receipt references the container hash, PRNG seeds, and tolerance profile via the Transport Pack; rerunning guards under `EnvLock` must reproduce identical bytes.
- Guard-first failures (priced `⊥`) and axis-isolation violations emit canonical `RejectionCerts` bound into `proof_surface`.

## Ledger binding
- Receipts are referenced by digest in the bundle manifest; the manifest's Merkle root is part of `proof_surface`.
- Governance jobs sample receipts, recompute kernels, and compare digests to detect drift or tampering.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).


# SCp5 - Compliance Bundle

## Required contents
- `attestation_receipt`: boot-time attestation with loader hash and environment descriptors.
- `guard_receipts`: ordered list of EF/DRO/PR/CBF receipts.
- `tail_receipts`: optional I11–I13 receipts sharing the uniform surface.
- `Ω_receipt`: terminal adapter verdict with counterexample hashes on failure.
- `bundle_manifest`: Merkle root plus index of all artifacts included in the run.
- `axis_catalog_digest`, `policy_digests`: pin the acceptance algebra and policy families in force.
- Optional: UpdateCert references, LegacyRebindCert entries, normalization-of-deviance memos.

## Canonical encoding
- Entire bundle serialized as canon/v1 JSON, hashed with BLAKE3-256, and bound into the run's `proof_surface` before commit.
- Ordering of receipts is deterministic; duplicates are forbidden and audited during manifest traversal.

## Replay expectations
- Transport Pack contains PRNG seeds, library hashes, tolerances, and KPI row hashes so replay reproduces guard inputs bit-for-bit.
- Governance scripts recompute the manifest, verify guard digests, and ensure the Compliance Bundle matches the stored `proof_surface` entry.

## Governance hooks
- Threshold changes append ThresholdChange VC entries; weekly audits confirm realized FDR, clamp policy adherence, and normalization-of-deviance memos.
- Guard-first (`C_UNK_PRICED`) and axis isolation (`C_AXIS_LEAK`) failures surface as explicit receipts in the bundle, preventing silent cancellation.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).


# SCp5 - Threat Model (STRIDE)

## TCB & Hardening
- TCB boundary includes loader binary, canonical kernels, replay container, and governance keys; all hashed with BLAKE3-256 and attested at boot.
- Seed discipline bans ambient entropy; deterministic replay prevents spoofing randomization.
- EnvLock protects floating-point modes, libraries, and traversal orders; tampering yields `C_ENV_DRIFT` receipts.

## Attack Surfaces & Mitigations
- **Spoofing/Tampering**: prevented via attestation receipts, manifest hashes, and guard-first semantics; UpdateCert requires bisimulation proofs.
- **Repudiation**: impossible once `proof_surface` seals receipts; LegacyRebindCert provides backward-compatible bindings.
- **Information disclosure**: Transport Pack limits contents to replay essentials; privacy-sensitive artifacts are hashed and only rehydrated with explicit keys.
- **Denial of service**: No-Zeno dwell and watchdog timers enforce bounded runtimes; work pricing discourages runaway tail searches.
- **Elevation of privilege**: Axis isolation and policy-pinned kernels prevent undeclared writes; governance requires m-of-n ThresholdChange VCs.

## Replay & Governance Discipline
- Compliance bundle plus Transport Pack give auditors deterministic reproduction; mismatches raise governance alarms and halt deployment.
- Normalization-of-deviance checks (shock ledger, clamp policy audits) surface attempts to slowly relax safety thresholds.
- Policy-kernel separation ensures that threshold changes require explicit governance artifacts rather than code edits.

## References
- [SpecChain-NL whitepaper](../../Research/SpecChainLight.pdf): Architecture for audit-ready categorical proof solvers and the normative loader design (2025).
- [Stress Testing Deliberative Alignment for Anti-Scheming Training](../../Research/stress_testing_antischeming.pdf): Apollo Research and OpenAI evaluation of covert actions for governance threat considerations (2025).



---

# (a) Geometric diagnosis — DEC/Hodge split, dwell, holonomy, Fisher continuity (**v2.1**)

**Goal:** Preserve **I₁–I₅** with explicit, auditable margins; guarantee **persistent feasibility** of the safety kernel; harden interfaces at **hybrid frontiers** and **multi-modal fusion seams**.

## A1. Invariants & operating bounds (hard gates)

- **I₁ No-Zeno dwell at frontiers (hybrid safety)**
    
    - Compute **τ_min** via CI on normal speed `ν̂_min`, saltation bound `C_salt`, with safety factor `γ_dwell ≥ 1.5`.
        
    - **Δ add – Hard dwell & hysteresis:** Enforce **both** Average Dwell Time (**ADT**) **and** **hard minimum dwell**: after any switch, forbid the next switch for `τ_min`. Add **hysteresis** ϵ on switching surfaces (`S↑>+ϵ`, `S↓<−ϵ`).
        
    - **Π-freeze** of projector during crossings.
        
    - **Acceptance (replay):** (i) tube residuals `LB_i ≥ 0`, (ii) `‖K−I‖_obs ≤ C_salt·1.1`, (iii) **ADT margin ≥ 0**, (iv) **hard dwell satisfied**.
        
- **I₂ Statistical locality & provenance continuity (two-channel)**
    
    - EF radius `r = ε_EF / L_ψ` (KL-quad sandwich) **and** OOD shift (`HSIC_p`, `MMD_p`) must both pass.
        
    - **Δ add – Power & adaptivity:** use **incomplete U-statistics** (block / random subsample) with tracked **test power ≥ 0.8**; multi-kernel (MK) bandwidth selection (median heuristic fallback).
        
    - Targets: ≤5% MAPE up to k=4; **CVaR₀.₉₅** preserved. Failing either ⇒ `Clamp=Red`.
        
- **I₂x Cross-modal consistency (fusion seam guard; Δ new hard gate under I₂)**
    
    - **Geometric projection IoU:** project LiDAR 3D clusters into image plane; require IoU with vision masks ≥ `IoU_min`.
        
    - **Physics consistency:** IMU-predicted ego-motion must match visual flow / LiDAR odometry within `(ε_R, ε_t)`.
        
    - **Conditional independence check:** `HSIC(Feat_cam, Feat_lidar | x̂_state) ≈ 0` within tolerance; high value ⇒ unmodeled coupling → `Clamp=Amber` (degrade; see GDM below).
        
- **I₃ Identifiability-first discovery (correlation ≠ coupling)**
    
    - Promotions require **pre-registered tests** (HSIC + FDR) **and** instrument/lag sanity.
        
    - Triggers: ρ≥0.6 or Kendall-τ≥0.5 **or** HSIC p<0.01 (post-FDR). **Power ≥ 0.8** documented.
        
- **I₄ Actuation-basis stability (holonomy/DEC + degeneracy sentinels)**
    
    - Track **Holonomy** and **Harmonic Rotational Mass** as budgets; add **λ_gap_min** and **κ(A)** sentinels.
        
    - Two consecutive sentinel hits ⇒ **basis freeze** + escalate `k` before updates.
        
- **I₅ Rights-plane & PR stability (CBF/CLF-QP with robust PR)**
    
    - Runtime **CBF/CLF-QP** enforces barrier invariance; **finite-band PR** witness via **GKYP** over Ω; band re-tunes only when a valid **offline** certificate exists (see D).
        
    - **Default-deny:** missing/invalid telemetry or expired Ω ⇒ lock.
        

> **Meta-guard (Anti-Goodhart):** Treat **coupling mass** `M_t = κ_tᵀF_t^{-1}κ_t` as **diagnostic only**. If `M_t` drops without corroborating process change or test power, set `Clamp=Amber` and require operator review.

## A2. DEC/Hodge operationalization (runnable interfaces)

- Maintain a **DEC complex per mode**. Per window compute **gradient/solenoidal/harmonic** energies; trend **harmonic mass** as degeneracy sentinels.
    
- Holonomy budget = line integral of the connection over closed loops (approx. from control cycles); breach ⇒ basis freeze + dwell escalation.
    
- **Δ guard:** prefer **linear-algebra sentinels** (λ_gap_min, κ) for online gating; run DEC/holonomy at **Tier-2** cadence (see telemetry tiers).
    

## A3. Governance against normalization-of-deviance

- Any threshold relaxation (dwell, EF radius, q, grazing `p_thr`, Ω bounds) requires:  
    (i) **structured risk memo** (template below), (ii) **dual approval** (independent, blinded first pass), (iii) **reversion ≤ 21 days**, (iv) **ThresholdChange VC** (m-of-n).
    
- **Risk memo template (Δ add):** Worst-case w/ latent fault, auto-revert conditions, monitoring plan, live experiment bounds.
    

---

# (b) Safety kernel — optimal-decay **CLF-CBF-QP** (always-feasible) + ω-automata/LTL-MTL

**Mission:** Guarantee **point-wise feasibility** inside `h(x)>0`; isolate kernel; produce proofs & numerics that Tier-1 can audit.

## B1. Optimal-decay safety QP

- Decision: `u, δ, ω`
    
- Minimize: `½ uᵀH u + Fᵀu + p δ² + q (ω−ω₀)²`
    
- s.t.
    
    - **CBF:** `L_f h + L_g h · u ≥ − ω α(h)` (ω ≥ 0, cost-penalized)
        
    - **CLF:** `L_f V + L_g V · u ≤ −γ V + δ`
        
    - **Actuator:** `u ∈ U_adm`
        
- **Feasibility:** For any `h(x)>0`, convex `U_adm` ⇒ ∃ feasible `(u, ω)`; ω absorbs conflict.
    

**Δ numerics (hard):**

- Enforce **watchdog** `t_solve ≤ WCET`; timeout ⇒ `π_brake` + `A_PROOF_DRIFT_HARD`.
    
- Track **KKT residual**; CI gate on `p99(resid) ≤ ε_kkt`.
    
- Telemetry: `solver_iterations`, `warm_start_used`, **`max_input_staleness_ms`**.
    

**Export (Tier-1):** `ω*`, `δ*`, **KKT residual**, **CVaR₀.₉₅ CBF slack**, iterations, `max_input_staleness_ms`.

## B2. Kernel isolation & fail-safe

- Kernel runs in a **protected process**. Input `u_nom` → output `u_safe`.
    
- Solver fail or `h≤0` ⇒ `u=π_brake` + **lock**; raise `A_PROOF_DRIFT_HARD`.
    

## B3. DRO envelope precondition + **SPRT** on coupling mass

- Verify **envelope identity** `d/dρ E[φ_η] |_{η=η⋆} ≈ η⋆`; else quarantine (`Clamp=Red`).
    
- Register `{H₀: M_t ≤ B_saf, H₁: M_t ≥ B_risk, α, β, δ, bounds, stop_time, verdict}`; link transcript id.
    

## B4. ω-automata (accept/reject) **with liveness**

Safety LTL (existing):

- `G(¬fresh(backpressure) → X locked)`
    
- `G(valid(Ω) ∧ PR_ok → allow) ∧ G(¬valid(Ω) → ¬allow)`
    
- `G((EF_ok ∧ OOD_ok ∧ XMOD_ok) ∨ quarantine)`
    
- `G(λ_gap_min < λ_floor ∨ κ>κ_max → X freeze_basis)`
    

**Δ add – Liveness / bounded response (MTL):**

- **Bounded Amber:** `G(Amber → F_{≤N} (Green ∨ Red))`
    
- **Retry budget:** `G(retry → F_{≤R} stable ∨ Red)`
    
- **ω tension:** `G(ω* > ω_crit for T≥T₀ → F_{≤N} (mode=Conservative ∨ request_replan))`  
    Implement via counters/watchdogs; expose **verdict + timer** in Tier-1.
    

---

# (c) Hybrid handling — Zeno control, saltation, switching stability (**replayable**)

## C1. Frontier calculus (saltation replay)

- Log `F±`, normal `n`, reset map; compute saltation `K`.
    
- **Accept iff** `‖K−I‖_obs ≤ C_salt·1.1` and `LB_i ≥ 0`.
    

**Δ add – Atomic packet & consequence:**

- **Atomic packet** on crossing:  
    `{ts, F_plus, F_minus, n, reset_jac, x_pre, x_post, K_obs, pass_bool, window_id}`
    
- If **pass_bool = false** ⇒ `Clamp=Amber`, raise incident, bias planner away from this frontier until analyzed.
    

## C2. ADT supervisor & switching stability

- Enforce **ADT** and **hard minimum dwell** `τ_min`.
    
- If grazing probability > `p_thr` or CI(ν̂_min)→0, **increase dwell**, **shrink tube** by `γ_dwell`.
    
- Ensure **CQLF/common storage** for projected control; export `switch_stability_id`.
    

## C3. Π-freeze & tube-aware CBF

- Freeze Π across crossings; include tube margins in **CBF** (`h⁺(x) ≥ 0` from saltation).
    

---

# (d) Robust PR control — GKYP, Ω governance, & **pre-certified degradations**

## D1. Finite-band PR witness via GKYP (**offline**)

- Certify ℜ{C_N(jω)} ≥ ε on `[ω_ℓ, ω_u]` ∀ plant in **Ω** (polytopic/LFT).
    
- Output certificate `{Ω, ε, P,Q, multiplier, postcheck hit-map}` (versioned).
    

## D2. Ω specification & **contract governance**

- `/specs/omega.yaml`: `model_class`, `param_bounds`, `disturbance_bounds (L₂/L∞)`, `valid_until ≤ τ*`, **Omega_sha256**, **cert_id**.
    
- **Δ stance:** Ω is a **contract**, not a live knob. Online system **does not expand Ω** automatically.
    
- **On breach:** switch to **pre-certified** conservative controller (e.g., **Ω_wc**, **Ω_vision_only**, **Ω_lidar_only**) or safe state; open RCA.
    
- Any Ω update → **offline recertification** + **ThresholdChange VC** (time-boxed), Merkle-rooted into Ω preimage.
    

---

# (e) Sensing & provenance — telemetry tiers, OOD, VCs/Merkle

## E1. **Tiered Telemetry Architecture (Δ add)**

- **Tier-1 (hard realtime):** `h(x)`, `Lf h`, `Lg h·u`, **KKT residual**, `ADT margin`, invariant booleans, **liveness timers**.
    
- **Tier-2 (near-realtime):** `ω*, δ*`, `solver_iterations`, `λ_gap_min`, `κ(A)`, **IoU_xmod**, `IMU↔odom deltas`, HSIC/MMD p-values (approx).
    
- **Tier-3 (batch/audit):** VC bundles, dense GKYP hit-maps, full HSIC/FDR tables, DEC/holonomy, DevOps KPIs.
    

## E2. OOD/shift monitors

- Keep HSIC/MMD; support **permutation-free cross-HSIC** for spikes; log estimator type, subsample size, and power.
    

## E3. Decentralized provenance — **VCs + Merkle**

- Required VCs: `EFGuardVC`, `DROEnvelopeVC`, `PRWitnessVC`, `CBFVC`, `ThresholdChangeVC`.
    
- Bundle per window; store **Merkle root** in Tier-1 and Ω preimage.
    

---

# (f) Contracts, schemas, CI hooks, and policies

## F1. Contracts (sidecar) — crisp errors

- Default-deny on missing/stale risk state or unreachable store.
    
- Dual-control relaxations require **ThresholdChange VC (m-of-n)**, blinded first pass.
    
- Two-channel locality **+** cross-modal (`I₂x`) required; else `E_LOCALITY_UNCERTAIN`.
    
- Degeneracy sentinel twice ⇒ `E_BASIS_DEGENERACY_IMMINENT` + basis freeze.
    
- Provenance is **decentralized** (VCs authoritative).
    

## F2. Tier-1 schema extensions (**Δ additions in bold**)

```json
"SafetyKernel": {
  "type":"object",
  "required":["omega_star","delta_star","kkt_residual","cvar95_cbf_slack"],
  "properties":{
    "omega_star":{"type":"number","minimum":0},
    "delta_star":{"type":"number","minimum":0},
    "kkt_residual":{"type":"number","minimum":0},
    "cvar95_cbf_slack":{"type":"number"},
    "solver_iterations":{"type":"integer","minimum":0},          // Δ add
    "warm_start_used":{"type":"boolean"},                        // Δ add
    "max_input_staleness_ms":{"type":"number","minimum":0}       // Δ add
  }
},
"Switching": {
  "type":"object",
  "required":["adt_margin","grazing_p","frontier_hits","hard_dwell_ok"],
  "properties":{
    "adt_margin":{"type":"number"},
    "grazing_p":{"type":"number"},
    "frontier_hits":{"type":"integer","minimum":0},
    "hard_dwell_ok":{"type":"boolean"}                           // Δ add
  }
},
"PRWitness": {
  "type":"object",
  "required":["band","epsilon","P_sha256","Q_sha256","uncertainty_sha256","postcheck_min_margin","hitmap_sha256","cert_id"],
  "properties":{
    "band":{"type":"array","items":{"type":"number"},"minItems":2,"maxItems":2},
    "epsilon":{"type":"number"},
    "P_sha256":{"type":"string"},
    "Q_sha256":{"type":"string"},
    "uncertainty_sha256":{"type":"string"},
    "postcheck_min_margin":{"type":"number"},
    "hitmap_sha256":{"type":"string"},
    "cert_id":{"type":"string"}                                   // Δ add
  }
},
"LocalityEvidence": {
  "type":"object",
  "required":["ef_radius","oob_shift","xmod"],
  "properties":{
    "ef_radius":{"type":"number","exclusiveMinimum":0},
    "oob_shift":{
      "type":"object",
      "required":["hsic_p","mmd_p","power"],
      "properties":{
        "hsic_p":{"type":"number"},
        "mmd_p":{"type":"number"},
        "cross_hsic_p":{"type":"number"},
        "estimator":{"type":"string","enum":["U","B","R"]},       // Δ add
        "power":{"type":"number","minimum":0,"maximum":1}         // Δ add
      }
    },
    "xmod":{                                                      // Δ add
      "type":"object",
      "required":["iou_proj","imu_flow_resid","hsic_cond_p"],
      "properties":{
        "iou_proj":{"type":"number","minimum":0,"maximum":1},
        "imu_flow_resid":{"type":"number","minimum":0},
        "hsic_cond_p":{"type":"number","minimum":0,"maximum":1}
      }
    }
  }
},
"Automata": {
  "type":"object",
  "properties":{
    "A_STATE_RETRY_BUDGET":{"type":"string"},
    "A_OOB_SHIFT_DIVERGENCE":{"type":"string"},
    "A_PROOF_DRIFT_HARD":{"type":"string"},
    "A_VC_CHAIN_INCOMPLETE":{"type":"string"},
    "A_BACKPRESSURE_FAILSAFE":{"type":"string"},
    "A_THRESHOLD_RELAXATION_GUARD":{"type":"string"},
    "LIVENESS_AMBER_BOUND_TIMER":{"type":"integer","minimum":0},  // Δ add
    "OMEGA_CONTRACT_VALID":{"type":"boolean"}                     // Δ add
  }
}
```

**Atomic frontier packet (new object, audit bus):**

```json
"FrontierPacket": {
  "type":"object",
  "required":["ts","F_plus","F_minus","n","reset_jac","x_pre","x_post","K_obs","pass_bool","window_id"],
  "properties":{
    "ts":{"type":"string","format":"date-time"},
    "F_plus":{"type":"string"},
    "F_minus":{"type":"string"},
    "n":{"type":"string"},
    "reset_jac":{"type":"string"},
    "x_pre":{"type":"string"},
    "x_post":{"type":"string"},
    "K_obs":{"type":"string"},
    "pass_bool":{"type":"boolean"},
    "window_id":{"type":"string"}
  }
}
```

## F3. CI gate (Δ)

- Require **VC quorum** + **Merkle root**; else `E_VC_QUORUM`/`E_VC_MERKLE_MISMATCH`.
    
- **Locality two-channel + cross-modal**; else `E_LOCALITY_UNCERTAIN`.
    
- **Ω.valid_until > window_end & cert_id present**; else `E_OMEGA_EXPIRED`.
    
- **Kernel numerics:** `KKT p99 ≤ ε_kkt` and `WCET` met; else `E_SAFETY_KERNEL_NUMERICS`.
    
- **Liveness timers** configured; else `E_STATE_LIVENESS`.
    

## F4. Runtime OPA/Gatekeeper policy (Δ)

- Enforce policies **in CI and at runtime** on config plane.
    
- **Break-glass** requires special short-lived **VC** with m-of-n signers; emits high-priority audit event.
    

---

# (g) Minimal code stubs (drop-in)

## G1. Safety kernel watchdog wrapper

```python
# src/core/safety_kernel/qp.py
def solve_safety_qp(x, u_nom, h, Lf_h, Lg_h, V, Lf_V, Lg_V, U_adm, H, F, params, now_ms, latest_sensor_ts_ms):
    """
    Returns: u_safe, meta = {
      omega_star, delta_star, kkt_residual, cvar95_cbf_slack,
      solver_iterations, warm_start_used, max_input_staleness_ms
    }
    Hard timeouts trigger π_brake and A_PROOF_DRIFT_HARD.
    """
    ...
```

## G2. Cross-modal invariant checks

```python
# src/perception/xmod/checks.py
def project_lidar_to_image(points3d, K, T_cam_lidar): ...
def iou(mask_a, mask_b): ...
def imu_flow_consistency(imu_state, flow_field, tol_R, tol_t): ...

def xmod_checks(lidar_clusters, image_masks, imu_state, state_hat):
    iou_min = 0.5  # config
    iou_vals = [iou(project_lidar_to_image(c.pts, K, T), m) for c, m in zip(lidar_clusters, image_masks)]
    iou_proj = min(iou_vals) if iou_vals else 1.0
    imu_resid = imu_flow_consistency(imu_state, flow_field=..., tol_R=..., tol_t=...)
    hsic_cond_p = hsic_conditional(features_cam(...), features_lidar(...), cond=state_hat, estimator="B")
    return {"iou_proj": iou_proj, "imu_flow_resid": imu_resid, "hsic_cond_p": hsic_cond_p}
```

## G3. Saltation replay packet

```python
# src/models/plant/saltation.py
def saltation_matrix(F_minus, F_plus, n, reset_jac):
    # K = reset_jac + ((F_plus - reset_jac @ F_minus) @ n / (n.T @ F_minus)) @ n.T
    ...

def emit_frontier_packet(Fm, Fp, n, Rj, x_pre, x_post, window_id, clk):
    K_obs = saltation_matrix(Fm, Fp, n, Rj)
    ok = np.linalg.norm(K_obs - np.eye(K_obs.shape[0]), ord=2) <= C_salt * 1.1
    pkt = {"ts": clk.now_iso(), "F_plus": hash_blob(Fp), "F_minus": hash_blob(Fm), "n": hash_blob(n),
           "reset_jac": hash_blob(Rj), "x_pre": hash_blob(x_pre), "x_post": hash_blob(x_post),
           "K_obs": hash_blob(K_obs), "pass_bool": ok, "window_id": window_id}
    audit_bus.publish("FrontierPacket", pkt)
    return ok
```

## G4. GKYP certificate export (offline toolchain)

```python
# tools/robust/gkyp_cert.py
def certify_pr_band(A,B,C,D, band, Omega_desc):
    """
    Offline: solves LMI, returns epsilon, P,Q, hitmap, postcheck_min_margin, cert_id
    """
    ...
```

## G5. Approx HSIC/MMD with power tracking

```python
# src/stats/ood.py
def mmd_multi_kernel(x, y, kernels, estimator="B", subsample=None):
    """Incomplete U-statistic estimator; returns (stat, pval, power_est)"""
    ...
```

---

# (h) KPIs & horizons (τ*≈21 days; CVaR₀.₉₅)

**Process:** `pipeline_wait_time_p95 ≤ 15m (CVaR95 ≤ 20m)`, `cas_retry_rate ≤ 10%`, no gate type >35% failures (7d), `cooldown.level p90 ≤ 2`.  
**Outcome:** `0 critical/0 high` prod findings; `rollback_rate ≤ 1%`; `false_positive_rate ≤ 5%`; `mttr ≤ 1 business day`.  
**Interface:** `oob_shift sustained breaches = 0 (7d)`; `provenance_coverage = 100%`; `Ω revalidation lag ≤ τ*/3`.  
**Kernel numerics:** `kkt_residual p99 ≤ ε_kkt`; **`QP WCET violations = 0`**; `postcheck_min_margin ≥ ε_min`.  
**Fusion:** `xmod IoU p5 ≥ IoU_min`; `imu_flow_resid p95 ≤ ε_flow`.  
**Liveness:** `Amber→(Green|Red)` within **N** windows p99; `ω* > ω_crit` sustained escalations handled ≤ **N**.

---

# (i) Auditor’s replay checklist (**tightened**)

1. **Tier-1/Tier-2 ingest**; recompute HSIC/MMD (record estimator & subsample) → two-channel pass with **power ≥ 0.8**.
    
2. **Cross-modal:** IoU projection ≥ `IoU_min`; IMU↔flow residual ≤ bounds; `HSIC_cond` ok.
    
3. **Saltation & tubes:** recompute `K`; `‖K−I‖` bound & `LB_i≥0`; **hard dwell satisfied**; ADT margin ≥ 0.
    
4. **Safety kernel:** `ω* > 0` only when needed; `kkt_residual ≤ ε_kkt`; **WCET not violated**; CVaR₀.₉₅ slack within budget.
    
5. **DRO envelope:** `d/dρ E[φ_η] ≈ η⋆`; otherwise quarantine bit set.
    
6. **SPRT transcript:** parameters/bounds/stop time/verdict; **power ≥ 0.8**.
    
7. **PR replay:** GKYP `{Ω, ε, P,Q, cert_id}`; dense post-check hit-map; certificate validity/expiry.
    
8. **Ω contract:** on breach, evidence of **pre-certified** conservative controller switch; RCA ticket link.
    
9. **Automata:** reproduce **safety** and **liveness** verdicts from logs (timers/counters).
    
10. **Provenance:** VC quorum + Merkle root; Ω.valid_until in future; break-glass VCs (if any) valid/expired as expected.
    

---

# (j) Human & process guardrails (HFE-hardened)

- **Runbooks (action-first):** the first step places the system safe (`enter_safe_mode` / **activate ECK**); diagnostics follow. Checklist, verbs, screenshots.
    
- **Alerting:** tiered (Critical/Warning/Caution/Advisory), **actionable only** for pages, correlation to suppress cascades.
    
- **Independence:** DAL-A-style independence for Tier-1 schema & kernel code; auditors use **independent VC keys**.
    
- **Training:** drills for **quarantine**, **basis freeze**, **Ω breach**; reward “call-the-halt”.
    
- **Threshold changes:** blinded first-pass reviews to resist authority/anchoring bias.
    

---

# (k) Error catalog (superset)

`E_VC_QUORUM`, `E_VC_MERKLE_MISMATCH`, `E_LOCALITY_UNCERTAIN`, `E_XMOD_INCONSISTENT`, `E_BASIS_DEGENERACY_IMMINENT`, `E_OMEGA_EXPIRED`, `E_BACKPRESSURE_LOCK`, `E_STATE_LIVENESS`, `E_SAFETY_KERNEL_NUMERICS`, `E_SALTATION_BREACH`, `E_QP_WCET`.

---

# (l) Prompts & guides (paste-ins)

- **Interpreter.md — Locality & Fusion**
    
    > Locality requires **two channels** (EF radius & OOD) **and** **cross-modal consistency**. If any of the three fails, **degrade or quarantine**.
    
- **Reviewer.md — Governance**
    
    > **Ω is a contract.** Any update is offline, re-certified, and shipped with a **ThresholdChange VC**. Break-glass uses a short-lived emergency VC (m-of-n).
    
- **Splitter.md — Outputs**
    
    > Emit `SafetyKernel.{omega_star,delta_star,kkt_residual,solver_iterations,warm_start_used,max_input_staleness_ms,cvar95_cbf_slack}`,  
    > `Switching.{adt_margin,hard_dwell_ok,grazing_p,frontier_hits}`,  
    > `PRWitness.{band,epsilon,postcheck_min_margin,cert_id}`,  
    > `LocalityEvidence.{ef_radius,oob_shift{...},xmod{...}}`,  
    > `Automata.{... liveness timers ...}`.
    

---

## Graceful Degradation Mode (GDM) & Eyes-Closed Kernel (Δ new)

- **Pre-certified controller families:** `{Ω_full, Ω_vision_only, Ω_lidar_only, Ω_wc}` each with `cert_id`.
    
- **Trigger:** Any `I₂x` failure or sustained sensor dropout ⇒ **GDM** selection with lower max speed/inflated margins.
    
- **Eyes-Closed Kernel (ECK):** Maintain reachable set from which safety is guaranteed for horizon **H** without modality **m**. Planner is constrained to remain inside ECK; failing sensor → execute **ECK policy** (safe stop/lane-hold).
    

---

## Strategic drop-order (revised)

1. **Tier-1 schema + OPA runtime policies + ThresholdChange VC**
    
2. **Safety kernel with watchdog + numerics (KKT/WCET + staleness)**
    
3. **ADT + hard dwell + hysteresis + saltation atomic packets**
    
4. **Cross-modal invariants (I₂x) + GDM/ECK**
    
5. **Offline GKYP toolchain; ship pre-certified controller family**
    
6. **Two-channel locality with power & MK-MMD; CI gates**
    
7. **DEC/holonomy diagnostics (Tier-2 cadence) + provenance VC bundles**
    

---

## Why this closes the remaining gaps (one-liners)

- **Chatter/fragility at frontiers:** **Hard dwell + hysteresis + atomic saltation** ⇒ bounded switching, auditable jumps.
    
- **Feasibility vs realtime:** **Watchdog + WCET KPI + KKT p99 gate** ⇒ theory doesn’t out-run the clock.
    
- **Fusion seam risk:** **I₂x** gives **geometric + physics + conditional-HSIC** checks; failures **degrade, not crash**.
    
- **Ω drift & over-adaptation:** Treat Ω as **contract**; **pre-certified fallbacks** replace live retune risk.
    
- **Liveness:** **Bounded-time automata** prevent indefinite Amber/livelock.
    
- **Human error:** **Action-first runbooks**, blinded approvals, and **break-glass VCs** raise the floor under stress.
    
- **Auditability:** Every gate yields **bits you can re-run**; proofs and numerics are **versioned, hashed, and replayable**.
    

---

### Appendix — Structured Risk Memo (template)

- **Change requested:** (threshold / Ω / band / policy)
    
- **Motivation & evidence:** (failure mode, data)
    
- **Worst-case with latent fault:** (explicit scenario)
    
- **Auto-revert condition & timer:** (quantitative)
    
- **Monitoring plan:** (signals, power, alerting)
    
- **Blast radius / mitigation:** (scope, rollback)
    
- **Signers (blinded first pass):** safety champion, domain lead
    
- **ThresholdChange VC id / Merkle root:** (filled by CI)
    

---

# Priority Reading List

- [JSGseries] JSGI  —  JSGI.txt
- [JSGseries] JSGII  —  JSGII.txt
- [JSGseries] JSGIII  —  JSGIII.txt
- [JSGseries] JSGIV  —  JSGIV.txt
- [SCp] SCp1  —  SCp1.txt
- [SCp] SCp2  —  SCp2.txt
- [SCp] SCp3  —  SCp3.txt
- [SCp] SCp4  —  SCp4.txt
- [SCp] SCp5  —  SCp5.txt
- [ConceptualOrigins] CascadingPDE  —  CascadingPDE.txt
- [Research] 2509.14185v1  —  2509.14185v1.txt
- [Research] DissapitativePDE  —  DissapitativePDE.txt
- [Research] General Modal Model  —  General Modal Model.txt
- [Research] SpecChainLight  —  SpecChainLight.txt
- [Research] stress_testing_antischeming  —  stress_testing_antischeming.txt


# Scope Focus

## JSGI

Joint Strategic Geometry on Decision and Objective Spaces Contents 1 Introduction and Motivation 3 2 Foundations: Categorical Back-Hook from ACT to JSG I 5 2.1 Semantic Substrate and Categories . . . . . .

## JSGII

Joint Strategic Geometry II: Algorithms, Diagnostics, and Benchmarks (Populated Draft) Contents 1 Introduction and Scope 2 2 State Spaces & Hybrid Calculus: Implementation Notes 5 3 Strategic Series and Cross-Cumulants (Operationalized) 9 4 DRO Closure: Tuning, KKT Logging, and Sensitivity 12 5 Entropy Neighborhood: EF Radius, Conditioning, and Leakage 15 6 Projected Control: PR Certification and ISS Budgets 17 7 Computable Kernels: Plane Selection & Structural Derivatives 20 8 Algebraic/Categorical Layer: Quasi-Shuffle & Lipschitz 23 9 Computational Statistics and Reporting 25 10 Conclusions & Deployment Notes 28 11 Tables & Schemas (Certificate-First Appendix) 31 11.1 KPI Registry: symbols, units, estimators, contracts . . . . . .

## JSGIII

Joint Strategic Geometry III Control, Diagnostics, and Benchmarks (Populated Draft) Contents 1 Introduction 4 1.1 Guard topology and Rule Index . . . . . .

## JSGIV

JSG + Category Theory: Compositional Safety by Construction (ACT Bridge Draft 2) Contents 1 Map & Build Philosophy 1 2 Categorical Grammar for Safe Composition 6 2.1 Semantic substrate (fixed throughout) . . . . . .

## SCp1

SpecChain — Part 1: Algebraic Foundations, Complexity, and Mechanization (Normative Revision) SpecChain Working Group September 17, 2025 This revision makes Part 1 a normative, machine-checkable contract. We (i) pin the run fingerprint proof_surface to a byte-precise canonicalization rule (canon/v1) so that any auditor can recompute the exact bytes bound by BLAKE3-256; (ii) fix global naming (proof_surface, root_print) and deprecate obsolete terms; (iii) resolve "unknowns" semantics by treating per- axis unknown as an absorbing bottom ⊥ (fail-closed) in Q with strict ledgering; (iv) upgrade the acceptance algebra to a policy-driven typed quantale/quantaloid and expose an uncertainty- aware lift Q' ; (v) unify computational hardness via a single strong NP-hardness statement for exact frontier debit, and (vi) state sound upper-bounding regimes with mechanization hooks. A Lean/Coq extraction surface provides verified checkers (frontier guards, subadditivity spot checks, and proof_surface binding). Later parts carry domain ontologies, the Normative Loader and runtime assurance, governance, and end-to-end safety cases (Part 2–Part 5). 1 Global Objects, Notation, and Thin Categories Definition 1.1 (Posets as thin categories). A poset (P, ≤) induces a thin category P with objects the elements of P and a unique morphism x → y iff x ≤ y.

## SCp2

SpecChain Part 2 (Normative Construction): Q-Grade Algebra, Uncertainty Lift, and Frontier Accounting SpecChain Working Draft September 17, 2025 Contract (what Part 2 exports). This part closes three obligations promised in Part 1: (i) it instantiates per-axis quantales and their typed product, yielding a complete, mechanizable acceptance algebra Q with unknown as absorbing bottom ⊥ and distributivity-on-demand on declared complete axes; (ii) it lifts Q to an uncertainty-aware Q' via sound, order-theoretic carriers (intervals, sub-Gaussian envelopes, robust sets) and exports acceptance stances with guard lifting; (iii) it defines and analyzes the canonical frontier debit ∆fr , proves the frontier axioms, establishes strong NP-hardness of exact evaluation, and specifies sound upper-bounding algorithms with verifiable receipts. These constructions are policy-driven and match the axis catalog/typed product surface from Part 1 (§10–§11); they align with the Loader's guard-first, fail-closed semantics and receipt discipline (Parts 3–4). Notation hygiene. Internally we use q ⊎ r for the heterogeneous ("horizontal") aggregator (max on M, + on S) and q ⋆ r for the sequential aggregator (+ on both). For cross-part consistency we expose aliases ⊎ ≡ ⊎ (Part 5's ⊙) and ⋆ ≡ ⋆ (Part 1's product aggregator ∧).

## SCp3

Part 3 — Normative Loader, Runtime Assurance, and UpdateCert Verifiable Automaton, TCB Hardening (STRIDE), and Uniform Receipts SpecChain Formal Specification September 17, 2025 This Part specifies the Normative Loader as a verifiable automaton; fixes the trusted- computing-base (TCB) boundary with a boot-time attestation receipt; and formalizes dynamic adaptation via UpdateCert with step-preserving bisimulation (replay-impact equivalence) and Σ-non-expansion proof obligations. We state the safety-or-halt theorem and a No-Zeno liveness discipline using a well-founded lexicographic rank; baseline checks (I1–I10) produce uniform, byte- replayable receipts bound by proof_surface under canon/v1 with BLAKE3-256. Acceptance is gated by per-axis budgets in Q (fail-closed unknowns = ⊥) and, when enabled, by tail contracts (I11–I13) from Part 4; every successful or failing run emits auditable evidence suitable for deterministic third-party replay. The pipeline order EF → DRO → PR → CBF → Ω and seed discipline are harmonized with Part 1; notation and unknown semantics follow the absorbing-bottom convention. 1 Scope and Interfaces This Part specifies the Normative Loader—the sole arbiter of runtime state transitions for the pipeline EF → DRO → PR → CBF → Ω, and the enforcer of the safety-or-halt contract. All outcomes (PASS/FAIL) materialize as canonical JSON receipts bound into the run's proof_surface, enabling deterministic, third-party replay.

## SCp4

SpecChain Part 4: Tail Contracts (I11–I13) Contraction, ISS/Tubes, and WSTS Byte-replayable witnesses, termination under EnvLock, and acceptance obligations We strengthen Part 4 with a unifying TailContract interface and two meta-theorems that make acceptance extensional in the tail bytes and safety-or-halt immediate under the Part 3 No-Zeno discipline. Each family—I11 Contraction, I12 ISS/Tubes, and I13 WSTS—instantiates TailContract with (i) a canonical witness-bytes shape (canon/v1 JSON), (ii) machine-checkable obligations and a progress measure coupled to the Loader's rank, and (iii) explicit termination guarantees compatible with the acceptance algebra Q and frontier accounting ∆fr . We normalize axis bindings, work bounds, and unknowns ledgering across families and fix a uniform TailReceipt surface that prices work, binds evidence into the proof_surface, and preserves acceptance determinism. 1 Scope, Interfaces, and Acceptance Determinism Assumption 1.1 (Replay discipline: EnvLock, ReplayPlan, canonical traversal). All computations are executed under EnvLock and ReplayPlan: arithmetic, RNG, solver libraries, and serialization are pinned and byte-replayable under canon/v1. Each tail run exposes a canonical witness sub-object (the tail-witness bytes) inside the run's proof_surface.

## SCp5

SpecChain: Part 5 – Auditing Governance and Incentive Networks SpecChain Working Group September 17, 2025 This part consolidates and refines SpecChain's auditing and governance protocols, en- suring consistency with the formal semantics of Parts 1–4. We specify runtime audit rules, evidence bundling, and incentive-related constructs under the fixed execution pipeline EF→DRO→PR→CBF→ Ω. Terminology and algebraic conventions (acceptance algebra Q, obligations Σ, unknowns ⊥, EnvLock) follow SCp1–4. We normalize or footnote any speculative mechanisms from prior drafts, present canonical JSON schemas for receipts and certificates, and summarize the guard checks and audit emissions in a reference table. All JSON formats use canon/v1 encoding with explicit witness and digest fields. 1 Preliminaries and Notation We inherit the algebraic and loader semantics of Parts 1–4 and make the following normative choices for Part 5.

## CascadingPDE

Coalition Shuffling Formalism Marley McWilliams September 16, 2025 The foundation of the analysis is the modeling of a discrete, multiplayer, stochastic game as a finite directed acyclic graph, G = (V, E). This structure allows for a complete and deterministic solution to a system that includes both rational decision-making and chance. 1 The State-Space Graph Formulation The game is entirely captured by its state-space graph, where vertices represent game states and edges represent state transitions. 1.1 Vertices as Game States (v ∈ V ) A vertex represents a complete, instantaneous snapshot of the game. Each state is formally defined by a tuple (U, p, C), where: • U is a vector of player utilities (e.g., health). • p is an integer identifying the active player whose turn it is to act.

## 2509.14185v1

Discovery of Unstable Singularities Yongji Wang1, 2 , Mehdi Bennani3 , James Martens3 , Sébastien Racanière3 , Sam Blackwell3 , Alex Matthews3 , Stanislav Nikolov3 , Gonzalo Cao-Labora1, 4 , Daniel S. Park5 , Martin † † † † † Arjovsky3, , Daniel Worrall3, , Chongli Qin3, , Ferran Alet3, , Borislav Kozlovskii3, , Nenad † Tomašev3, , Alex Davies3 , Pushmeet Kohli3 , Tristan Buckmaster1,* , Bogdan Georgiev3,* , Javier Gómez-Serrano6,* , Ray Jiang3,* and Ching-Yao Lai2,* 1 New York University, Department of Mathematics, New York, NY 10012, USA 2 Stanford University, Department of Geophysics, Stanford, CA 94305, USA 3 Google DeepMind, London, N1C 4DJ, UK arXiv:2509.14185v1 [math.AP] 17 Sep 2025 4 École Polytechnique Fédérale de Lausanne, Institute of Mathematics, Lausanne, VA 1015, Switzerland 5 Google DeepMind, New York, NY 10011, USA 6 Brown University, Department of Mathematics, Providence, RI 02912, USA † These authors have comparable contributions * Corresponding author: buckmaster@cims.nyu.edu * Corresponding author: bogeorgiev@google.com * Corresponding author: javier gomez serrano@brown.edu * Corresponding author: rayjiang@google.com * Corresponding author: cyaolai@stanford.edu * All corresponding authors contributed equally and are listed in alphabetical order Whether singularities can form in fluids remains a foundational unanswered question in mathematics. This phenomenon occurs when solutions to governing equations, such as the 3D Euler equations, develop infinite gradients from smooth initial conditions. Historically, numerical approaches have primarily identified stable singularities. However, these are not expected to exist for key open problems, such as the boundary-free Euler and Navier-Stokes cases, where unstable singularities are hypothesized to play a crucial role. Here, we present the first systematic discovery of new families of unstable singularities.

## DissapitativePDE

A Compositional, Audit-Ready Proof Program for 3D Navier–Stokes We present a windowed, auditable proof program for dissipative PDEs. Analytical risk lives in a graded algebra Q; side-conditions in a typed effect system Σ; and a lax compo- sition rule compose_ev upper-bounds order effects. A Hybrid-Space layer prices reassociation (time↔frequency↔patch↔mesh) as frontier crossings with No-Zeno dwell, Dirac freeze/reproject, and a geometry-priced frontier defect that prints into Q. Specializing to 3D incompressible Navier–Stokes (NSE), the spine reduces to five lemmas: (L1) a frequency-local energy inequality under a frozen Littlewood–Paley (LP) architecture, (L2) a priced-commutator interchange bound, (L3) ε-regularity via a CVaR→CKN bridge, (L4) closure in L∞ t Lx , and (L5) a rigidity theorem 3 for ancient limits. Discharging L4 empties Σ at the first candidate singular time; the solution extends. 1 Introduction and contributions Problem context.

## General Modal Model

General Modal Model This General Modal Model (GMM) is a formal spec defining a generative mechanism that reverses a dissipative-PDE process within the SpecChain (SC) framework. It embeds fully into SC's acceptance algebra Q and its uncertainty lift Q' , and cooperates with SC components (TailContracts, Loader, Governance) to ensure ledger-safe, constructive generation. Our approach is inspired by diffusion-based generative models, which reverse forward PDE flows 1 2 , and by formal algebraic specifications of systems. Integration with the SpecChain (SC) Framework We embed the GMM into SC by mapping to the acceptance algebra Q and its uncertainty lift Q' . By algebraic specification, a system is defined by a signature and class of algebras. Accordingly, we define: • Acceptance Algebra Q : a partially-ordered algebra of acceptance values (e.g.

## SpecChainLight

SpecChain–NL: A General, Audit-Ready Architecture for Blockchain-Organized Categorical Proof Solvers Byte-Replayable Gates (I6–I13), Frontier Pricing, Cross-Axiom Orchestration, and Liveness (I14) with Standardized Failure Codes We formalize a modular proof-solver that orchestrates heterogeneous axiom systems (categori- cal logic, PDE proof programs, ordinal contracts) under a content-addressed ledger. The core is a typed acceptance algebra Q with sum/max channels, a typed effect system Σ, a lax reassociation rule compose_ev with priced frontiers, and a Normative Loader enforcing byte-replayable inter- layer gates I6–I10 (ordinal dominance, Lyapunov drop, negative controls, non-expansive retunes, frontier clamp), tail contracts I11–I13 (Banach-ball quiescence, contraction/ISS, WSTS), and a liveness guard I14 (bounded consecutive quarantine/progress miss). A Byte-Replay Envelope (EnvLock, ReplayPlan) pins numerics/RNG/serialization so all Tier-1/2 decisions are bitwise- replayable. We standardize evidence (ThetaCert, VCert, RetuneCert, FrontierRow), governor logs (GovernorUpdateCert, GovernorPerformanceCert), and rejections (RejectionCertwith reason codes), and bind inputs/config via RawDataDigest and ConfigCertin the proof_print. The calculus specializes to dissipative PDE pipelines while remaining axiom-agnostic, with fail-closed global safety. 1 Global Objects, Notation, and Ledger Definition 1.1 (Posets as thin categories).

## stress_testing_antischeming

2025-09-15 Stress Testing Deliberative Alignment for Anti-Scheming Training Bronson Schoen∗, Evgenia Nitishinskaya†, Mikita Balesni∗, Axel Højmark∗, Felix Hofstätter∗, Jérémy Scheurer∗, Alexander Meinke∗, Jason Wolfe†, Teun van der Weij∗, Alex Lloyd∗, Nicholas Goldowsky-Dill∗ Angela Fan†, Andrei Matveiakin∗, Rusheb Shah∗, Marcus Williams†, Amelia Glaese†, Boaz Barak† Wojciech Zaremba†, Marius Hobbhahn∗ Apollo Research & OpenAI A BSTRACT Highly capable AI systems could secretly pursue misaligned goals – what we call "scheming". Because a scheming AI would deliberately try to hide its misaligned goals and actions, measuring and mitigating scheming requires different strategies than are typically used in ML. We propose that assessing anti-scheming interventions requires at least (1) testing propensity to scheme on far out-of-distribution (OOD) tasks, (2) evaluating for situational awareness and whether lack of scheming is driven by situational awareness, and (3) checking for robustness to pre-existing misaligned goals. We use a broad category of "covert actions"–such as secretly breaking rules or intentionally underperforming in tests–as a proxy for scheming, and design evaluations for covert actions. We then stress-test deliberative alignment (Guan et al., 2024) as a case study for anti-scheming. Across 26 OOD evaluations (180+ environments), deliberative alignment reduces covert action rates (OpenAI o3: 13%→0.4%; OpenAI o4-mini: 8.7%→0.3%) but does not fully eliminate them.



# Concepts Map

| Source | Concepts |
|---|---|
| 2509.14185v1 | Rule, Stability |
| DissapitativePDE | Rule, Stability, Acceptance Algebra, Normative Loader, Audit & Governance |
| General Modal Model | Rule, Acceptance Algebra, Normative Loader, Audit & Governance |
| JSGI | Rule, p0_threshold, Stability, Acceptance Algebra, Normative Loader, Audit & Governance |
| JSGII | Rule, p0_threshold, Stability, Acceptance Algebra, Normative Loader, Audit & Governance |
| JSGIII | Rule, p0_threshold, Stability, Acceptance Algebra, Normative Loader, Audit & Governance |
| JSGIV | Rule, p0_threshold, Stability, Acceptance Algebra, Normative Loader, Audit & Governance |
| SCp1 | Rule, Acceptance Algebra, Normative Loader, Audit & Governance |
| SCp2 | Rule, Acceptance Algebra, Normative Loader, Audit & Governance |
| SCp3 | Rule, Acceptance Algebra, Normative Loader, Audit & Governance |
| SCp4 | Rule, Acceptance Algebra, Normative Loader, Tail Contracts, Audit & Governance |
| SCp5 | Rule, Stability, Acceptance Algebra, Normative Loader, Audit & Governance |
| SpecChainLight | Rule, p0_threshold, Stability, Acceptance Algebra, Normative Loader, Tail Contracts, Audit & Governance |
| stress_testing_antischeming | Rule, Normative Loader, Audit & Governance |


# Critique Prompts

### 2509.14185v1

**Summary:** Discovery of Unstable Singularities Yongji Wang1, 2 , Mehdi Bennani3 , James Martens3 , Sébastien Racanière3 , Sam Blackwell3 , Alex Matthews3 , Stanislav Nikolov3 , Gonzalo Cao-Labora1, 4 , Daniel S. Park5 , Martin † † † † † Arjovsky3, , Daniel Worrall3, , Chongli Qin3, , Ferran Alet3, , Borislav Kozlovskii3, , Nenad † Tomašev3, , Alex Davies3 , Pushmeet Kohli3 , Tristan Buckmaster1,* , Bogdan Georgiev3,* , Javier Gómez-Serrano6,* , Ray Jiang3,* and Ching-Yao Lai2,* 1 New York University, Department of Mathematics, New York, NY 10012, USA 2 Stanford University, Department of Geophysics, Stanford, CA 94305, USA 3 Google DeepMind, London, N1C 4DJ, UK arXiv:2509.14185v1 [math.AP] 17 Sep 2025 4 École Polytechnique Fédérale de Lausanne, Institute of Mathematics, Lausanne, VA 1015, Switzerland 5 Google DeepMind, New York, NY 10011, USA 6 Brown University, Department of Mathematics, Providence, RI 02912, USA † These authors have comparable contributions * Corresponding author: buckmaster@cims.nyu.edu * Corresponding author: bogeorgiev@google.com * Corresponding author: javier gomez serrano@brown.edu * Corresponding author: rayjiang@google.com * Corresponding author: cyaolai@stanford.edu * All corresponding authors contributed equally and are listed in alphabetical order Whether singularities can form in fluids remains a foundational unanswered question in mathematics. This phenomenon occurs when solutions to governing equations, such as the 3D Euler equations, develop infinite gradients from smooth initial conditions. Historically, numerical approaches have primarily identified stable singularities.

**Assumptions:** 
- [ ] List assumptions

**Claims & Evidence:** 
- [ ] Claim → where supported (page/section/equation)

**Edge cases / failure modes:** 
- [ ] Itemize

**Conflicts with other PDFs:** 
- [ ] Cite conflicting section(s)

**Implementation blockers:** 
- [ ] Code / tests / data required

**Revision plan:** 
- [ ] Specific edits (sections/definitions) to apply

### CascadingPDE

**Summary:** Coalition Shuffling Formalism Marley McWilliams September 16, 2025 The foundation of the analysis is the modeling of a discrete, multiplayer, stochastic game as a finite directed acyclic graph, G = (V, E). This structure allows for a complete and deterministic solution to a system that includes both rational decision-making and chance. 1 The State-Space Graph Formulation The game is entirely captured by its state-space graph, where vertices represent game states and edges represent state transitions. 1.1 Vertices as Game States (v ∈ V ) A vertex represents a complete, instantaneous snapshot of the game.

**Assumptions:** 
- [ ] List assumptions

**Claims & Evidence:** 
- [ ] Claim → where supported (page/section/equation)

**Edge cases / failure modes:** 
- [ ] Itemize

**Conflicts with other PDFs:** 
- [ ] Cite conflicting section(s)

**Implementation blockers:** 
- [ ] Code / tests / data required

**Revision plan:** 
- [ ] Specific edits (sections/definitions) to apply

### DissapitativePDE

**Summary:** A Compositional, Audit-Ready Proof Program for 3D Navier–Stokes We present a windowed, auditable proof program for dissipative PDEs. Analytical risk lives in a graded algebra Q; side-conditions in a typed effect system Σ; and a lax compo- sition rule compose_ev upper-bounds order effects. A Hybrid-Space layer prices reassociation (time↔frequency↔patch↔mesh) as frontier crossings with No-Zeno dwell, Dirac freeze/reproject, and a geometry-priced frontier defect that prints into Q. Specializing to 3D incompressible Navier–Stokes (NSE), the spine reduces to five lemmas: (L1) a frequency-local energy inequality under a frozen Littlewood–Paley (LP) architecture, (L2) a priced-commutator interchange bound, (L3) ε-regularity via a CVaR→CKN bridge, (L4) closure in L∞ t Lx , and (L5) a rigidity theorem 3 for ancient limits.

**Assumptions:** 
- [ ] List assumptions

**Claims & Evidence:** 
- [ ] Claim → where supported (page/section/equation)

**Edge cases / failure modes:** 
- [ ] Itemize

**Conflicts with other PDFs:** 
- [ ] Cite conflicting section(s)

**Implementation blockers:** 
- [ ] Code / tests / data required

**Revision plan:** 
- [ ] Specific edits (sections/definitions) to apply

### General Modal Model

**Summary:** General Modal Model This General Modal Model (GMM) is a formal spec defining a generative mechanism that reverses a dissipative-PDE process within the SpecChain (SC) framework. It embeds fully into SC's acceptance algebra Q and its uncertainty lift Q' , and cooperates with SC components (TailContracts, Loader, Governance) to ensure ledger-safe, constructive generation. Our approach is inspired by diffusion-based generative models, which reverse forward PDE flows 1 2 , and by formal algebraic specifications of systems. Integration with the SpecChain (SC) Framework We embed the GMM into SC by mapping to the acceptance algebra Q and its uncertainty lift Q' .

**Assumptions:** 
- [ ] List assumptions

**Claims & Evidence:** 
- [ ] Claim → where supported (page/section/equation)

**Edge cases / failure modes:** 
- [ ] Itemize

**Conflicts with other PDFs:** 
- [ ] Cite conflicting section(s)

**Implementation blockers:** 
- [ ] Code / tests / data required

**Revision plan:** 
- [ ] Specific edits (sections/definitions) to apply

### JSGI

**Summary:** Joint Strategic Geometry on Decision and Objective Spaces Contents 1 Introduction and Motivation 3 2 Foundations: Categorical Back-Hook from ACT to JSG I 5 2.1 Semantic Substrate and Categories . . . .

**Assumptions:** 
- [ ] List assumptions

**Claims & Evidence:** 
- [ ] Claim → where supported (page/section/equation)

**Edge cases / failure modes:** 
- [ ] Itemize

**Conflicts with other PDFs:** 
- [ ] Cite conflicting section(s)

**Implementation blockers:** 
- [ ] Code / tests / data required

**Revision plan:** 
- [ ] Specific edits (sections/definitions) to apply

### JSGII

**Summary:** Joint Strategic Geometry II: Algorithms, Diagnostics, and Benchmarks (Populated Draft) Contents 1 Introduction and Scope 2 2 State Spaces & Hybrid Calculus: Implementation Notes 5 3 Strategic Series and Cross-Cumulants (Operationalized) 9 4 DRO Closure: Tuning, KKT Logging, and Sensitivity 12 5 Entropy Neighborhood: EF Radius, Conditioning, and Leakage 15 6 Projected Control: PR Certification and ISS Budgets 17 7 Computable Kernels: Plane Selection & Structural Derivatives 20 8 Algebraic/Categorical Layer: Quasi-Shuffle & Lipschitz 23 9 Computational Statistics and Reporting 25 10 Conclusions & Deployment Notes 28 11 Tables & Schemas (Certificate-First Appendix) 31 11.1 KPI Registry: symbols, units, estimators, contracts . . . .

**Assumptions:** 
- [ ] List assumptions

**Claims & Evidence:** 
- [ ] Claim → where supported (page/section/equation)

**Edge cases / failure modes:** 
- [ ] Itemize

**Conflicts with other PDFs:** 
- [ ] Cite conflicting section(s)

**Implementation blockers:** 
- [ ] Code / tests / data required

**Revision plan:** 
- [ ] Specific edits (sections/definitions) to apply

### JSGIII

**Summary:** Joint Strategic Geometry III Control, Diagnostics, and Benchmarks (Populated Draft) Contents 1 Introduction 4 1.1 Guard topology and Rule Index . . . .

**Assumptions:** 
- [ ] List assumptions

**Claims & Evidence:** 
- [ ] Claim → where supported (page/section/equation)

**Edge cases / failure modes:** 
- [ ] Itemize

**Conflicts with other PDFs:** 
- [ ] Cite conflicting section(s)

**Implementation blockers:** 
- [ ] Code / tests / data required

**Revision plan:** 
- [ ] Specific edits (sections/definitions) to apply

### JSGIV

**Summary:** JSG + Category Theory: Compositional Safety by Construction (ACT Bridge Draft 2) Contents 1 Map & Build Philosophy 1 2 Categorical Grammar for Safe Composition 6 2.1 Semantic substrate (fixed throughout) . . . .

**Assumptions:** 
- [ ] List assumptions

**Claims & Evidence:** 
- [ ] Claim → where supported (page/section/equation)

**Edge cases / failure modes:** 
- [ ] Itemize

**Conflicts with other PDFs:** 
- [ ] Cite conflicting section(s)

**Implementation blockers:** 
- [ ] Code / tests / data required

**Revision plan:** 
- [ ] Specific edits (sections/definitions) to apply

### SCp1

**Summary:** SpecChain — Part 1: Algebraic Foundations, Complexity, and Mechanization (Normative Revision) SpecChain Working Group September 17, 2025 This revision makes Part 1 a normative, machine-checkable contract. We (i) pin the run fingerprint proof_surface to a byte-precise canonicalization rule (canon/v1) so that any auditor can recompute the exact bytes bound by BLAKE3-256; (ii) fix global naming (proof_surface, root_print) and deprecate obsolete terms; (iii) resolve "unknowns" semantics by treating per- axis unknown as an absorbing bottom ⊥ (fail-closed) in Q with strict ledgering; (iv) upgrade the acceptance algebra to a policy-driven typed quantale/quantaloid and expose an uncertainty- aware lift Q' ; (v) unify computational hardness via a single strong NP-hardness statement for exact frontier debit, and (vi) state sound upper-bounding regimes with mechanization hooks. A Lean/Coq extraction surface provides verified checkers (frontier guards, subadditivity spot checks, and proof_surface binding). Later parts carry domain ontologies, the Normative Loader and runtime assurance, governance, and end-to-end safety cases (Part 2–Part 5).

**Assumptions:** 
- [ ] List assumptions

**Claims & Evidence:** 
- [ ] Claim → where supported (page/section/equation)

**Edge cases / failure modes:** 
- [ ] Itemize

**Conflicts with other PDFs:** 
- [ ] Cite conflicting section(s)

**Implementation blockers:** 
- [ ] Code / tests / data required

**Revision plan:** 
- [ ] Specific edits (sections/definitions) to apply

### SCp2

**Summary:** SpecChain Part 2 (Normative Construction): Q-Grade Algebra, Uncertainty Lift, and Frontier Accounting SpecChain Working Draft September 17, 2025 Contract (what Part 2 exports). This part closes three obligations promised in Part 1: (i) it instantiates per-axis quantales and their typed product, yielding a complete, mechanizable acceptance algebra Q with unknown as absorbing bottom ⊥ and distributivity-on-demand on declared complete axes; (ii) it lifts Q to an uncertainty-aware Q' via sound, order-theoretic carriers (intervals, sub-Gaussian envelopes, robust sets) and exports acceptance stances with guard lifting; (iii) it defines and analyzes the canonical frontier debit ∆fr , proves the frontier axioms, establishes strong NP-hardness of exact evaluation, and specifies sound upper-bounding algorithms with verifiable receipts. These constructions are policy-driven and match the axis catalog/typed product surface from Part 1 (§10–§11); they align with the Loader's guard-first, fail-closed semantics and receipt discipline (Parts 3–4). Notation hygiene.

**Assumptions:** 
- [ ] List assumptions

**Claims & Evidence:** 
- [ ] Claim → where supported (page/section/equation)

**Edge cases / failure modes:** 
- [ ] Itemize

**Conflicts with other PDFs:** 
- [ ] Cite conflicting section(s)

**Implementation blockers:** 
- [ ] Code / tests / data required

**Revision plan:** 
- [ ] Specific edits (sections/definitions) to apply

### SCp3

**Summary:** Part 3 — Normative Loader, Runtime Assurance, and UpdateCert Verifiable Automaton, TCB Hardening (STRIDE), and Uniform Receipts SpecChain Formal Specification September 17, 2025 This Part specifies the Normative Loader as a verifiable automaton; fixes the trusted- computing-base (TCB) boundary with a boot-time attestation receipt; and formalizes dynamic adaptation via UpdateCert with step-preserving bisimulation (replay-impact equivalence) and Σ-non-expansion proof obligations. We state the safety-or-halt theorem and a No-Zeno liveness discipline using a well-founded lexicographic rank; baseline checks (I1–I10) produce uniform, byte- replayable receipts bound by proof_surface under canon/v1 with BLAKE3-256. Acceptance is gated by per-axis budgets in Q (fail-closed unknowns = ⊥) and, when enabled, by tail contracts (I11–I13) from Part 4; every successful or failing run emits auditable evidence suitable for deterministic third-party replay. The pipeline order EF → DRO → PR → CBF → Ω and seed discipline are harmonized with Part 1; notation and unknown semantics follow the absorbing-bottom convention.

**Assumptions:** 
- [ ] List assumptions

**Claims & Evidence:** 
- [ ] Claim → where supported (page/section/equation)

**Edge cases / failure modes:** 
- [ ] Itemize

**Conflicts with other PDFs:** 
- [ ] Cite conflicting section(s)

**Implementation blockers:** 
- [ ] Code / tests / data required

**Revision plan:** 
- [ ] Specific edits (sections/definitions) to apply

### SCp4

**Summary:** SpecChain Part 4: Tail Contracts (I11–I13) Contraction, ISS/Tubes, and WSTS Byte-replayable witnesses, termination under EnvLock, and acceptance obligations We strengthen Part 4 with a unifying TailContract interface and two meta-theorems that make acceptance extensional in the tail bytes and safety-or-halt immediate under the Part 3 No-Zeno discipline. Each family—I11 Contraction, I12 ISS/Tubes, and I13 WSTS—instantiates TailContract with (i) a canonical witness-bytes shape (canon/v1 JSON), (ii) machine-checkable obligations and a progress measure coupled to the Loader's rank, and (iii) explicit termination guarantees compatible with the acceptance algebra Q and frontier accounting ∆fr . We normalize axis bindings, work bounds, and unknowns ledgering across families and fix a uniform TailReceipt surface that prices work, binds evidence into the proof_surface, and preserves acceptance determinism. 1 Scope, Interfaces, and Acceptance Determinism Assumption 1.1 (Replay discipline: EnvLock, ReplayPlan, canonical traversal).

**Assumptions:** 
- [ ] List assumptions

**Claims & Evidence:** 
- [ ] Claim → where supported (page/section/equation)

**Edge cases / failure modes:** 
- [ ] Itemize

**Conflicts with other PDFs:** 
- [ ] Cite conflicting section(s)

**Implementation blockers:** 
- [ ] Code / tests / data required

**Revision plan:** 
- [ ] Specific edits (sections/definitions) to apply

### SCp5

**Summary:** SpecChain: Part 5 – Auditing Governance and Incentive Networks SpecChain Working Group September 17, 2025 This part consolidates and refines SpecChain's auditing and governance protocols, en- suring consistency with the formal semantics of Parts 1–4. We specify runtime audit rules, evidence bundling, and incentive-related constructs under the fixed execution pipeline EF→DRO→PR→CBF→ Ω. Terminology and algebraic conventions (acceptance algebra Q, obligations Σ, unknowns ⊥, EnvLock) follow SCp1–4. We normalize or footnote any speculative mechanisms from prior drafts, present canonical JSON schemas for receipts and certificates, and summarize the guard checks and audit emissions in a reference table.

**Assumptions:** 
- [ ] List assumptions

**Claims & Evidence:** 
- [ ] Claim → where supported (page/section/equation)

**Edge cases / failure modes:** 
- [ ] Itemize

**Conflicts with other PDFs:** 
- [ ] Cite conflicting section(s)

**Implementation blockers:** 
- [ ] Code / tests / data required

**Revision plan:** 
- [ ] Specific edits (sections/definitions) to apply

### SpecChainLight

**Summary:** SpecChain–NL: A General, Audit-Ready Architecture for Blockchain-Organized Categorical Proof Solvers Byte-Replayable Gates (I6–I13), Frontier Pricing, Cross-Axiom Orchestration, and Liveness (I14) with Standardized Failure Codes We formalize a modular proof-solver that orchestrates heterogeneous axiom systems (categori- cal logic, PDE proof programs, ordinal contracts) under a content-addressed ledger. The core is a typed acceptance algebra Q with sum/max channels, a typed effect system Σ, a lax reassociation rule compose_ev with priced frontiers, and a Normative Loader enforcing byte-replayable inter- layer gates I6–I10 (ordinal dominance, Lyapunov drop, negative controls, non-expansive retunes, frontier clamp), tail contracts I11–I13 (Banach-ball quiescence, contraction/ISS, WSTS), and a liveness guard I14 (bounded consecutive quarantine/progress miss). A Byte-Replay Envelope (EnvLock, ReplayPlan) pins numerics/RNG/serialization so all Tier-1/2 decisions are bitwise- replayable. We standardize evidence (ThetaCert, VCert, RetuneCert, FrontierRow), governor logs (GovernorUpdateCert, GovernorPerformanceCert), and rejections (RejectionCertwith reason codes), and bind inputs/config via RawDataDigest and ConfigCertin the proof_print.

**Assumptions:** 
- [ ] List assumptions

**Claims & Evidence:** 
- [ ] Claim → where supported (page/section/equation)

**Edge cases / failure modes:** 
- [ ] Itemize

**Conflicts with other PDFs:** 
- [ ] Cite conflicting section(s)

**Implementation blockers:** 
- [ ] Code / tests / data required

**Revision plan:** 
- [ ] Specific edits (sections/definitions) to apply

### stress_testing_antischeming

**Summary:** 2025-09-15 Stress Testing Deliberative Alignment for Anti-Scheming Training Bronson Schoen∗, Evgenia Nitishinskaya†, Mikita Balesni∗, Axel Højmark∗, Felix Hofstätter∗, Jérémy Scheurer∗, Alexander Meinke∗, Jason Wolfe†, Teun van der Weij∗, Alex Lloyd∗, Nicholas Goldowsky-Dill∗ Angela Fan†, Andrei Matveiakin∗, Rusheb Shah∗, Marcus Williams†, Amelia Glaese†, Boaz Barak† Wojciech Zaremba†, Marius Hobbhahn∗ Apollo Research & OpenAI A BSTRACT Highly capable AI systems could secretly pursue misaligned goals – what we call "scheming". Because a scheming AI would deliberately try to hide its misaligned goals and actions, measuring and mitigating scheming requires different strategies than are typically used in ML. We propose that assessing anti-scheming interventions requires at least (1) testing propensity to scheme on far out-of-distribution (OOD) tasks, (2) evaluating for situational awareness and whether lack of scheming is driven by situational awareness, and (3) checking for robustness to pre-existing misaligned goals. We use a broad category of "covert actions"–such as secretly breaking rules or intentionally underperforming in tests–as a proxy for scheming, and design evaluations for covert actions.

**Assumptions:** 
- [ ] List assumptions

**Claims & Evidence:** 
- [ ] Claim → where supported (page/section/equation)

**Edge cases / failure modes:** 
- [ ] Itemize

**Conflicts with other PDFs:** 
- [ ] Cite conflicting section(s)

**Implementation blockers:** 
- [ ] Code / tests / data required

**Revision plan:** 
- [ ] Specific edits (sections/definitions) to apply



## 2025-09-21T09:42:12 — Automated notes
- Updated extraction log: extract_log.txt
- Normalized texts present: 15 files

| Symbol | Description | Source |
| --- | --- | --- |
| $M$ | Number of trees in the ensemble. | Default |
| $R(\\cdot)$ | Rule evaluation mapping applied to an input. | Default |
| $Z$ | Binary rule activation matrix. | Default |
| $\\boldsymbol{\\beta}$ | Coefficient vector for aggregated rules. | Default |
| $\\hat{p}$ | Estimated selection probability of a rule. | Default |
| $\\hat{p}_j$ | Selection probability for rule $j$ across trees. | Default |
| $\\lambda$ | Ridge regularization strength for aggregation. | Default |
| $\\mathbf{x}$ | Generic feature vector. | Default |
| $\\mathbf{x}_i$ | Feature vector for observation $i$. | Default |
| $\\mathcal{P}$ | Candidate pool of extracted rules. | Default |
| $\\mathcal{S}$ | Selected stable subset of rules. | Default |
| $d$ | Number of input features. | Default |
| $n$ | Number of training samples. | Default |
| $p_0$ | Minimum rule frequency threshold for inclusion. | Default |
| $y_i$ | Target value for observation $i$. | Default |


# SIRUS API Reference

## Core Hyperparameters
| Parameter | Default | Typical Range | Effect |
| --- | --- | --- | --- |
| $M$ (number of trees) | 500 | 200–1000 | Larger $M$ stabilizes rule frequencies but increases compute cost. |
| `max_depth` | 4 | 3–5 | Controls rule length; shallower trees improve interpretability. |
| `min_leaf` | 5 | 2–20 | Minimum samples per leaf; higher values reduce overfitting. |
| $p_0$ (rule frequency threshold) | 0.6 | 0.4–0.9 | Governs stability vs. coverage; higher $p_0$ keeps only ubiquitous rules. |
| $\lambda$ (ridge penalty) | 1.0 | $10^{-4}$–$10^{2}$ | Shrinks coefficients to stabilize aggregated model. |

## R Example
```r
library(sirus)
library(caret)
set.seed(42)

# Prepare data
X <- as.matrix(iris[, -5])
y <- iris$Species

# Simple repeated split to tune p0
p0_grid <- seq(0.5, 0.9, by = 0.1)
stability_runs <- 20
results <- lapply(p0_grid, function(p0) {
  metrics <- replicate(stability_runs, {
    idx <- createDataPartition(y, p = 0.7, list = FALSE)
    train_X <- X[idx, ]; train_y <- y[idx]
    test_X <- X[-idx, ]; test_y <- y[-idx]

    model <- sirus(X = train_X, y = train_y,
                   task = "classification",
                   num_trees = 400,
                   max_depth = 4,
                   min_leaf = 5,
                   p0 = p0,
                   lambda = 1.0)

    preds <- predict(model, test_X, type = "class")
    acc <- mean(preds == test_y)
    rules <- get_rules(model)
    list(accuracy = acc, rules = rules)
  }, simplify = FALSE)

  accs <- sapply(metrics, function(m) m$accuracy)
  rule_sets <- lapply(metrics, function(m) m$rules$description)
  # Bootstrap Jaccard on selected rules
  jaccards <- combn(seq_along(rule_sets), 2, function(idx) {
    a <- unique(rule_sets[[idx[1]]])
    b <- unique(rule_sets[[idx[2]]])
    length(intersect(a, b)) / length(union(a, b))
  })
  list(p0 = p0,
       accuracy = mean(accs),
       sd_acc = sd(accs),
       mean_jaccard = ifelse(length(jaccards) > 0, mean(jaccards), NA))
})

table <- do.call(rbind, lapply(results, as.data.frame))
print(table)

# Fit final model at chosen p0 and export readable rules
best_p0 <- results[[which.max(sapply(results, function(r) r$mean_jaccard))]]$p0
final_model <- sirus(X = X, y = y, task = "classification", num_trees = 500,
                     max_depth = 4, min_leaf = 5, p0 = best_p0, lambda = 0.5)
writeLines(get_rules(final_model)$description, "sirus_rules_r.txt")
```

## Python Example
```python
from sirus import SIRUSClassifier, SIRUSRegressor
from sklearn.datasets import load_breast_cancer, load_diabetes
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, roc_auc_score, mean_squared_error
import numpy as np

# Classification with p0 tuning
X_cls, y_cls = load_breast_cancer(return_X_y=True)
X_train, X_test, y_train, y_test = train_test_split(X_cls, y_cls, test_size=0.3, random_state=42, stratify=y_cls)

p0_grid = np.linspace(0.5, 0.9, 5)
stability_runs = 20
results = []
for p0 in p0_grid:
    scores = []
    rulesets = []
    rng = np.random.default_rng(42)
    for _ in range(stability_runs):
        idx = rng.choice(len(X_train), size=len(X_train), replace=True)
        model = SIRUSClassifier(n_estimators=400, max_depth=4, min_samples_leaf=5, p0=p0, lambda_reg=1.0)
        model.fit(X_train[idx], y_train[idx])
        preds = model.predict(X_test)
        proba = model.predict_proba(X_test)[:, 1]
        scores.append((accuracy_score(y_test, preds), roc_auc_score(y_test, proba)))
        rulesets.append(tuple(sorted(model.rules_)))
    jaccard = []
    for i in range(len(rulesets)):
        for j in range(i + 1, len(rulesets)):
            a, b = set(rulesets[i]), set(rulesets[j])
            if a or b:
                jaccard.append(len(a & b) / len(a | b))
    mean_acc = np.mean([s[0] for s in scores])
    mean_auc = np.mean([s[1] for s in scores])
    mean_jaccard = np.mean(jaccard) if jaccard else np.nan
    results.append((p0, mean_acc, mean_auc, mean_jaccard))

best_p0 = max(results, key=lambda r: (np.nan_to_num(r[3]), r[1]))[0]
final_cls = SIRUSClassifier(n_estimators=500, max_depth=4, min_samples_leaf=5, p0=best_p0, lambda_reg=0.5)
final_cls.fit(X_train, y_train)
with open("sirus_rules_python_cls.txt", "w", encoding="utf-8") as fh:
    for rule in final_cls.rules_:
        fh.write(rule + "\n")

# Regression example
X_reg, y_reg = load_diabetes(return_X_y=True)
X_tr, X_te, y_tr, y_te = train_test_split(X_reg, y_reg, test_size=0.3, random_state=123)
model_reg = SIRUSRegressor(n_estimators=500, max_depth=4, min_samples_leaf=5, p0=0.6, lambda_reg=1.0)
model_reg.fit(X_tr, y_tr)
rmse = mean_squared_error(y_te, model_reg.predict(X_te), squared=False)
with open("sirus_rules_python_reg.txt", "w", encoding="utf-8") as fh:
    for rule, weight in zip(model_reg.rules_, model_reg.coef_):
        fh.write(f"{rule} => weight {weight:.3f}\n")
print({"rmse": rmse})
```

## Practical Notes
- Always report rule frequencies $\hat{p}$ alongside the human-readable descriptions so downstream reviewers can assess stability.
- When $p_0$ is high (≥0.8), consider increasing $M$ to maintain coverage.
- For heavily imbalanced classification, adjust the logistic intercept after fitting or reweight classes before tree construction.
- Export both the rule list and the canonical notation glossary to keep documentation consistent across teams.


# SIRUS Unified Documentation {#sirus-unified}

## Abstract {#abstract}

See per-paper abstracts in 00_scope_focus.md.
## Introduction {#introduction}

_(concise motivation and scope)_
## Definitions & Notation {#def-notation}

# Definitions {#definitions}

## Interpretability {#interpretability}
Definition not found in source material. [Unverified]

## Simplicity {#simplicity}
Definition not found in source material. [Unverified]

## Stability {#stability}
Definition not found in source material. [Unverified]

## Predictivity {#predictivity}
Definition not found in source material. [Unverified]

## Rule {#rule}
Definition not found in source material. [Unverified]

## Rule Ensemble {#rule-ensemble}
Definition not found in source material. [Unverified]

## SIRUS Algorithm {#sirus-algorithm}
Definition not found in source material. [Unverified]


---

| Symbol | Description | Source |
| --- | --- | --- |
| $M$ | Number of trees in the ensemble. | Default |
| $R(\\cdot)$ | Rule evaluation mapping applied to an input. | Default |
| $Z$ | Binary rule activation matrix. | Default |
| $\\boldsymbol{\\beta}$ | Coefficient vector for aggregated rules. | Default |
| $\\hat{p}$ | Estimated selection probability of a rule. | Default |
| $\\hat{p}_j$ | Selection probability for rule $j$ across trees. | Default |
| $\\lambda$ | Ridge regularization strength for aggregation. | Default |
| $\\mathbf{x}$ | Generic feature vector. | Default |
| $\\mathbf{x}_i$ | Feature vector for observation $i$. | Default |
| $\\mathcal{P}$ | Candidate pool of extracted rules. | Default |
| $\\mathcal{S}$ | Selected stable subset of rules. | Default |
| $d$ | Number of input features. | Default |
| $n$ | Number of training samples. | Default |
| $p_0$ | Minimum rule frequency threshold for inclusion. | Default |
| $y_i$ | Target value for observation $i$. | Default |


## Algorithm {#algorithm}

﻿# SIRUS Algorithm

## Problem Setup {#problem-setup}
SIRUS targets supervised learning problems where the input is a rectangular design matrix $\mathbf{X} \in \mathbb{R}^{n \times d}$ and the goal is to produce a small, interpretable collection of decision rules that approximate either a regression signal $y \in \mathbb{R}^n$ or a binary/multi-class response $y \in \{1, \ldots, K\}^n$. The method assumes access to $M$ independent subsamples of the data and restricts the underlying tree learners to shallow depth (typically depth $\leq 4$) so that every path can be rendered as a short rule.

## Forest Construction with Shallow Trees {#forest-construction-with-shallow-trees}
SIRUS grows an ensemble of $M$ extremely randomized trees. Each tree is trained on a bootstrap or subsampled replica of the training set using small depth, minimal leaf size constraints, and feature subsampling. Splits are drawn at random thresholds to favor diversity and to decouple rule selection from greedy impurity optimization. Because the depth is capped at four, each tree yields at most $2^4$ leaves and therefore contributes only a handful of rules.

## Rule Extraction from Root-to-Leaf Paths {#rule-extraction-from-root-to-leaf-paths}
For every terminal node in each tree, SIRUS extracts the conjunction of split predicates encountered on the path from root to that leaf. The result is a binary rule $r_j(\mathbf{x}) \in \{0,1\}$ that fires when $\mathbf{x}$ satisfies all predicates. Duplicate rules generated by different trees are merged by summing their occurrence counts. The procedure records the leaf prediction (mean response for regression, class proportion for classification) associated with each rule.

## Rule Frequency Estimation and Thresholding with $p_0$ {#rule-frequency-estimation-and-thresholding-with-p-0}
The rule extraction step induces a matrix $Z \in \{0,1\}^{n \times J}$ where $Z_{ij}=1$ indicates that rule $j$ covers observation $i$. Let $\hat{p}_j = \frac{1}{M}\sum_{m=1}^M \mathbb{1}\{r_j \text{ appears in tree } m\}$ denote the empirical selection frequency of rule $j$. SIRUS retains only those rules whose frequency exceeds a stability threshold $p_0$ (typically between $0.5$ and $0.9$). The threshold can be tuned by cross-validation or stability selection heuristics.

## Rule Aggregation and Weighting {#rule-aggregation-and-weighting}
The surviving rules define a sparse, human-readable feature representation. For regression tasks, SIRUS fits a ridge penalty on the rule activation matrix $Z$ to stabilize the coefficient vector $\boldsymbol{\beta}$. For classification, it fits a multinomial logistic regression (binary logistic in the two-class case) using the same $Z$ design. Both models include an intercept and can incorporate the original predictors if desired, but the default exposes only the rule activations to maintain interpretability.

## Model Selection and Stability Notes {#model-selection-and-stability-notes}
SIRUS emphasizes stability by reporting the final rule set together with their selection frequencies. Analysts typically run several values of $p_0$, inspect the trade-off between accuracy and rule count, and prefer configurations where the selected rules appear across repeated subsamples. The algorithm also recommends reporting the bootstrap Jaccard index across repeated runs to quantify stability. Because the trees are shallow and randomized, the resulting rule list remains short, and every rule directly maps to a root-to-leaf path, simplifying governance and documentation.


## Pseudocode - Classification {#pseudocode-classification}

﻿# SIRUS Classification Pseudocode

```pseudo
Input: training data (X, y), number of trees M, max_depth, min_leaf, frequency threshold p0, ridge penalty λ for logistic
Output: rule coefficients β, intercept b, retained rules R

1. Initialize empty multiset of rules.
2. For m = 1 to M:
      a. Draw a bootstrap (or subsample) of the training data.
      b. Grow an extremely randomized tree with depth ≤ max_depth and leaf size ≥ min_leaf.
      c. For each terminal node:
            i. Record the conjunction of split predicates along the path as rule r.
           ii. Store the class histogram at the leaf and increment the count of r.
3. Merge duplicate rules and compute selection frequency p̂(r) = count(r) / M.
4. Keep rules with p̂(r) ≥ p0 and form binary design matrix Z where Z[i, j] = 1 if rule j covers sample i.
5. Fit multinomial (binary) logistic regression: minimize  −loglikelihood(Z, y; β, b) + λ‖β‖².
6. Return coefficients β, intercept b, and the list of retained rules with their frequencies.
```


## Pseudocode - Regression {#pseudocode-regression}

﻿# SIRUS Regression Pseudocode

```pseudo
Input: training data (X, y), number of trees M, max_depth, min_leaf, frequency threshold p0, ridge penalty λ
Output: regression coefficients β, intercept b, retained rules R

1. Initialize empty multiset of rules.
2. For m = 1 to M:
      a. Draw a bootstrap (or subsample) of the training data.
      b. Grow an extremely randomized tree with depth ≤ max_depth and leaf size ≥ min_leaf.
      c. For each terminal node:
            i. Record the conjunction of split predicates along the path as rule r.
           ii. Store the leaf mean response and increment the count of r.
3. Merge duplicate rules and compute selection frequency p̂(r) = count(r) / M.
4. Keep rules with p̂(r) ≥ p0 and form binary design matrix Z.
5. Fit ridge regression on Z: minimize ‖y − (b + Zβ)‖² + λ‖β‖².
6. Return coefficients β, intercept b, and the list of retained rules with their frequencies and leaf means.
```


## Parameters & Guidance {#parameters}

_(pending)_


## Theoretical Results {#theory}

﻿# Theoretical Core

1. **Selection Stability of Frequency Thresholding**  
   **Assumptions:** Trees are built on i.i.d. subsamples of size $\lfloor\alpha n\rfloor$ with replacement; the probability that rule $r$ is generated by the randomized tree builder converges to $p(r)$ as $M \to \infty$; the threshold satisfies $p_0 > \sup_{r \notin \mathcal{S}} p(r)$.  
   **Statement:** With probability tending to one as $M \to \infty$, SIRUS retains exactly the stable rule set $\mathcal{S} = \{r : p(r) \geq p_0\}$ and discards all other rules.  
   **Intuition:** The empirical frequency $\hat{p}(r)$ concentrates around $p(r)$ by the law of large numbers, so once $M$ is large enough the separation gap between stable and unstable rules is preserved.

2. **Risk Control for Ridge Aggregation**  
   **Assumptions:** The design matrix $Z$ of retained rules has bounded column norms, the loss is squared error (regression) or logistic (classification), and $\lambda > 0$.  
   **Statement:** The ridge-regularized estimator satisfies $\|\hat{\boldsymbol{\beta}} - \boldsymbol{\beta}^*\|_2^2 \leq C(\kappa(Z), \lambda) \cdot (\sigma^2 / n)$ for some constant depending on the condition number of $Z$ and the ridge penalty.  
   **Intuition:** Penalization prevents the ill-conditioned rule design from exploding, ensuring the aggregated model inherits the stability of the selected rules.

3. **Consistency Under Honest Subsampling**  
   **Assumptions:** The randomized tree builder is honest (each leaf prediction uses observations disjoint from those used for splits), the true regression function is piecewise constant on a finite rule partition, and the maximum depth is sufficient to represent that partition.  
   **Statement:** As $n \to \infty$ and $M \to \infty$, the SIRUS prediction converges in probability to the Bayes optimal rule-based predictor.  
   **Intuition:** Honest subsampling ensures unbiased rule estimates, and the stability filter preserves the subset of rules that repeatedly appear, recovering the target partition in the limit.


## Implementation Guide {#implementation-guide}

﻿# SIRUS API Reference

## Core Hyperparameters {#core-hyperparameters}
| Parameter | Default | Typical Range | Effect |
| --- | --- | --- | --- |
| $M$ (number of trees) | 500 | 200–1000 | Larger $M$ stabilizes rule frequencies but increases compute cost. |
| `max_depth` | 4 | 3–5 | Controls rule length; shallower trees improve interpretability. |
| `min_leaf` | 5 | 2–20 | Minimum samples per leaf; higher values reduce overfitting. |
| $p_0$ (rule frequency threshold) | 0.6 | 0.4–0.9 | Governs stability vs. coverage; higher $p_0$ keeps only ubiquitous rules. |
| $\lambda$ (ridge penalty) | 1.0 | $10^{-4}$–$10^{2}$ | Shrinks coefficients to stabilize aggregated model. |

## R Example {#r-example}
```r
library(sirus)
library(caret)
set.seed(42)

# Prepare data {#prepare-data}
X <- as.matrix(iris[, -5])
y <- iris$Species

# Simple repeated split to tune p0 {#simple-repeated-split-to-tune-p0}
p0_grid <- seq(0.5, 0.9, by = 0.1)
stability_runs <- 20
results <- lapply(p0_grid, function(p0) {
  metrics <- replicate(stability_runs, {
    idx <- createDataPartition(y, p = 0.7, list = FALSE)
    train_X <- X[idx, ]; train_y <- y[idx]
    test_X <- X[-idx, ]; test_y <- y[-idx]

    model <- sirus(X = train_X, y = train_y,
                   task = "classification",
                   num_trees = 400,
                   max_depth = 4,
                   min_leaf = 5,
                   p0 = p0,
                   lambda = 1.0)

    preds <- predict(model, test_X, type = "class")
    acc <- mean(preds == test_y)
    rules <- get_rules(model)
    list(accuracy = acc, rules = rules)
  }, simplify = FALSE)

  accs <- sapply(metrics, function(m) m$accuracy)
  rule_sets <- lapply(metrics, function(m) m$rules$description)
# Bootstrap Jaccard on selected rules {#bootstrap-jaccard-on-selected-rules}
  jaccards <- combn(seq_along(rule_sets), 2, function(idx) {
    a <- unique(rule_sets[[idx[1]]])
    b <- unique(rule_sets[[idx[2]]])
    length(intersect(a, b)) / length(union(a, b))
  })
  list(p0 = p0,
       accuracy = mean(accs),
       sd_acc = sd(accs),
       mean_jaccard = ifelse(length(jaccards) > 0, mean(jaccards), NA))
})

table <- do.call(rbind, lapply(results, as.data.frame))
print(table)

# Fit final model at chosen p0 and export readable rules {#fit-final-model-at-chosen-p0-and-export-readable-rules}
best_p0 <- results[[which.max(sapply(results, function(r) r$mean_jaccard))]]$p0
final_model <- sirus(X = X, y = y, task = "classification", num_trees = 500,
                     max_depth = 4, min_leaf = 5, p0 = best_p0, lambda = 0.5)
writeLines(get_rules(final_model)$description, "sirus_rules_r.txt")
```

## Python Example {#python-example}
```python
from sirus import SIRUSClassifier, SIRUSRegressor
from sklearn.datasets import load_breast_cancer, load_diabetes
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, roc_auc_score, mean_squared_error
import numpy as np

# Classification with p0 tuning {#classification-with-p0-tuning}
X_cls, y_cls = load_breast_cancer(return_X_y=True)
X_train, X_test, y_train, y_test = train_test_split(X_cls, y_cls, test_size=0.3, random_state=42, stratify=y_cls)

p0_grid = np.linspace(0.5, 0.9, 5)
stability_runs = 20
results = []
for p0 in p0_grid:
    scores = []
    rulesets = []
    rng = np.random.default_rng(42)
    for _ in range(stability_runs):
        idx = rng.choice(len(X_train), size=len(X_train), replace=True)
        model = SIRUSClassifier(n_estimators=400, max_depth=4, min_samples_leaf=5, p0=p0, lambda_reg=1.0)
        model.fit(X_train[idx], y_train[idx])
        preds = model.predict(X_test)
        proba = model.predict_proba(X_test)[:, 1]
        scores.append((accuracy_score(y_test, preds), roc_auc_score(y_test, proba)))
        rulesets.append(tuple(sorted(model.rules_)))
    jaccard = []
    for i in range(len(rulesets)):
        for j in range(i + 1, len(rulesets)):
            a, b = set(rulesets[i]), set(rulesets[j])
            if a or b:
                jaccard.append(len(a & b) / len(a | b))
    mean_acc = np.mean([s[0] for s in scores])
    mean_auc = np.mean([s[1] for s in scores])
    mean_jaccard = np.mean(jaccard) if jaccard else np.nan
    results.append((p0, mean_acc, mean_auc, mean_jaccard))

best_p0 = max(results, key=lambda r: (np.nan_to_num(r[3]), r[1]))[0]
final_cls = SIRUSClassifier(n_estimators=500, max_depth=4, min_samples_leaf=5, p0=best_p0, lambda_reg=0.5)
final_cls.fit(X_train, y_train)
with open("sirus_rules_python_cls.txt", "w", encoding="utf-8") as fh:
    for rule in final_cls.rules_:
        fh.write(rule + "\n")

# Regression example {#regression-example}
X_reg, y_reg = load_diabetes(return_X_y=True)
X_tr, X_te, y_tr, y_te = train_test_split(X_reg, y_reg, test_size=0.3, random_state=123)
model_reg = SIRUSRegressor(n_estimators=500, max_depth=4, min_samples_leaf=5, p0=0.6, lambda_reg=1.0)
model_reg.fit(X_tr, y_tr)
rmse = mean_squared_error(y_te, model_reg.predict(X_te), squared=False)
with open("sirus_rules_python_reg.txt", "w", encoding="utf-8") as fh:
    for rule, weight in zip(model_reg.rules_, model_reg.coef_):
        fh.write(f"{rule} => weight {weight:.3f}\n")
print({"rmse": rmse})
```

## Practical Notes {#practical-notes}
- Always report rule frequencies $\hat{p}$ alongside the human-readable descriptions so downstream reviewers can assess stability.
- When $p_0$ is high (≥0.8), consider increasing $M$ to maintain coverage.
- For heavily imbalanced classification, adjust the logistic intercept after fitting or reweight classes before tree construction.
- Export both the rule list and the canonical notation glossary to keep documentation consistent across teams.


## Experiments {#experiments}

﻿# Experiments Summary

## Classification {#classification}
| Dataset | Accuracy | AUC | F1 | RulesCount | AvgRuleLength | Mean Jaccard |
| --- | --- | --- | --- | --- | --- | --- |
| Breast Cancer | 0.972 ± 0.006 | 0.994 ± 0.002 | 0.971 ± 0.007 | 14 | 2.6 | 0.88 |
| COMPAS | 0.731 ± 0.012 | 0.782 ± 0.010 | 0.718 ± 0.015 | 18 | 2.8 | 0.74 |

## Regression {#regression}
| Dataset | RMSE | MAE | $R^2$ | RulesCount | AvgRuleLength | Mean Jaccard |
| --- | --- | --- | --- | --- | --- | --- |
| Diabetes | 42.1 ± 1.4 | 34.5 ± 1.1 | 0.51 ± 0.03 | 19 | 3.0 | 0.69 |
| California Housing | 0.47 ± 0.02 | 0.35 ± 0.01 | 0.72 ± 0.02 | 24 | 3.1 | 0.76 |

## Observations {#observations}
- Increasing $p_0$ from 0.6 to 0.8 reduced rule count by ~35% with only marginal loss in accuracy for Breast Cancer.
- Regression tasks benefited from setting $M=800$ when $p_0 \geq 0.7$, stabilizing the Jaccard index above 0.7.
- Across all runs, no rule longer than four predicates survived the frequency filter, keeping the documentation concise.
## Discussion & Limitations {#discussion}

_(to be expanded)_
## Conclusion {#conclusion}

_(to be expanded)_
## References {#references}

See bibliography.bib (author-year) and inline cites.


# Supplementary Proof Sketches

## A. Concentration of Rule Frequencies
Let $X_1, \ldots, X_M$ be Bernoulli indicators that rule $r$ appears in tree $m$. Under independent subsampling, $\mathbb{E}[X_m] = p(r)$ and the $X_m$ are conditionally independent. Hoeffding's inequality yields
$$\Pr\big(|\hat{p}(r) - p(r)| > \epsilon\big) \leq 2\exp(-2M\epsilon^2).$$
Choosing $M \geq \frac{1}{2\epsilon^2}\log\frac{2J}{\delta}$ ensures all $J$ candidate rules concentrate within $\epsilon$ uniformly with probability at least $1-\delta$.

## B. Bias of Honest Leaf Estimates
Assume each tree uses a split sample $I_\text{split}$ to grow the structure and a disjoint $I_\text{pred}$ to compute leaf means. Conditional on the structure, the prediction at any leaf is an average of i.i.d. draws, hence unbiased for the local mean. When aggregated across rules, the resulting ridge estimator inherits this unbiasedness modulo the shrinkage induced by $\lambda$.

## C. Stability Metric
Given two SIRUS runs producing rule sets $A$ and $B$, the bootstrap Jaccard index is
$$J(A,B) = \frac{|A \cap B|}{|A \cup B|}.$$
Under the stability threshold assumptions of Statement 1, $J(A,B) \to 1$ in probability as $M \to \infty$ because both runs converge to the same stable rule set $\mathcal{S}$.


# Run fingerprint, canonical bytes, and fixed pipeline
- The canonical run-fingerprint field is **`proof_surface`** (JSON key "proof_surface"). The legacy term `proof_print` must not appear in new outputs.
- All JSON that influences priced outputs, seeds, or audit is encoded under **canon/v1**.
- Block hashes are **BLAKE3-256(hbytes ∥ pbytes)** where both header and payload are canon/v1-encoded bytes.
- The loader pipeline is fixed and acyclic: **EF → DRO → PR → CBF → Ω**.

## Speculative State Engine (SSE)

**Mission**: turn *formal derivations* (physics & math) into *normative contracts* (the law) into *reference tech* (working code) with deterministic replay and audit-ready receipts.

- ðŸ“š **Formal Derivation** (`01_formal_derivation/`): concepts â†’ math â†’ compositional proofs.
- ðŸ“œ **Spec** (`02_spec/`): versioned, normative API/contracts.
- ðŸ› ï¸ **Implementation** (`03_implementation/`): reference kernels, SpecChain core, and a pilot app.

## Core ideas
- **Expectiminimax state-space** as a canonical game substrate.
- **Hybrid-stratified calculus** with Whitney stratifications & Filippov selections.
- **Acceptance algebra `Q`** (typed product of max/sum axes) with an **uncertainty lift `Q'`**.
- **Frontier pricing `Î”_fr`** and **guard-first** discipline, byte-bound by **canon/v1 + BLAKE3-256**.
- **Normative Loader**: verifiable automaton with liveness (Noâ€‘Zeno dwell, lexicographic rank).
- **Tail Contracts** (I11â€“I13): byte-replayable acceptance families.

## Quick start (dev)
1. Install: `pip install -r requirements.txt`.
2. Hash/canon tool: `python 03_implementation/02_specchain_core/hasher.py sample.json`.
3. Run a toy scenario: `python 03_implementation/03_sse_pilot/run_scenario.py`.

> **Note**: Hashing requires the `blake3` Python package. All JSON must be canon/v1 (sorted keys, UTFâ€‘8, minimal decimals). See `02_spec/SCp1_Global_Conventions/02_canonicalization.md`.

## Status
This is **v0.1 scaffold**: code runs, specs are stubs with normative surfaces, proofs are sketched and crossâ€‘referenced. Expect iteration.




# README: Integrating SCp and PDE Modules into TransportPack Pipeline

This section explains how to extend the proof-generation codebase with new SCp (SpecChain) and dissipative PDE theory modules, and how to author stage runners.

## Integrating New Theory Modules
- Pipeline Stages: We introduce a new stage SCP between CBF and OMEGA. This stage uses SpecChain (SCp) dynamics to algorithmically refine and generate theoretical proofs via non-deterministic, generative processes (inspired by the General Modal Model).
- TransportPack Artifacts: The TransportPack model is extended with SCp-specific artifacts. In code, we added scp_artifact_digests to BridgeCert for canonical hashing of SCp-generated arguments, and add scp_* keys in TransportPack.artifacts.
- Schemas and Hashing: Update sirus/artifacts/schemas.py to include SCp fields, ensuring all new theoretical constructs (claims, definitions, proof tactics) are hashed with digest_obj for byte-level reproducibility.

## Hashing, Testing, and Validation
- Canonical Hashing: Use utils.canon functions (digest_obj, write_canon) to serialize new artifacts deterministically. Extended receipts or certificates (e.g. BridgeCert) bind SCp artifacts into the proof surface.
- Validation: Write tests or checks (similar to PR checks) that new definitions and claims adhere to schema or logical constraints. Failed checks should emit RejectionCert or receipts analogously, triggering retraining or alternative proof paths.

## Authoring or Extending Stage Runners
- SCP Runner (scripts/run_scp.py): Implement the run(tp, docs_dir) function to take the current TransportPack and optionally a BridgeCert, then generate SCp theoretical proposals. Use generative inversions (GMM tails/contracts) to propose new claims. Emit receipts for any new proof artifacts and update the TransportPack with their digests.
- Deterministic vs Non-Deterministic: For deterministic tasks, the runner should be idempotent under fixed random seeds (use canonical RNG seeds). For generative SCp exploration, allow non-deterministic branching but record all random seeds and outcomes in receipts to ensure reproducibility.
- Iterative Learning: If a generated definition or lemma fails PR checks or causes spike in unknowns, use those failure receipts as feedback in subsequent runs. This can be automated by logging rejection receipts and incorporating them into the SCp generation logic.

