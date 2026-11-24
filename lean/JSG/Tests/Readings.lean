import JSG.Defs
import JSG.Tests.Gamers

/-!
Independent readings of the ordinal core's ten theorems, the ten that
guide/STATEMENTS_REVIEW.md's section "Gamers and the kill matrix: the ordinal core" tests. Its
section "Independent readings: the ordinal core" gives both readings and what each finding means.
Both produce leads only: by the hardening plan's decision 2, a model's review never counts
toward `statement_fidelity`.

* **A back-translation.** A fresh-context subagent read one frozen statement, named `T`, with the
  definitions it uses, stripped of docstrings and comments, and wrote what `T` claims and what it
  leaves out. That reading is prose; the review compares it with the docstring and the source.
* **A second formalization.** Another fresh-context subagent read only the passage the layer map
  cites as the theorem's source, or for the Milestone 5 theorems its roadmap bullet, with the same
  definitions, and wrote its own Lean statement.

This file states each frozen statement and each second formalization as a predicate on the
definition the theorem constrains: `combine`, `verdict` or `DefinitelyFails`, with every other
definition fixed, as `JSG.Tests.Gamers`'s restated copies do. For each theorem it proves the two
equivalent for every such definition, or, where neither implies the other, gives a definition
for each direction. An `example` checks by `Iff.rfl` that each predicate, at the frozen
definitions, is the statement it stands for: the frozen statement, or the one its subagent wrote.

Like `JSG.Tests.Gamers`, this file imports only the definitions and the test modules, so nothing
here leans on the proofs of the frozen theorems.
-/

namespace JSG.Tests.Readings

open JSG JSG.Tests.Mutants JSG.Tests.Gamers

/-- A combination, as `combine` is: one for each assignment of kinds to axes. -/
abbrev Comb (ι : Type) := (ι → Kind) → Grade ι → Grade ι → Grade ι

/-- A verdict, as `verdict` is. -/
abbrev Verd (ι : Type) := (ι → ENNReal) → Grade ι → Decision

/-- A test of definite failure, as `DefinitelyFails` is. -/
abbrev Fails (ι : Type) := (ι → ENNReal) → Grade ι → Prop

/-! ## `combine_comm`, from JSG V §2: equivalent -/

/-- `combine_comm`, as a predicate on the combination. -/
def CommFrozen {ι : Type} (C : Comb ι) : Prop := ∀ kind (g h : Grade ι), C kind g h = C kind h g

/-- The second formalization, `aggregation_comm`. -/
def CommSecond {ι : Type} (C : Comb ι) : Prop := ∀ kind (g h : Grade ι), C kind g h = C kind h g

example {ι : Type} : CommFrozen (ι := ι) combine ↔
    ∀ (kind : ι → Kind) (g h : Grade ι), combine kind g h = combine kind h g := Iff.rfl

example {ι : Type} : CommSecond (ι := ι) combine ↔
    ∀ (kind : ι → Kind) (g h : Grade ι), combine kind g h = combine kind h g := Iff.rfl

/-- The second formalization is the frozen statement, up to names. -/
theorem comm_equivalent {ι : Type} (C : Comb ι) : CommFrozen C ↔ CommSecond C := Iff.rfl

/-! ## `combine_assoc`, from JSG V §2: equivalent -/

/-- `combine_assoc`, as a predicate on the combination. -/
def AssocFrozen {ι : Type} (C : Comb ι) : Prop :=
  ∀ kind (g h l : Grade ι), C kind (C kind g h) l = C kind g (C kind h l)

/-- The second formalization, which its subagent also named `combine_assoc`. -/
def AssocSecond {ι : Type} (C : Comb ι) : Prop :=
  ∀ kind (x y z : Grade ι), C kind (C kind x y) z = C kind x (C kind y z)

example {ι : Type} : AssocFrozen (ι := ι) combine ↔ ∀ (kind : ι → Kind) (g h l : Grade ι),
    combine kind (combine kind g h) l = combine kind g (combine kind h l) := Iff.rfl

example {ι : Type} : AssocSecond (ι := ι) combine ↔ ∀ (kind : ι → Kind) (x y z : Grade ι),
    combine kind (combine kind x y) z = combine kind x (combine kind y z) := Iff.rfl

/-- The second formalization is the frozen statement, up to names. -/
theorem assoc_equivalent {ι : Type} (C : Comb ι) : AssocFrozen C ↔ AssocSecond C := Iff.rfl

/-! ## `interchange`, from JSG V §2: different

`seqComp` and `parComp` are both `combine`, so in the frozen statement both become `C`, and it
says that each `C kind` is medial. The second formalization is JSG V's lax law: its vertical
operator, the max on every axis, is `C` with every axis a floor, its horizontal operator is
`C kind`, and its order is read on both ends. Neither implies the other: `combineFlipped`
satisfies only the frozen statement, and `mulPlus` only the second. -/

/-- `interchange`, as a predicate on the combination. -/
def InterchangeFrozen {ι : Type} (C : Comb ι) : Prop := ∀ kind, Interchange (C kind) (C kind)

/-- The second formalization, `lax_interchange`. -/
def InterchangeSecond {ι : Type} (C : Comb ι) : Prop :=
  ∀ (kind : ι → Kind) (x x' y y' : Grade ι) (i : ι),
    (C (fun _ => .floor) (C kind x y) (C kind x' y') i).lo
        ≤ (C kind (C (fun _ => .floor) x x') (C (fun _ => .floor) y y') i).lo
      ∧ (C (fun _ => .floor) (C kind x y) (C kind x' y') i).hi
        ≤ (C kind (C (fun _ => .floor) x x') (C (fun _ => .floor) y y') i).hi

example {ι : Type} : InterchangeFrozen (ι := ι) combine ↔
    ∀ kind : ι → Kind, Interchange (seqComp kind) (parComp kind) := Iff.rfl

example {ι : Type} : InterchangeSecond (ι := ι) combine ↔
    ∀ (kind : ι → Kind) (x x' y y' : Grade ι), ∀ i : ι,
      (seqComp (fun _ : ι => Kind.floor) (parComp kind x y) (parComp kind x' y') i).lo ≤
          (parComp kind (seqComp (fun _ : ι => Kind.floor) x x')
            (seqComp (fun _ : ι => Kind.floor) y y') i).lo ∧
        (seqComp (fun _ : ι => Kind.floor) (parComp kind x y) (parComp kind x' y') i).hi ≤
          (parComp kind (seqComp (fun _ : ι => Kind.floor) x x')
            (seqComp (fun _ : ι => Kind.floor) y y') i).hi := Iff.rfl

/-- JSG V's lax law holds for the frozen `combine`: on a floor both sides are the max of all four,
    and on a budget the max of two sums is at most the sum of two maxes. -/
theorem interchangeSecond_combine {ι : Type} : InterchangeSecond (ι := ι) combine := by
  intro kind x x' y y' i
  simp only [combine]
  cases kind i <;> simp only [combineAxis]
  · exact ⟨le_of_eq (max_max_max_comm _ _ _ _), le_of_eq (max_max_max_comm _ _ _ _)⟩
  · exact ⟨max_le (add_le_add (le_max_left _ _) (le_max_left _ _))
        (add_le_add (le_max_right _ _) (le_max_right _ _)),
      max_le (add_le_add (le_max_left _ _) (le_max_left _ _))
        (add_le_add (le_max_right _ _) (le_max_right _ _))⟩

/-- Floor and budget swapped. -/
def flipKind : Kind → Kind
  | .floor => .budget
  | .budget => .floor

/-- `combine` with every axis's kind swapped: floors add, and budgets take the max. Invented. -/
def combineFlipped {ι : Type} : Comb ι := fun kind => combine (fun i => flipKind (kind i))

/-- The frozen statement holds for `combineFlipped`, as it does for any combination that is
    commutative and associative on each axis. -/
theorem interchangeFrozen_combineFlipped {ι : Type} :
    InterchangeFrozen (ι := ι) combineFlipped := by
  intro kind a b c d
  funext i
  simp only [combineFlipped, combine]
  cases kind i
  · exact Bound.ext (add_add_add_comm _ _ _ _) (add_add_add_comm _ _ _ _)
  · exact Bound.ext (max_max_max_comm _ _ _ _) (max_max_max_comm _ _ _ _)

/-- JSG V's lax law fails for `combineFlipped`: on a budget, which now takes the max, with the
    known 1 at x and y′ and the known 0 at x′ and y, the left side is 2 and the right side 1. -/
theorem interchangeSecond_fails_combineFlipped :
    ¬ InterchangeSecond (ι := Unit) combineFlipped := by
  intro h
  have := (h budget (k 1) (k 0) (k 0) (k 1) ()).2
  norm_num [combineFlipped, combine, combineAxis, flipKind, budget, k, Bound.known, max_def]
    at this

/-- On a floor, as `combineAxis`; on a budget, `a * b + b` on each end. Monotone in each operand,
    but not medial. Invented. -/
noncomputable def mulPlusAxis : Kind → Bound → Bound → Bound
  | .floor, a, b => combineAxis .floor a b
  | .budget, a, b =>
      ⟨a.lo * b.lo + b.lo, a.hi * b.hi + b.hi, add_le_add (mul_le_mul' a.le b.le) b.le⟩

/-- `mulPlusAxis` on every axis. -/
noncomputable def mulPlus {ι : Type} : Comb ι :=
  fun kind g h i => mulPlusAxis (kind i) (g i) (h i)

/-- JSG V's lax law holds for `mulPlus`: on a budget, a horizontal operator that is monotone in
    each operand is enough. -/
theorem interchangeSecond_mulPlus {ι : Type} : InterchangeSecond (ι := ι) mulPlus := by
  intro kind x x' y y' i
  simp only [mulPlus]
  cases kind i <;> simp only [mulPlusAxis, combineAxis]
  · exact ⟨le_of_eq (max_max_max_comm _ _ _ _), le_of_eq (max_max_max_comm _ _ _ _)⟩
  · exact ⟨max_le
        (add_le_add (mul_le_mul' (le_max_left _ _) (le_max_left _ _)) (le_max_left _ _))
        (add_le_add (mul_le_mul' (le_max_right _ _) (le_max_right _ _)) (le_max_right _ _)),
      max_le (add_le_add (mul_le_mul' (le_max_left _ _) (le_max_left _ _)) (le_max_left _ _))
        (add_le_add (mul_le_mul' (le_max_right _ _) (le_max_right _ _)) (le_max_right _ _))⟩

/-- The frozen statement fails for `mulPlus`: on a budget, with the known 1 at a, b and d and the
    known 0 at c, the two groupings give 3 and 2. -/
theorem interchangeFrozen_fails_mulPlus : ¬ InterchangeFrozen (ι := Unit) mulPlus := by
  intro h
  have := congrArg (fun g => (g ()).hi) (h budget (k 1) (k 1) (k 0) (k 1))
  norm_num [mulPlus, mulPlusAxis, budget, k, Bound.known] at this

/-! ## `verdict_sound`, from SIRUS §1.2–1.3: equivalent -/

/-- `verdict_sound`, as a predicate on the verdict. -/
def SoundFrozen {ι : Type} (V : Verd ι) : Prop :=
  ∀ θ (g : Grade ι) i, θ i < (g i).hi → V θ g = .reject

/-- The second formalization, `verdict_fail_closed`. -/
def SoundSecond {ι : Type} (V : Verd ι) : Prop :=
  ∀ θ (g : Grade ι) i, θ i < (g i).hi → V θ g = .reject

example {ι : Type} : SoundFrozen (ι := ι) verdict ↔ ∀ (θ : ι → ENNReal) (g : Grade ι) (i : ι),
    θ i < (g i).hi → verdict θ g = .reject := Iff.rfl

example {ι : Type} : SoundSecond (ι := ι) verdict ↔ ∀ (θ : ι → ENNReal) (g : Grade ι) (i : ι),
    θ i < (g i).hi → verdict θ g = .reject := Iff.rfl

/-- The second formalization is the frozen statement, up to names. -/
theorem sound_equivalent {ι : Type} (V : Verd ι) : SoundFrozen V ↔ SoundSecond V := Iff.rfl

/-! ## `verdict_complete`, from SIRUS §1.2–1.3: different

The passage has no rule that forces ACCEPT. The subagent formalized the one it found, §1.2's
monotonicity law, as narrowing keeping an acceptance, which is `narrowing_keeps_accept`'s claim.
`alwaysReject` satisfies only that reading, and `verdictLo` only the frozen statement. -/

/-- `verdict_complete`, as a predicate on the verdict. -/
def CompleteFrozen {ι : Type} (V : Verd ι) : Prop :=
  ∀ θ (g : Grade ι), (∀ i, (g i).lo = (g i).hi) → (∀ i, (g i).lo ≤ θ i) → V θ g = .accept

/-- The second formalization, `accept_of_more_evidence`. -/
def CompleteSecond {ι : Type} (V : Verd ι) : Prop :=
  ∀ θ (g₁ g₂ : Grade ι), (∀ i, (g₁ i).lo ≤ (g₂ i).lo ∧ (g₂ i).hi ≤ (g₁ i).hi) →
    V θ g₁ = .accept → V θ g₂ = .accept

example {ι : Type} : CompleteFrozen (ι := ι) verdict ↔ ∀ (θ : ι → ENNReal) (g : Grade ι),
    (∀ i, (g i).lo = (g i).hi) → (∀ i, (g i).lo ≤ θ i) → verdict θ g = .accept := Iff.rfl

example {ι : Type} : CompleteSecond (ι := ι) verdict ↔ ∀ (θ : ι → ENNReal) {g₁ g₂ : Grade ι},
    (∀ i, (g₁ i).lo ≤ (g₂ i).lo ∧ (g₂ i).hi ≤ (g₁ i).hi) → verdict θ g₁ = .accept →
      verdict θ g₂ = .accept := Iff.rfl

/-- The second reading holds for the frozen verdict, since its hypothesis is `Narrows g₂ g₁`. -/
theorem completeSecond_verdict {ι : Type} : CompleteSecond (ι := ι) verdict :=
  fun θ _ _ hmore hacc =>
    narrowing_keeps_accept_of_hi Narrows (fun _ _ hn i => (hn i).2) θ hacc hmore

/-- The always-reject gate satisfies the second reading, since it accepts nothing. -/
theorem completeSecond_alwaysReject {ι : Type} : CompleteSecond (ι := ι) alwaysReject := by
  intro _ _ _ _ h
  simp [alwaysReject] at h

/-- ... but not the frozen statement: `verdict_complete_mutant`. -/
theorem completeFrozen_fails_alwaysReject : ¬ CompleteFrozen (ι := Unit) alwaysReject :=
  verdict_complete_mutant

/-- `verdictLo` accepts every point within θ, so it satisfies the frozen statement. -/
theorem completeFrozen_verdictLo {ι : Type} : CompleteFrozen (ι := ι) verdictLo := by
  intro θ g _ hin
  unfold verdictLo
  exact ite_eq_left hin

/-- ... but not the second reading: under it, more evidence can undo an acceptance
    (`narrowing_keeps_accept_mutant`). -/
theorem completeSecond_fails_verdictLo : ¬ CompleteSecond (ι := Unit) verdictLo :=
  fun h => narrowing_keeps_accept_mutant fun θ g g' hacc hn => h θ g g' hn hacc

/-! ## `no_flip`, from SIRUS §1.4: equivalent, since both hold for every verdict -/

/-- `no_flip`, as a predicate on the verdict. -/
def NoFlipFrozen {ι : Type} (V : Verd ι) : Prop :=
  ∀ (E : Type) (θ : ι → ENNReal) (gradeOf : Evidence E → Grade ι), Noninterfering gradeOf →
    ∀ (r : E) (m m' : List (String × Float)), V θ (gradeOf ⟨r, m⟩) = V θ (gradeOf ⟨r, m'⟩)

/-- The second formalization, `qprime_no_flip`. -/
def NoFlipSecond {ι : Type} (V : Verd ι) : Prop :=
  ∀ (E : Type) (θ : ι → ENNReal) (gradeOf : Evidence E → Grade ι), Noninterfering gradeOf →
    ∀ (r : E) (m m' : List (String × Float)), V θ (gradeOf ⟨r, m⟩) = .reject →
      V θ (gradeOf ⟨r, m'⟩) ≠ .accept

example {ι : Type} : NoFlipFrozen (ι := ι) verdict ↔ ∀ {E : Type} (θ : ι → ENNReal)
    (gradeOf : Evidence E → Grade ι), Noninterfering gradeOf → ∀ (r : E)
      (m m' : List (String × Float)), verdict θ (gradeOf ⟨r, m⟩) = verdict θ (gradeOf ⟨r, m'⟩) :=
  Iff.rfl

example {ι : Type} : NoFlipSecond (ι := ι) verdict ↔ ∀ {E : Type} (θ : ι → ENNReal)
    (gradeOf : Evidence E → Grade ι), Noninterfering gradeOf → ∀ (r : E)
      (m m' : List (String × Float)), verdict θ (gradeOf ⟨r, m⟩) = .reject →
        verdict θ (gradeOf ⟨r, m'⟩) ≠ .accept := Iff.rfl

/-- The frozen statement holds for every verdict (`no_flip_holds_any`). -/
theorem noFlipFrozen_any {ι : Type} (V : Verd ι) : NoFlipFrozen V :=
  fun _ θ gradeOf hni r m m' => no_flip_holds_any V θ gradeOf hni r m m'

/-- So does the second reading. -/
theorem noFlipSecond_any {ι : Type} (V : Verd ι) : NoFlipSecond V := by
  intro _ θ gradeOf hni r m m' hrej
  rw [← no_flip_holds_any V θ gradeOf hni r m m', hrej]
  decide

/-- Equivalent, since both hold for every verdict: each puts the passage's rule in its
    hypothesis. -/
theorem noFlip_equivalent {ι : Type} (V : Verd ι) : NoFlipFrozen V ↔ NoFlipSecond V :=
  ⟨fun _ => noFlipSecond_any V, fun _ => noFlipFrozen_any V⟩

/-! ## `accept_bounds_truth`, from Milestone 5's C: equivalent -/

/-- `accept_bounds_truth`, as a predicate on the combination. -/
def TruthFrozen {ι : Type} (C : Comb ι) : Prop :=
  ∀ (kind : ι → Kind) (θ : ι → ENNReal) (g h : Grade ι) (x y z : ι → ENNReal),
    Encloses g x → Encloses h y → (∀ i, ComposesNoWorse (kind i) (x i) (y i) (z i)) →
      verdict θ (C kind g h) = .accept → ∀ i, z i ≤ θ i

/-- The second formalization, `accept_bounds_composed_truth`. -/
def TruthSecond {ι : Type} (C : Comb ι) : Prop :=
  ∀ (kind : ι → Kind) (θ : ι → ENNReal) (g h : Grade ι) (x y z : ι → ENNReal),
    Encloses g x → Encloses h y → (∀ i, ComposesNoWorse (kind i) (x i) (y i) (z i)) →
      verdict θ (C kind g h) = .accept → ∀ i, z i ≤ θ i

example {ι : Type} : TruthFrozen (ι := ι) combine ↔ ∀ (kind : ι → Kind) (θ : ι → ENNReal)
    (g h : Grade ι) (x y z : ι → ENNReal), Encloses g x → Encloses h y →
      (∀ i, ComposesNoWorse (kind i) (x i) (y i) (z i)) →
        verdict θ (combine kind g h) = .accept → ∀ i, z i ≤ θ i := Iff.rfl

example {ι : Type} : TruthSecond (ι := ι) combine ↔ ∀ (kind : ι → Kind) (θ : ι → ENNReal)
    (g h : Grade ι) (x y z : ι → ENNReal), Encloses g x → Encloses h y →
      (∀ i, ComposesNoWorse (kind i) (x i) (y i) (z i)) →
        verdict θ (combine kind g h) = .accept → ∀ i, z i ≤ θ i := Iff.rfl

/-- The second formalization is the frozen statement, up to names. -/
theorem truth_equivalent {ι : Type} (C : Comb ι) : TruthFrozen C ↔ TruthSecond C := Iff.rfl

/-! ## `combine_respects_narrowing`, from Milestone 5's D: equivalent -/

/-- `combine_respects_narrowing`, as a predicate on the combination. -/
def NarrowFrozen {ι : Type} (C : Comb ι) : Prop :=
  ∀ (kind : ι → Kind) {g g' h h' : Grade ι}, Narrows g' g → Narrows h' h →
    Narrows (C kind g' h') (C kind g h)

/-- The second formalization, `combine_narrows_combine`. -/
def NarrowSecond {ι : Type} (C : Comb ι) : Prop :=
  ∀ (kind : ι → Kind) {g g' h h' : Grade ι}, Narrows g' g → Narrows h' h →
    Narrows (C kind g' h') (C kind g h)

example {ι : Type} : NarrowFrozen (ι := ι) combine ↔ ∀ (kind : ι → Kind) {g g' h h' : Grade ι},
    Narrows g' g → Narrows h' h → Narrows (combine kind g' h') (combine kind g h) := Iff.rfl

example {ι : Type} : NarrowSecond (ι := ι) combine ↔ ∀ (kind : ι → Kind) {g g' h h' : Grade ι},
    Narrows g' g → Narrows h' h → Narrows (combine kind g' h') (combine kind g h) := Iff.rfl

/-- The second formalization is the frozen statement, up to names. -/
theorem narrow_equivalent {ι : Type} (C : Comb ι) : NarrowFrozen C ↔ NarrowSecond C := Iff.rfl

/-! ## `narrowing_keeps_accept`, from Milestone 5's D: equivalent -/

/-- `narrowing_keeps_accept`, as a predicate on the verdict. -/
def KeepFrozen {ι : Type} (V : Verd ι) : Prop :=
  ∀ θ {g g' : Grade ι}, V θ g = .accept → Narrows g' g → V θ g' = .accept

/-- The second formalization, `verdict_accept_of_narrows`. -/
def KeepSecond {ι : Type} (V : Verd ι) : Prop :=
  ∀ θ {g g' : Grade ι}, V θ g = .accept → Narrows g' g → V θ g' = .accept

example {ι : Type} : KeepFrozen (ι := ι) verdict ↔ ∀ (θ : ι → ENNReal) {g g' : Grade ι},
    verdict θ g = .accept → Narrows g' g → verdict θ g' = .accept := Iff.rfl

example {ι : Type} : KeepSecond (ι := ι) verdict ↔ ∀ (θ : ι → ENNReal) {g g' : Grade ι},
    verdict θ g = .accept → Narrows g' g → verdict θ g' = .accept := Iff.rfl

/-- The second formalization is the frozen statement, up to names. -/
theorem keep_equivalent {ι : Type} (V : Verd ι) : KeepFrozen V ↔ KeepSecond V := Iff.rfl

/-! ## `definitelyFails_spec`, from Milestone 5's G: equivalent -/

/-- `definitelyFails_spec`, as a predicate on the test of definite failure. -/
def FailsFrozen {ι : Type} (D : Fails ι) : Prop :=
  ∀ θ (g : Grade ι), D θ g ↔ ∀ g' : Grade ι, Narrows g' g → verdict θ g' = .reject

/-- The second formalization, `definite_rejection`: the bullet's two sentences, as two halves. -/
def FailsSecond {ι : Type} (D : Fails ι) : Prop :=
  ∀ θ (g : Grade ι), (D θ g → ∀ g' : Grade ι, Narrows g' g → verdict θ g' = .reject) ∧
    (¬ D θ g → ∃ g' : Grade ι, Narrows g' g ∧ verdict θ g' = .accept)

example {ι : Type} : FailsFrozen (ι := ι) DefinitelyFails ↔ ∀ (θ : ι → ENNReal) (g : Grade ι),
    DefinitelyFails θ g ↔ ∀ g' : Grade ι, Narrows g' g → verdict θ g' = .reject := Iff.rfl

example {ι : Type} : FailsSecond (ι := ι) DefinitelyFails ↔ ∀ (θ : ι → ENNReal) (g : Grade ι),
    (DefinitelyFails θ g → ∀ g' : Grade ι, Narrows g' g → verdict θ g' = .reject) ∧
      (¬ DefinitelyFails θ g → ∃ g' : Grade ι, Narrows g' g ∧ verdict θ g' = .accept) :=
  Iff.rfl

/-- Equivalent, since a verdict that isn't a rejection is an acceptance. -/
theorem fails_equivalent {ι : Type} (D : Fails ι) : FailsFrozen D ↔ FailsSecond D := by
  constructor
  · intro h θ g
    refine ⟨(h θ g).mp, fun hn => ?_⟩
    by_contra hne
    refine hn ((h θ g).mpr fun g' hg' => ?_)
    cases hv : verdict θ g' with
    | reject => rfl
    | accept => exact absurd ⟨g', hg', hv⟩ hne
  · intro h θ g
    refine ⟨(h θ g).1, fun hall => ?_⟩
    by_contra hn
    obtain ⟨g', hg', hacc⟩ := (h θ g).2 hn
    rw [hall g' hg'] at hacc
    cases hacc

/-- Both hold for the frozen `DefinitelyFails` (`definitelyFails_spec_of`, with `Narrows`). -/
theorem failsSecond_definitelyFails {ι : Type} : FailsSecond (ι := ι) DefinitelyFails :=
  (fails_equivalent DefinitelyFails).mp fun θ g =>
    definitelyFails_spec_of Narrows (fun g' _ hn i => le_trans (hn i).1 (g' i).le)
      (fun g i => ⟨le_rfl, (g i).le⟩) θ g

end JSG.Tests.Readings
