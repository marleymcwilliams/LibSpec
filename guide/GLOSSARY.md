# Glossary

The canon's terms, each defined once, and the four core objects they name. The reading rules are in [MASTER_GUIDE.md](MASTER_GUIDE.md), and [README.md](README.md) maps the rest of the guide.

## Canonical glossary

Twenty-two terms, each with one home. The SIRUS name waits: not yet, since no v1 statement depends on it.

| Canonical term | Meaning | Replaces or aliases | Home |
| --- | --- | --- | --- |
| Graded values **G** | Per-axis intervals \[lo, hi\] in \[0, ∞\]; the verdict reads hi; ordered by badness (endpoints) and by information (narrower is better) | "Q" in JSG V, the PDE paper and SCp2 | Core v2 |
| Floor axes **M** | Per-window rates; combined by max | max-channels, Q\_max | Core v2 |
| Budget axes **S** | Cumulative spends; combined by +; each carries a subadditivity side condition | sum-channels, Q\_sum, ledger and CVaR axes | Core v2 |
| Unknown | The interval \[0, ∞\]; a lease β allows width up to β, and anything wider is a breach | ⊤unk (JSG V, PDE); ⊥ in SCp1 and SCp2, placed below every value (a known defect); "third value" (SIRUS spec) | Core v2; PDE I4b |
| Combine **⊕** | Endpointwise max on M, + on S; a commutative monoid, not a join (on S, g ⊕ g = 2g) | "Parallel join"; horizontal ⊙ (JSG V); ∧ (PDE; SCp1, Def 2.2); ⊎ and ⊙ (SCp2) | Core v2 |
| Sequential composition | Resolved: the same ⊕; sequence and parallel differ only in data flow | vertical ∧ (JSG V); ∧ (SCp1, Prop 7.4, where it is ⊕); ⋆ (SCp2, whose "∧ ≡ ⋆" misreads SCp1) | Core v2 |
| Residual **θ ⊸ g** | Budget left for later stages: θ ⊖ g on S; θ on M when g ≤ θ | None | Core v2 |
| Decision **D** | {REJECT < ACCEPT}; no third value | "Q" in the SIRUS spec | SIRUS spec §1.2 |
| Verdict map **δ\_θ** | Indicator of the down-set of θ, read on upper endpoints | Implicit threshold checks | Core v2 |
| Receipted result **R** | (grade, receipt address, metrics). The decision is derived as δ\_θ(grade), never stored, and metrics cannot influence the grade | Q′ | SIRUS spec §1.4 |
| Obligations **Σ** | Typed: each has a witness type and an authority stage; progress is the Dershowitz–Manna order | Typed effects | Core v2 |
| Must-pass set **MP** | Inputs the gate must ACCEPT; disjoint from the must-fail set | None | Core v2 |
| Frontier charge **Δ\_fr** | Total variation A · Σ‖jump\_k‖ at the finest resolution; additive, so regrouping can't change it | C\_fr, frontier spend, C\_salt, the subadditive merged-crossing debit | Core v2 |
| **proof\_surface** | Window or run digest binding the guard IDs in fixed order | proof\_print, proof print | SCp1 |
| Guard order | EF → DRO → PR → CBF → ω | None | JSG III |
| **ω stage** | Automata verdict over KPI row hashes; the fifth guard | "Ω" in the SIRUS pipeline | JSG III |
| Uncertainty set **𝒰** | Model-uncertainty set for PR/GKYP witnesses and degraded profiles | "Ω" in JSG II–IV, including Ω\_wc | JSG IV §Ω contract |
| Clamp states | Green, Amber, Red | "Yellow" | JSG IV |
| Invariant families | Prefix by family: H1–H5 (governor, JSG III list), A1–A5 (PDE acceptance), L1–L10 (Loader), T11–T13 (tail contracts) | I₁–I₅ (three incompatible versions); I1–I13 | New |
| Policy lattice **⪰** | Dials in a complete lattice, larger is stricter; E(t) = baseline ⊓ active weakenings; threshold dials store their inverse | "Strictest unexpired policy P\*"; ThresholdChange VC semantics | Core v2 |
| **SIRUS** (this project) | The governance and evidence spec | Also the name of Bénard et al.'s random-forest rule-set algorithm; the two were merged in MDmaster | Not yet: no v1 statement depends on it |
| Content address | BLAKE3-256 of canonical bytes | `b3:…` placeholders (849 in the master spec) | SIRUS spec §0.5 |

## Unified core objects (v2)

Four objects carry the calculus. This revision folds in an outside review of v1, which found that its seven objects were partly the same object in different notation, and that a gate rejecting everything satisfied every v1 theorem.

**1. Graded values.** Each axis holds an interval \[lo, hi\] in \[0, ∞\], and the verdict reads hi. A known value is \[x, x\], full ignorance is \[0, ∞\], and a lease β allows \[x, x + β\]. Floor axes M carry per-window rates and combine by max; budget axes S carry cumulative spends and combine by +. Both are commutative ordered monoids, so the operation is called **combine**, not join: on budgets, g ⊕ g = 2g.

```latex
[a,b] \oplus [c,d] = \begin{cases} [\max(a,c),\ \max(b,d)] & \text{floor axis} \\ [a+c,\ b+d] & \text{budget axis} \end{cases}
```

Sequential and parallel composition use the same ⊕. A stage is a function X → G × Y; stages in sequence pass Y along and combine their grades, so the two kinds of composition differ only in data flow, and interchange holds as an equation. Each budget axis registers a soundness side condition: the real quantity must be subadditive under composition, as CVaR is.

**2. Residuated budgets.** The verdict is the indicator of the down-set of θ, read on upper endpoints. On budget axes, accepted parts do not combine into an accepted whole, so each stage is checked against the residual that earlier stages left:

```latex
\theta \multimap g = \max\{h : g \oplus h \le \theta\} = \begin{cases} \theta & \text{floor axis, when } g \le \theta \\ \theta \ominus g \ \text{(truncated subtraction)} & \text{budget axis} \end{cases}
```

The same mechanism covers thresholds, the frontier charge, the governance cap and any explicit step bound. The frontier charge is total variation: A · Σ‖jump\_k‖ at the finest resolution. It is additive under concatenation, so no regrouping can change it, and chattering across a frontier and back is never free. A is computed conservatively, with ν̂\_min as a lower confidence bound and κ\_max, r\_tube as upper bounds, in ENNReal so that ν̂\_min = 0 gives A = ∞.

**3. Typed obligations.** Each obligation o has a witness type W(o) and an authority stage. Discharging o requires a witness of type W(o) produced at authority(o), and a window passes only when every emitted obligation was discharged that way. The Loader's progress is measured by the Dershowitz–Manna order on its pending obligations, which allows one obligation to be replaced by finitely many smaller ones. Its safety is a separate theorem: an invariant Inv (L1–L10) preserved by every accepted step. A halt with rejection carries the remaining obligations and the axes still unknown as its certificate.

**4. Policy lattice.** A policy maps dials into a complete lattice where larger is stricter. Must-fail classes are hard floors, not runtime dials: runtime weakenings can't touch them, and removing one takes a new statements version with a CHANGELOG line marking the weakening ([decisions/RAILS.md](decisions/RAILS.md)). The effective policy is a monotone baseline met with the active weakenings:

```latex
E(t) = B(t) \wedge \bigwedge \{\, w : w \text{ active at } t \,\}
```

Expiry removes a term from the meet, so it can only make E stricter. Thresholds are looser when larger, so a threshold dial stores its inverse (`threshold` in the stubs), and the bridge theorem catches the mistake if it doesn't: if P₂ ⪰ P₁ then Accept(P₂) ⊆ Accept(P₁). Weakenings are priced by magnitude × duration against a token bucket: a reservoir of capacity C that refills at rate ρ per window, both of them dials. Without the refill this is the lifetime budget again, just draining more slowly. The bucket bounds the rate of weakening, not its persistence: a weakening that costs at most ρ per window can be renewed forever, so three options are open: set ρ to the standing weakening you accept, cap each weakening's cumulative duration, or raise each consecutive renewal's cost by a factor γ > 1, which any finite C and ρ eventually refuse. Choosing among them waits for the milestone that states the token bucket, since no v1 statement depends on it. Escalation must be keyed to the dial being weakened, not to the request, or relabeling and brief lapses would reset it. It also needs a deliberate reset, such as decay after a quiet period, or one long episode leaves the dial effectively frozen.

**Positive controls.** Every property above is a safety property, and a gate that rejects everything satisfies all of them. Two counterweights are required: a must-pass set MP of inputs that must ACCEPT, kept disjoint from the must-fail set, and a completeness lemma: complete evidence whose values are within θ is accepted. That lemma stays nearly definitional unless a statement ties each interval to the true value (lo ≤ truth ≤ hi). That enclosure is empirical, because truth is measured: it holds at a declared coverage level and belongs to the CI layer, or to the certificate layer when the interval comes from exact computation on a model. It is not a Lean item. The real guard against vacuity is the must-pass set together with the always-reject mutant.
