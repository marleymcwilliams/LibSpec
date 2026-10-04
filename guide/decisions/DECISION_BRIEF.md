# Decision brief: sequential composition ⊗ and the normative rails

Phase 2 prep for the two open decisions in [MASTER_GUIDE.md](../MASTER_GUIDE.md) (Roadmap, lines 317–318). Research only: this brief lays out what the sources say and what each option commits you to. It does not recommend an option.

**Conventions**

- Quotes are word for word. LaTeX and Markdown sources are cited as `file:line`, the PDE paper by page. LaTeX is quoted as source, with the rendered symbol noted where it matters. Math in PDF quotes is transcribed from the rendered page.
- *Summary:* marks my paraphrase.
- *Hand-checked* means I worked the algebra by hand. *Unverified* means nobody has checked it, in Lean or otherwise. None of the Lean below has been compiled.
- Paths are relative to `archive/` unless they start with `guide/`.
- Contradictions carry labels (X1, J1, …) so the options can point back to them.

**Contents**

1. [Decision 1: sequential composition ⊗](#decision-1-sequential-composition-)
2. [Decision 2: are the normative rails must-fails?](#decision-2-are-the-normative-rails-must-fails)
3. [Facts this brief could not establish](#3-facts-this-brief-could-not-establish)

---

## Decision 1: sequential composition ⊗

The question (guide/MASTER_GUIDE.md:50, :317): when two stages run one after the other in a window, how do their grades combine? The sources give three answers: max on every axis (JSG V), sum on every axis (SCp2), or the same operator as the parallel join ⊕ (the PDE paper).

### 1.1 Key passages

#### JSG V: `Buckshot_Roulette/JSGV.tex`

Symbols, lines 119–121. These decide how every formula below renders:

```tex
\newcommand{\unk}{\top_{\mathrm{unk}}}         % Unknown/top
\newcommand{\vmeet}{\wedge}                    % Vertical aggregation
\newcommand{\hplus}{\odot}                     % Horizontal aggregation
```

So JSG V's vertical (sequential) operator renders as **∧** and its horizontal (parallel) operator as **⊙**.

Line 243:

> Safety aggregation must respect two orthogonal compositions: \emph{vertical} (sequential stages within a window) and \emph{horizontal} (wiring disjoint subsystems).

Definition and lemma, lines 262–266:

```tex
\begin{definition}[Vertical operator]
For $x,y\in\Q$, define $(x\vmeet y)_i \coloneqq \max(x_i,y_i)$ (with $\max(\unk,a)=\unk$).
\end{definition}
\begin{lemma}[Laws of $(\Q,\vmeet)$]\label{lem:meet-laws}
$(\Q,\vmeet)$ is a commutative, idempotent monoid with identity $0$ (the all-zero vector). Moreover, $\unk$ is absorbing: $x\vmeet\unk=\unk$.
```

Horizontal operator, lines 277–281 (sum on the two accumulating coordinates, max elsewhere):

```tex
  (x\hplus y)_i \coloneqq
  \begin{cases}
    x_i + y_i, & i\in\{\ledger,\cvar\},\\[0.2em]
    \max(x_i,y_i), & \text{otherwise},
  \end{cases}
```

Lax interchange law, lines 290–296:

```tex
\begin{proposition}[Lax interchange law]\label{prop:lax-interchange}
For all $x,x',y,y'\in\Q$,
\[
  (x\vmeet x') \hplus (y\vmeet y') \;\geqQ\; (x\hplus y)\vmeet(x'\hplus y').
\]
\emph{Proof sketch.} Coordinatewise. For max–max coordinates, both sides equal $\max(x_i,x'_i,y_i,y'_i)$. For sum–max coordinates ($i\in\{\ledger,\cvar\}$), the claim reduces to
$\max(x_i,x'_i) + \max(y_i,y'_i) \ge \max(x_i+y_i,\,x'_i+y'_i)$, which holds by elementary case analysis.
```

Coordinate registry, lines 338 and 347–348. Every coordinate takes max vertically, including frontier cost:

```tex
\textbf{Name} & \textbf{Semantics} & \textbf{Vert.} & \textbf{Horiz.} & \textbf{Enforced at} & \textbf{REQ?}\\
\ledger & Frontier cost & $\max$ & \textbf{sum} & Hard floor & Y \\
\cvar & Tail risk (CVaR) & $\max$ & \textbf{sum}$^\dagger$ & Hard floor & Y \\
```

Stage transition, lines 437–438. Each stage folds its delta in with the vertical operator:

```tex
(\Q_{\text{out}}, \Sigma_{\text{out}}) \;=\;
\Big(\;\Q_{\text{in}} \vmeet \Delta\Q_S,\quad
```

Lax Exchange theorem, lines 517–518, read with line 481:

> (481) \item \emph{Vertical morphisms:} Pipeline stages drawn from the ordered set \(\{\EF,\DRO,\PR,\CBF,\om\}\); composition is function composition in that order.

```tex
  \mathrm{grade}\big(\composeev(v\circ h)\big)\;\geqQ\;
  \mathrm{grade}\big(\composeev(h\circ v)\big).
```

> (522, last sentence of the proof sketch) Thus, composing first (then piping) is conservatively no better than piping first (then composing).

"Why lax", line 530. *Summary of the first part:* tuning two subsystems together vs separately improves one coordinate and worsens another. The paragraph ends:

> Because \(\hplus\) mixes sum and max, some coordinates tighten while others loosen, justifying an inequality rather than equality.

Also: the only ⊕ in JSG V is a golden fixture, line 643 (`$(A\oplus B)\oplus C$ vs.\ $A\oplus(B\oplus C)$`). The API at line 680 reads `\code{seqCompose(stages, q0, sigma0)} $\to (\Q,\Sig)$ uses $\vmeet$ and discharge.`

#### SCp2 in MDmaster: `Markdown/MDmaster.md`

SCp1 "Algebraic defaults", lines 296–298:

> - Acceptance states live in the typed product `Q = Q_max × Q_sum`, with coordinatewise aggregation (`max` on max-axes, `+` on sum-axes).
> - Runtime operators: `⊎` (heterogeneous join: `max` on `M`, `+` on `S`) and `⋆` (sequential: `+` on both). Cross-part aliases `⊙ ≡ ⊎`, `∧ ≡ ⋆` match the implementation surface.
> - Unknowns are absorbing bottoms `⊥_i`: once ledgered on an axis they propagate under both operators and cannot be cancelled.

SCp2 "Acceptance Algebra `Q`", lines 349–352 and 356–357:

> - Partition acceptance axes into sum-like `S` and max-like `M`; each axis `i` carries `(Q_i, ≤_i)` with identity `e_i` and absorbing bottom `⊥_i`.
> - Aggregation is defined by two runtime operators:
>   - **Heterogeneous join** `q ⊎ r = ( q_M ⊕ r_M , q_S + r_S )` (`⊕` is componentwise `max` on `M`).
>   - **Sequential aggregation** `q ⋆ r = ( q_M + r_M , q_S + r_S )` (componentwise `+` on both partitions).
>
> - `⊎` is associative, commutative, and idempotent on `M`; `⋆` is associative with unit `e`. Both operators are monotone in each coordinate.
> - Cross-part aliases match the implementation surface: `⊙ ≡ ⊎` (horizontal aggregation) and `∧ ≡ ⋆` (vertical/temporal aggregation).

Line 361:

> - Unknowns are represented by the absorbing bottom `⊥`; if any coordinate is `⊥`, both `⊎` and `⋆` absorb and the value propagates.

SCp2 "Frontier Debit `Δ_fr`", line 409:

> - Debits accrue only on sum-axes; max-axes remain invariant so reassociations do not alter hard gates.

SpecChain Part 2 abstract (dated September 17, 2025), end of line 1279:

> Notation hygiene. Internally we use q ⊎ r for the heterogeneous ("horizontal") aggregator (max on M, + on S) and q ⋆ r for the sequential aggregator (+ on both). For cross-part consistency we expose aliases ⊎ ≡ ⊎ (Part 5's ⊙) and ⋆ ≡ ⋆ (Part 1's product aggregator ∧).

#### PDE paper: `DissipativePDEs.pdf`

"A Compositional, Audit-Ready Proof Program for 3D Navier–Stokes", 30 pages.

p. 1, abstract:

> Analytical risk lives in a graded algebra Q; side-conditions in a typed effect system Σ; and a lax composition rule compose_ev upper-bounds order effects.

p. 1, §1 "Two core innovations":

> (I) Priced frontiers. Non-commuting reassociations are modeled as frontier crossings that incur a saltation bound Csalt and a ledgered ∆fr. […] By design, ∆fr debits only sum-channels, preserving max-channel invariants used by decisive L∞-type gates.

p. 2, §2.1 (math transcribed):

> Grades are vectors q ∈ 𝒬 = ∏ᵢ 𝒬ᵢ with coordinatewise preorder (larger=worse). We fix disjoint index sets of channels: 𝒮 = {L, ℰ_CVaR, Q_fr, …}, ℳ = {E, S₃, P_{H⁻¹}, Q_τ, Q_h, …}. Aggregation ∧ acts coordinatewise by (q ∧ q′)ᵢ = max{qᵢ, q′ᵢ} for i ∈ ℳ, and qᵢ + q′ᵢ for i ∈ 𝒮.

p. 3, adapter contract: "r ⪰ r′ ⇒ g(r) ⪰ g(r′), g(r ⊕ r′) = g(r) ∧ g(r′), g(⊥) = 0, g(∅) = ⊤unk." Here ⊕ merges raw evidence and ⊥ is the raw monoid's identity.

p. 5, §2.3:

> Proposition 2.2 (Laxity Lemma). Under (A1)–(A3), for any legal reassociations 𝒪₁, 𝒪₂, 𝒬max[𝒪₁] ≤ 𝒬max[𝒪₂], 𝒬sum[𝒪₁] ≤ 𝒬sum[𝒪₂] + ∆fr, and pass ⇒ Σfinal = ∅.
>
> Q readouts (sum vs max). Only sum-channels are perturbed by ledgered frontier spend ∆fr; max-channels are invariant under reassociation.

p. 18, §8.1:

> Compositional risk algebra. Q = Qmax × Qsum with ∧ (max on Qmax, sum on Qsum) keeps “budgets vs. worst-cases” disentangled; reassociation perturbs only Qsum by design (∆fr ledger).

p. 21, §10.1: "A frontier crossing c is any non-commuting reassociation (e.g., basis swap, mesh retune) that generates an auditable packet […]"

p. 22, Lemma 10.1. *Summary:* for the crossings in a window, the merged crossing's debit is at most the sum of the individual debits, ∆fr(c⊕) ≤ Σᵢ ∆fr(cᵢ). Its acceptance hook checks a window budget, "Cfr+ ≤ siss_budget".

p. 29, §13: "Qt = Qmax,t∧Qsum,t".

*Summary:* the PDE paper has one binary operator on grades (∧: max on ℳ, sum on 𝒮). It never writes a separate formula for composing stages. Order effects are handled by the Laxity Lemma, which charges reassociation to the sum channels through ∆fr.

### 1.2 At a glance

| Source | What it says about ⊗ | Where it sits in the lineage |
| --- | --- | --- |
| JSG V | Sequential = max on every axis (its "vertical ∧"). Parallel = sum on ledger and CVaR, max elsewhere (its "horizontal ⊙"). Lax interchange: (x∧x′)⊙(y∧y′) ⪰ (x⊙y)∧(x′⊙y′) | Stage 5 of 8, the acceptance calculus. The PDE program branches off here |
| PDE paper | One operator ∧ (max on ℳ, sum on 𝒮), no separate sequential formula. Reassociation costs ∆fr on 𝒮 only | Side branch off JSG V |
| MDmaster, SCp2 | Join ⊎ = max on M, + on S. Sequential ⋆ = + on both partitions. Claims ∧ ≡ ⋆ and ⊙ ≡ ⊎ | Stage 6, SpecChain SCp1–5 and MDmaster |
| Master guide | ⊗ open. ⊕ = max on M, sum on S. Floors: "worst reading counts". Budgets: "add up and can be spent" (lines 46–50) | The canon being written |

### 1.3 Contradictions

**Between sources**

- **X1. ∧ names three different operators.** In JSG V it is max on every axis, used for sequential composition (JSGV.tex:120, 263). In the PDE paper it is max on ℳ and sum on 𝒮, the only aggregation (p. 2). MDmaster says "∧ ≡ ⋆", which is + on both partitions (MDmaster.md:297, 357, 1279). No source in the archive defines ∧ as + on both partitions, so MDmaster's alias matches neither JSG V's ∧ nor the PDE paper's.
- **X2. The master guide misrecords JSG V's symbols.** The glossary lists "horizontal ⊕ (JSG V)" and "vertical ⊓ (JSG V)" (guide/MASTER_GUIDE.md:49–50). JSG V's macros render them as ⊙ and ∧ (JSGV.tex:120–121). JSG V uses ⊕ once, in a golden fixture (line 643), and never ⊓. This needs correcting whatever you decide.
- **X3. Frontier cost across sequential stages: max or sum?** JSG V's registry takes max (JSGV.tex:347). The PDE paper adds the per-crossing debits within a window (Lemma 10.1, p. 22), and SCp2's ⋆ adds every axis (MDmaster.md:352, 409). Caveat: if JSG V's stages emitted running totals, max would agree with a sum. JSG V calls them deltas, ΔQ_S (line 435), so on its face they conflict. Which is meant is unverified.
- **X4. Where laxity comes from.** JSG V: from ⊙ mixing sum and max (line 530, and the interchange law). PDE paper: from non-commuting reassociations priced by ∆fr (pp. 1, 5, 21). Under the PDE's own ∧, which is associative and commutative, re-bracketing alone cannot change a grade, so its laxity has to come from the stage computations themselves (my reading).
- **X5. Which end is "unknown".** In JSG V and the PDE paper, unknown is the top, ⊤unk (JSGV.tex:119, 257; PDE p. 3), as in the guide (line 48). MDmaster calls it an "absorbing bottom ⊥" (lines 298, 349, 361). See S1.
- **X6. What a floor axis is.** The guide says floors are where "the worst reading counts; combined by max" (line 46). SCp2's ⋆ adds the M axes (MDmaster.md:352).

**Within JSG V**

- **J1. The Lax Exchange theorem and its proof point opposite ways.** The interchange law (line 293) is correct for JSG V's own operators (hand-checked). Take the ledger axis, which sums in parallel and takes max in sequence. Subsystem 1 has stage readings x = 1, x′ = 0; subsystem 2 has y = 0, y′ = 1.
  - Pipe each subsystem first, then wire them: (x∧x′)⊙(y∧y′) = max(1,0) + max(0,1) = **2**.
  - Wire each stage first, then pipe: (x⊙y)∧(x′⊙y′) = max(1+0, 0+1) = **1**.

  The interchange says piping first is the worse order (2 ⪰ 1), which holds. The proof's last sentence (line 522) says wiring first is "no better than" piping first, that is 1 ⪰ 2. The theorem's formula (lines 517–518) agrees with the interchange only if v∘h means "v first". Line 481 says composition is function composition, so v∘h means "h first", and then the formula also claims 1 ⪰ 2.
- **J2. The "why lax" example describes incomparable grades.** Line 530 justifies the inequality because "some coordinates tighten while others loosen". A coordinatewise ⪰ cannot hold when coordinates move in opposite directions, so the example is one the theorem doesn't cover (my reading).
- **J3. Max is called "meet".** The operator is named meet (`\vmeet`, invariant `\IMeet`, API `meetQ` at line 590) and rendered ∧. Under the order at line 257 (x ⪰ y iff xᵢ ≥ yᵢ for all i, with unknown on top), max is the least upper bound, which is a join. The macro comment at line 122 calls ⪯ the "“no better than” order", the reverse of line 257. Under that orientation max would be a meet.

**Within the PDE paper**

- **P1.** ∧ is the aggregation on grades (p. 2) and also pairs the two subvectors (p. 29, "Qt = Qmax,t∧Qsum,t").
- **P2.** The Laxity Lemma (p. 5) has no proof in §2.3, and I didn't find one elsewhere in the paper (unverified). Because it holds "for any" 𝒪₁ and 𝒪₂, its first inequality forces 𝒬max[𝒪₁] = 𝒬max[𝒪₂]. That matches "max-channels are invariant".

**Within MDmaster (SCp1 and SCp2)**

- **S1. "Absorbing bottom" doesn't fit max and +.** Under max and +, the bottom element is the identity: max(⊥, a) = a. It absorbs only if the order is reversed, and then "max" picks the better reading, not the worse. The guide already records this as "⊥ in SCp2 (reversed orientation)" (line 48).
- **S2.** M is called "max-like" (line 349), but ⋆ adds it (line 352). Under SCp2, M behaves like max only in the join.
- **S3.** ⋆ is listed as "associative with unit `e`" (line 356). Componentwise + is also commutative, so SCp2's sequential operator can't tell stage order apart. That's not a contradiction, but it limits what ⊗ can express.
- **S4.** SCp1's defaults (line 296) say the typed product aggregates by max on max-axes and + on sum-axes, which is SCp2's ⊎. Line 1279 ties "Part 1's product aggregator ∧" to ⋆ instead. Whether SCp1's original ∧ was the mixed operator can't be checked, because SCp1's source text isn't in the archive (unverified).

**Within the master guide**

- **G1.** The ⊗ row says "the PDE paper reuses ⊕" (line 50). The paper never writes a sequential formula, so "reuses" is an inference from its single operator and the Laxity Lemma. It's a reasonable inference, but the paper doesn't state it.

### 1.4 Options and what each commits you to

**Common to all three (hand-checked)**

- Each candidate is associative, commutative and monotone in both arguments, has the all-zero grade as its identity, and lets ⊤ absorb. None of them encodes the order of stages. The fixed order EF → DRO → PR → CBF → ω stays outside the algebra, as in JSG V (line 481).
- Each is inflationary: g ≤ g ⊗ h. So `verdict_antitone` (MASTER_GUIDE.md:179) already gives "if the composite is accepted, every stage was accepted".
- Statements.lean gains a `seq` definition next to `join`, its laws, and an interchange statement. The layer-map row "Lax interchange law | Lean now | Not started | JSG V §2" (line 73) is in no milestone yet (guide/ROADMAP.md:108–110).

The sketches build on the guide's stubs: `Axis := WithTop NNReal`, `Grade ι := ι → Axis` and `join kind` (MASTER_GUIDE.md:143–163). They have not been compiled (unverified).

#### Option A: max on every axis (JSG V)

```lean
/-- Sequential composition: on every axis the worse reading wins. -/
def seq (g h : Grade ι) : Grade ι := fun i => max (g i) (h i)

/-- JSG V's direction (hand-checked). -/
theorem lax_interchange (x x' y y' : Grade ι) :
    seq (join kind x y) (join kind x' y') ≤ join kind (seq x x') (seq y y') := by sorry
```

- **Laws that hold:** associative, commutative, idempotent (`seq g g = g`), identity 0, ⊤ absorbs, monotone. `seq g h` is the pointwise `g ⊔ h`, so Mathlib's `sup` lemmas should apply (unverified).
- **Interchange:** holds in JSG V's direction. Floors are equal on both sides. On budgets, max(x+y, x′+y′) ≤ max(x,x′) + max(y,y′). This is strict for x = 1, x′ = 0, y = 0, y′ = 1 (1 against 2).
- **Verdict:** compositional both ways: `verdict θ (seq g h) = .accept ↔ verdict θ g = .accept ∧ verdict θ h = .accept` (hand-checked).
- **What breaks or changes:**
  - Budgets don't accumulate over time. Running a stage twice costs nothing extra.
  - "Budget axes S: add up and can be spent" (line 47) then holds only across parallel subsystems.
  - A window's frontier spend (PDE Lemma 10.1; SCp2's ∆fr) can't be computed through ⊗ and needs its own ledger (X3).
- **Rows affected:**
  - Lax interchange law: provable as JSG V states it, but JSG V's Lax Exchange text must be fixed (J1).
  - Grade lattice laws: Milestone 1 gains the `seq` laws.
  - Frontier debit (line 78): the lemma is unchanged, but ∆fr no longer flows through ⊗.
  - Unknowns lease β (line 82) and CVaR tail-to-level (line 83): CVaR would take the max over stages. How that interacts with PDE Lemma 9.1 is unverified.

#### Option B: sum on every axis (SCp2)

```lean
/-- Sequential composition: readings add on every axis. -/
def seq (g h : Grade ι) : Grade ι := fun i => g i + h i

/-- The reverse of JSG V's direction (hand-checked). -/
theorem lax_interchange (x x' y y' : Grade ι) :
    join kind (seq x x') (seq y y') ≤ seq (join kind x y) (join kind x' y') := by sorry
```

- **Laws that hold:** associative, commutative, identity 0, ⊤ absorbs (⊤ + a = ⊤ in `WithTop`), monotone. It is not idempotent.
- **Interchange:** holds, but in the opposite direction to JSG V. On floors, max(x+x′, y+y′) ≤ max(x,y) + max(x′,y′); on budgets the two sides are equal. JSG V's interchange (line 293) becomes false: on a floor axis with x = 1, x′ = 0, y = 0, y′ = 1, JSG V's left side (x⊗x′)⊕(y⊗y′) = max(1, 1) = 1 and its right side (x⊕y)⊗(x′⊕y′) = 1 + 1 = 2, so it would claim 1 ⪰ 2.
- **Verdict:** one direction only. Two accepted stages can compose to REJECT on any axis, floors included.
- **What breaks or changes:**
  - Floors accumulate over time, so "the worst reading counts" (line 46) holds only across parallel subsystems.
  - This conflicts with the PDE paper's "budgets vs. worst-cases" split (p. 18) and with JSG V's registry.
  - Lean must put unknown at ⊤. SCp2's "absorbing bottom" wording can't be carried over as written (S1).
- **Rows affected:**
  - Lax interchange law: the direction reverses, and JSG V §2's text changes.
  - Frontier debit: ∆fr accumulates through ⊗, and so do floors.
  - Unknowns lease β: the guide allows leases on budget axes only (line 48). Whether floors now need leases is unverified.

#### Option C: ⊗ = ⊕ (PDE paper)

```lean
/-- Sequential composition reuses the parallel join. -/
abbrev seq := join kind

/-- Strict interchange, from `join_assoc` and `join_comm` (hand-checked). -/
theorem interchange (x x' y y' : Grade ι) :
    join kind (join kind x x') (join kind y y') =
      join kind (join kind x y) (join kind x' y') := by sorry
```

- **Laws that hold:** exactly the join laws already stubbed for Milestone 1 (`join_comm`, `join_assoc`, `join_mono`, `top_absorbs`; lines 157–163). It is idempotent on floors only.
- **Interchange:** an equality, so the "lax interchange law" row becomes a strict law. Any laxity has to come from the PDE's Laxity Lemma instead (∆fr on 𝒮 under non-commuting reassociations, X4). That needs a model of schedules and reassociations that Statements.lean doesn't have (not drafted; unverified).
- **Verdict:** compositional both ways on floors; one direction on budgets.
- **What breaks or changes:**
  - Parallel and sequential composition become the same operator, and the ⊗ glossary row folds into ⊕.
  - Conflicts with JSG V's registry (max over stages on ledger and CVaR, X3) and with SCp2's ⋆ on M.
- **Rows affected:**
  - Grade lattice laws: already cover it.
  - Lax interchange law: becomes trivial. A Laxity statement would be new and isn't in the layer map.
  - Frontier debit: consistent with core object 4 (line 115), charged to S with floors invariant.
  - CVaR: a budget axis that sums over stages, consistent with the PDE paper.

#### Other options

- **Per-axis vertical kind.** Give each axis a vertical kind as well as a horizontal one; JSG V's registry already has both columns. A, B and C become special cases. If some axes pair vertical max with horizontal sum and others pair vertical sum with horizontal max, the interchange holds in opposite directions on different axes, so no single inequality holds (hand-checked).
- **Defer.** Leave ⊗ out of `statements-v1`, state only ⊕, and mark the Lax interchange row Open.
- **Order-aware ⊗.** Compose ordered lists of stages and charge ∆fr between adjacent stages that cross regimes. This makes ⊗ associative but not commutative. No source writes this.

---

## Decision 2: are the normative rails must-fails?

The question (guide/MASTER_GUIDE.md:318): are the normative rails must-fails inside the gates, or a declared layer outside them? The layer map currently files "Golden Rule, restoration debt, consent brake, bravery-as-accountability" as Norm, with Lean status Not applicable and source main.tex (line 94). The known-defects table says the drafts drop must-fails that their own rule protects (line 284).

### 2.1 First: which file, which rails, which "must-fail"

**Which main.tex.** The archive has three:

- `SIRUS/main.tex` ("SIRUS: Ethics-First Prototype Draft", line 30) holds the four rails the guide names.
- `NormGovProposal/main.tex` ("SIRUS: Continuous Thread Execution", line 97) shares 163 identical lines with the Playbook and contains no rails.
- `Buckshot_Roulette/main.tex` contains neither rails nor must-fails.

The guide's lineage box, "Ethics rails, runtime note: main.tex, Playbook, crit.tex, SIRUS_game.tex", groups main.tex with the NormGovProposal files, so which file it means is unverified. This brief treats `SIRUS/main.tex` as the rails source and also covers `NormGovProposal/main.tex`.

**"Rails" means five different things:**

- `SIRUS/main.tex`: ethical and mechanism rails (Golden Rule, consent brake, restoration debt, bravery; NO_PACK, NO_ENVLOCK, TAILCONTRACT_BREACH).
- `crit.tex`: infrastructure (Dataset Receipts, EnvLock, Pack, TailContracts, Ledger).
- Draft1–5: the Green/Amber/Red clamp bands.
- The Playbook: "governance rails" as technical gates.
- `SIRUS_game.tex`: runtime drift caps.

**"Must-fail" has three senses:**

- `NormGovProposal/main.tex` and the Playbook: a negative test fixture that must fail with an expected reason code ("Must-fail Coverage Entry").
- The drafts: failure classes in a norms bundle, MF(N), which may only grow.
- `SIRUS/main.tex`: a move that must be rejected ("the move is MUST–FAIL … and admission to Q* is disallowed").

"The rails are must-fails" means something different in each sense.

### 2.2 Key passages

#### `SIRUS/main.tex`

Lines 40–44, the Golden Rule:

```tex
\textbf{Purpose.} This work proposes governance and control rails intended to \emph{reduce harm} while enabling safe progress. Apply a \textbf{Golden-Rule framing}: for any proposed action, first check the mirrored-risk bound
\[
\mathrm{risk}_{\text{in}\leftarrow\text{out}} \le \rho\,\mathrm{risk}_{\text{out}\leftarrow\text{in}},\qquad \rho\in(0,1].
\]
If this bound fails, the move is \textsc{MUST--FAIL} (\texttt{GOLDEN\_RULE\_BREACH}) and admission to Q* is disallowed.
```

Line 56:

```tex
\textbf{Mechanism rails (binding).} We require: \texttt{NO\_PACK} (no SSOT $\Rightarrow$ no run), \texttt{NO\_ENVLOCK} (no promotion/rollback), \texttt{TAILCONTRACT\_BREACH} (auto-rollback; two-strike freeze), \texttt{CONSENT\_BRAKE} (growth capped until revocations cleared), \texttt{RESTORATION\_DEBT\_OPEN} (no growth with outstanding harm), and \texttt{BRAVERY\_BREACH} (risk-taking without receipts/remedies/DP aggregates).
```

Line 76: `\textbf{Vow.} Serve people. Build trustworthy scaffolding. Keep the tail honest. Move.`

Lines 82 and 87, from the commitments C1–C8: `\item $\beta$-leases on unknowns; breaches quarantine.` and `\item Bravery-as-Accountability (bravery without receipts = \texttt{BRAVERY\_BREACH}).`

Lines 123–124:

```tex
\section{Conformance \& Must-Fail Set}
\texttt{FRONTIER\_MISSING\_FREEZE}, \texttt{RETUNE\_NONEXPANSIVE\_VIOLATION}, \texttt{UNK\_BUDGET\_EXCEEDED}, \texttt{CDG\_UNSET\_QSTAR}, \texttt{CDG\_COINCIDENTAL\_QSTAR}, \texttt{MIRROR\_GAP\_OVERBAND}, \texttt{SENTINEL\_VETO\_IGNORED}, \texttt{GOLDEN\_RULE\_BREACH}, \texttt{EXCHANGE\_SLACK\_OVERBAND}, \texttt{RECIPROCITY\_VIOLATION}. Mechanism rails binding as listed in the ethics block.
```

#### `NormGovProposal/Operational_Playbook.tex`

`NormGovProposal/main.tex` repeats Playbook lines 122, 143, 219–225 and 268 at its lines 130, 186–187, 256–262 and 295.

Lines 102–103:

> \textit{Serve people. Build trustworthy scaffolding. Keep the tail honest. Move.}
> This playbook unifies: (i) a modular composition engine for prompts and artifacts; (ii) a mathematical skeleton for coupled decision--objective spaces; and (iii) governance rails that make moral good enforceable as technical gates.

Line 122: `Master Plan & Task-focused now $\rightarrow$ next & Each requirement maps to SPEC/file/test; must-fails mandatory \\`

Line 133: `\item \textbf{Spark (Propose)}: Compose a proposal; list SPEC anchors to update; enumerate new must-fails with reason codes.`

Lines 219–225, the fixture format:

```tex
\subsection{Must-fail Coverage Entry}
\begin{lstlisting}[language=json,caption={Coverage manifest entry}]
{
  "id": "NEGATIVE_ID",
  "path": "patterns/must-fail/<file>.card.yaml",
  "reason_code": "<EXPECTED_REASON>"
}
```

*Summary:* neither the Playbook nor `NormGovProposal/main.tex` lists which rails exist. "Must-fail" there means a negative fixture.

#### `NormGovProposal/crit.tex` ("SIRUS Rails for BLT")

Line 134: `\textcolor{slate}{\small \textbf{Vow:} Serve people. Build trustworthy scaffolding. Keep the tail honest. Move.}\\[10pt]`

Line 150: `\item \textbf{Safety gates} (DP, red-team, evals) $\rightarrow$ \textbf{TailContracts} auto-remedy if tripped.`

Lines 228–232:

```tex
		\textbf{4) TailContracts}\\[-4pt]
		\begin{itemize}
			\item Triggers \& remedies (freeze, revoke keys)
			\item Restoration-first discipline
			\item Human-readable + machine-enforced
```

*Summary:* "The Rails" panel (lines 196–235) lists five infrastructure rails: Dataset Receipts, EnvLock, Pack, TailContracts, and Ledger & Hope Ledger. The file never says "must-fail" and doesn't mention the Golden Rule, consent brake or bravery.

#### `NormGovProposal/SIRUS_game.tex` (a pdfLaTeX log)

*Summary:* the surviving text is decoded from the log's 3,733 missing-character lines. The log drops spaces, so the spacing below is mine, and [lost] marks a symbol the log doesn't record. The rail passages:

> Every update produces a receipt with the prior state hash, the chosen action, seed streams, and a rails snapshot.
> These rails act before and after selection, and their decisions are recorded in receipts.
> Rails enforce a per-step drift cap so even large [lost] cannot cause sudden changes.
> Receipts include [lost] and the rails snapshot so we can replay any run and verify safety gates.

The bold heading fragments logged at lines 753, 1614 and 3602 read "Safety rails" and "Rails".

#### Draft0–7: `UpdatedMechanism/`

- Draft0:70: `\item \textbf{Mechanized governance.} Safety cannot regress; monotonicity is checked automatically on each norms update.`
- Draft0:121: `\textbf{Monotone safety.} The must--fail set in the active NormsBundle is a monotone sequence under versioning; deltas are checked mechanically (e.g., policy engine) at CI time, and \stl\ entailment may be discharged via \smt. Any regression is a hard reject.`
- Draft1:131–134:

  ```tex
  The must--fail set in the active norms bundle is monotone under versioning; deltas are checked mechanically in CI. ...
  \section{Ethics Rails and Clamp States}
  Rails provide banded operating regions (Green/Amber/Red) with hysteresis and dwell; sentinel thresholds and mirror gaps enforce conservative transitions. ...
  \RailGauge{4.2}{GOVERN}{Golden--Rule margin}
  ```

- Draft2:123: `Let $\mathrm{MF}(N)$ be must--fail IDs in norms bundle $N$. CI enforces $\mathrm{MF}(N_t)\subseteq \mathrm{MF}(N_{t+1})$.` Draft3:183 repeats it; Draft4:147 and Draft5:238 repeat it with plain `MF`.
- Draft2:155 (also Draft3:215, Draft4:204, Draft5:288): `Set inclusion prevents removal of any previously required must--fail; additions tighten obligations; equality preserves them.`
- Draft2:125–126 (also Draft3:185–186, Draft4:150–152, Draft5:241–243): `\section{Rails and Clamp States}` followed by `Rails define banded operating regions (Green/Amber/Red) with hysteresis and dwell; ...`
- Draft6:182: `A \emph{Norms Bundle} is a finite set of such guards plus invariants and budgeted potentials; its evolution is governed by monotone policies (new versions must not remove must-fail cases).`
- Draft7:140: `A \emph{Norms Bundle} is a finite set of such guards with parameters (thresholds, windows) and a set $M$ of \emph{must-fail} checks.`
- Draft7:147: `Must-fail inclusion blocks removal of failure classes. Tightening guards reduces or preserves feasible sets under bounded unfolding; CI rejects any weakening.`

*Summary:* every draft keeps the grow-only must-fail rule. No draft lists what MF contains, and none mentions any `SIRUS/main.tex` code. Searching the drafts, "Golden" appears once (Draft1's gauge label); consent, restoration, bravery, harm and vow appear in none.

#### Master guide, for reference

- Line 94: `| Golden Rule, restoration debt, consent brake, bravery-as-accountability | Norm | Not applicable | main.tex |`
- Line 129: "**7. Must-fail sets.** For successive norms versions, MF(N\_t) ⊆ MF(N\_{t+1}). Removing a failure class is a weakening and follows rule 5."
- Line 121, rule 5: "Any other change is a weakening: it needs an expiry, and on expiry the runtime reverts to the strictest unexpired policy P\*."
- Line 284, the proposed fix: "Restore the rails as must-fails, or record the removal as a signed, expiring weakening".

### 2.3 At a glance

| Source | What it says | Where it sits in the lineage |
| --- | --- | --- |
| `SIRUS/main.tex` | A Golden Rule breach is MUST-FAIL and in the must-fail set. Consent brake, restoration debt and bravery are "binding" mechanism rails, outside the listed set | Ethics-rails side branch, beside the SIRUS spec master (by content; the guide's box says only "main.tex") |
| Playbook (and `NormGovProposal/main.tex`) | Rails make "moral good enforceable as technical gates". Must-fails are mandatory negative fixtures | Ethics-rails side branch |
| `crit.tex` | Rails = receipts, EnvLock, Pack, TailContracts ("restoration-first"), Ledger. No must-fails | Ethics-rails side branch |
| `SIRUS_game.tex` | Runtime rails: drift caps acting before and after selection, recorded in receipts | Ethics-rails side branch (the "runtime note") |
| Draft0–7 | The must-fail set may only grow, but its contents are never listed. Draft1 keeps a "Golden–Rule margin" gauge; Draft2–5 use "rails" for clamp bands | Stage 8 of 8, the last |
| Master guide | Files the four rails as Norm / Not applicable, and lists restoring them as must-fails as one fix | The canon being written |

### 2.4 Contradictions

**Between sources**

- **Y1. Is a weakening ever allowed?** Draft0:121 ("Any regression is a hard reject") and Draft7:147 ("CI rejects any weakening") forbid it. The guide's rule 5 and core object 7 (lines 121, 129) allow one if it expires. So the guide's second proposed fix, "record the removal as a signed, expiring weakening" (line 284), is ruled out by the drafts' own gate.
- **Y2. Did the drafts remove anything?** The drafts never list MF, so they can't be shown to drop a specific class. The known-defect row (line 284) assumes `SIRUS/main.tex`'s must-fail set is an earlier version of the drafts' norms bundle. Nothing in the drafts says so (unverified).
- **Y3. Inside or outside the gates.** The Playbook (line 103) and `SIRUS/main.tex` (lines 44 and 56, "binding") put the rails inside the gates. The guide's layer map (line 94) files them outside, as Norm / Not applicable.
- **Y4. "Rails" and "must-fail" change meaning between sources** (see 2.1). Draft1's heading "Ethics Rails and Clamp States" keeps the ethics label over clamp-band content. From Draft2 on, the label is gone.
- **Y5. M is reused.** Draft7:140 calls the must-fail set M; the guide uses M for floor axes (line 46).

**Within one source**

- **W1. `SIRUS/main.tex`: the Golden Rule vs the other rails.** The Golden Rule is explicitly MUST-FAIL (line 44) and in the must-fail set (line 124). Consent brake, restoration debt and bravery are "binding" (line 56) but not in that set (line 124: "Mechanism rails binding as listed in the ethics block"). The file doesn't say whether "binding" means must-fail. It also describes two of them as growth caps ("growth capped until revocations cleared", "no growth with outstanding harm"), which are limits rather than rejections.
- **W2. The master guide.** The layer map files the rails outside the gates (line 94), while the known-defect fix starts with "Restore the rails as must-fails" (line 284). Rule 2 names six kinds of justification ending in "a declared value" (line 10); the layer map calls the matching layer "Norm".
- **W3. The Playbook and `NormGovProposal/main.tex`.** These near-copies differ on this topic: the North Star sentence about rails as technical gates (Playbook:103) has no counterpart in `main.tex`.

### 2.5 Options and what each commits you to

#### Option 1: the rails are must-fails inside the gates

- **First, choose which rails.** At least `GOLDEN_RULE_BREACH`, the only one called MUST-FAIL. Possibly consent brake, restoration debt and bravery. Possibly NO_PACK, NO_ENVLOCK and TAILCONTRACT_BREACH (`SIRUS/main.tex`:44, 56, 124).
- **Lean.** The statement of `mustFail_monotone` doesn't change; it's generic in the class type `C` (MASTER_GUIDE.md:254–256). What's new is concrete classes for the tests, plus a decision on how a breach reaches the verdict. A sketch (unverified):

  ```lean
  inductive FailClass
    | goldenRuleBreach | consentBrake | restorationDebtOpen | braveryBreach
    -- plus whichever other must-fail codes you keep

  /-- One way in: a rail breach rejects regardless of the grade. -/
  def accepts (railsPass : Bool) (θ : ι → NNReal) (g : Grade ι) : Prop :=
    railsPass = true ∧ verdict θ g = .accept
  ```

  The alternative is to give the rails axes in the grade with threshold 0, so `verdict_unknown` and `verdict_antitone` cover them unchanged (see Other options). Either way, `JSG/Tests/` gains a negative control: a norms version without `goldenRuleBreach` violates `mustFail_monotone`'s step hypothesis.
- **What can be checked where.**
  - The Golden Rule bound compares measured risks. It is checked per instance (the CI / test or certificate layer), not proved in Lean, and ρ stays a declared value (rule 3, line 11).
  - As must-fails, consent brake and restoration debt need a pass/fail reading, such as "any growth while revocations or harm are open fails". That turns them from caps into rejections (W1).
- **Corpus.**
  - Draft7, marked Keep as the external-facing summary, would need the rails restored to its M.
  - Under Draft7's own gate, restoring them is the only route (Y1).
  - Under rule 5, an expiring weakening is allowed. But it lapses back to the stricter policy on expiry, and it goes through the governance fold whose nightly check currently cannot fail (known defect 1; `fold_check_vacuous` and `admits_mono`, lines 243–250). Hand-reasoned.
- **Rows affected:**
  - The Norm row (line 94) moves to CI / test or Certificate.
  - "Must-fail sets only grow" (line 81) gets concrete data.
  - The roadmap's CI item (fail the build on any must-fail removed without a signed weakening) must cover the rail classes.
  - Milestone 1: `mustFail_monotone` is unchanged. `fold_check_vacuous` and `admits_mono` matter if a weakening record is used.

#### Option 2: the rails are a declared layer outside the gates

- **Lean.** Nothing new in the verdict. The rails don't enter `C`, so `mustFail_monotone` and its tests are untouched. The rails are listed in the guide, or as a plain Lean `def` with no theorem, and the layer-map row stays Norm / Not applicable.
- **The catch.** `SIRUS/main.tex` already declares `GOLDEN_RULE_BREACH` a must-fail (lines 44, 124). If that file counts as an earlier version of the same norms bundle, moving the rail out removes a failure class, which is a weakening (core object 7). Rule 5 would then require an expiry, after which the old policy returns, so a permanent move can't be expressed under rule 5. Under the gates in Draft0 and Draft7 it is rejected outright (Y1). Option 2 therefore commits you to one of:
  - (a) declaring `SIRUS/main.tex` outside the norms-bundle lineage, so nothing was removed (Y2); or
  - (b) adding a rule-5 exception for moving a class between layers. The guide has none, and I found none in the sources.
- **Corpus.** The known-defect row (line 284) is resolved by declaration rather than restoration, but only through (a) or (b). The Playbook's "governance rails that make moral good enforceable as technical gates" (line 103) would no longer describe the design.
- **Rows affected:** none change. The Norm row stays, and "Must-fail sets only grow" is untouched.

#### Other options

- **Split by rail.** `GOLDEN_RULE_BREACH` inside, since it's the only rail `SIRUS/main.tex` calls MUST-FAIL; consent brake, restoration debt and bravery declared outside.
- **Split by checkability.** The mechanism rails NO_PACK, NO_ENVLOCK and TAILCONTRACT_BREACH inside as must-fails; the ethical rails (Golden Rule, consent, restoration, bravery) declared outside.
- **Golden Rule as a graded floor axis.** Make the margin max(0, risk_in←out − ρ·risk_out←in) a floor axis with threshold 0, inside the grade lattice rather than a must-fail class. Draft1's "Golden–Rule margin" gauge hints at this.
- **Declared but grow-only.** The rails stay outside the verdict but form a set with its own grow-only rule, so removing one still needs a signed record.

---

## 3. Facts this brief could not establish

- Which file the guide's "main.tex" means (2.1).
- Whether the drafts' MF is meant to continue `SIRUS/main.tex`'s must-fail set (Y2).
- What SCp1's original ∧ was. SCp1's source text isn't in the archive (S4).
- Whether JSG V's stages emit increments or running totals (X3).
- Whether the PDE paper's Laxity Lemma is proved anywhere (P2).
