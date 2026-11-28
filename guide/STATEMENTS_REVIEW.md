# Statements review: mutants and witnesses

Review support before `statements-v1` is tagged. Nothing here changes a statement. Updated for the Q2, Q3 and Q4 restatements of `bridge`, the must-fail gate and the verdict. For each of the 16 theorems in `lean/JSG/Statements.lean`, it shows the Prop its mutant refutes in `lean/JSG/Tests/Mutants.lean`, next to the statement. The [statements-v2](#statements-v2), [statements-v3](#statements-v3), [statements-v4](#statements-v4), [statements-v5](#statements-v5) and [statements-v6](#statements-v6) sections at the end do the same for the seven, three, eight, four and one theorems those versions add. The section after them, [Gamers and the kill matrix](#gamers-and-the-kill-matrix-the-ordinal-core), tests the other direction for the ordinal core's ten theorems: definitions that satisfy them yet do what the corpus forbids, and which one-change mutants they kill. The last section, [Independent readings](#independent-readings-the-ordinal-core), reads the same ten statements twice more, once from the statement alone and once from its source alone, and records each difference as a lead.

**How to read it.**
- **Same Prop:** the mutant refutes the statement's own named definition with the mutant plugged in.
- **Restated copy:** a hand-written Prop with the statement's shape.
- **Fixtures:** every copy fixes the index type to `Unit` (one axis), and a counterexample there refutes the statement for every index type.
- **Context:** the statements use `variable {ι : Type} (kind : ι → Kind)`. Sections 4 and 5 add `{E : Type} [NormedAddCommGroup E]` and `{P : Type} [CompleteLattice P]`.

## Summary

| Theorem | The mutant refutes | What differs from the statement |
| --- | --- | --- |
| `combine_comm` | Restated copy | `combine kind` → `overwrite` |
| `combine_assoc` | Restated copy | `combine kind` → `avgCombine budget` |
| `interchange` | **Same Prop** (`Interchange`) | `seqComp kind` → `jsgVSeq`; `kind` → `budget` |
| `verdict_sound` | Restated copy, two mutants | `verdict` → `verdictLo`, or → `unknownOnly`, a gate that rejects only unknowns (replaces `verdict_unknown` after [Q4](QUEUE.md)) |
| `verdict_complete` | Restated copy | `verdict` → `alwaysReject` |
| `residual_spec` | Restated copy | `residual` → `residualFull` |
| `no_flip` | **Not refuted**: the conclusion fails only for a grader that breaks the hypothesis | `inflatingGrader` isn't `Noninterfering` (`noninterfering_mutant`, the same Prop) |
| `Loader.safe` | Restated copy **without the `Loader` structure** | A bare step relation with no `inv_step`; no `Loader` can fail the statement ([note](#note-loadersafe-and-loaderterminates-hold-for-any-loader)) |
| `Loader.terminates` | Restated copy **without the `Loader` structure** | A bare relation with no `progress`; `retry_breaks_progress` shows the retry can't be a `Loader` ([note](#note-loadersafe-and-loaderterminates-hold-for-any-loader)) |
| `charge_append` | Restated copy | `charge` → `chargeMerged`; `E` = ℝ |
| `charge_chatter` | Restated copy | `charge` → `chargeMerged`; `E` = ℝ |
| `expiry_tightens` | Restated copy, **different shape** | Lists and `Sublist` instead of sets and `⊆`; `revertRecent` for `effective`; `P` = Prop ([note](#note-why-expiry_tightens-is-tested-on-lists)) |
| `bridge` | Restated copy (`BridgeHolds`) | `threshold` → `id`, the un-inverted dial (restated over dials after [Q2](QUEUE.md)) |
| `fold_check_vacuous` | Restated copy | `fold` → `foldUncapped` |
| `mfGate_signed` | Restated copy (`SignedRemovals`), at the drafts' history | `mfGate` → `looseGate`, a gate that accepts every change (replaces `mfGate_monotone` after [Q3](QUEUE.md)) |
| `dwell_lower_bound` | Restated copy **with a different hypothesis** | JSG I's lemma: "speed at least α" replaces "speed at most `Smax`" |

The two definitions with Mutant lines, `Noninterfering` and `Calibrated`, are refuted on their own Props.

**What this means.**
- **11 theorems** have a mutant that plugs a wrong implementation into the claim: `interchange` through its own Prop, and 10 through faithful copies that swap one definition, map or gate.
- **`no_flip`** is proved by `rw` and holds for every grader that satisfies `Noninterfering`. Its mutant shows the hypothesis carries the weight; the real work is proving `Noninterfering` for each concrete grader, which is deferred.
- **`Loader.safe` and `Loader.terminates`** hold for every `Loader`; see the note below. A concrete Loader is still owed.
- **`expiry_tightens`'s mutant is list-based by necessity**; see the note below for why it tests the same claim.
- **`dwell_lower_bound`** has no definition to mutate, so its mutant is the wrong lemma, JSG I's.

### Note: why `expiry_tightens` is tested on lists

`expiry_tightens` is stated on sets, and `effective` ignores order. Its named mutant, "revert to the most recent policy", can't be stated on sets, because "most recent" needs an order that a set doesn't have. So `expiry_tightens_mutant` states the same claim for ordered active lists:

- **Expiry** is `List.Sublist`: entries are removed and the rest keep their order. A sublist's entries are a subset of the original's, so every expiry on lists is also an expiry on sets.
- **The conclusion** is the same comparison: the policy before expiry is at most as strict as the policy after.
- **For the real `effective`,** the set claim implies the list claim, applied to each list's set of entries. So the list claim asks nothing extra of `effective`; it only lets the effective-policy function read the order, which `revertRecent` needs. `revertRecent` fails it.

What the copy doesn't show is a set-level implementation failing `expiry_tightens` as stated. If you want that too, one candidate mutant is meeting the baseline with `sSup` of the active weakenings instead of `sInf`, so the strictest weakening wins. It fails with baseline True, active {True}, and expiry to ∅.

### Note: `Loader.safe` and `Loader.terminates` hold for any Loader

Both hold for every `Loader` by construction. Building one requires proving `inv_step` and `progress`, and the two theorems only lift those fields from one step to whole runs. Their mutants are step relations that can't be built as Loaders. So the theorems can't catch a wrong Loader; they can only catch a wrong idea of what a Loader must prove.

**A concrete Loader (L1–L10) is still owed.** When Milestone 2 proves these theorems, its milestone note must say so. [ROADMAP's Milestone 2](https://github.com/marleymcwilliams/LibSpec/blob/3b481d5e951bb30300195598e9dada5a753ab61c/guide/ROADMAP.md#phases-35-the-three-proof-milestones) now carries that reminder. `statements-v2` states one, `LoaderStep`, with its own two theorems; see [statements-v2](#statements-v2).

## Side by side

### 1. `combine_comm`: restated copy
```lean
-- Statement
theorem combine_comm (g h : Grade ι) : combine kind g h = combine kind h g
-- Mutant
theorem combine_comm_mutant : ¬ ∀ g h : Grade Unit, overwrite g h = overwrite h g
```

### 2. `combine_assoc`: restated copy
```lean
-- Statement
theorem combine_assoc (g h k : Grade ι) :
    combine kind (combine kind g h) k = combine kind g (combine kind h k)
-- Mutant
theorem combine_assoc_mutant :
    ¬ ∀ g h l : Grade Unit,
      avgCombine budget (avgCombine budget g h) l = avgCombine budget g (avgCombine budget h l)
```

### 3. `interchange`: same Prop
```lean
-- Statement
theorem interchange : Interchange (seqComp kind) (parComp kind)
-- Mutant
theorem interchange_mutant : ¬ Interchange jsgVSeq (parComp budget)
```

### 4. `verdict_sound`: restated copy, two mutants
```lean
-- Statement
theorem verdict_sound (θ : ι → ENNReal) (g : Grade ι) (i : ι)
    (hover : θ i < (g i).hi) : verdict θ g = .reject
-- Mutant: a verdict that reads lo
theorem verdict_sound_mutant :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit) (i : Unit),
      θ i < (g i).hi → verdictLo θ g = .reject
-- Mutant: a gate that rejects only unknowns
theorem verdict_sound_unknownOnly_mutant :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit) (i : Unit),
      θ i < (g i).hi → unknownOnly θ g = .reject
```

Before [Q4](QUEUE.md) this was `verdict_unknown`, which assumed `g i = Bound.unknown`. The unknown-only gate satisfied it, and it said nothing about [5, ∞] or about finite values over their threshold.

### 5. `verdict_complete`: restated copy
```lean
-- Statement
theorem verdict_complete (θ : ι → ENNReal) (g : Grade ι)
    (hk : ∀ i, (g i).lo = (g i).hi) (hin : ∀ i, (g i).lo ≤ θ i) :
    verdict θ g = .accept
-- Mutant
theorem verdict_complete_mutant :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit),
      (∀ i, (g i).lo = (g i).hi) → (∀ i, (g i).lo ≤ θ i) → alwaysReject θ g = .accept
```

### 6. `residual_spec`: restated copy
```lean
-- Statement
theorem residual_spec (θ x y : ENNReal) (hθ : θ ≠ ⊤) (hx : x ≤ θ) :
    y ≤ residual θ x ↔ x + y ≤ θ
-- Mutant
theorem residual_spec_mutant :
    ¬ ∀ θ x y : ENNReal, θ ≠ ⊤ → x ≤ θ → (y ≤ residualFull θ x ↔ x + y ≤ θ)
```

### 7. `no_flip`: not refuted; the hypothesis fails instead
```lean
-- Statement
theorem no_flip {E : Type} (θ : ι → ENNReal) (gradeOf : Evidence E → Grade ι)
    (hni : Noninterfering gradeOf) (r : E) (m m' : List (String × Float)) :
    verdict θ (gradeOf ⟨r, m⟩) = verdict θ (gradeOf ⟨r, m'⟩)
-- Mutant: the conclusion fails for a grader...
theorem no_flip_mutant :
    verdict (fun _ => 0) (inflatingGrader ⟨(), []⟩)
      ≠ verdict (fun _ => 0) (inflatingGrader ⟨(), [("confidence", 0.99)]⟩)
-- ...that doesn't meet the hypothesis (same Prop)
theorem noninterfering_mutant : ¬ Noninterfering inflatingGrader
```

### 8. `Loader.safe`: restated copy without the `Loader` structure
```lean
-- Statement
theorem Loader.safe {S O : Type} [Preorder O] (L : Loader S O) {s t : S}
    (hs : L.Inv s) (hr : Relation.ReflTransGen L.step s t) : L.Inv t
-- Mutant: a bare step relation and invariant, with no inv_step
theorem loader_safe_mutant :
    ¬ ∀ s t, skipInv s → Relation.ReflTransGen skipStep s t → skipInv t
```

### 9. `Loader.terminates`: restated copy without the `Loader` structure
```lean
-- Statement
theorem Loader.terminates {S O : Type} [Preorder O] [WellFoundedLT O]
    (L : Loader S O) : WellFounded (fun t s => L.step s t)
-- Mutant: a bare relation, with no progress...
theorem loader_terminates_mutant : ¬ WellFounded (fun t s => retryStep s t)
-- ...and it can't be a Loader: the Dershowitz–Manna order is irreflexive
theorem retry_breaks_progress : ¬ Multiset.IsDershowitzMannaLT ({0} : Multiset ℕ) {0}
```

### 10. `charge_append`: restated copy
```lean
-- Statement
theorem charge_append (A : ENNReal) (j₁ j₂ : List E) :
    charge A (j₁ ++ j₂) = charge A j₁ + charge A j₂
-- Mutant
theorem charge_append_mutant :
    ¬ ∀ (A : ENNReal) (j₁ j₂ : List ℝ),
      chargeMerged A (j₁ ++ j₂) = chargeMerged A j₁ + chargeMerged A j₂
```

### 11. `charge_chatter`: restated copy
```lean
-- Statement
theorem charge_chatter (A : ENNReal) (v : E) :
    charge A [v, -v] = 2 * A * (‖v‖₊ : ENNReal)
-- Mutant
theorem charge_chatter_mutant :
    ¬ ∀ (A : ENNReal) (v : ℝ), chargeMerged A [v, -v] = 2 * A * (‖v‖₊ : ENNReal)
```

### 12. `expiry_tightens`: restated copy, different shape
```lean
-- Statement
theorem expiry_tightens (B : P) {a a' : Set P} (h : a' ⊆ a) :
    effective B a ≤ effective B a'
-- Mutant: lists, newest first, because "most recent" needs an order
theorem expiry_tightens_mutant :
    ¬ ∀ (B : Prop) (a a' : List Prop), a'.Sublist a → revertRecent B a ≤ revertRecent B a'
```

### 13. `bridge`: restated copy with the map swapped
```lean
-- Statement
theorem bridge {Inp : Type} (gradeOf : Inp → Grade ι) {dial₁ dial₂ : ι → ENNReal}
    (h : dial₁ ≤ dial₂) :
    {x | verdict (threshold dial₂) (gradeOf x) = .accept}
      ⊆ {x | verdict (threshold dial₁) (gradeOf x) = .accept}
-- The claim with the map as a parameter
def BridgeHolds (thresholdOf : (Unit → ENNReal) → Unit → ENNReal) : Prop :=
  ∀ (gradeOf : Unit → Grade Unit) (dial₁ dial₂ : Unit → ENNReal), dial₁ ≤ dial₂ →
    {x | verdict (thresholdOf dial₂) (gradeOf x) = .accept}
      ⊆ {x | verdict (thresholdOf dial₁) (gradeOf x) = .accept}
-- Mutant: the un-inverted dial
theorem bridge_mutant : ¬ BridgeHolds id
```

### 14. `fold_check_vacuous`: restated copy
```lean
-- Statement
theorem fold_check_vacuous (Rmax lam : ℝ) (h : 0 ≤ Rmax) (rs : List ℝ) :
    fold Rmax lam rs ≤ Rmax
-- Mutant
theorem fold_check_vacuous_mutant :
    ¬ ∀ (Rmax lam : ℝ), 0 ≤ Rmax → ∀ rs : List ℝ, foldUncapped Rmax lam rs ≤ Rmax
```

### 15. `mfGate_signed`: restated copy with the gate swapped
```lean
-- Statement
theorem mfGate_signed {C : Type} (signed : Set C → Prop) (MF : ℕ → Set C)
    (hg : ∀ t, mfGate signed (MF t) (MF (t + 1))) {s t : ℕ} (hst : s ≤ t) {c : C}
    (hs : c ∈ MF s) (ht : c ∉ MF t) :
    ∃ u, s ≤ u ∧ u < t ∧ c ∈ MF u \ MF (u + 1) ∧ signed (MF u \ MF (u + 1))
-- The claim with the gate as a parameter, for histories of FailClass
def SignedRemovals (gate : (Set FailClass → Prop) → Set FailClass → Set FailClass → Prop)
    (signed : Set FailClass → Prop) (MF : ℕ → Set FailClass) : Prop :=
  (∀ t, gate signed (MF t) (MF (t + 1))) → ∀ {s t : ℕ}, s ≤ t → ∀ {c : FailClass},
    c ∈ MF s → c ∉ MF t →
      ∃ u, s ≤ u ∧ u < t ∧ c ∈ MF u \ MF (u + 1) ∧ signed (MF u \ MF (u + 1))
-- Mutant: a gate that accepts every change, on the drafts' history
theorem mfGate_signed_mutant : ¬ SignedRemovals looseGate nothingSigned draftHistory
```

The old `mfGate_monotone` controls stay as tests of the real gate: `mfGate_rejects_draft_history` and `mfGate_accepts_kept_history`.

### 16. `dwell_lower_bound`: restated copy with a different hypothesis
```lean
-- Statement
theorem dwell_lower_bound {d : ℝ → ℝ} {Smax r t₁ t₂ : ℝ} (hS : 0 < Smax)
    (hlip : ∀ s t, |d t - d s| ≤ Smax * |t - s|)
    (h₁ : d t₁ = r) (h₂ : d t₂ = -r) (ht : t₁ ≤ t₂) :
    2 * r / Smax ≤ t₂ - t₁
-- Mutant: JSG I's lemma, with a lower bound on speed in place of hlip
theorem dwell_lower_bound_mutant :
    ¬ ∀ (d : ℝ → ℝ) (α r t₁ t₂ : ℝ), 0 < α → (∀ s t, α * |t - s| ≤ |d t - d s|) →
      d t₁ = r → d t₂ = -r → t₁ ≤ t₂ → 2 * r / α ≤ t₂ - t₁
```

## Witnesses: hypotheses as well as conclusions

Nine witnesses proved only their conclusion, or skipped some hypotheses. [#11](https://github.com/marleymcwilliams/LibSpec/pull/11) makes each prove a conjunction for the same concrete instance: every hypothesis of its theorem, in the statement's order, then the conclusion.

| Theorem | Hypotheses | Before | After #11 |
| --- | --- | --- | --- |
| `verdict_sound` | `hover` | new after Q4 | all proved: [5, ∞] under θ = 10, a grade `verdict_unknown` didn't cover |
| `verdict_complete` | `hk`, `hin` | conclusion only | all proved |
| `residual_spec` | `hθ`, `hx` | conclusion only | all proved |
| `no_flip` | `hni` | proved in a separate theorem | proved together |
| `Loader.safe` | `hs`, `hr` | assumed, for every pair of states | a concrete pair (3 down to 1) |
| `expiry_tightens` | `h : a' ⊆ a` | conclusion only | all proved |
| `bridge` | `h : dial₁ ≤ dial₂` (was `θ₂ ≤ θ₁`) | conclusion only | all proved, with the real `threshold` |
| `fold_check_vacuous` | `h : 0 ≤ Rmax` | conclusion only | all proved |
| `dwell_lower_bound` | `hS`, `hlip`, `h₁`, `h₂`, `ht` | missed `hS` and `ht` | all proved |
| `mfGate_signed` | `hg`, `hst`, `hs`, `ht` | new after Q3 | all proved: the drafts' history with its removal signed |

The remaining witnesses already covered everything:
- `combine_comm`, `combine_assoc`, `interchange`, `charge_append` and `charge_chatter` have no hypotheses.
- `Loader.terminates` has only typeclass instances, which Lean finds for ℕ.
- `mfGate_monotone`'s witness already proved `hg` and `hs`; it stays as `mfGate_accepts_kept_history`.

## statements-v2

Review support for the `statements-v2` proposal, read the same way as above. The seven theorems are in sections 8–11 of `lean/JSG/Statements.lean`, their definitions in the same sections of `lean/JSG/Defs.lean`, and their controls in the "statements-v2" part of `lean/JSG/Tests/Mutants.lean`. Every mutant comes from a defect in `archive/` with two exceptions: `lease_sound`'s second mutant, a widths-only gate, and `threads_spec`'s, which comes from v1's own `residual`.

**Context.** Besides `variable {ι : Type} (kind : ι → Kind)`, section 9 adds `{St O W : Type}`: stages, obligations and witnesses. Section 10 adds `{Bytes D : Type}`: bytes and digests.

**Tickets.** What a window has pending is a `Pending St O`: a stage's ticket or an obligation.
- **Where tickets come from:** a window starts with one ticket per stage (`windowStart`), issued at boot (`bootState`).
- **Clearing:** a stage clears its own ticket when it runs, along with the obligations it discharges (`DischargeMatrix.Clears`).
- **Order:** tickets rank above every obligation (`Pending.rank`).
- **Consequences:** a window passes only once every stage has run. `LoaderStep` runs a stage only while its ticket is pending, so each stage runs once and every step lowers what is pending. Without tickets, a stage with nothing pending to discharge couldn't step at all. That included every window's first stage, because a JSG V window starts with Σ empty.

**Fixtures.** The v2 controls use one axis (`Unit`), and stages, obligations and witnesses as follows:
- **Stages:** `Stg`, two of JSG V's stages (EF and PR), where stages matter, and otherwise `Unit`. The window `efPr` has EF and PR as its stages.
- **Obligations:** `Unit`, or ℕ where their order matters. ℕ's order stands in for JSG V's type order, with RequiresHitmap as 1 and OmegaPrecond, which ranks above it, as 2.
- **Loader primitives:** the digest is the identity, every signature verifies, replay returns the probe, and a bundle's root is its length.

| Theorem | The mutant refutes | What differs from the statement | The defect it comes from |
| --- | --- | --- | --- |
| `lease_sound` | Restated copy, two mutants | `leaseVerdict` → `qPrimeGate`, the plain verdict, which reads `hi` only; or → `widthsOnly`, which reads widths only | SirusSC `specchain/algebra/q_prime.py`: `QPrime`'s only guard is `guard_no_bottom`. The second is PDE I4b's unknowns cap, run on its own |
| `lease_complete` | Restated copy | `leaseVerdict` → `pointsOnly`, which accepts points only | SirusSC `specchain/algebra/q.py`, where ⊥ absorbs, and `loader.py`'s guards, which reject it (`C_UNK_PRICED`) |
| `pass_sound` | Restated copy (`PassSoundHolds`) | `afterStage` → `afterListed`, which clears tickets the same way but obligations by their witness alone | JSG V §3: the displayed stage transition, and the matrix row that lists PR or EF for RetuneDisabledInRed |
| `pass_complete` | Restated copy (`PassCompleteHolds`) | `Passes` → `Passes ∧ ISigma`, with I_Σ read on the obligations alone | JSG V §3: Invariant I_Σ-Progress, which its CI check runs on passing runs |
| `LoaderStep.inv_step` | Restated copy, two mutants | `LoaderStep` → `TRowStep`, without `hiso` and `hround`; or → `SirusIsoStep`, with `hiso` waived for a stage missing from the table | SCp3 §6.3, rule T-Row; SirusSC `loader.py`, `_resolve_allowed_axes` and `_detect_axis_leaks` |
| `LoaderStep.progress` | Restated copy, two mutants | `LoaderStep` → `OrStep`, with JSG V's progress condition in place of `hticket`; or → `LoaderStep` plus a step from every state to itself | JSG V §3, Lemma (Progress via multiset ordering); SCp3 §6.3, rules T-AdapterAttest, T-AxisIsolation, T-AdapterMono and T-Attest |
| `threads_spec` | Restated copy | `Threads` → `ResidualOnly`, which checks only the last stage's fit | `statements-v1`'s `residual`, used without `residual_spec`'s `hx` (QUEUE.md, Q5) |

**What this means.**
- **No v1 statement or definition changes.** Each v2 theorem is new, and so is every definition it uses.
- **`lease_sound` and `lease_complete` test both halves of `leaseVerdict`.** A gate that checks only widths satisfies `lease_complete` but fails `lease_sound` on [5, 5] under θ = 1. A gate that checks only thresholds fails `lease_sound` on [0, 5] leased 1.
- **`LoaderStep.inv_step` and `LoaderStep.progress` are the two fields a `Loader` needs.** Once both are proved, `LoaderStep kind prims M`, with `LoaderInv kind prims` as its invariant and each state's `pending` as what it has pending, is a `Loader`, and `Loader.safe` and `Loader.terminates` apply to it. Unlike those two, these theorems can fail: each mutant is a step relation that breaks one.
- **The Loader runs a window.** `loader_runs_window` runs EF and then PR from T-Boot's state, and the window passes. `empty_run_fails` is its must-fail control: from the same state, a run with no stages leaves both tickets pending.
- **`pass_sound` and `pass_complete` are a pair, like `verdict_sound` and `verdict_complete`.** A transition that never clears anything satisfies `pass_sound`; `pass_complete` rules it out.

### 17. `lease_sound`: restated copy, two mutants
```lean
-- Statement
theorem lease_sound (θ β : ι → ENNReal) (g : Grade ι) (i : ι)
    (hout : θ i < (g i).hi ∨ β i < (g i).width) : leaseVerdict θ β g = .reject
-- Mutant: SirusSC's QPrime, which never reads a width
theorem lease_sound_mutant :
    ¬ ∀ (θ β : Unit → ENNReal) (g : Grade Unit) (i : Unit),
      θ i < (g i).hi ∨ β i < (g i).width → qPrimeGate θ β g = .reject
-- Mutant: a gate that reads widths only
theorem lease_sound_widthsOnly_mutant :
    ¬ ∀ (θ β : Unit → ENNReal) (g : Grade Unit) (i : Unit),
      θ i < (g i).hi ∨ β i < (g i).width → widthsOnly θ β g = .reject
```

### 18. `lease_complete`: restated copy
```lean
-- Statement
theorem lease_complete (θ β : ι → ENNReal) (g : Grade ι) (hlease : WithinLease β g)
    (hin : ∀ i, (g i).hi ≤ θ i) : leaseVerdict θ β g = .accept
-- Mutant: SirusSC's Q, where a reading wider than a point can only be ⊥
theorem lease_complete_mutant :
    ¬ ∀ (θ β : Unit → ENNReal) (g : Grade Unit), WithinLease β g →
      (∀ i, (g i).hi ≤ θ i) → pointsOnly θ β g = .accept
```

### 19. `pass_sound`: restated copy
```lean
-- Statement
theorem pass_sound (θ β : ι → ENNReal) (M : DischargeMatrix St O W) (stages : Multiset St)
    (carried : Multiset O) (pre post : List (StageRun ι St O W)) (r : StageRun ι St O W)
    (hpass : Passes kind θ β M stages carried (pre ++ r :: post)) {p : Pending St O}
    (hp : p ∈ pendingAfter M (windowStart stages carried) pre + r.emits.map Pending.obl) :
    ∃ s ∈ r :: post, M.Clears s p
-- The claim at the fixtures, with the stage transition as a parameter
def PassSoundHolds (M : DischargeMatrix Stg Unit Bool)
    (after : Multiset (Pending Stg Unit) → StageRun Unit Stg Unit Bool →
      Multiset (Pending Stg Unit)) : Prop :=
  ∀ (θ β : Unit → ENNReal) (stages : Multiset Stg) (carried : Multiset Unit)
    (pre post : List (StageRun Unit Stg Unit Bool)) (r : StageRun Unit Stg Unit Bool),
    leaseVerdict θ β (windowGrade budget (pre ++ r :: post)) = .accept →
    (pre ++ r :: post).foldl after (windowStart stages carried) = 0 →
    ∀ p ∈ pre.foldl after (windowStart stages carried) + r.emits.map Pending.obl,
      ∃ s ∈ r :: post, M.Clears s p
-- Mutant: JSG V's displayed transition, which checks only the witness
theorem pass_sound_mutant : ¬ PassSoundHolds retuneRed (afterListed retuneRed)
```

`PassSoundHolds M (afterStage M)` is `pass_sound` at these fixtures. `Passes` unfolds to the grade check and `pendingAfter`, the fold of `afterStage`, from `windowStart`. In the counterexample, EF emits RetuneDisabledInRed while Red, and PR later produces the witness. The mutant lets PR discharge it, so the window passes, though EF, its only authority, never discharges it.

### 20. `pass_complete`: restated copy
```lean
-- Statement
theorem pass_complete (θ β : ι → ENNReal) (M : DischargeMatrix St O W) (stages : Multiset St)
    (carried : Multiset O) (pre : List (StageRun ι St O W)) (r : StageRun ι St O W)
    (hgrade : leaseVerdict θ β (windowGrade kind (pre ++ [r])) = .accept)
    (hlast : ∀ p ∈ pendingAfter M (windowStart stages carried) pre + r.emits.map Pending.obl,
      M.Clears r p) :
    Passes kind θ β M stages carried (pre ++ [r])
-- The claim at the fixtures, with the pass condition as a parameter
def PassCompleteHolds (passes : (Unit → ENNReal) → (Unit → ENNReal) →
    DischargeMatrix Unit ℕ Unit → Multiset Unit → Multiset ℕ →
      List (StageRun Unit Unit ℕ Unit) → Prop) : Prop :=
  ∀ θ β M stages carried (pre : List (StageRun Unit Unit ℕ Unit)) r,
    leaseVerdict θ β (windowGrade budget (pre ++ [r])) = .accept →
    (∀ p ∈ pendingAfter M (windowStart stages carried) pre + r.emits.map Pending.obl,
      M.Clears r p) →
    passes θ β M stages carried (pre ++ [r])
-- Mutant: passing also requires JSG V's I_Σ, on the obligations alone
theorem pass_complete_mutant :
    ¬ PassCompleteHolds (fun θ β M stages carried run =>
      Passes budget θ β M stages carried run ∧ ISigma M stages carried run)
```

The counterexample is one idle stage, whose window starts with only its ticket. The stage clears the ticket, so the window passes. But I_Σ, read on JSG V's Σ, asks the empty multiset of obligations to fall, and nothing is below it.

### 21. `LoaderStep.inv_step`: restated copy, two mutants
```lean
-- Statement
theorem LoaderStep.inv_step (prims : Prims Bytes D) (M : DischargeMatrix St O W)
    (s t : LoaderState ι St O Bytes D) (hs : LoaderInv kind prims s)
    (h : LoaderStep kind prims M s t) : LoaderInv kind prims t
-- Mutant: SCp3's T-Row, LoaderStep without hiso and hround
theorem loader_inv_step_mutant :
    ¬ ∀ s t, LoaderInv budget toyPrims s → TRowStep anyStage s t → LoaderInv budget toyPrims t
-- Mutant: SirusSC's axis-leak check, hiso waived for a stage missing from the table
theorem loader_inv_step_sirus_mutant :
    ¬ ∀ s t, LoaderInv budget toyPrims s → SirusIsoStep anyStage s t →
      LoaderInv budget toyPrims t
```

`TRowStep` and `SirusIsoStep` copy `LoaderStep`'s rule and change only the premises named. Under T-Row, a row that adds round-off 5 against a cap of 1 is accepted, and L8 fails afterwards. SCp3 leaves I8 to T-Accept, so its invariant holds when the run accepts, not after every step.

### 22. `LoaderStep.progress`: restated copy, two mutants
```lean
-- Statement
theorem LoaderStep.progress [Preorder O] (prims : Prims Bytes D) (M : DischargeMatrix St O W)
    (s t : LoaderState ι St O Bytes D) (h : LoaderStep kind prims M s t) :
    Multiset.IsDershowitzMannaLT t.pending s.pending
-- Mutant: JSG V's progress lemma in place of the ticket
theorem loader_progress_mutant :
    ¬ ∀ s t, OrStep hitmapOnly s t → Multiset.IsDershowitzMannaLT t.pending s.pending
-- Mutant: SCp3's check rules, each a step from a state to itself
theorem loader_progress_selfloop_mutant :
    ¬ ∀ s t, (LoaderStep budget toyPrims anyStage s t ∨ t = s) →
      Multiset.IsDershowitzMannaLT t.pending s.pending
```

Under JSG V's "or", with no ticket pending, a stage that discharges RequiresHitmap and emits OmegaPrecond qualifies, and what is pending goes from {1} to {2}. A self-loop leaves it where it was. The Dershowitz–Manna order allows neither. With the ticket, every emitted obligation ranks below the ticket the stage clears.

### 23. `threads_spec`: restated copy
```lean
-- Statement
theorem threads_spec (θ : ENNReal) (hθ : θ ≠ ⊤) (xs : List ENNReal) :
    Threads θ xs ↔ xs.sum ≤ θ
-- Mutant: v1's residual check alone
theorem threads_spec_mutant :
    ¬ ∀ θ : ENNReal, θ ≠ ⊤ → ∀ xs : List ENNReal, (ResidualOnly θ xs ↔ xs.sum ≤ θ)
```

### The Loader runs a window
```lean
-- Witness: from T-Boot's state, EF and then PR, and the window passes
theorem loader_runs_window :
    ∃ s₁ s₂, LoaderStep budget toyPrims hitmap (bootState toyPrims efPrBoot (0 : Multiset Unit)) s₁
      ∧ LoaderStep budget toyPrims hitmap s₁ s₂
      ∧ s₂.pending = 0 ∧ LoaderInv budget toyPrims s₂
      ∧ Passes budget (fun _ => 0) (fun _ => 0) hitmap efPrBoot.stages 0 [efEmits, prRuns]
-- Must-fail: from the same state, a run with no stages
theorem empty_run_fails :
    ¬ Passes budget (fun _ => 0) (fun _ => 0) hitmap efPrBoot.stages 0 []
```

EF emits RequiresHitmap and clears only its ticket. That's the step v2's first draft couldn't take, since its `LoaderStep` required every stage to discharge a pending obligation. PR then clears its ticket and discharges RequiresHitmap. This is the run `pass_sound`'s witness uses, now through the Loader.

### Witnesses

Each witness proves every hypothesis of its theorem, then the conclusion, for one concrete instance.

| Theorem | Hypotheses | Instance |
| --- | --- | --- |
| `lease_sound` | `hout` | [0, 5] with lease 1, under θ = 10, which is wider than its lease; and [5, 5] with lease 0, under θ = 1, which is over its threshold |
| `lease_complete` | `hlease`, `hin` | [0, 1] with lease 1, under θ = 1 |
| `pass_sound` | `hpass`, `hp` | a window of EF and PR: EF emits RequiresHitmap, and PR discharges it; the run split at EF |
| `pass_complete` | `hgrade`, `hlast` | the same run, with PR as the last stage |
| `LoaderStep.inv_step` | `hs`, `h` | from T-Boot's state, one stage prices a row and clears its ticket; the invariant is proved after the step too |
| `LoaderStep.progress` | `h` | from T-Boot's state with OmegaPrecond carried in, a stage clears its ticket and replaces OmegaPrecond by RequiresHitmap |
| `threads_spec` | `hθ` | θ = 10 with stages 3 then 4, where both sides hold; θ = 1 with stages 2 then 0, where neither does |

## statements-v3

Review support for the `statements-v3` proposal, read the same way as above. Its three theorems are in sections 12–14 of `lean/JSG/Statements.lean`, their definitions in the same sections of `lean/JSG/Defs.lean`, and their controls in the "statements-v3" part of `lean/JSG/Tests/Mutants.lean`. Every mutant comes from a defect in `archive/`.

**Scope** ([Q8](QUEUE.md)). Milestone 3 is the analysis layer. `dwell_lower_bound` is already frozen in `statements-v1`, so v3 adds the other three: the CVaR tail-to-level step, the local KL–Fisher bound and the DRO envelope identity. The geometry-scaled Jacobi frontier defect is left out. JSG I never defines its defect Δ\_fr, and its bound adds ‖S‖∞ to ‖∇S‖∞, which have different units.

**Context.**
- **Section 12** adds `{Ω : Type} [MeasurableSpace Ω]`, the outcomes.
- **Section 13** adds `{V : Type}`, a real Hilbert space for the dictionary's statistics and the natural parameters. Its inner product is the Fisher metric at 0, so the coordinates are whitened ([Q9](QUEUE.md)).
- **Opens:** both files open `MeasureTheory`, and `Statements.lean` also opens `InformationTheory`, for `klDiv`.

**Fixtures.**
- **CVaR:** a point mass on `Unit`, and `Bool` with masses 1/4 and 3/4.
- **KL–Fisher:** a fair coin on `Bool` with the statistic ±c. Its log-partition function is log cosh(cx), its cumulant c·tanh(cx) and its Fisher information c²/cosh²(cx). The controls derive all three, and the coin's KL divergences, from the definitions.
- **DRO:** a Gaussian loss of variance 2, through Mathlib's `gaussianReal 0 2` and `mgf_id_gaussianReal`. Its KL dual's g(η) = η log E[e^{ℓ/η}] is 1/η.

| Theorem | The mutant refutes | What differs from the statement | The defect it comes from |
| --- | --- | --- | --- |
| `cvar_tail_to_level` | Restated copy | `{ω \| ε < X ω}` → `{ω \| ε ≤ X ω}`; Ω = `Unit` | PDE Lemma 9.1's conclusion, E < ε\_CKN outside the tail, with every constant at 1 |
| `kl_fisher_local` | Restated copy (`KLFisherRaw`), at the fair coin | `‖H x - 1‖` → `‖H x - H 0‖`, and `‖κ θ‖ ^ 2` → `κ θ ^ 2 / H 0 1`: the Fisher information at 0 needn't be the identity | jsg-lab's `FisherContext` (`stats/fisher.py`): r = ε/L\_ψ, with L\_ψ the raw features' largest third absolute moment |
| `dro_envelope` | Restated copy (`TiltEnvelope`) | `η * ρ + g η` → `ρ / η + k η`: η read as the tilt | JSG II's KL dual, whose η is both the multiplier (ηρ) and the tilt (e^{ηℓ}) |

**What this means.**
- **No `statements-v1` or `statements-v2` statement or definition changes.** Each v3 theorem is new, and so is every definition it uses.
- **Each source claim needed correcting, and the corrected forms are true.** All three are proved in an uncommitted scratch file ([Provability check](#provability-check-v3)).
- **Where a source's statement was false, it became the mutant.** Where only its argument was wrong, the section below says so.

### 24. `cvar_tail_to_level`: restated copy
```lean
-- Statement
theorem cvar_tail_to_level (μ : Measure Ω) (α : ENNReal) {X : Ω → ENNReal}
    (hX : AEMeasurable X μ) {ε : ENNReal} (h : cvar μ α X ≤ ε) :
    μ {ω | ε < X ω} ≤ α
-- Mutant: PDE Lemma 9.1's conclusion, with every constant at 1
theorem cvar_tail_to_level_mutant :
    ¬ ∀ (μ : Measure Unit) (α : ENNReal) (X : Unit → ENNReal), AEMeasurable X μ →
      ∀ ε, cvar μ α X ≤ ε → μ {ω | ε ≤ X ω} ≤ α
```

**Source.** `archive/DissipativePDEs.pdf`, §9.2: Lemma 9.1 (CVaR→CKN constant) and the note "Why C₀ = 1 is universal"; §9.3, Step 1.

**What the source gets wrong, and the correction.**
- **The note's argument is too weak.** It says μ{X > τ} > α implies CVaR₁₋α(X) ≥ τ, and concludes that CVaR ≤ ε forces μ{X > ε} ≤ α. But the contrapositive of what it says covers only CVaR < ε. The conclusion is still true, because μ{X > τ} > α in fact forces CVaR > τ. By continuity from below, some level s > τ still has μ{X > s} > α, and then every level t gives t + E[(X − t)₊]/α ≥ s. That's the proof.
- **Lemma 9.1's conclusion is strict.** It says every cell outside the tail has E\_rk < ε\_CKN, but Step 1 gives only E\_rk ≤ ε. With every constant at 1, the strict form fails for a loss equal to ε everywhere. That's the mutant.
- **The quantifier is misplaced.** "For every grid cell k, CVaR₁₋α E\_rk ≤ ε" takes the CVaR of a single number. §9.4's checklist shows the CVaR is over the grid's cells, of k ↦ E\_rk, which is what Ω and X are here.
- **"Aggregate measure ≥ 1 − α"** needs the total mass to be 1. The theorem bounds the tail instead, so it needs no mass.

**Mathlib** (Loogle, then `#check`ed against the pin): no CVaR, VaR or quantile. The proof uses Markov's inequality (`mul_meas_ge_le_lintegral₀`) and continuity from below (`tendsto_measure_iUnion_atTop`).

**Definition.** `cvar μ α X` is Rockafellar and Uryasev's infimum, over levels t in [0, ∞], of t + E[(X − t)₊]/α, in ENNReal. When α ≤ 1, a level below 0 does no better than 0, so for a nonnegative loss this is the usual CVaR.

**Hypotheses.**
- **`hX`, a.e.-measurability.** Without it the lower integral can't see the tail. Take Bool with the trivial σ-algebra, where only ∅ and Bool are measurable. Let μ be the point mass at `true`, X = 2 on `true` and 0 on `false`, α = 1/2 and ε = 1. Every measurable function is constant, so the lower integral of (X − t)₊ is 0 and the CVaR is 0. But μ{X > 1} = μ{true} = 1.
- **None on μ or α.** It holds for every measure and every α in [0, ∞]. For α = 0 the CVaR is X's essential supremum.

### 25. `kl_fisher_local`: restated copy, at the fair coin
```lean
-- Statement
theorem kl_fisher_local (μ : Measure Ω) [IsProbabilityMeasure μ] (T : Ω → V)
    (κ : V → V) (H : V → V →L[ℝ] V) {L ε : ℝ} {θ : V}
    (hgrad : ∀ x ∈ segment ℝ 0 θ, HasGradientAt (logPartition μ T) (κ x) x)
    (hhess : ∀ x ∈ segment ℝ 0 θ, HasFDerivAt κ (H x) x)
    (hcenter : κ 0 = 0)
    (hlip : ∀ x ∈ segment ℝ 0 θ, ‖H x - 1‖ ≤ L * ‖x‖)
    (hint : θ ∈ interior {x | Integrable (fun ω => Real.exp (inner ℝ x (T ω))) μ})
    (hr : L * ‖θ‖ ≤ ε) (hε : ε ≤ 1) :
    ENNReal.ofReal ((1 - ε) / 2 * ‖κ θ‖ ^ 2) ≤ klDiv (expFamily μ T θ) μ ∧
      klDiv (expFamily μ T θ) μ ≤ ENNReal.ofReal ((1 + ε) / 2 * ‖κ θ‖ ^ 2)
-- The claim in raw coordinates, at the fair coin
def KLFisherRaw : Prop :=
  ∀ (T : Bool → ℝ) (κ : ℝ → ℝ) (H : ℝ → ℝ →L[ℝ] ℝ) (L ε θ : ℝ),
    (∀ x ∈ segment ℝ 0 θ, HasGradientAt (logPartition coin T) (κ x) x) →
    (∀ x ∈ segment ℝ 0 θ, HasFDerivAt κ (H x) x) → κ 0 = 0 →
    (∀ x ∈ segment ℝ 0 θ, ‖H x - H 0‖ ≤ L * ‖x‖) →
    θ ∈ interior {x | Integrable (fun ω => Real.exp (inner ℝ x (T ω))) coin} →
    L * ‖θ‖ ≤ ε → ε ≤ 1 →
    ENNReal.ofReal ((1 - ε) / 2 * (κ θ ^ 2 / H 0 1)) ≤ klDiv (expFamily coin T θ) coin ∧
      klDiv (expFamily coin T θ) coin ≤ ENNReal.ofReal ((1 + ε) / 2 * (κ θ ^ 2 / H 0 1))
-- Mutant: jsg-lab's raw-coordinate radius
theorem kl_fisher_local_mutant : ¬ KLFisherRaw
```

With `H 0 = 1`, `KLFisherRaw` is `kl_fisher_local` at the coin, `κ θ ^ 2 / 1` standing for `‖κ θ‖ ^ 2`.

**Source.** `archive/Buckshot_Roulette/JSGI.tex`: the setup (line 1063), Theorem 2, "FIM-invariant local equivalence" (`thm:FIMbound`, lines 1069–1081), and the remark "Tight constants" (`rem:constants`, lines 1095–1097). The code is `archive/Reach/jsg-lab/src/jsg/stats/fisher.py`.

**What the source gets wrong or leaves vague, and the correction.**
- **Which norms?** The theorem writes ‖κ‖\_{F⁻¹} but never says which norm ‖θ‖ ≤ r and the Hessian-Lipschitz constant use. In raw coordinates it's false; that's the mutant. The paper means Fisher norms:
  - its setup's dictionary is "whitened" (line 1063);
  - JSG II's `estimate_Lpsi` takes a whitening, `F_whiten`;
  - JSG I says "All norms are Fisher-induced (Theorem 2) unless noted" (line 2243).

  So the statement is in whitened coordinates: V's inner product is the Fisher metric at 0, F is the identity, and ‖κ‖\_{F⁻¹} is ‖κ‖. That loses nothing, since any F ≻ 0 whitens by the change of variables T ↦ F^{−1/2}T.
- **Less than Hessian-Lipschitz is needed.** The proof uses only ‖H(x) − F‖ ≤ L‖x‖ along the segment from 0 to θ, not a Lipschitz bound on a neighborhood. That's a weaker hypothesis, so the theorem is stronger.
- **ε = 1 is allowed.** The source has 0 < ε < 1; the statement allows any ε ≤ 1.
- **"Sharp to first order in ε" is wrong.** Along a ray where ψ'' falls linearly at rate L, KL/(½‖κ‖²) = 1 + δ/3 + O(δ²), with δ = L‖θ‖. So to first order the bound's slack is ε/3, not ε. For quadratic ψ the ratio is exactly 1, so no ε is needed at all, and "optimal for quadratic ψ" has nothing to be optimal about. Neither remark is part of the theorem.
- **The theorem itself is true,** for every ε ≤ 1. It's proved below.

**Mathlib** (Loogle, then `#check`ed against the pin):
- **Present:** the KL divergence (`InformationTheory.klDiv`, `klDiv_of_ac_of_integrable`), log-likelihood ratios of tilted measures (`llr_tilted_left`, `llr_self`), tilted measures (`Measure.tilted`, `isProbabilityMeasure_tilted`), the one-dimensional cumulant generating function (`cgf`, `integrableExpSet`, `integral_tilted_mul_self`, `memLp_tilted_mul`), gradients (`HasGradientAt`), Cauchy's mean value theorem (`exists_ratio_hasDerivAt_eq_ratio_slope`) and the mean value inequality (`norm_image_sub_le_of_norm_deriv_le_segment'`).
- **Absent:** Fisher information, a multivariate cgf, and differentiating ∫ exp⟪θ, T⟫ in θ beyond one dimension. The proof needs none of them: along the ray t ↦ tθ, ψ is the one-dimensional cgf of ⟪θ, T⟫.

**Definitions.**
- `expFamily μ T θ` is P\_θ: μ tilted by ⟪θ, T⟫, which is Mathlib's `Measure.tilted`.
- `logPartition μ T θ` is ψ(θ) = log E\_μ[exp⟪θ, T⟫].
- The cumulants κ and the Fisher information H aren't definitions. The statement takes them as functions and pins them down by `hgrad` and `hhess`, so κ = ∇ψ, as the source writes κ\_mix = ∇ψ ([Q9](QUEUE.md)).

**Hypotheses.** The counterexamples use the fair coin with statistic ±1. At θ = log 2 its KL divergence is (3/5) log 2 − log(5/4) ≈ 0.193, and ½κ² = ½(3/5)² = 0.18.
- **`hgrad`, κ is ψ's gradient.** Without it, κ(x) = x with H = 1, L = 0 and ε = 0 meets the rest, and the bound would make the KL divergence ½θ² ≈ 0.240.
- **`hhess`, H is κ's derivative.** Without it, H = 1, L = 0 and ε = 0 with the coin's true κ = tanh meet the rest, and the bound would make it ½ tanh² θ = 0.18.
- **`hcenter`, centered statistics.** The statistic 1 ± 1 tilts the coin the same way, so it has the same KL divergences, but κ(0) = E[T] = 1. At θ = 0 the lower bound then reads ½(1 − ε) ≤ 0.
- **`hlip`, whitened, with the Fisher information moving at most L‖x‖.** Without whitening, the mutant fails it. Without the rate, L = 0 and ε = 0 again make the bound claim ½ tanh² θ.
- **`hint`, θ is an interior natural parameter.** No counterexample: `hgrad`, `hcenter` and `hlip` imply it. Mathlib's integral of a non-integrable function is 0, so ψ jumps where the natural parameter space ends, and `hgrad` rules out a jump on the segment. I kept it for two reasons. It says what the source assumes, that P\_θ is a regular exponential family member. And without it the statement would lean on that convention. Since the others imply it, keeping it doesn't narrow the theorem.
- **`hr`, the radius.** At θ = 10, with L = 1 and ε = 1/10, `hlip` holds. But the KL divergence, about 0.69, exceeds ½(1 + ε) tanh² 10 ≈ 0.55.
- **`hε`, ε ≤ 1.** This is the source's range, closed at 1. For larger ε the lower bound says nothing. Whether the upper bound still holds there is open: the proof needs ψ'' > 0 along the ray, which δ ≤ 1 gives.

The mutant's counterexample is the statistic ±1/4. `FisherContext` takes L\_ψ = (1/4)³ = 1/64 and, with its ε = 0.1, r = 6.4. At θ = 8 log 2 ≈ 5.5, inside r, the KL divergence is (81/17) log 2 − log 17 ≈ 0.469. That exceeds (1 + ε)/2 · κ²/F = (11/20)(15/17)² ≈ 0.428.

### 26. `dro_envelope`: restated copy
```lean
-- Statement
theorem dro_envelope (S : Set ℝ) (g : ℝ → ℝ) (ηstar : ℝ → ℝ) {ρ₀ : ℝ}
    (hmin : ∀ᶠ ρ in nhds ρ₀, ηstar ρ ∈ S ∧ ∀ η ∈ S, ηstar ρ * ρ + g (ηstar ρ) ≤ η * ρ + g η)
    (hcont : ContinuousAt ηstar ρ₀) :
    HasDerivAt (dualValue S g) (ηstar ρ₀) ρ₀
-- The bounds read with η as the tilt
noncomputable def tiltDual (S : Set ℝ) (k : ℝ → ℝ) (ρ : ℝ) : ℝ := ⨅ η : S, ρ / (η : ℝ) + k η
-- The claim with the bounds read in the tilt
def TiltEnvelope : Prop :=
  ∀ (S : Set ℝ) (k ηstar : ℝ → ℝ) (ρ₀ : ℝ),
    (∀ᶠ ρ in nhds ρ₀, ηstar ρ ∈ S ∧ ∀ η ∈ S, ρ / ηstar ρ + k (ηstar ρ) ≤ ρ / η + k η) →
    ContinuousAt ηstar ρ₀ → HasDerivAt (tiltDual S k) (ηstar ρ₀) ρ₀
-- Mutant: JSG II's KL dual, with η read as the tilt
theorem dro_envelope_mutant : ¬ TiltEnvelope
```

**Source.** `archive/Buckshot_Roulette/JSGII.tex`, in "DRO Closure": the KL dual (lines 679–681), Theorem "Strong duality & uniqueness of η\*" (`thm:duality-uniq`, line 699) and Theorem "ρ-sensitivity & envelope identity" (`thm:rho-sense`, lines 728–740). The 5% finite-difference check that relies on it is at lines 177, 562–567, 629–630, 769 and 781–784. The code is `archive/Reach/jsg-lab/src/jsg/dro/soft_transport.py`.

**What the source gets wrong, and the correction.**
- **The KL dual is wrong.** It reads inf over η > 0 of ηρ + (1/η) log E[e^{ηℓ}], which uses η as the multiplier in ηρ and as the tilt in e^{ηℓ}. The units show it: a tilt has units 1/[ℓ], so ηρ isn't a loss. The right dual, which follows from the Donsker–Varadhan formula, is inf over η > 0 of ηρ + η log E[e^{ℓ/η}], with η the multiplier. For a Gaussian loss of variance σ², the source's formula gives inf η(ρ + σ²/2) = 0, but the worst-case mean is σ√(2ρ).
- **dv/dρ = η\* holds for the multiplier, not the tilt.** Read with the source's e^{ηℓ}, η is a tilt t. The dual is then inf over t of ρ/t + (1/t) log E[e^{tℓ}], and dv/dρ = 1/t\*. That's the mutant: for variance 2, v = 2√ρ and t\* = √ρ, so at ρ = 4 the slope is 1/2 while t\* = 2.
- **A unique η\* is enough only with convexity.** When g is convex, as in both of JSG II's duals, a unique minimizer makes v differentiable: the minimizers are exactly v's supergradients (Fenchel duality). Without convexity it fails. Take S = {1} ∪ {2 + 1/n : n ≥ 1}, g(1) = 0 and g(2 + 1/n) = 1/n. Then the minimizer at ρ₀ = 0 is unique (η = 1), but v(ρ) = ρ for ρ ≥ 0 and 2ρ just below 0.

  The statement assumes a continuous minimizer selection instead:
  - it's what JSG II's "shrinking η\* bracket" observes;
  - uniqueness plus compactness gives it (Berge's maximum theorem);
  - proving the convex form would need Fenchel conjugacy, which Mathlib has only in part.
- **The check can't catch a wrong dual.** Every dual of the form ηρ + g(η) satisfies the identity, the source's wrong one included. So the 5% check tests the solver, not the duality. This theorem doesn't show that the dual equals the worst-case risk either ([Q10](QUEUE.md)).
- **jsg-lab never computes v.** `DRO.step` finds η\* by bisection on a soft-transport cost, `_g`, that never reads the loss, and stores η\* alone. So the check can't run against its output.
- **The θ-gradient half** of `thm:rho-sense`, ∇\_θ R = E[∇\_θ φ̃\_{η\*}], uses the smoothed Wasserstein c-transform φ̃ even in the KL case. It isn't in v3.

**Mathlib** (Loogle, then `#check`ed against the pin): no envelope or Danskin theorem. A search for "envelope" finds only category-theory names, and "danskin" finds nothing. The proof uses `ciInf_le`, `le_ciInf` and `hasDerivAt_iff_isLittleO`. The controls use `mgf_id_gaussianReal`.

**Definition.** `dualValue S g ρ` is the infimum, over multipliers η in S, of ηρ + g(η). Both of JSG II's duals fit. Its KL dual takes S = (0, ∞) and g(η) = η log E\_P[e^{ℓ/η}], and its smoothed Wasserstein dual takes S = [0, ∞) and g(η) = E\_P[φ̃\_η].

**Hypotheses.** The counterexamples use S = {1, 2}, g(1) = 0 and g(2) = −1. Then v(ρ) = min(ρ, 2ρ − 1), which has a kink at ρ₀ = 1.
- **`hmin`, at every radius near ρ₀.** The constant selection η\* = 2 is continuous and attains v for every ρ ≤ 1, ρ₀ included, but at no ρ above 1.
- **`hcont`.** The selection that is 2 for ρ ≤ 1 and 1 above attains v at every ρ, and jumps at 1.

In both cases v isn't differentiable at 1.

### Provability check (v3)

All three theorems are proved in an uncommitted scratch file. Each proof is against its frozen statement, since an `example` checks by `rfl` that their types are equal, and each uses only propext, Classical.choice and Quot.sound.
- **`cvar_tail_to_level`,** about 50 lines: the argument in §24's first bullet.
- **`kl_fisher_local`,** about 300 lines, with four helper lemmas that belong in `Lemmas/`:
  - Along the ray t ↦ tθ, ψ is the cgf of ⟪θ, T⟫, and the KL divergence is ψ'(1) − ψ(1), from the log-likelihood ratio of a tilted measure.
  - Cauchy's mean value theorem, applied to tψ'(t) − ψ(t) and ψ'(t)²/2, gives KL = ½ψ'(1)²·ξ/ψ'(ξ) for some ξ in (0, 1).
  - The bound on ψ'' puts ξ/ψ'(ξ) between 1/(1 + δ/2) and 1/(1 − δ/2), times 1/‖θ‖².
  - The mean value inequality keeps the part of κ(θ) across θ within δ‖θ‖.
  - The rest is algebra, for every ε ≤ 1.
- **`dro_envelope`,** about 40 lines. For ρ near ρ₀, η\*(ρ)(ρ − ρ₀) ≤ v(ρ) − v(ρ₀) ≤ η\*(ρ₀)(ρ − ρ₀), and continuity squeezes the slope to η\*(ρ₀).

### Witnesses (v3)

Each witness proves every hypothesis of its theorem, then the conclusion, for one concrete instance.

| Theorem | Hypotheses | Instance |
| --- | --- | --- |
| `cvar_tail_to_level` | `hX`, `h` | `Bool` with a quarter of the mass on `true`, a loss of 2 there and 0 elsewhere, tail mass 1/2 and ε = 1. The level 0 gives a CVaR of at most (1/2)/(1/2) = 1, and the loss exceeds 1 on a quarter of the mass |
| `kl_fisher_local` | all seven | the fair coin with statistic ±1, which is whitened, at θ = log 2, with L = 1 and ε = 7/10. Its KL divergence, (3/5) log 2 − log(5/4) ≈ 0.193, lies between 0.054 and 0.306 |
| `dro_envelope` | `hmin`, `hcont` | the KL dual of a Gaussian loss of variance 2, at ρ₀ = 1. Its bounds are ηρ + 1/η, minimized by η\*(ρ) = 1/√ρ, which is continuous. The dual is 2√ρ, whose slope at 1 is η\*(1) = 1 |

## statements-v4

Review support for the `statements-v4` proposal, read the same way as above. Its eight theorems are in section 15 of `lean/JSG/Statements.lean`, their definitions in the same section of `lean/JSG/Defs.lean`, and their controls in the "statements-v4" part of `lean/JSG/Tests/Mutants.lean`. Each mutant is a twin with a known defect, so it can run as a negative control ([EXECUTABLE_GATE.md](EXECUTABLE_GATE.md) §2). Four come from `archive/`, two from v1's and v2's own controls, and two are invented: `xknown_agrees`'s and `xwidth_agrees`'s.

**Scope** ([Q11](QUEUE.md)). v4 adds an executable twin of each definition the pilot and the first SirusSC differential test need, with a theorem that it agrees with its frozen definition: the graded values and `combine`, `verdict`, `residual` and `Threads`, and `Bound.width` and `leaseVerdict`. Core v2 makes `seqComp` and `parComp` both `combine`, so `xcombine` is their twin too. The obligation and Loader twins wait for a version with an implementation to test them against.

**The carrier** ([Q15](QUEUE.md)). Every twin computes in `WithTop ℚ≥0`: exact nonnegative rationals, plus ∞. Its order and arithmetic are decidable, and its subtraction truncates at 0, with ∞ − ∞ = 0, as in `ENNReal`. `xcast` sends ∞ to ∞ and each rational to itself, through `NNReal`. It is how each twin is compared with its frozen definition. It is noncomputable, but no twin calls it.

**Context.** Section 15 uses section 1's `variable {ι : Type} (kind : ι → Kind)`. `xverdict` and `xleaseVerdict` add `[Fintype ι]`, since an executable check must visit every axis, so their agreement theorems cover finitely many axes.

**Fixtures.** One axis (`Unit`), as before: `xk x` is the known exact value x, and `xunk` is the unknown. The controls import only `JSG.Defs`, so they prove the casts of 0, 1, the numerals and ∞ themselves, from `xcast`'s definition.

| Theorem | The mutant refutes | What differs from the statement | The defect it comes from |
| --- | --- | --- | --- |
| `xknown_agrees` | Restated copy | `XBound.known` → `upperOnly`, which reads a value x as [0, x] | Invented: a reading taken as an upper bound only |
| `xunknown_agrees` | Restated copy | `XBound.unknown` → `bottomUnknown`, which is [0, 0] | SCp1 Def 2.1, whose order puts ⊥ below every value; SirusSC `specchain/algebra/q.py`, `Q.leq` ("bottom <= x") |
| `xcombine_agrees` | Restated copy | `xcombine kind` → `absorbCombine floor`, where an unknown absorbs | SirusSC `specchain/algebra/q_prime.py`, `Interval.join` and `Interval.plus` |
| `xverdict_agrees` | Restated copy | `xverdict` → `leqSkipsUnknown`, which skips an unknown axis | SirusSC `specchain/algebra/q.py`, `Q.leq`, read as a threshold check |
| `xresidual_agrees` | Restated copy | `xresidual` → `xresidualFull`, which returns θ | `statements-v1`'s `residual_spec` mutant, `residualFull` |
| `xthreads_agrees` | Restated copy | `xthreads` → `xResidualOnly`, which checks only the last stage's fit | `statements-v2`'s `threads_spec` mutant, `ResidualOnly`: v1's `residual` alone |
| `xwidth_agrees` | Restated copy | `XBound.width` → `floatWidth`, which is ∞ whenever the upper end is | Invented, from floating point, where ∞ − ∞ is NaN |
| `xleaseVerdict_agrees` | Restated copy | `xleaseVerdict` → `xQPrimeGate`, which never reads a width | SirusSC `specchain/algebra/q_prime.py`, as for `lease_sound`: `QPrime`'s only guard is `guard_no_bottom` |

**What this means.**
- **No `statements-v1`–`v3` statement or definition changes.** Each v4 theorem is new, and so is every definition it uses.
- **Through agreement, the v1–v3 theorems hold of the twins.** For example, `xverdict_agrees` and `verdict_sound` say that the twin verdict rejects a grade with an axis above its threshold. With `xunknown_agrees`, that covers an unknown axis under any finite threshold, which is the pilot's "unknown axes must reject".
- **The statements are easy by design.** Each reduces to a lemma about `xcast` ([Provability check](#provability-check-v4)). The executable gate's hard parts are the harness, the corpus and the pilot's data, which are tested, not proved.
- **The twins run.** The scratch check ran each one through Lean's compiler, and the witnesses compute values by `decide`, which the kernel checks.

### 27. `xknown_agrees`: restated copy
```lean
-- Statement
theorem xknown_agrees (x : WithTop ℚ≥0) : (XBound.known x).toBound = Bound.known (xcast x)
-- Mutant: a reading taken as an upper bound only, [0, x]
theorem xknown_agrees_mutant : ¬ ∀ x, (upperOnly x).toBound = Bound.known (xcast x)
```

The mutant forgets that x is known: [0, 1] has width 1, so a lease of 0 would reject a reading that is exact. No source in `archive/` reads a point that way, so this mutant is invented.

### 28. `xunknown_agrees`: restated copy
```lean
-- Statement
theorem xunknown_agrees : XBound.unknown.toBound = Bound.unknown
-- Mutant: an unknown at the bottom of the order, [0, 0]
theorem xunknown_agrees_mutant : bottomUnknown.toBound ≠ Bound.unknown
```

**Source.** SCp1 Def 2.1 and Appendix A, and SirusSC `q.py`'s `Q.leq` (lines 86–98), whose `if a == self.BOTTOM: continue` lets ⊥ pass any bound. The master guide's defect table lists it as "Unknown sits below every value". The statement has no parameters, so its witness is the statement itself, checked end by end.

### 29. `xcombine_agrees`: restated copy
```lean
-- Statement
theorem xcombine_agrees (g h : XGrade ι) :
    (xcombine kind g h).toGrade = combine kind g.toGrade h.toGrade
-- Mutant: SirusSC's Interval.join and Interval.plus, where ⊥ absorbs
theorem xcombine_agrees_mutant :
    ¬ ∀ g h : XGrade Unit,
      (absorbCombine floor g h).toGrade = combine floor g.toGrade h.toGrade
```

**Source.** SirusSC `q_prime.py`: `Interval.plus` and `Interval.join` return ⊥ when either side is ⊥, and `q.py`'s `hetero_join` and `sequential` do the same. Read with ⊥ as the unknown, combining [0, ∞] with the known 1 on a floor gives [0, ∞], where `combine` gives [1, ∞]. No verdict changes, since the upper end is ∞ either way. But the known lower end is lost, so a report would call the axis unknown when it is known to be at least 1, and can never fit θ = 0.

### 30. `xverdict_agrees`: restated copy
```lean
-- Statement
theorem xverdict_agrees [Fintype ι] (θ : ι → WithTop ℚ≥0) (g : XGrade ι) :
    xverdict θ g = verdict (xcast ∘ θ) g.toGrade
-- Mutant: SirusSC's Q.leq as a threshold check, which skips an axis holding ⊥
theorem xverdict_agrees_mutant :
    ¬ ∀ (θ : Unit → WithTop ℚ≥0) (g : XGrade Unit),
      leqSkipsUnknown θ g = verdict (xcast ∘ θ) g.toGrade
```

**Hypotheses.** `[Fintype ι]`: an executable check must visit every axis. The frozen `verdict` decides "every axis" classically, for any axis type, and the twin agrees with it on the finite ones.

### 31. `xresidual_agrees`: restated copy
```lean
-- Statement
theorem xresidual_agrees (θ x : WithTop ℚ≥0) :
    xcast (xresidual θ x) = residual (xcast θ) (xcast x)
-- Mutant: v1's check of each stage against the full θ
theorem xresidual_agrees_mutant :
    ¬ ∀ θ x : WithTop ℚ≥0, xcast (xresidualFull θ x) = residual (xcast θ) (xcast x)
```

It holds for θ = ∞ too: both carriers truncate, and both take ∞ − ∞ to 0.

### 32. `xthreads_agrees`: restated copy
```lean
-- Statement
theorem xthreads_agrees (θ : WithTop ℚ≥0) (xs : List (WithTop ℚ≥0)) :
    xthreads θ xs = true ↔ Threads (xcast θ) (xs.map xcast)
-- Mutant: v1's residual check alone, run on the twins
theorem xthreads_agrees_mutant :
    ¬ ∀ (θ : WithTop ℚ≥0) (xs : List (WithTop ℚ≥0)),
      (xResidualOnly θ xs = true ↔ Threads (xcast θ) (xs.map xcast))
```

Unlike `threads_spec`, it needs no `θ ≠ ⊤`: it compares two threadings, not a threading and a sum.

### 33. `xwidth_agrees`: restated copy
```lean
-- Statement
theorem xwidth_agrees (b : XBound) : xcast b.width = b.toBound.width
-- Mutant: a width that is ∞ whenever the upper end is
theorem xwidth_agrees_mutant : ¬ ∀ b : XBound, xcast (floatWidth b) = b.toBound.width
```

The mutant is what a floating-point gate finds: in IEEE arithmetic ∞ − ∞ is NaN, and NaN ≤ β is false for every lease β. So the known ∞, which a withdrawn manuscript's `withdrawn` axis holds, would count as wider than any finite lease. Its frozen width is ∞ − ∞ = 0. No twin in `archive/` computes a width, so the mutant is invented.

### 34. `xleaseVerdict_agrees`: restated copy
```lean
-- Statement
theorem xleaseVerdict_agrees [Fintype ι] (θ β : ι → WithTop ℚ≥0) (g : XGrade ι) :
    xleaseVerdict θ β g = leaseVerdict (xcast ∘ θ) (xcast ∘ β) g.toGrade
-- Mutant: SirusSC's QPrime, which never reads a width, run on the twins
theorem xleaseVerdict_agrees_mutant :
    ¬ ∀ (θ β : Unit → WithTop ℚ≥0) (g : XGrade Unit),
      xQPrimeGate θ β g = leaseVerdict (xcast ∘ θ) (xcast ∘ β) g.toGrade
```

**Source** as for `lease_sound` (§17). **Hypotheses:** `[Fintype ι]`, as for `xverdict_agrees`.

### Provability check (v4)

All eight theorems are proved in an uncommitted scratch file that imports this draft's `JSG.Statements`. Each proof is against its frozen statement, since an `example` checks by `rfl` that their types are equal, and each uses only propext, Classical.choice and Quot.sound. The proofs take about 50 lines, eight cast lemmas for `Lemmas/` included:
- **Order:** `xcast` preserves and reflects ≤, from Mathlib's `WithTop.map_le_iff` and `NNRat.cast_le`, so it also preserves max.
- **+, 0 and ∞:** case by case on ∞.
- **Truncated subtraction:** Mathlib has no lemma for the cast from ℚ≥0 to ℝ≥0, where `NNRat.cast_sub` needs a `DivisionRing`. A helper proves it from `exists_add_of_le` and `tsub_eq_zero_of_le`.

The agreement theorems then follow by unfolding, and `xthreads_agrees` by induction on the stages.

**The twins run.** In a second scratch file, `#eval` ran the frozen twins through Lean's compiler:
- `xverdict` rejects the unknown under θ = 1 and accepts the known 1;
- `xleaseVerdict` rejects [0, 5] leased 1 under θ = 10;
- `xthreads` rejects θ = 1 with stages 2 then 0, and accepts θ = 10 with stages 3 then 4;
- ∞ − ∞ = 0, and 3 − 1 = 2.

**Kernel evaluation.** Plain `decide` evaluates the twins' comparisons and max: enough for a pilot verdict over seven floor axes at θ = 0, which a scratch check proved that way. It stops at rational addition and subtraction, since Lean marks `Rat.add` and `Rat.sub` irreducible. `decide +kernel` evaluates those too, with only the three axioms. Neither is native evaluation.

### Witnesses (v4)

Several witnesses use their mutant's counterexample, so the same input separates the twin from its mutant.

| Theorem | Instance |
| --- | --- |
| `xknown_agrees` | the known ∞, which a withdrawn manuscript's `withdrawn` axis holds |
| `xunknown_agrees` | the statement itself, which has no parameters |
| `xcombine_agrees` | on a floor, the unknown combined with the known 1: both sides are [1, ∞] |
| `xverdict_agrees` | the unknown under θ = 1: both sides reject, and `decide` computes the twin's verdict |
| `xresidual_agrees` | θ = x = 1: both sides are 0 |
| `xthreads_agrees` | θ = 10 with stages 3 then 4, which thread, and θ = 1 with stages 2 then 0, which don't |
| `xwidth_agrees` | the known ∞: both widths are 0 |
| `xleaseVerdict_agrees` | [0, 5] leased 1 under θ = 10: both sides reject, and `decide +kernel` computes the twin's verdict |

## statements-v5

Review support for the `statements-v5` proposal, read the same way as above. Its four theorems are in section 16 of `lean/JSG/Statements.lean`, their definitions in the same section of `lean/JSG/Defs.lean`, and their controls in the "statements-v5" part of `lean/JSG/Tests/Mutants.lean`, which still imports only the definitions. [Milestone 5](https://github.com/marleymcwilliams/LibSpec/blob/3b481d5e951bb30300195598e9dada5a753ab61c/guide/MILESTONE_5.md) proved all four. Two of the mutants are v1's, and the other two rest on readings of `archive/`, not on quotes, and say so.

**Scope** ([Q16](QUEUE.md)). v5 states Milestone 5's candidates C, D and G about the ordinal core, the part of the model the pilot uses ([ROADMAP.md](https://github.com/marleymcwilliams/LibSpec/blob/statements-v5/guide/ROADMAP.md#milestone-5-the-cores-gap-statements)). None of the 34 frozen theorems ties a grade to the true values behind it, says how the verdict behaves as evidence narrows, or tells a definite rejection from one that only lacks evidence. D has two halves with different hypotheses, so it's two theorems, and v5 adds four. They use four new definitions:
- **`Narrows g' g`:** on every axis, g′'s interval lies inside g's, so g′ knows at least as much.
- **`Encloses g x`:** each axis's interval contains that axis's value.
- **`ComposesNoWorse`:** a composite's true value is at most the larger of its parts' on a floor, and at most their sum on a budget.
- **`DefinitelyFails θ g`:** some axis's lower end is above its threshold.

**Context.** Section 16 uses section 1's `variable {ι : Type} (kind : ι → Kind)`. `accept_bounds_truth` and `combine_respects_narrowing` take `kind`, and the other two don't need it. Unlike v4's twin verdicts, none needs `[Fintype ι]`, since the frozen `verdict` decides "every axis" classically.

**Fixtures.** One axis (`Unit`), as before: `k x` is the known x, `zeroOne` is [0, 1], `θone` is θ = 1, and `budget` and `floor` make the axis a budget or a floor. v5 adds one, `unk`, the unknown on the single axis.

| Theorem | The mutant refutes | What differs from the statement | The defect it comes from |
| --- | --- | --- | --- |
| `accept_bounds_truth` | Restated copy, two mutants | `combine kind` → `jsgVSeq`, on a budget axis; or → `dropCombine floor`, where an unknown stage drops out | JSG V §2, whose vertical operator takes the max on every coordinate, ledger and CVaR included (v1's `interchange` mutant). The second is the reading of SirusSC's `q.py` in the next row |
| `combine_respects_narrowing` | Restated copy | `combine kind` → `dropCombine floor` | SirusSC `specchain/algebra/q.py`: `hetero_join` and `sequential` read an axis a grade leaves out as the identity, though SCp1's Remark 2.4 says missing evidence must descend to ⊥. A reading, not a quote |
| `narrowing_keeps_accept` | Restated copy | `verdict` → `verdictLo`, which reads `lo` | v1's `verdict_sound` mutant, from "Unknown sits below every value" in [DEFECTS.md](DEFECTS.md): SCp1 Def 2.1 and SirusSC's `Q.leq` |
| `definitelyFails_spec` | Restated copy | `DefinitelyFails` → `rejectIsFinal`, which counts every rejected grade as a definite failure | SCp1 Assumption 6.2, I9 and Proposition 15.1, which give a missing input the same RejectionCert as a failing one. A reading, not a quote |

**What this means.**
- **No `statements-v1`–`v4` statement or definition changes.** Each v5 theorem is new, and so is every definition it uses.
- **C's hypotheses carry its meaning.** Enclosure is measured, not proved, so `accept_bounds_truth` takes it as a hypothesis, with how true values compose. Lean proves what follows from enclosure, not that it holds ([GLOSSARY.md](GLOSSARY.md#unified-core-objects-v2), "Positive controls"). §35 says what supplies the hypotheses on the pilot's axes.
- **D says more evidence can't hurt.** Narrowing a stage narrows what it combines into, and an accepted grade stays accepted however it narrows. With C's composition hypothesis, the two halves also give C, since the point at each true value narrows its stage's grade.
- **G tells definite rejections from the rest.** A grade fails definitely exactly when every grade that narrows it is rejected. Any other rejection is one that more evidence can undo. The pilot's report already makes that split, axis by axis (§38).
- **The proofs are short.** The provability check proves all four in about 40 lines of tactics, with no helper lemma ([Provability check](#provability-check-v5)).

### 35. `accept_bounds_truth`: restated copy, two mutants
```lean
-- Statement
theorem accept_bounds_truth (θ : ι → ENNReal) (g h : Grade ι) (x y z : ι → ENNReal)
    (hx : Encloses g x) (hy : Encloses h y)
    (hz : ∀ i, ComposesNoWorse (kind i) (x i) (y i) (z i))
    (hacc : verdict θ (combine kind g h) = .accept) : ∀ i, z i ≤ θ i
-- Mutant: JSG V's rule, max on every axis in sequence, on a budget axis
theorem accept_bounds_truth_mutant :
    ¬ ∀ (θ : Unit → ENNReal) (g h : Grade Unit) (x y z : Unit → ENNReal),
      Encloses g x → Encloses h y → (∀ i, ComposesNoWorse (budget i) (x i) (y i) (z i)) →
      verdict θ (jsgVSeq g h) = .accept → ∀ i, z i ≤ θ i
-- Mutant: an unknown stage that drops out of the combination, on a floor
theorem accept_bounds_truth_dropCombine_mutant :
    ¬ ∀ (θ : Unit → ENNReal) (g h : Grade Unit) (x y z : Unit → ENNReal),
      Encloses g x → Encloses h y → (∀ i, ComposesNoWorse (floor i) (x i) (y i) (z i)) →
      verdict θ (dropCombine floor g h) = .accept → ∀ i, z i ≤ θ i
```

Under θ = 1, `jsgVSeq` combines two stages that each cost 1 into [1, 1], which is accepted, though together they cost 2. On a floor, `dropCombine` combines the known 1 with the unknown, whose true value is 2, into [1, 1], which is accepted, though the composed true value is 2. The second mutant is the one C would keep if it covered floors alone ([Q16](QUEUE.md)).

**What supplies C's hypotheses on the pilot's axes.** C needs each grade to enclose its stage's true values, and the true values to compose no worse than `combine` assumes. The pilot's seven axes are floors, and `ownGrade` in `lean/JSG/Pilot/Core.lean` gives each the values below, from the manuscript's own record:

| Axis | Known values | The check behind them |
| --- | --- | --- |
| `withdrawn` | ∞ if the manuscript has a withdrawal notice, and 0 otherwise | The collectors' reading of withdrawal notices |
| `dependency_withdrawn` | 0 once its dependencies have been read, or its formalization is complete, and unknown otherwise. The closure then combines in what each dependency passes on, ∞ from one that is withdrawn | The collectors' reading of dependencies, with the closure |
| `formal_proof` | 0 if Comparator accepted every challenge, and 1 if it rejected one; unknown otherwise, or with no challenge | Phase 7's trusted Comparator runs |
| `statement_fidelity` | 0 once a named reviewer has confirmed that the challenges state the top-line claim, and unknown otherwise | Phase 8's named reviewers |
| `axioms` | 0 if every challenge permits exactly the three axioms, and 1 if one doesn't; unknown with no challenge | The challenges' configurations |
| `independent_review` | 0 once a review is published, and unknown otherwise | Nothing yet |
| `novelty` | 0 once its priority has been checked against the literature, and unknown otherwise | Nothing yet |

An unknown encloses any value, so it needs nothing. A known value encloses the truth if the check behind it is right, which is what that check is trusted for, and not something Lean proves. The floor clause holds when a manuscript is no better than the worst of its own record and what its dependencies carry, which is how Q14's carry-over rule reads. All of this is a reading, not a proof.

**C's limits.**
- **Two stages, once.** C combines two grades once. A window folds many, and the pilot's closure also masks what carries ([Q14](QUEUE.md)). Neither is stated ([IDEAS.md](IDEAS.md#found-while-drafting-statements-v5)).
- **The twins.** The pilot computes with twins, which reach C through `xcombine_agrees` and `xverdict_agrees`: the twin verdict of a twin combination is the frozen verdict of the frozen combination of their casts.

**Why the budget clause is needed.** On a budget, C needs the true values to be subadditive, and value-at-risk isn't. Two independent losses of 1, each with probability 0.04, each have a 95% value-at-risk of 0, since each is 0 with probability 0.96. Their sum is 0 only with probability 0.9216, so its 95% value-at-risk is 1. Grades of [0, 0] enclose both stages' values and combine to [0, 0], which θ = 1/2 accepts, though the composed value is 1. `ComposesNoWorse` rules that out, as [GLOSSARY.md](GLOSSARY.md#unified-core-objects-v2) does by asking every budget axis to be subadditive, as CVaR is.

### 36. `combine_respects_narrowing`: restated copy
```lean
-- Statement
theorem combine_respects_narrowing {g g' h h' : Grade ι} (hg : Narrows g' g)
    (hh : Narrows h' h) : Narrows (combine kind g' h') (combine kind g h)
-- Mutant: an unknown stage that drops out of the combination, on a floor
theorem combine_respects_narrowing_mutant :
    ¬ ∀ g g' h h' : Grade Unit, Narrows g' g → Narrows h' h →
      Narrows (dropCombine floor g' h') (dropCombine floor g h)
```

On a floor, `dropCombine` gives [1, 1] for the known 1 with the unknown, and [2, 2] with the known 2, which narrows the unknown, in its place. [2, 2] isn't inside [1, 1], so more evidence moved the combination outside what it claimed. `combine` gives [1, ∞] and [2, 2], and [2, 2] is inside [1, ∞].

**Source, a reading.** In SirusSC's `specchain/algebra/q.py`, a grade maps axes to values, and `hetero_join` and `sequential` (lines 42–84) read an axis a grade leaves out as the identity: 0 on a sum axis, and −∞ on a max axis. So a stage with no evidence on an axis drops out of the combination there. SCp1's Remark 2.4 says that "any appearance of unknown/missing/invalid evidence must descend to ⊥ and persist through aggregation". Two things qualify the reading:
- **An explicit ⊥ absorbs.** Both functions return ⊥ when either side holds it. v4's `absorbCombine` reads the unknown that way (§29), and so does v2's `pointsOnly` (§18). `dropCombine` reads it as an axis left out instead. Both are readings of the same code, which has both ways to represent missing evidence.
- **Undeclared axes.** SCp1's Definition 7.1 gives the axes a stage doesn't declare the identity on purpose, and the code can't tell such an axis from one whose evidence is missing.

### 37. `narrowing_keeps_accept`: restated copy
```lean
-- Statement
theorem narrowing_keeps_accept (θ : ι → ENNReal) {g g' : Grade ι}
    (hacc : verdict θ g = .accept) (hn : Narrows g' g) : verdict θ g' = .accept
-- Mutant: a verdict that reads lo
theorem narrowing_keeps_accept_mutant :
    ¬ ∀ (θ : Unit → ENNReal) (g g' : Grade Unit),
      verdictLo θ g = .accept → Narrows g' g → verdictLo θ g' = .accept
```

Under θ = 1, `verdictLo` accepts the unknown, whose lower end 0 is within θ, but rejects the known 2, which narrows it. So more evidence turns its acceptance into a rejection. The verdict reads `hi`, which narrowing can only lower. **Source:** v1's `verdict_sound` mutant (§4).

### 38. `definitelyFails_spec`: restated copy
```lean
-- Statement
theorem definitelyFails_spec (θ : ι → ENNReal) (g : Grade ι) :
    DefinitelyFails θ g ↔ ∀ g' : Grade ι, Narrows g' g → verdict θ g' = .reject
-- Mutant: SCp1's single kind of rejection, which counts every rejected grade as definite
theorem definitelyFails_spec_mutant :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit),
      rejectIsFinal θ g ↔ ∀ g' : Grade Unit, Narrows g' g → verdict θ g' = .reject
```

Under θ = 1, `rejectIsFinal` counts the unknown as a definite failure, since its upper end, ∞, is above θ. But the known 1 narrows the unknown and is accepted, so more evidence can undo that rejection.

**Source, a reading.** In SCp1, a ⊥ priced input "forces the guard to fail (deterministic rejection with a RejectionCert)" (Assumption 6.2), "any ⊥ in priced inputs triggers rejection" (I9), and Proposition 15.1 says "There is no third case". A RejectionCert has at least kind, predicate_id, failing_witness_hash, seed_snapshot, parent_tip, time and stage, and predicate_id names a cause, the "identifier of the violated invariant". But since a ⊥ priced input and a failing value violate the same guard (Assumption 6.2, I9), no field SCp1 requires tells them apart. So a missing input and a failing one earn the same rejection. SirusSC's loader adds a reason code, such as `C_UNK_PRICED`, that SCp1's certificate doesn't require.

**G and the pilot's report.** `Release.why` in `lean/JSG/Pilot/Core.lean` already gives `.evidence` when an axis's own lower end is above θ, and `.unknown` when only its upper end is, and `.through` a dependency for the same split in what that dependency carries. G is that split, frozen, for a whole grade. It isn't proved for the twins, or for `Release.why` ([IDEAS.md](IDEAS.md#found-while-drafting-statements-v5)).

### Provability check (v5)

All four theorems are proved in an uncommitted scratch file: first before the copy, against the two sections in the context each has at the end of its file, and again after it, against the real `JSG.Statements`. Each proof is against its frozen statement, since an `example` checks by `rfl` that their types are equal, and each uses only propext, Classical.choice and Quot.sound. They take about 40 lines of tactics, with no helper lemma, and open `verdict` with `unfold` and `split_ifs`, as Milestones 1 and 2 do:
- **`accept_bounds_truth`:** the accept bounds each axis's combined upper end by θ. On a floor, z ≤ max(x, y), which is at most the larger upper end, by `max_le_max`; on a budget, the same with `add_le_add`.
- **`combine_respects_narrowing`:** case by case on the axis's kind, by `max_le_max` and `add_le_add` on each end.
- **`narrowing_keeps_accept`:** each narrowed upper end is at most the accepted one.
- **`definitelyFails_spec`:** if θ is below some lower end, it's below every narrowing's upper end on that axis, so every narrowing is rejected. Otherwise the point at each axis's lower end narrows the grade and is accepted.

### Witnesses (v5)

Each witness proves every hypothesis of its theorem, in order, then the conclusion, at one instance. Two use their mutant's inputs, so the same input separates the statement from its mutant.

| Theorem | Hypotheses | Instance |
| --- | --- | --- |
| `accept_bounds_truth` | `hx`, `hy`, `hz`, `hacc` | the first mutant's inputs with `combine`, under θ = 2: on a budget, two costs of 1 add to [2, 2], which is accepted, and the true total, 2, is within θ |
| `combine_respects_narrowing` | `hg`, `hh` | the mutant's inputs with `combine`, on a floor: the known 1 with the unknown is [1, ∞], and with the known 2 it's [2, 2], which lies inside it |
| `narrowing_keeps_accept` | `hacc`, `hn` | θ = 1: [0, 1] is accepted, and so is the known 1, which narrows it |
| `definitelyFails_spec` | none, so both sides of the iff | θ = 0: the known 1, where both sides hold, and [0, 1], where neither does, since the known 0 narrows it and is accepted |

## statements-v6

Review support for the `statements-v6` proposal, read the same way as above. Its one theorem is in section 17 of `lean/JSG/Statements.lean`. Its controls are in the "statements-v6" part of `lean/JSG/Tests/Mutants.lean`, which still imports only the definitions, and in the last part of `lean/JSG/Tests/Gamers.lean`. It uses no new definition, so `lean/JSG/Defs.lean` doesn't change. Its proof is one line, committed in the same PR after the tagged commit.

**Scope** ([Q17](QUEUE.md)). Since Q4 replaced `verdict_unknown` with `verdict_sound`, no frozen theorem has said what the unknown is. So reading it as zero survives every theorem of the ordinal core ([the gamers section's finding on `unknownZero`](#what-each-finding-means)). v6 states the gamers' candidate 1, `narrows_unknown`: every grade narrows the grade that is unknown on every axis.

**Context.** Section 17 uses section 1's `variable {ι : Type} (kind : ι → Kind)`, and doesn't need `kind`.

**Fixtures.** v5's, on one axis: `k x` is the known x, and `unk` is the unknown.

| Theorem | The mutant refutes | What differs from the statement | The defect it comes from |
| --- | --- | --- | --- |
| `narrows_unknown` | Restated copy | `Bound.unknown` → `bottomBound`, the known 0 | "Unknown sits below every value" in [DEFECTS.md](DEFECTS.md): SCp1's order puts ⊥ below every value, and SirusSC's `Q.leq` lets ⊥ pass any bound. It's v4's `bottomUnknown` before the cast (§28), and the gamers' `unknownZero` |

### 39. `narrows_unknown`: restated copy
```lean
-- Statement
theorem narrows_unknown (g : Grade ι) : Narrows g (fun _ => Bound.unknown)
-- Mutant: the unknown at the bottom of the order, [0, 0]
theorem narrows_unknown_mutant : ¬ ∀ g : Grade Unit, Narrows g (fun _ => bottomBound)
```

The known 1 narrows the unknown, [0, ∞], but not [0, 0], since its upper end, 1, is above 0.

**What it adds.**
- **It pins the unknown.** [0, ∞] is the only bound that every bound narrows. With `xunknown_agrees`, it pins the twin too.
- **It kills two survivors of the gamers' matrix:** `unknownZero`, the same change as its mutant, and `narrowsToLo` (`narrows_unknown_kills_narrowsToLo`, in `Gamers.lean`).
- **It makes the first claim of `Narrows`' docstring a theorem.** The second, that only a point narrows a point, stays a docstring claim. It's the gamers' recorded limit for `narrowsHiInside`, and v6 leaves it out.

### Provability check (v6)

`narrows_unknown` is proved in an uncommitted scratch file: first before the copy, with section 17 in the context it has at the end of the file, and again after it, against the real `JSG.Statements`. The proof is against the frozen statement, since an `example` checks by `rfl` that their types are equal, and it uses only propext, Classical.choice and Quot.sound. It's one line, `fun _ => ⟨zero_le, le_top⟩`: on every axis, the unknown's lower end is 0 and its upper end ∞. It's in `lean/JSG/Proofs/Milestone5.lean`.

### Witness (v6)

`narrows_unknown_witness`: the known 1 narrows `unk`. The theorem has no hypotheses, so its conclusion at one instance is all a witness needs.

## Gamers and the kill matrix: the ordinal core

Mutants show that a statement can fail. This section tests the other direction, for the ten theorems of the ordinal core, which decision 0 hardens ([ROADMAP.md](https://github.com/marleymcwilliams/LibSpec/blob/3b481d5e951bb30300195598e9dada5a753ab61c/guide/ROADMAP.md#after-milestone-4-grading-real-claims)): `combine_comm`, `combine_assoc`, `interchange`, `verdict_sound`, `verdict_complete`, `no_flip`, `accept_bounds_truth`, `combine_respects_narrowing`, `narrowing_keeps_accept` and `definitelyFails_spec`.
- **A gamer** is a definition that satisfies every restated copy, yet does what a passage of `archive/` says the model must not.
- **A survivor** is a first-order mutant that no theorem kills: behaviour no statement pins down.

Both are in `lean/JSG/Tests/Gamers.lean`, which imports only the definitions and `JSG.Tests.Mutants`, as `Mutants.lean` imports only the definitions.

**Left out.** The twins' agreement theorems (§§27–34): they kill any mutant whose twin isn't changed with it, which says nothing about behaviour. By decision 0, budgets, residuals, leases, obligations, the frontier charge and the Loader wait, and so do `LoaderStep`'s guards and Milestone 2's gamer, a last stage that clears everything.

### Gamers

A fresh-context subagent looked for one gamer in each layer: graded values and `combine`, the verdict, and narrowing and definite failure. It was given only the ten theorems, their definitions, and the passages of `archive/` this review cites for them, as data. It ran nothing and opened no file. Like every subagent here, it also had Claude Code's own context, which includes the repository's CLAUDE.md, and CLAUDE.md quotes no statement. It found four, two in the first layer. `Gamers.lean` builds each, with a proof of every copy that mentions what it changes and one instance of what it does wrong. Two of them are survivors of the matrix below too, found independently, since the subagent saw no mutant.

| Gamer | What it changes | The passage it goes against | What it does wrong | Origin |
| --- | --- | --- | --- | --- |
| `unknownZero` | `Bound.unknown` is the known 0 | SCp1's Remark 2.4: missing evidence "must descend to ⊥ and persist through aggregation"; JSG V's (V2): "Optional missing metrics map to [the unknown] at their coordinates (fail-closed)" | on a budget under θ = 5, the unknown with the known 3 gives [3, 3], which is accepted; the frozen unknown gives [3, ∞], which is rejected | real: SirusSC's `Q` reads a missing coordinate as its axis's identity, 0 or −∞, and `loader.py`'s guard looks only for the ⊥ sentinel |
| `floorAdd` | `combineAxis`'s floor case sums, as its budget case does | SCp1's Proposition 2.3(c): "Axiswise idempotence: (q ∧ q)ᵢ = qᵢ iff i ∈ M", and a floor is a max-axis | on a floor under θ = 7, two stages at the known 5 give [10, 10], which is rejected; the frozen [5, 5] is accepted | real: SirusSC's `Q.sequential` sums "on both axis families". It is `scp2Seq` in both places, and `interchange_scp2_mutant` kills that only when parallel composition takes the max |
| `pointsVerdict` | the verdict accepts only points within θ | SCp1's rejection certificate names "the violated invariant", and its Proposition 15.1 says "There is no third case". A reading, not a quote | under θ = 10, [2, 3] is rejected though no axis is over θ, and the known 3, its worst case, is accepted; `verdict` accepts [2, 3] | real: v2's `pointsOnly`, read from SirusSC's `Q`, with no lease (`pointsVerdict_eq`) |
| `narrowsHiInside` | a narrowing need only keep its upper end inside | SCp1's Definition 7.1: "x ⪯ x′ ⇒ A_S(x) ≤_Q A_S(x′)", read as: more input never falls below what was established. A reading, not a quote | under θ = 5, [0, 8] narrows the known 8, which fails definitely, and the accepted known 0 narrows [0, 8], so two rounds of "more evidence" accept a known violation | invented: a one-token slip |

**What else the subagent found.**
- **`DefinitelyFails` has no gamer:** `definitelyFails_spec` fixes it once `Narrows` and `verdict` are fixed.
- **A gamer of the verdict can only reject more:** by `verdict_sound`, whatever it accepts, `verdict` accepts too.
- **Two more of its candidates survive the ten.** It didn't count them as gamers, and they're leads here:
  - forgetting a floor's lower end, `lo := 0` in the floor case: invented, and it breaks SCp1's Proposition 2.3(d), "q ∧ e = q";
  - [0, ∞] whenever an operand's upper end is ∞: JSG V asks for exactly this ("any composition with [the unknown] yields [the unknown]"), and [DEFECTS.md](DEFECTS.md) records the same absorption in SirusSC as a defect. Only `xcombine_agrees`, a twin's theorem, kills the like mutant `absorbCombine` (§29).

### The mutants and the bounds

- **What's mutated:** the definitions the ten theorems use, one change at a time: `combineAxis`'s floor case, `Bound.unknown`, `verdict`, `Narrows`, `Encloses`, `ComposesNoWorse`'s floor case and `DefinitelyFails`.
- **The operators:**
  - the plan's four: max and + swapped, `hi` and `lo` swapped, ≤ and < swapped, and one conjunct dropped. The verdict's check is a conjunct per axis, so dropping one skips an axis, and on one axis the verdict then accepts every grade.
  - one more, since decision 0 names unknowns and none of the four reaches them: `Bound.unknown`'s ⊤ becomes 0, so missing evidence reads as zero ([DEFECTS.md](DEFECTS.md), "Unknown sits below every value").
- **The search** ran in an uncommitted Python script that models the seven definitions and the ten copies, and checks first that the frozen definitions satisfy every copy. Its bounds:
  - one axis, with interval ends in {0, 1, 2, ∞}, and thresholds and true values in {0, 1, 2, 3, 4, ∞};
  - two axes, for the copies that read several, with ends, thresholds and true values in {0, 1, 2, ∞};
  - in `definitelyFails_spec`'s copy, "every grade that narrows it" ranges over the grid's grades.

  The copies about `combine` hold or fail axis by axis, so one axis covers them.
- **A kill** proves a copy's negation at one instance, on one axis, by `simp` or `norm_num`, as `Mutants.lean` does. A survivor's copies are proved to hold, on any axes, so it is no artefact of the grid.

### The matrix

One row per mutant. "Proved" marks a copy proved to hold for the mutant; the others it survives were searched, with no counterexample within the bounds. A theorem that doesn't mention the changed definition is left out of its row: its copy is the frozen theorem itself.

| Mutant | Its change | Killed by | Survives |
| --- | --- | --- | --- |
| — | `combineAxis`'s floor case, + in the lower end | can't be built: [1, 1] with [1, 1] gives [2, 1] | — |
| `floorHiAdd` | `combineAxis`'s floor case, + in the upper end | none: a survivor | `combine_comm`, `combine_assoc`, `interchange`, `accept_bounds_truth` and `combine_respects_narrowing`, all proved |
| `floorLoLeftHi` | the floor case's lower end reads `a.hi` for `a.lo` | `combine_comm`, `combine_respects_narrowing` | `accept_bounds_truth`, proved; `combine_assoc` and `interchange`, searched |
| `floorLoRightHi` | the floor case's lower end reads `b.hi` for `b.lo` | `combine_comm`, `combine_respects_narrowing` | `accept_bounds_truth`, proved; `combine_assoc` and `interchange`, searched |
| `floorHiLeftLo` | the floor case's upper end reads `a.lo` for `a.hi` | `combine_comm`, `accept_bounds_truth`, `combine_respects_narrowing` | `combine_assoc`, `interchange` |
| `floorHiRightLo` | the floor case's upper end reads `b.lo` for `b.hi` | `combine_comm`, `accept_bounds_truth`, `combine_respects_narrowing` | `combine_assoc`, `interchange` |
| — | the floor case's two ends swapped | can't be built: [0, 0] with [0, 1] gives [1, 0] | — |
| `unknownZero` | `Bound.unknown`'s ⊤ read as 0: [0, 0] | none: a survivor, and a gamer | all ten, since none mentions `Bound.unknown` |
| — | `Bound.unknown`'s ends swapped, [∞, 0] | can't be built | — |
| `verdictLo` (`Mutants.lean`) | `verdict` reads `lo` for `hi` | `verdict_sound` and `narrowing_keeps_accept` (both in `Mutants.lean`), `accept_bounds_truth` | `no_flip`, proved; `verdict_complete` and `definitelyFails_spec`, searched |
| `verdictLt` | `verdict`'s ≤ to < | `verdict_complete`, `definitelyFails_spec` | `verdict_sound`, `no_flip` and `accept_bounds_truth`, all proved; `narrowing_keeps_accept` |
| `verdictSkip` | `verdict` skips one axis's check; on one axis it accepts every grade | `verdict_sound`, `accept_bounds_truth`, `definitelyFails_spec` | `no_flip`, proved; `verdict_complete` and `narrowing_keeps_accept`, searched |
| `narrowsToHi` | `Narrows`' first conjunct reads `g`'s `hi` for its `lo` | `definitelyFails_spec` | `narrowing_keeps_accept`, proved; `combine_respects_narrowing`, searched |
| `narrowsHiInside` | `Narrows`' first conjunct reads `g'`'s `hi` for its `lo` | none: a survivor, and a gamer | `combine_respects_narrowing`, `narrowing_keeps_accept` and `definitelyFails_spec`, all proved |
| `narrowsLoInside` | `Narrows`' second conjunct reads `g'`'s `lo` for its `hi` | `narrowing_keeps_accept` | `definitelyFails_spec`, proved; `combine_respects_narrowing`, searched |
| `narrowsToLo` | `Narrows`' second conjunct reads `g`'s `lo` for its `hi` | none: a survivor | `combine_respects_narrowing`, `narrowing_keeps_accept` and `definitelyFails_spec`, all proved |
| `narrowsLoStrict` | `Narrows`' first conjunct, ≤ to < | `definitelyFails_spec` | `narrowing_keeps_accept`, proved; `combine_respects_narrowing`, searched |
| `narrowsHiStrict` | `Narrows`' second conjunct, ≤ to < | `definitelyFails_spec` | `narrowing_keeps_accept`, proved; `combine_respects_narrowing`, searched |
| `narrowsLoOnly` | `Narrows`' second conjunct dropped | `narrowing_keeps_accept` | `definitelyFails_spec`, proved; `combine_respects_narrowing`, searched |
| `narrowsHiOnly` | `Narrows`' first conjunct dropped | `definitelyFails_spec` | `narrowing_keeps_accept`, proved; `combine_respects_narrowing`, searched |
| — | `Encloses`' first conjunct reads `hi` for `lo` | can't be killed: it only strengthens a hypothesis | `accept_bounds_truth` |
| — | `Encloses`' second conjunct reads `lo` for `hi` | can't be killed: it only strengthens a hypothesis | `accept_bounds_truth` |
| — | `Encloses`' first conjunct, ≤ to < | can't be killed: it only strengthens a hypothesis | `accept_bounds_truth` |
| — | `Encloses`' second conjunct, ≤ to < | can't be killed: it only strengthens a hypothesis | `accept_bounds_truth` |
| `enclosesHiOnly` | `Encloses`' first conjunct dropped | none: a survivor, in a hypothesis | `accept_bounds_truth`, proved |
| `enclosesLoOnly` | `Encloses`' second conjunct dropped | `accept_bounds_truth` | — |
| `composesSum` | `ComposesNoWorse`'s floor case, max to + | `accept_bounds_truth` | — |
| — | `ComposesNoWorse`'s floor case, ≤ to < | can't be killed: it only strengthens a hypothesis | `accept_bounds_truth` |
| `rejectIsFinal` (`Mutants.lean`) | `DefinitelyFails` reads `hi` for `lo` | `definitelyFails_spec` (in `Mutants.lean`) | — |
| `definitelyFailsLe` | `DefinitelyFails`' < to ≤ | `definitelyFails_spec` | — |

**In numbers.** 30 mutants: 17 killed, 5 survivors, 5 that only strengthen a hypothesis of `accept_bounds_truth` and so can't be killed, 3 that can't be built, and none equivalent. The 17 take 28 kills: 25 proved in `Gamers.lean` and 3 already in `Mutants.lean`.

### What each finding means

The pilot computes with the twins, so a frozen definition's change reaches its verdicts only through its twin. The twins' agreement theorems ask the twin to change with it, so each finding below assumes it does. `Narrows`, `Encloses`, `ComposesNoWorse` and `DefinitelyFails` have no twin, and the pilot computes none of them. Under θ = 0 on every axis ([Q12](QUEUE.md), `θ0` in `lean/JSG/Pilot/Core.lean`), a grade is accepted only when every axis is the known 0, so most of what tells these findings apart is invisible there. Decision 0's test applies: a candidate that no pilot verdict can tell apart is a recorded limit until a threshold above 0 has a user.

**`unknownZero`, a gamer and a survivor: missing evidence read as zero.**
- **Why it survives:** no theorem of the ten mentions `Bound.unknown`. `verdict_sound` replaced `verdict_unknown` after [Q4](QUEUE.md). It covers every grade over its threshold, unknowns included, but no longer says what the unknown is. Of the 38 frozen theorems, only `xunknown_agrees` mentions it, and it ties it to the twin, so a change to both survives all 38.
- **Pilot verdicts: 721 of 724 change.** With its twin changed with it, every unknown axis passes θ = 0. Each manuscript whose report lists only unknowns would be accepted: reports 1–4 in `pilot/reports/catalogue.md`. Only the three withdrawn manuscripts would still fail, on their known `withdrawn` axis.
- **Recommendation: a statement candidate.** `statements-v6` states it, as `narrows_unknown` ([§39](#39-narrows_unknown-restated-copy)). Every grade narrows the grade that is unknown on every axis, as `Narrows`' docstring already says. It kills `unknownZero`, since the known 1 doesn't narrow [0, 0], and `narrowsToLo` too. It pins the unknown exactly, since the only bound that every bound narrows is [0, ∞].

**`floorAdd`, a gamer, and `floorHiAdd`, a survivor: a floor that adds.** `floorAdd` sums both ends, and `floorHiAdd` only the upper end.
- **Pilot verdicts: none change.** On [0, ∞], a + b is 0 exactly when max(a, b) is, so under θ = 0 an end passes under one rule exactly when it does under the other. Above 0 both only reject more: under θ = 1, [0, 1] with itself gives [0, 2], which is rejected, where the frozen [0, 1] is accepted.
- **Recommendation: a recorded limit.** If a threshold above 0 gets a user, the statement that would kill both is SCp1's Proposition 2.3(c), axiswise idempotence: on a floor, a grade combined with itself is that grade.

**`pointsVerdict`, a gamer: only complete evidence accepted.**
- **Pilot verdicts: none change.** Under θ = 0, a grade with every upper end within θ is the known 0 on every axis, a point, which `pointsVerdict` accepts too. Above 0 it only rejects more, as the subagent found every gamer of the verdict must.
- **Recommendation: a recorded limit.** The statement that would kill it is `verdict_sound`'s converse: a grade whose upper ends are all within their thresholds is accepted. `verdict_complete` says that only for points.

**`narrowsHiInside`, a gamer and a survivor: a narrowing need only keep its upper end inside.**
- **What it permits:** D and G hold for a narrowing that may lower a lower end, so the theorems don't say that more evidence keeps what was known. Under it, a known violation can be narrowed, in two rounds, to an acceptance.
- **Pilot verdicts: none change,** since the pilot never computes `Narrows`.
- **Recommendation: a recorded limit.** The statement that would kill it is `Narrows`' docstring's other claim: the only grade that narrows a point is that point.

**`narrowsToLo`, a survivor: a grade's only narrowing is the point at its lower end.**
- **Pilot verdicts: none change,** as for `narrowsHiInside`.
- **Recommendation:** no candidate of its own. The candidate for `unknownZero` kills it, since under it only the known 0 narrows the unknown.

**`enclosesHiOnly`, a survivor: a grade need only bound its true value from above.**
- **Could `accept_bounds_truth` be stronger? Yes.** It holds with this weaker hypothesis, proved on any axes, since its proof never reads a lower end. The four mutants that strengthen `Encloses`, and the one that strengthens `ComposesNoWorse`, can't be killed.
- **Pilot verdicts: none change.** Enclosure is a hypothesis about the true values, not something the pilot computes.
- **Recommendation: a recorded limit.** A stronger C would change nothing the pilot shows. Enclosure's lower half would matter to a statement about definite failure: if a grade encloses the true values and fails definitely, some true value is over its threshold. That statement would kill `enclosesHiOnly`, and would make the report's "evidence" a claim about the truth. It changes no verdict either, so it is a recorded limit too.

## Independent readings: the ordinal core

The mutants and the gamers test what a statement rules out. This section reads what each of the ten says, twice, with fresh-context subagents, one theorem each. Each got only its inputs, pasted into its prompt, and was told to open no file. Each made one tool call, the one that returned its answer. Each also had Claude Code's own context, which includes the repository's CLAUDE.md: one answer ends with the session note CLAUDE.md asks for. CLAUDE.md quotes no statement.
- **A back-translation.** A subagent got the frozen statement, with its name replaced by `T`, and the definitions it uses from `Defs.lean`, with every docstring and comment removed. It wrote in plain words what `T` claims and what it leaves out. Each answer is compared with the theorem's docstring and with its source.
- **A second formalization.** Another subagent got only the source and the same definitions, and wrote its own Lean statement. All ten type-checked as written. `lean/JSG/Tests/Readings.lean` states each, and its frozen statement, as a predicate on the definition the theorem constrains: `combine`, `verdict` or `DefinitelyFails`, with every other definition fixed. It proves the two equivalent, or gives a definition for each direction where neither implies the other.

**The sources.** For the first six theorems, the passage the layer map's Source column names, read from `archive/` as data. JSG V §2, "The Algebra of Acceptance" (`archive/Buckshot_Roulette/JSGV.tex`), went with the preamble's definitions of the macros it uses. The SIRUS spec's §1.2–1.4 are in `archive/Markdown/SIRUS_SPEC_MASTER.md`. C, D and G have no source in the corpus, so their subagents got [ROADMAP.md](https://github.com/marleymcwilliams/LibSpec/blob/statements-v5/guide/ROADMAP.md#milestone-5-the-cores-gap-statements)'s Milestone 5 bullet, verbatim, which was written knowing their statements. Where one source makes several claims, the prompt named the one to formalize in the source's words, such as "the passage's claim that its aggregation operators are commutative".

Both checks produce leads, never fidelity: by the hardening plan's decision 2, a model's review never counts toward `statement_fidelity`, and these subagents share a model with whoever drafted the statements, so a match is weak evidence.

| Theorem | Source | Back-translation | Second formalization |
| --- | --- | --- | --- |
| `combine_comm` | JSG V §2 | matches | equivalent: the same statement |
| `combine_assoc` | JSG V §2 | matches | equivalent: the same statement |
| `interchange` | JSG V §2 | lead 1: with one operator, the law follows from `combine_comm` and `combine_assoc`, where JSG V's relates two | different: JSG V's lax law. `combineFlipped` satisfies only the frozen statement, and `mulPlus` only the second |
| `verdict_sound` | SIRUS §1.2–1.3 | lead 2: under θ = ∞ the unknown is accepted, where SIRUS rejects every missing observation | equivalent: the same statement, and its notes raise θ = ∞ too |
| `verdict_complete` | SIRUS §1.2–1.3 | lead 3: the passage has no rule that forces ACCEPT | different: §1.2's monotonicity law, read as narrowing keeping an acceptance. `alwaysReject` satisfies only that reading, and `verdictLo` only the frozen statement |
| `no_flip` | SIRUS §1.4 | lead 4: the passage's rule is the hypothesis, so the statement holds for every verdict | equivalent: both hold for every verdict |
| `accept_bounds_truth` | Milestone 5, C | matches | equivalent: the same statement |
| `combine_respects_narrowing` | Milestone 5, D | matches | equivalent: the same statement |
| `narrowing_keeps_accept` | Milestone 5, D | matches | equivalent: the same statement |
| `definitelyFails_spec` | Milestone 5, G | matches | equivalent: the bullet's two sentences as two halves, which make the iff since a verdict has two values |

**In numbers.** The back-translations: 6 match, and 4 are leads. The second formalizations: 8 equivalent, none stronger or weaker, and 2 different. Six of the eight equivalent ones are the frozen statement up to names.

### What each lead means

The pilot computes with the twins, under θ = 0 on every axis ([Q12](QUEUE.md)). None of the four leads changes a pilot verdict.

**Lead 1, `interchange`: one operator, where JSG V has two.**
- **The readings:** with `seqComp` and `parComp` both `combine`, the back-translation found that `T` is the medial law of one operation, which follows from commutativity and associativity. The second formalization stated JSG V's own law: an inequality between the max on every axis, in sequence, and `combine`, in parallel.
- **Known:** [Q1](QUEUE.md) chose this form in 2026-10, so that JSG V's rule could be stated, as `interchange_mutant`. It says the one-operator law "can't fail for any commutative, associative `combine`".
- **New here:** JSG V's lax law holds for the frozen `combine` (`interchangeSecond_combine`), so the frozen definitions satisfy both readings.
- **Recommendation:** a note for the next statements version. The docstring could say that both compositions are `combine`, so the equation follows from `combine_comm` and `combine_assoc`, as Q1 records.

**Lead 2, `verdict_sound`: the unknown under an infinite threshold.**
- **The readings:** both raise it. Under θ = ∞, `T` never fires, and `verdict` accepts the unknown. SIRUS §1.3's fail-closed rule says missing observations "MUST yield `REJECT`", with no exception.
- **Known, and deliberate:** the docstring says the unknown rejects "whenever its threshold is finite". Milestone 1's must-pass control `unknown_on_infinite_threshold_passes`, in `Tests/Calibration.lean`, requires the acceptance: "with no limit on the axis, even [0, ∞] is within it".
- **Recommendation:** nothing.

**Lead 3, `verdict_complete`: its cited source doesn't state it.**
- **The readings:** the layer map cites SIRUS §1.2–1.3 for both verdict theorems. Their rules limit when ACCEPT is allowed, and none requires it. The second formalization's subagent said so, and formalized the one rule it read as requiring an ACCEPT: §1.2's monotonicity law, as narrowing keeping an acceptance, which is `narrowing_keeps_accept`'s claim.
- **Where completeness comes from:** core v2's positive controls ([GLOSSARY.md](GLOSSARY.md#unified-core-objects-v2)), which ask for "a completeness lemma: complete evidence whose values are within θ is accepted", against the gate that rejects everything.
- **Recommendation:** nothing for the statement. The layer map's Source cell for the verdict row could add core v2's positive controls, as the gap statements' row does, in a later docs change.

**Lead 4, `no_flip`: the passage's rule is the hypothesis.**
- **The readings:** `T` assumes a grader that ignores metrics (`Noninterfering`), so it holds for every verdict, as `no_flip_holds_any` in `Gamers.lean` shows. The second formalization put SIRUS §1.4's homomorphism rule in the same hypothesis. So the two are equivalent only because both always hold. The back-translation adds that metrics copied into the record, or built into the grader, aren't screened.
- **Known since v1:** [§7](#7-no_flip-not-refuted-the-hypothesis-fails-instead) above, and the layer map: "no real grader shown noninterfering yet". The collectors' metamorphic tests check the property on the pilot's own collectors.
- **Recommendation:** nothing.

**Also found, not leads.**
- **JSG V's monoid laws** give an identity, the all-zero grade, and the vertical operator's idempotence. No frozen theorem states either. Idempotence on floors is the gamers section's candidate against `floorAdd`.
- **`accept_bounds_truth` reads no lower end,** as the back-translation noted. It's the gamers section's `enclosesHiOnly`.
- **A narrowing may be any sub-interval,** a point included, whether or not evidence could reach it, as `definitelyFails_spec`'s back-translation noted. D's and G's docstrings read a narrowing as more evidence, as `Narrows`' docstring does.
