# Statements review: mutants and witnesses

Review support before `statements-v1` is tagged. Nothing here changes a statement. Updated for the Q2, Q3 and Q4 restatements of `bridge`, the must-fail gate and the verdict. For each of the 16 theorems in `lean/JSG/Statements.lean`, it shows the Prop its mutant refutes in `lean/JSG/Tests/Mutants.lean`, next to the statement. The [statements-v2](#statements-v2) section at the end does the same for the seven theorems that version adds.

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

**A concrete Loader (L1–L10) is still owed.** When Milestone 2 proves these theorems, its milestone note must say so. ROADMAP's Milestone 2 now carries that reminder. `statements-v2` states one, `LoaderStep`, with its own two theorems; see [statements-v2](#statements-v2).

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

Review support for the `statements-v2` proposal, read the same way as above. The seven theorems are in sections 8–11 of `lean/JSG/Statements.lean`, their definitions in the same sections of `lean/JSG/Defs.lean`, and their controls in the "statements-v2" part of `lean/JSG/Tests/Mutants.lean`. Every mutant comes from a defect in `archive/`, except `threads_spec`'s, which comes from v1's own `residual`.

**Context.** Besides `variable {ι : Type} (kind : ι → Kind)`, section 9 adds `{St O W : Type}`: stages, obligations and witnesses. Section 10 adds `{Bytes D : Type}`: bytes and digests.

**Fixtures.** The v2 controls use one axis (`Unit`). Where stages matter they use `Stg`, two of JSG V's stages (EF and PR), and otherwise `Unit`. Obligations are `Unit`, or ℕ where their order matters: ℕ's order stands in for JSG V's type order, with RequiresHitmap as 1 and OmegaPrecond, which ranks above it, as 2. The Loader controls use toy primitives: the digest is the identity, every signature verifies, replay returns the probe, and a bundle's root is its length.

| Theorem | The mutant refutes | What differs from the statement | The defect it comes from |
| --- | --- | --- | --- |
| `lease_breach` | Restated copy | `leaseVerdict` → `qPrimeGate`, the plain verdict, which reads `hi` only | SirusSC `specchain/algebra/q_prime.py`: `QPrime`'s only guard is `guard_no_bottom` |
| `lease_complete` | Restated copy | `leaseVerdict` → `pointsOnly`, which accepts points only | SirusSC `specchain/algebra/q.py`, where ⊥ absorbs, and `loader.py`'s guards, which reject it (`C_UNK_PRICED`) |
| `pass_sound` | Restated copy (`PassSoundHolds`) | `afterStage` → `afterListed`, which checks only the witness | JSG V §3: the displayed stage transition, and the matrix row that lists PR or EF for RetuneDisabledInRed |
| `pass_complete` | Restated copy (`PassCompleteHolds`) | `Passes` → `Passes ∧ ISigma` | JSG V §3: Invariant I_Σ-Progress, which its CI check runs on passing runs |
| `LoaderStep.inv_step` | Restated copy, two mutants | `LoaderStep` → `TRowStep`, without `hiso` and `hround`; or → `SirusIsoStep`, with `hiso` waived for a stage missing from the table | SCp3 §6.3, rule T-Row; SirusSC `loader.py`, `_resolve_allowed_axes` and `_detect_axis_leaks` |
| `LoaderStep.progress` | Restated copy, two mutants | `LoaderStep` → `OrStep`, with `hdis ∨ hsmall` for both; or → `LoaderStep` plus a step from every state to itself | JSG V §3, Lemma (Progress via multiset ordering); SCp3 §6.3, rules T-AdapterAttest, T-AxisIsolation, T-AdapterMono and T-Attest |
| `threads_spec` | Restated copy | `Threads` → `ResidualOnly`, which checks only the last stage's fit | `statements-v1`'s `residual`, used without `residual_spec`'s `hx` (QUEUE.md, Q5) |

**What this means.**
- **No v1 statement or definition changes.** Each v2 theorem is new, and so is every definition it uses.
- **`LoaderStep.inv_step` and `LoaderStep.progress` are the two fields a `Loader` needs.** Once both are proved, `LoaderStep kind prims M`, with `LoaderInv kind prims` as its invariant and each state's `pending` as its obligations, is a `Loader`, and `Loader.safe` and `Loader.terminates` apply to it. Unlike those two, these theorems can fail: each mutant is a step relation that breaks one.
- **`pass_sound` and `pass_complete` are a pair, like `verdict_sound` and `verdict_complete`.** A transition that never discharges anything satisfies `pass_sound`; `pass_complete` rules it out.

### 17. `lease_breach`: restated copy
```lean
-- Statement
theorem lease_breach (θ β : ι → ENNReal) (g : Grade ι) (i : ι) (hwide : β i < (g i).width) :
    leaseVerdict θ β g = .reject
-- Mutant: SirusSC's QPrime, which never reads a width
theorem lease_breach_mutant :
    ¬ ∀ (θ β : Unit → ENNReal) (g : Grade Unit) (i : Unit),
      β i < (g i).width → qPrimeGate θ β g = .reject
```

### 18. `lease_complete`: restated copy
```lean
-- Statement
theorem lease_complete (θ β : ι → ENNReal) (g : Grade ι) (hlease : WithinLease β g)
    (hin : ∀ i, (g i).lo + β i ≤ θ i) : leaseVerdict θ β g = .accept
-- Mutant: SirusSC's Q, where a reading wider than a point can only be ⊥
theorem lease_complete_mutant :
    ¬ ∀ (θ β : Unit → ENNReal) (g : Grade Unit), WithinLease β g →
      (∀ i, (g i).lo + β i ≤ θ i) → pointsOnly θ β g = .accept
```

### 19. `pass_sound`: restated copy
```lean
-- Statement
theorem pass_sound (θ β : ι → ENNReal) (M : DischargeMatrix St O W) (pend₀ : Multiset O)
    (pre post : List (StageRun ι St O W)) (r : StageRun ι St O W)
    (hpass : Passes kind θ β M pend₀ (pre ++ r :: post)) {o : O}
    (ho : o ∈ pendingAfter M pend₀ pre + r.emits) :
    ∃ s ∈ r :: post, M.Discharges s o
-- The claim at the fixtures, with the stage transition as a parameter
def PassSoundHolds (M : DischargeMatrix Stg Unit Bool)
    (after : Multiset Unit → StageRun Unit Stg Unit Bool → Multiset Unit) : Prop :=
  ∀ (θ β : Unit → ENNReal) (pend₀ : Multiset Unit) (pre post : List (StageRun Unit Stg Unit Bool))
    (r : StageRun Unit Stg Unit Bool),
    leaseVerdict θ β (windowGrade budget (pre ++ r :: post)) = .accept →
    (pre ++ r :: post).foldl after pend₀ = 0 →
    ∀ o ∈ pre.foldl after pend₀ + r.emits, ∃ s ∈ r :: post, M.Discharges s o
-- Mutant: JSG V's displayed transition, which checks only the witness
theorem pass_sound_mutant : ¬ PassSoundHolds retuneRed (afterListed retuneRed)
```

`PassSoundHolds M (afterStage M)` is `pass_sound` at these fixtures: `Passes` unfolds to the grade check and `pendingAfter`, which is the fold of `afterStage`. In the counterexample, EF emits RetuneDisabledInRed while Red, and PR later produces the witness. The mutant lets PR discharge it, so the window passes, though EF, its only authority, never discharges it.

### 20. `pass_complete`: restated copy
```lean
-- Statement
theorem pass_complete (θ β : ι → ENNReal) (M : DischargeMatrix St O W) (pend₀ : Multiset O)
    (pre : List (StageRun ι St O W)) (r : StageRun ι St O W)
    (hgrade : leaseVerdict θ β (windowGrade kind (pre ++ [r])) = .accept)
    (hlast : ∀ o ∈ pendingAfter M pend₀ pre + r.emits, M.Discharges r o) :
    Passes kind θ β M pend₀ (pre ++ [r])
-- The claim at the fixtures, with the pass condition as a parameter
def PassCompleteHolds (passes : (Unit → ENNReal) → (Unit → ENNReal) →
    DischargeMatrix Unit ℕ Unit → Multiset ℕ → List (StageRun Unit Unit ℕ Unit) → Prop) : Prop :=
  ∀ θ β M pend₀ (pre : List (StageRun Unit Unit ℕ Unit)) r,
    leaseVerdict θ β (windowGrade budget (pre ++ [r])) = .accept →
    (∀ o ∈ pendingAfter M pend₀ pre + r.emits, M.Discharges r o) →
    passes θ β M pend₀ (pre ++ [r])
-- Mutant: passing also requires JSG V's I_Σ
theorem pass_complete_mutant :
    ¬ PassCompleteHolds
      (fun θ β M pend₀ run => Passes budget θ β M pend₀ run ∧ ISigma M pend₀ run)
```

The counterexample is one idle stage from an empty Σ. It passes, but I_Σ asks the empty multiset to fall, and nothing is below it.

### 21. `LoaderStep.inv_step`: restated copy, two mutants
```lean
-- Statement
theorem LoaderStep.inv_step [Preorder O] (prims : Prims Bytes D) (M : DischargeMatrix St O W)
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
-- Mutant: JSG V's progress lemma, hdis ∨ hsmall for both
theorem loader_progress_mutant :
    ¬ ∀ s t, OrStep hitmapOnly s t → Multiset.IsDershowitzMannaLT t.pending s.pending
-- Mutant: SCp3's check rules, each a step from a state to itself
theorem loader_progress_selfloop_mutant :
    ¬ ∀ s t, (LoaderStep budget toyPrims anyStage s t ∨ t = s) →
      Multiset.IsDershowitzMannaLT t.pending s.pending
```

Under JSG V's "or", a stage that discharges RequiresHitmap and emits OmegaPrecond qualifies, and Σ goes from {1} to {2}. A self-loop leaves Σ where it was. The Dershowitz–Manna order allows neither.

### 23. `threads_spec`: restated copy
```lean
-- Statement
theorem threads_spec (θ : ENNReal) (hθ : θ ≠ ⊤) (xs : List ENNReal) :
    Threads θ xs ↔ xs.sum ≤ θ
-- Mutant: v1's residual check alone
theorem threads_spec_mutant :
    ¬ ∀ θ : ENNReal, θ ≠ ⊤ → ∀ xs : List ENNReal, (ResidualOnly θ xs ↔ xs.sum ≤ θ)
```

### Witnesses

Each witness proves every hypothesis of its theorem, then the conclusion, for one concrete instance.

| Theorem | Hypotheses | Instance |
| --- | --- | --- |
| `lease_breach` | `hwide` | [0, 5] with lease 1, under θ = 10 |
| `lease_complete` | `hlease`, `hin` | [0, 1] with lease 1, under θ = 1 |
| `pass_sound` | `hpass`, `ho` | EF emits RequiresHitmap and PR discharges it; the run split at EF |
| `pass_complete` | `hgrade`, `hlast` | the same run, with PR as the last stage |
| `LoaderStep.inv_step` | `hs`, `h` | one stage prices a row and discharges the one pending obligation; the invariant is proved after the step too |
| `LoaderStep.progress` | `h` | a stage discharges OmegaPrecond and emits RequiresHitmap |
| `threads_spec` | `hθ` | θ = 10 with stages 3 then 4, where both sides hold; θ = 1 with stages 2 then 0, where neither does |
