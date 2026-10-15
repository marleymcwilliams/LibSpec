# Statements review: mutants and witnesses

Review support before `statements-v1` is tagged. Nothing here changes a statement. For each of the 16 theorems in `lean/JSG/Statements.lean`, it shows the Prop its mutant refutes in `lean/JSG/Tests/Mutants.lean`, next to the statement.

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
| `Loader.safe` | Restated copy **without the `Loader` structure** | A bare step relation with no `inv_step`; no `Loader` can fail the statement |
| `Loader.terminates` | Restated copy **without the `Loader` structure** | A bare relation with no `progress`; `retry_breaks_progress` shows the retry can't be a `Loader` |
| `charge_append` | Restated copy | `charge` → `chargeMerged`; `E` = ℝ |
| `charge_chatter` | Restated copy | `charge` → `chargeMerged`; `E` = ℝ |
| `expiry_tightens` | Restated copy, **different shape** | Lists and `Sublist` instead of sets and `⊆`; `revertRecent` for `effective`; `P` = Prop |
| `bridge` | Restated copy **with the hypothesis reversed** | `θ₂ ≤ θ₁` became `θ₁ ≤ θ₂`; `verdict` unchanged ([Q2](QUEUE.md)) |
| `fold_check_vacuous` | Restated copy | `fold` → `foldUncapped` |
| `mfGate_monotone` | **Not refuted**: the same Props for a history the gate rejects | No gate is mutated; the drafts' history fails `hg` ([Q3](QUEUE.md)) |
| `dwell_lower_bound` | Restated copy **with a different hypothesis** | JSG I's lemma: "speed at least α" replaces "speed at most `Smax`" |

The two definitions with Mutant lines, `Noninterfering` and `Calibrated`, are refuted on their own Props.

**What this means.**
- **9 theorems** have a mutant that plugs a wrong implementation into the statement: `interchange` through its own Prop, and 8 through faithful copies that swap one definition.
- **`bridge`'s mutant refutes a different statement.** No wrong implementation currently fails `bridge`. See [Q2](QUEUE.md).
- **`mfGate_monotone`'s mutant is a history, not a gate.** The real gate rejects that history, so the theorem's hypothesis fails and the theorem isn't touched. A gate that accepts every change, run on the same history, would fail it. See [Q3](QUEUE.md).
- **`no_flip`** is proved by `rw` and holds for every grader that satisfies `Noninterfering`. Its mutant shows the hypothesis carries the weight; the real work is proving `Noninterfering` for each concrete grader, which is deferred.
- **`Loader.safe` and `Loader.terminates`** hold for every `Loader`, because `inv_step` and `progress` are fields you must prove to build one. Their mutants are relations that can't be built as Loaders. They get teeth when a concrete Loader is defined (Milestone 2); not yet.
- **`expiry_tightens`'s mutant has a different shape by necessity:** "revert to the most recent policy" needs an order, so it works on lists.
- **`dwell_lower_bound`** has no definition to mutate, so its mutant is the wrong lemma, JSG I's.

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

### 13. `bridge`: restated copy with the hypothesis reversed
```lean
-- Statement
theorem bridge {Inp : Type} (gradeOf : Inp → Grade ι) {θ₁ θ₂ : ι → ENNReal}
    (h : θ₂ ≤ θ₁) :
    {x | verdict θ₂ (gradeOf x) = .accept} ⊆ {x | verdict θ₁ (gradeOf x) = .accept}
-- Mutant: θ₁ ≤ θ₂ instead of θ₂ ≤ θ₁; nothing is plugged in
theorem bridge_mutant :
    ¬ ∀ (gradeOf : Unit → Grade Unit) (θ₁ θ₂ : Unit → ENNReal), θ₁ ≤ θ₂ →
      {x | verdict θ₂ (gradeOf x) = .accept} ⊆ {x | verdict θ₁ (gradeOf x) = .accept}
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

### 15. `mfGate_monotone`: not refuted; the same Props for a history the gate rejects
```lean
-- Statement
theorem mfGate_monotone {C : Type} (signed : Set C → Prop) (MF : ℕ → Set C)
    (hg : ∀ t, mfGate signed (MF t) (MF (t + 1)))
    (hs : ∀ s, signed s → s = ∅) : Monotone MF
-- Mutant: hg fails for this history, and the history isn't monotone
theorem mfGate_monotone_mutant :
    ¬ mfGate nothingSigned (draftHistory 0) (draftHistory 1) ∧ ¬ Monotone draftHistory
```

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
| `bridge` | `h : θ₂ ≤ θ₁` | conclusion only | all proved |
| `fold_check_vacuous` | `h : 0 ≤ Rmax` | conclusion only | all proved |
| `dwell_lower_bound` | `hS`, `hlip`, `h₁`, `h₂`, `ht` | missed `hS` and `ht` | all proved |

The remaining witnesses already covered everything:
- `combine_comm`, `combine_assoc`, `interchange`, `charge_append` and `charge_chatter` have no hypotheses.
- `Loader.terminates` has only typeclass instances, which Lean finds for ℕ.
- `mfGate_monotone`'s witness already proved `hg` and `hs`.
