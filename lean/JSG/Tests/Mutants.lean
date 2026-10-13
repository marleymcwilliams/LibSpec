import JSG.Defs

/-!
Controls for the frozen statements in `JSG.Statements` (ROADMAP, Phase 2). For each
theorem, and for the two definitions that carry a `Mutant:` line:

* a **mutant**: the plausible wrong implementation named in `Statements.lean`, with a
  proof that it violates the statement;
* a **witness**: a concrete instance, with a proof that the statement holds there.

This file imports only `JSG.Defs`, so no control can lean on a theorem that is still
unproved. The witnesses for `combine_comm` and `expiry_tightens` are single computed
instances, not proofs of those theorems.
-/

namespace JSG.Tests.Mutants

open JSG

/-! ## Fixtures: grades over one axis, indexed by `Unit` -/

/-- Every axis is a budget axis. -/
def budget : Unit → Kind := fun _ => .budget

/-- A known value on the single axis. -/
def k (x : ENNReal) : Grade Unit := fun _ => Bound.known x

/-! ## combine_comm -/

/-- Mutant: overwrite, where the later stage's grade replaces the earlier one. -/
def overwrite {ι : Type} (_g h : Grade ι) : Grade ι := h

theorem combine_comm_mutant : ¬ ∀ g h : Grade Unit, overwrite g h = overwrite h g := by
  intro hc
  have := congrArg (fun g => (g ()).hi) (hc (k 0) (k 1))
  simp [overwrite, k, Bound.known] at this

theorem combine_comm_witness : combine budget (k 1) (k 2) = combine budget (k 2) (k 1) := by
  funext i
  ext <;> simp [combine, combineAxis, budget, k, Bound.known, add_comm]

/-! ## combine_assoc -/

/-- Mutant: average budget readings, (a + b) / 2, instead of adding them. -/
noncomputable def avgAxis : Kind → Bound → Bound → Bound
  | .floor,  a, b => ⟨max a.lo b.lo, max a.hi b.hi, max_le_max a.le b.le⟩
  | .budget, a, b => ⟨(a.lo + b.lo) / 2, (a.hi + b.hi) / 2,
      ENNReal.div_le_div_right (add_le_add a.le b.le) 2⟩

noncomputable def avgCombine {ι : Type} (kind : ι → Kind) (g h : Grade ι) : Grade ι :=
  fun i => avgAxis (kind i) (g i) (h i)

theorem combine_assoc_mutant :
    ¬ ∀ g h l : Grade Unit,
      avgCombine budget (avgCombine budget g h) l = avgCombine budget g (avgCombine budget h l) := by
  intro hc
  have := congrArg (fun g => (g ()).hi) (hc (k 0) (k 0) (k 2))
  simp only [avgCombine, avgAxis, budget, k, Bound.known, add_zero, zero_add,
    ENNReal.zero_div] at this
  rw [ENNReal.div_self (by norm_num) (by norm_num)] at this
  exact (ENNReal.half_lt_self one_ne_zero ENNReal.one_ne_top).ne' this

theorem combine_assoc_witness :
    combine budget (combine budget (k 1) (k 2)) (k 3)
      = combine budget (k 1) (combine budget (k 2) (k 3)) := by
  funext i
  ext <;> simp [combine, combineAxis, budget, k, Bound.known, add_assoc]

/-! ## interchange -/

/-- Mutant: JSG V's rule. Sequence takes the max on every axis (its `∧`); parallel
    composition stays core v2's `combine`. -/
def jsgVSeq {ι : Type} (g h : Grade ι) : Grade ι := fun i => combineAxis .floor (g i) (h i)

theorem interchange_mutant : ¬ Interchange jsgVSeq (parComp budget) := by
  intro hc
  have := congrArg (fun g => (g ()).hi) (hc (k 1) (k 0) (k 0) (k 1))
  simp [jsgVSeq, parComp, combine, combineAxis, budget, k, Bound.known] at this

theorem interchange_witness :
    parComp budget (seqComp budget (k 1) (k 2)) (seqComp budget (k 3) (k 4))
      = seqComp budget (parComp budget (k 1) (k 3)) (parComp budget (k 2) (k 4)) := by
  funext i
  ext <;> simp [seqComp, parComp, combine, combineAxis, budget, k, Bound.known] <;> ring

/-! ## verdict_unknown -/

/-- Mutant: a verdict that reads `lo` instead of `hi`. -/
noncomputable def verdictLo {ι : Type} (θ : ι → ENNReal) (g : Grade ι) : Decision := by
  classical
  exact if ∀ i, (g i).lo ≤ θ i then .accept else .reject

theorem verdict_unknown_mutant :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit) (i : Unit),
      θ i < ⊤ → g i = Bound.unknown → verdictLo θ g = .reject := by
  intro hc
  have := hc (fun _ => 0) (fun _ => Bound.unknown) () ENNReal.zero_lt_top rfl
  simp [verdictLo, Bound.unknown] at this

theorem verdict_unknown_witness :
    verdict (fun _ : Unit => 1) (fun _ => Bound.unknown) = .reject := by
  simp [verdict, Bound.unknown]

/-! ## verdict_complete -/

/-- Mutant: the always-REJECT gate. -/
def alwaysReject {ι : Type} (_θ : ι → ENNReal) (_g : Grade ι) : Decision := .reject

theorem verdict_complete_mutant :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit),
      (∀ i, (g i).lo = (g i).hi) → (∀ i, (g i).lo ≤ θ i) → alwaysReject θ g = .accept := by
  intro hc
  have := hc (fun _ => 0) (k 0) (fun _ => rfl) (fun _ => le_rfl)
  simp [alwaysReject] at this

theorem verdict_complete_witness : verdict (fun _ : Unit => 1) (k 1) = .accept := by
  simp [verdict, k, Bound.known]

/-! ## residual_spec -/

/-- Mutant: check each stage against the full θ. -/
def residualFull (θ _x : ENNReal) : ENNReal := θ

theorem residual_spec_mutant :
    ¬ ∀ θ x y : ENNReal, θ ≠ ⊤ → x ≤ θ → (y ≤ residualFull θ x ↔ x + y ≤ θ) := by
  intro hc
  have := (hc 1 1 1 ENNReal.one_ne_top le_rfl).mp le_rfl
  norm_num at this

theorem residual_spec_witness : (1 : ENNReal) ≤ residual 1 0 ↔ (0 : ENNReal) + 1 ≤ 1 := by
  simp [residual]

/-! ## Noninterfering and no_flip -/

/-- Mutant: a grader that narrows `hi` to 0 as soon as any metric is reported. -/
def inflatingGrader (e : Evidence Unit) : Grade Unit :=
  fun _ => if e.metrics = [] then Bound.unknown else Bound.known 0

theorem noninterfering_mutant : ¬ Noninterfering inflatingGrader := by
  intro h
  have := congrArg (fun g => (g ()).hi) (h () [] [("confidence", 0.99)])
  simp [inflatingGrader, Bound.unknown, Bound.known] at this

/-- The same grader: a confidence metric flips its verdict. -/
theorem no_flip_mutant :
    verdict (fun _ => 0) (inflatingGrader ⟨(), []⟩)
      ≠ verdict (fun _ => 0) (inflatingGrader ⟨(), [("confidence", 0.99)]⟩) := by
  simp [verdict, inflatingGrader, Bound.unknown, Bound.known]

/-- A grader that ignores metrics. -/
def constGrader (_e : Evidence Unit) : Grade Unit := k 0

theorem noninterfering_witness : Noninterfering constGrader := fun _ _ _ => rfl

theorem no_flip_witness :
    verdict (fun _ => 0) (constGrader ⟨(), []⟩)
      = verdict (fun _ => 0) (constGrader ⟨(), [("confidence", 0.99)]⟩) := rfl

/-! ## Loader.safe and Loader.terminates -/

/-- A countdown loader on ℕ: each step goes from `n + 1` to `n`, its one pending
    obligation is the counter, and the invariant is "at most 3". -/
def countdown : Loader ℕ ℕ where
  step s t := t + 1 = s
  Inv s := s ≤ 3
  inv_step s t hs h := by omega
  pending s := {s}
  progress s t h := ⟨0, {t}, {s}, by simp, by simp, by simp, by simp; omega⟩

/-- Mutant for `Loader.safe`: a countdown that skips the check excluding state 2. It
    still terminates, but a reachable state breaks the invariant. -/
def skipStep (s t : ℕ) : Prop := t + 1 = s

def skipInv (s : ℕ) : Prop := s ≠ 2

theorem loader_safe_mutant :
    ¬ ∀ s t, skipInv s → Relation.ReflTransGen skipStep s t → skipInv t := by
  intro hc
  exact hc 3 2 (by simp [skipInv]) (Relation.ReflTransGen.single rfl) rfl

theorem loader_safe_witness {s t : ℕ} (hs : countdown.Inv s)
    (hr : Relation.ReflTransGen countdown.step s t) : countdown.Inv t := by
  induction hr with
  | refl => exact hs
  | tail _ hst ih =>
    have h1 : _ + 1 = _ := hst
    have h2 : _ ≤ 3 := ih
    show _ ≤ 3
    omega

/-- Mutant for `Loader.terminates`: a retry that re-emits the same obligation, so a
    state can step to itself. -/
def retryStep (s t : Unit) : Prop := t = s

theorem loader_terminates_mutant : ¬ WellFounded (fun t s => retryStep s t) :=
  fun h => h.induction (C := fun x => ¬ retryStep x x) () (fun x ih hx => ih x hx hx) rfl

/-- The retry can't meet `progress`: the Dershowitz–Manna order is irreflexive. -/
theorem retry_breaks_progress : ¬ Multiset.IsDershowitzMannaLT ({0} : Multiset ℕ) {0} :=
  fun h => (Multiset.wellFounded_isDershowitzMannaLT.induction
    (C := fun M => ¬ Multiset.IsDershowitzMannaLT M M) {0}
    (fun M ih hM => ih M hM hM)) h

theorem loader_terminates_witness : WellFounded (fun t s => countdown.step s t) :=
  Subrelation.wf (q := fun t s => countdown.step s t) (r := (· < ·))
    (fun {t s} h => by
      have h1 : t + 1 = s := h
      omega)
    Nat.lt_wfRel.wf

/-! ## charge_append and charge_chatter -/

/-- Mutant: v1's merged-jump charge, A · ‖Σ jumps‖. -/
noncomputable def chargeMerged {E : Type} [NormedAddCommGroup E] (A : ENNReal)
    (jumps : List E) : ENNReal :=
  A * (‖jumps.sum‖₊ : ENNReal)

theorem charge_append_mutant :
    ¬ ∀ (A : ENNReal) (j₁ j₂ : List ℝ),
      chargeMerged A (j₁ ++ j₂) = chargeMerged A j₁ + chargeMerged A j₂ := by
  intro hc
  have := hc 1 [1] [-1]
  simp [chargeMerged] at this
  norm_num at this

theorem charge_append_witness :
    charge (1 : ENNReal) ([1] ++ [2] : List ℝ) = charge 1 [(1 : ℝ)] + charge 1 [(2 : ℝ)] := by
  simp [charge]

theorem charge_chatter_mutant :
    ¬ ∀ (A : ENNReal) (v : ℝ), chargeMerged A [v, -v] = 2 * A * (‖v‖₊ : ENNReal) := by
  intro hc
  have := hc 1 1
  simp [chargeMerged] at this

theorem charge_chatter_witness :
    charge (1 : ENNReal) [(1 : ℝ), -1] = 2 * 1 * (‖(1 : ℝ)‖₊ : ENNReal) := by
  simp [charge]
  norm_num

/-! ## expiry_tightens -/

/-- Mutant: on expiry, revert to the most recently activated policy (the baseline if
    none is active), which can land on a weaker one. The list is newest first. -/
def revertRecent {P : Type} (B : P) : List P → P
  | [] => B
  | w :: _ => w

theorem expiry_tightens_mutant :
    ¬ ∀ (B : Prop) (a a' : List Prop), a'.Sublist a → revertRecent B a ≤ revertRecent B a' := by
  intro hc
  exact hc True [True, False] [False] ((List.Sublist.refl [False]).cons True) trivial

theorem expiry_tightens_witness :
    effective True ({False} : Set Prop) ≤ effective True (∅ : Set Prop) := by
  simp [effective]

/-! ## bridge -/

/-- Mutant: a threshold dial stored un-inverted, so "stricter" raises θ. -/
theorem bridge_mutant :
    ¬ ∀ (gradeOf : Unit → Grade Unit) (θ₁ θ₂ : Unit → ENNReal), θ₁ ≤ θ₂ →
      {x | verdict θ₂ (gradeOf x) = .accept} ⊆ {x | verdict θ₁ (gradeOf x) = .accept} := by
  intro hc
  have hacc : () ∈ {x : Unit | verdict (fun _ => 1) ((fun _ => k 1) x) = .accept} := by
    simp [verdict, k, Bound.known]
  have := hc (fun _ => k 1) (fun _ => 0) (fun _ => 1) (fun _ => zero_le_one) hacc
  simp [verdict, k, Bound.known] at this

theorem bridge_witness :
    {x : Unit | verdict (fun _ => 0) ((fun _ => k 0) x) = .accept}
      ⊆ {x : Unit | verdict (fun _ => 1) ((fun _ => k 0) x) = .accept} := by
  intro _ _
  simp [verdict, k, Bound.known]

/-! ## fold_check_vacuous -/

/-- Mutant: the uncapped fold, a plain weighted sum. -/
def foldUncapped (_Rmax lam : ℝ) (rs : List ℝ) : ℝ := rs.foldl (fun x y => x + lam * y) 0

theorem fold_check_vacuous_mutant :
    ¬ ∀ (Rmax lam : ℝ), 0 ≤ Rmax → ∀ rs : List ℝ, foldUncapped Rmax lam rs ≤ Rmax := by
  intro hc
  have := hc 0 1 le_rfl [1]
  norm_num [foldUncapped] at this

theorem fold_check_vacuous_witness : fold 1 1 [2] ≤ 1 := by
  norm_num [fold]

/-! ## Calibrated -/

theorem calibrated_mutant : ¬ Calibrated (fun _ : Unit => Decision.reject) {()} ∅ := by
  rintro ⟨_, hmp, _⟩
  exact absurd (hmp () (Set.mem_singleton ())) (by decide)

theorem calibrated_witness : Calibrated (fun _ : Unit => Decision.accept) {()} ∅ :=
  ⟨by simp, fun _ _ => rfl, fun _ h => absurd h (by simp)⟩

/-! ## mfGate_monotone -/

/-- Failure classes for the mutant. GOLDEN_RULE_BREACH comes from the corpus
    (`SIRUS/main.tex`), though it sits outside the v1 gate (`decisions/RAILS.md`). -/
inductive FailClass | goldenRuleBreach | other
  deriving DecidableEq

/-- Mutant: Draft0–7's history, which dropped GOLDEN_RULE_BREACH with nothing signed. -/
def draftHistory : ℕ → Set FailClass
  | 0 => {.goldenRuleBreach, .other}
  | _ => {.other}

/-- Nothing is signed: the only signable removal is the empty one. -/
def nothingSigned (s : Set FailClass) : Prop := s = ∅

theorem mfGate_monotone_mutant :
    ¬ mfGate nothingSigned (draftHistory 0) (draftHistory 1) ∧ ¬ Monotone draftHistory := by
  have hmem : FailClass.goldenRuleBreach ∈ draftHistory 0 := by simp [draftHistory]
  have hnot : FailClass.goldenRuleBreach ∉ draftHistory 1 := by simp [draftHistory]
  refine ⟨?_, fun hm => hnot (hm (Nat.zero_le 1) hmem)⟩
  rintro (h | h)
  · exact hnot (h hmem)
  · have : FailClass.goldenRuleBreach ∈ draftHistory 0 \ draftHistory 1 := ⟨hmem, hnot⟩
    rw [show draftHistory 0 \ draftHistory 1 = ∅ from h] at this
    exact this

/-- A history that keeps its classes: the gate accepts every step and it only grows. -/
def keptHistory : ℕ → Set FailClass := fun _ => {.goldenRuleBreach}

theorem mfGate_monotone_witness :
    (∀ t, mfGate nothingSigned (keptHistory t) (keptHistory (t + 1)))
      ∧ (∀ s, nothingSigned s → s = ∅) ∧ Monotone keptHistory :=
  ⟨fun _ => Or.inl subset_rfl, fun _ h => h, fun _ _ _ => le_rfl⟩

/-! ## dwell_lower_bound -/

/-- Mutant: JSG I's version, which assumes the distance moves at least as fast as α
    instead of at most as fast as a speed bound. A trajectory moving 100 times faster
    than α crosses in 1/50 of the time the claim allows. -/
theorem dwell_lower_bound_mutant :
    ¬ ∀ (d : ℝ → ℝ) (α r t₁ t₂ : ℝ), 0 < α → (∀ s t, α * |t - s| ≤ |d t - d s|) →
      d t₁ = r → d t₂ = -r → t₁ ≤ t₂ → 2 * r / α ≤ t₂ - t₁ := by
  intro hc
  have hfast : ∀ s t : ℝ, 1 * |t - s| ≤ |(1 - 100 * t) - (1 - 100 * s)| := by
    intro s t
    rw [show (1 - 100 * t) - (1 - 100 * s) = -100 * (t - s) by ring, abs_mul, one_mul]
    norm_num
    nlinarith [abs_nonneg (t - s)]
  have := hc (fun t => 1 - 100 * t) 1 1 0 (1 / 50) one_pos hfast (by norm_num) (by norm_num)
    (by norm_num)
  norm_num at this

theorem dwell_lower_bound_witness :
    (∀ s t : ℝ, |(1 - t) - (1 - s)| ≤ 1 * |t - s|) ∧ (1 : ℝ) - 0 = 1 ∧ (1 : ℝ) - 2 = -1
      ∧ (2 * 1 / 1 : ℝ) ≤ 2 - 0 := by
  refine ⟨fun s t => ?_, by norm_num, by norm_num, by norm_num⟩
  rw [show (1 - t) - (1 - s) = -(t - s) by ring, abs_neg, one_mul]

end JSG.Tests.Mutants
