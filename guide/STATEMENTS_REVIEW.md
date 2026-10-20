# Statements review: mutants and witnesses

Review support before `statements-v1` is tagged. Nothing here changes a statement. Updated for the Q2 and Q3 restatements of `bridge` and the must-fail gate. For each of the 16 theorems in `lean/JSG/Statements.lean`, it shows the Prop its mutant refutes in `lean/JSG/Tests/Mutants.lean`, next to the statement.

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
| `verdict_unknown` | Restated copy | `verdict` → `verdictLo` |
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

**A concrete Loader (L1–L10) is still owed.** When Milestone 2 proves these theorems, its milestone note must say so. ROADMAP's Milestone 2 now carries that reminder.

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

### 4. `verdict_unknown`: restated copy
```lean
-- Statement
theorem verdict_unknown (θ : ι → ENNReal) (g : Grade ι) (i : ι)
    (hθ : θ i < ⊤) (hu : g i = Bound.unknown) : verdict θ g = .reject
-- Mutant
theorem verdict_unknown_mutant :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit) (i : Unit),
      θ i < ⊤ → g i = Bound.unknown → verdictLo θ g = .reject
```

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
| `verdict_unknown` | `hθ`, `hu` | conclusion only | all proved |
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
