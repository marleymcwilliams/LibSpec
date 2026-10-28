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

/-- Every axis is a floor axis. -/
def floor : Unit → Kind := fun _ => .floor

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

/-- Mutant: SCp2's operator pair, a real defect (ROADMAP, Milestone 1 notes). Sequence is
    its ⋆, + on every axis (SirusSC's `Q.sequential`); parallel composition is its ⊎, max
    on floors (`Q.hetero_join`). On a floor axis with a = 1, b = 0, c = 0, d = 1,
    parallel-of-sequences grades max(1 + 0, 0 + 1) = 1 and sequence-of-parallels 2. -/
def scp2Seq {ι : Type} (g h : Grade ι) : Grade ι := fun i => combineAxis .budget (g i) (h i)

theorem interchange_scp2_mutant : ¬ Interchange scp2Seq (parComp floor) := by
  intro hc
  have := congrArg (fun g => (g ()).hi) (hc (k 1) (k 0) (k 0) (k 1))
  simp [scp2Seq, parComp, combine, combineAxis, floor, k, Bound.known] at this
  norm_num at this

theorem interchange_witness :
    parComp budget (seqComp budget (k 1) (k 2)) (seqComp budget (k 3) (k 4))
      = seqComp budget (parComp budget (k 1) (k 3)) (parComp budget (k 2) (k 4)) := by
  funext i
  ext <;> simp [seqComp, parComp, combine, combineAxis, budget, k, Bound.known] <;> ring

/-! ## verdict_sound -/

/-- Mutant: a verdict that reads `lo` instead of `hi`. -/
noncomputable def verdictLo {ι : Type} (θ : ι → ENNReal) (g : Grade ι) : Decision := by
  classical
  exact if ∀ i, (g i).lo ≤ θ i then .accept else .reject

theorem verdict_sound_mutant :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit) (i : Unit),
      θ i < (g i).hi → verdictLo θ g = .reject := by
  intro hc
  have := hc (fun _ => 0) (fun _ => Bound.unknown) () ENNReal.zero_lt_top
  simp [verdictLo, Bound.unknown] at this

/-- The threshold 1 on the single axis. -/
def θone : Unit → ENNReal := fun _ => 1

/-- Mutant: a gate that rejects only unknowns, that is, exactly when some axis has
    `hi = ⊤` on a finite threshold. -/
noncomputable def unknownOnly {ι : Type} (θ : ι → ENNReal) (g : Grade ι) : Decision := by
  classical
  exact if ∃ i, (g i).hi = ⊤ ∧ θ i < ⊤ then .reject else .accept

theorem verdict_sound_unknownOnly_mutant :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit) (i : Unit),
      θ i < (g i).hi → unknownOnly θ g = .reject := by
  intro hc
  have := hc θone (k 2) () (by simp [θone, k, Bound.known])
  simp [unknownOnly, θone, k, Bound.known] at this

/-- The threshold 10 on the single axis. -/
def θten : Unit → ENNReal := fun _ => 10

/-- [5, ∞], which is what an unknown becomes when combined with the known 5. -/
def fiveUp : Grade Unit := fun _ => ⟨5, ⊤, le_top⟩

/-- Witness for `verdict_sound` ([5, ∞] under θ = 10, axis `()`): the hypothesis and the
    conclusion. Before Q4 the statement didn't cover this grade. -/
theorem verdict_sound_witness :
    θten () < (fiveUp ()).hi ∧ verdict θten fiveUp = .reject := by
  refine ⟨by simp [θten, fiveUp], ?_⟩
  simp [verdict, θten, fiveUp]

/-! ## verdict_complete -/

/-- Mutant: the always-REJECT gate. -/
def alwaysReject {ι : Type} (_θ : ι → ENNReal) (_g : Grade ι) : Decision := .reject

theorem verdict_complete_mutant :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit),
      (∀ i, (g i).lo = (g i).hi) → (∀ i, (g i).lo ≤ θ i) → alwaysReject θ g = .accept := by
  intro hc
  have := hc (fun _ => 0) (k 0) (fun _ => rfl) (fun _ => le_rfl)
  simp [alwaysReject] at this

/-- Witness for `verdict_complete` (θ = 1, the known grade 1): both hypotheses and the
    conclusion. -/
theorem verdict_complete_witness :
    (∀ i, (k 1 i).lo = (k 1 i).hi) ∧ (∀ i, (k 1 i).lo ≤ θone i)
      ∧ verdict θone (k 1) = .accept := by
  refine ⟨fun _ => rfl, fun _ => by simp [k, Bound.known, θone], ?_⟩
  simp [verdict, θone, k, Bound.known]

/-! ## residual_spec -/

/-- Mutant: check each stage against the full θ. -/
def residualFull (θ _x : ENNReal) : ENNReal := θ

theorem residual_spec_mutant :
    ¬ ∀ θ x y : ENNReal, θ ≠ ⊤ → x ≤ θ → (y ≤ residualFull θ x ↔ x + y ≤ θ) := by
  intro hc
  have := (hc 1 1 1 ENNReal.one_ne_top le_rfl).mp le_rfl
  norm_num at this

/-- Witness for `residual_spec` (θ = 1, x = 0, y = 1): both hypotheses and the
    conclusion. -/
theorem residual_spec_witness :
    (1 : ENNReal) ≠ ⊤ ∧ (0 : ENNReal) ≤ 1
      ∧ ((1 : ENNReal) ≤ residual 1 0 ↔ (0 : ENNReal) + 1 ≤ 1) := by
  refine ⟨by simp, zero_le_one, ?_⟩
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

/-- Witness for `no_flip` (a grader that ignores metrics, θ = 0): the hypothesis and the
    conclusion. -/
theorem no_flip_witness :
    Noninterfering constGrader ∧
      verdict (fun _ => 0) (constGrader ⟨(), []⟩)
        = verdict (fun _ => 0) (constGrader ⟨(), [("confidence", 0.99)]⟩) :=
  ⟨noninterfering_witness, rfl⟩

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

/-- `Loader.safe`'s conclusion for every pair of countdown states. -/
theorem loader_safe_countdown {s t : ℕ} (hs : countdown.Inv s)
    (hr : Relation.ReflTransGen countdown.step s t) : countdown.Inv t := by
  induction hr with
  | refl => exact hs
  | tail _ hst ih =>
    have h1 : _ + 1 = _ := hst
    have h2 : _ ≤ 3 := ih
    show _ ≤ 3
    omega

/-- Witness for `Loader.safe` (the countdown loader, from state 3 down to 1): both
    hypotheses and the conclusion. -/
theorem loader_safe_witness :
    countdown.Inv 3 ∧ Relation.ReflTransGen countdown.step 3 1 ∧ countdown.Inv 1 :=
  ⟨show 3 ≤ 3 from le_rfl,
   Relation.ReflTransGen.tail (b := 2)
     (Relation.ReflTransGen.single (show countdown.step 3 2 from rfl))
     (show countdown.step 2 1 from rfl),
   show 1 ≤ 3 by omega⟩

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

/-- Mutant: SCp2's frontier debit (§5), a real defect (ROADMAP, Milestone 1 notes). It
    folds jump prices with max, so repeats aren't double-charged: [v, -v] costs A‖v‖,
    not 2A‖v‖. -/
noncomputable def chargeMaxFold {E : Type} [NormedAddCommGroup E] (A : ENNReal)
    (jumps : List E) : ENNReal :=
  A * (jumps.map (fun v => (‖v‖₊ : ENNReal))).foldl max 0

theorem charge_chatter_scp2_mutant :
    ¬ ∀ (A : ENNReal) (v : ℝ), chargeMaxFold A [v, -v] = 2 * A * (‖v‖₊ : ENNReal) := by
  intro hc
  have := hc 1 1
  simp [chargeMaxFold] at this

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

/-- Witness for `expiry_tightens` (P = Prop, baseline True, one active weakening False
    that expires): the hypothesis and the conclusion. -/
theorem expiry_tightens_witness :
    (∅ : Set Prop) ⊆ {False}
      ∧ effective True ({False} : Set Prop) ≤ effective True (∅ : Set Prop) :=
  ⟨Set.empty_subset _, by simp [effective]⟩

/-! ## bridge -/

/-- `bridge`'s claim with the dial-to-threshold map as a parameter, so a wrong map can be
    plugged in. `BridgeHolds threshold` is the statement at `ι = Unit`, with inputs of
    type `Unit`. -/
def BridgeHolds (thresholdOf : (Unit → ENNReal) → Unit → ENNReal) : Prop :=
  ∀ (gradeOf : Unit → Grade Unit) (dial₁ dial₂ : Unit → ENNReal), dial₁ ≤ dial₂ →
    {x | verdict (thresholdOf dial₂) (gradeOf x) = .accept}
      ⊆ {x | verdict (thresholdOf dial₁) (gradeOf x) = .accept}

/-- Mutant: a threshold dial stored un-inverted (`id` in place of `threshold`), so
    "stricter" raises θ. -/
theorem bridge_mutant : ¬ BridgeHolds id := by
  intro hc
  have hacc :
      () ∈ {x : Unit | verdict (id fun _ => (1 : ENNReal)) ((fun _ => k 1) x) = .accept} := by
    simp [verdict, k, Bound.known]
  have := hc (fun _ => k 1) (fun _ => 0) (fun _ => 1) (fun _ => zero_le_one) hacc
  simp [verdict, k, Bound.known] at this

/-- Witness for `bridge` (dial₁ = 0, so no limit, below dial₂ = 1; the known grade 1): the
    hypothesis and the conclusion, with the real `threshold`. -/
theorem bridge_witness :
    (fun _ : Unit => (0 : ENNReal)) ≤ (fun _ => 1) ∧
      {x : Unit | verdict (threshold fun _ => (1 : ENNReal)) ((fun _ => k 1) x) = .accept}
        ⊆ {x : Unit | verdict (threshold fun _ => (0 : ENNReal)) ((fun _ => k 1) x) = .accept} :=
  ⟨fun _ => zero_le_one, fun _ _ => by simp [verdict, threshold, k, Bound.known]⟩

/-! ## fold_check_vacuous -/

/-- Mutant: the uncapped fold, a plain weighted sum. -/
def foldUncapped (_Rmax lam : ℝ) (rs : List ℝ) : ℝ := rs.foldl (fun x y => x + lam * y) 0

theorem fold_check_vacuous_mutant :
    ¬ ∀ (Rmax lam : ℝ), 0 ≤ Rmax → ∀ rs : List ℝ, foldUncapped Rmax lam rs ≤ Rmax := by
  intro hc
  have := hc 0 1 le_rfl [1]
  norm_num [foldUncapped] at this

/-- Witness for `fold_check_vacuous` (R_max = 1, λ = 1, one weakening of size 2): the
    hypothesis and the conclusion. -/
theorem fold_check_vacuous_witness : (0 : ℝ) ≤ 1 ∧ fold 1 1 [2] ≤ 1 :=
  ⟨zero_le_one, by norm_num [fold]⟩

/-! ## Calibrated -/

theorem calibrated_mutant : ¬ Calibrated (fun _ : Unit => Decision.reject) {()} ∅ := by
  rintro ⟨_, hmp, _⟩
  exact absurd (hmp () (Set.mem_singleton ())) (by decide)

theorem calibrated_witness : Calibrated (fun _ : Unit => Decision.accept) {()} ∅ :=
  ⟨by simp, fun _ _ => rfl, fun _ h => absurd h (by simp)⟩

/-! ## mfGate_signed -/

/-- Failure classes for the gate's controls. GOLDEN_RULE_BREACH comes from the corpus
    (`SIRUS/main.tex`), though it sits outside the v1 gate (`decisions/RAILS.md`). -/
inductive FailClass | goldenRuleBreach | other
  deriving DecidableEq

/-- Draft0–7's history, which dropped GOLDEN_RULE_BREACH. -/
def draftHistory : ℕ → Set FailClass
  | 0 => {.goldenRuleBreach, .other}
  | _ => {.other}

/-- Nothing is signed: the only signable removal is the empty one. -/
def nothingSigned (s : Set FailClass) : Prop := s = ∅

/-- The real gate rejects the drafts' history when nothing is signed, and that history
    doesn't only grow. -/
theorem mfGate_rejects_draft_history :
    ¬ mfGate nothingSigned (draftHistory 0) (draftHistory 1) ∧ ¬ Monotone draftHistory := by
  have hmem : FailClass.goldenRuleBreach ∈ draftHistory 0 := by simp [draftHistory]
  have hnot : FailClass.goldenRuleBreach ∉ draftHistory 1 := by simp [draftHistory]
  refine ⟨?_, fun hm => hnot (hm (Nat.zero_le 1) hmem)⟩
  rintro (h | h)
  · exact hnot (h hmem)
  · have : FailClass.goldenRuleBreach ∈ draftHistory 0 \ draftHistory 1 := ⟨hmem, hnot⟩
    rw [show draftHistory 0 \ draftHistory 1 = ∅ from h] at this
    exact this

/-- A history that keeps its classes: the real gate accepts every step, and it only grows. -/
def keptHistory : ℕ → Set FailClass := fun _ => {.goldenRuleBreach}

theorem mfGate_accepts_kept_history :
    (∀ t, mfGate nothingSigned (keptHistory t) (keptHistory (t + 1)))
      ∧ (∀ s, nothingSigned s → s = ∅) ∧ Monotone keptHistory :=
  ⟨fun _ => Or.inl subset_rfl, fun _ h => h, fun _ _ _ => le_rfl⟩

/-- `mfGate_signed`'s claim with the gate as a parameter, so a wrong gate can be plugged
    in, for histories of `FailClass`. -/
def SignedRemovals (gate : (Set FailClass → Prop) → Set FailClass → Set FailClass → Prop)
    (signed : Set FailClass → Prop) (MF : ℕ → Set FailClass) : Prop :=
  (∀ t, gate signed (MF t) (MF (t + 1))) → ∀ {s t : ℕ}, s ≤ t → ∀ {c : FailClass},
    c ∈ MF s → c ∉ MF t →
      ∃ u, s ≤ u ∧ u < t ∧ c ∈ MF u \ MF (u + 1) ∧ signed (MF u \ MF (u + 1))

/-- Mutant: a gate that accepts every change. -/
def looseGate (_signed : Set FailClass → Prop) (_old _new : Set FailClass) : Prop := True

/-- The loose gate accepts the drafts' history, in which GOLDEN_RULE_BREACH leaves in an
    unsigned step. -/
theorem mfGate_signed_mutant : ¬ SignedRemovals looseGate nothingSigned draftHistory := by
  intro hc
  have hmem : FailClass.goldenRuleBreach ∈ draftHistory 0 := by simp [draftHistory]
  have hnot : FailClass.goldenRuleBreach ∉ draftHistory 1 := by simp [draftHistory]
  obtain ⟨u, hu0, hu1, hin, hsig⟩ := hc (fun _ => trivial) (Nat.zero_le 1) hmem hnot
  obtain rfl : u = 0 := by omega
  rw [show draftHistory 0 \ draftHistory (0 + 1) = ∅ from hsig] at hin
  exact hin

/-- Signed: a removal of exactly GOLDEN_RULE_BREACH. -/
def signsGoldenRule (s : Set FailClass) : Prop := s = {.goldenRuleBreach}

/-- The drafts' history removes exactly GOLDEN_RULE_BREACH at step 0. -/
theorem draft_removal : draftHistory 0 \ draftHistory 1 = {.goldenRuleBreach} := by
  ext c
  cases c <;> simp [draftHistory]

/-- Witness for `mfGate_signed` (the drafts' history with its removal signed;
    GOLDEN_RULE_BREACH from step 0 to step 1): all four hypotheses and the conclusion. -/
theorem mfGate_signed_witness :
    (∀ t, mfGate signsGoldenRule (draftHistory t) (draftHistory (t + 1))) ∧ 0 ≤ 1
      ∧ FailClass.goldenRuleBreach ∈ draftHistory 0 ∧ FailClass.goldenRuleBreach ∉ draftHistory 1
      ∧ ∃ u, 0 ≤ u ∧ u < 1 ∧ FailClass.goldenRuleBreach ∈ draftHistory u \ draftHistory (u + 1)
          ∧ signsGoldenRule (draftHistory u \ draftHistory (u + 1)) := by
  refine ⟨fun t => ?_, Nat.zero_le 1, by simp [draftHistory], by simp [draftHistory],
    0, le_rfl, Nat.one_pos, ?_, draft_removal⟩
  · cases t with
    | zero => exact Or.inr draft_removal
    | succ n => exact Or.inl fun _ hx => hx
  · show FailClass.goldenRuleBreach ∈ draftHistory 0 \ draftHistory 1
    rw [draft_removal]
    exact Set.mem_singleton _

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

/-- The witness trajectory: signed distance 1 - t, moving at speed 1. -/
def dWitness : ℝ → ℝ := fun t => 1 - t

/-- Witness for `dwell_lower_bound` (S_max = 1, r = 1, t₁ = 0, t₂ = 2): all five
    hypotheses and the conclusion. -/
theorem dwell_lower_bound_witness :
    (0 : ℝ) < 1 ∧ (∀ s t, |dWitness t - dWitness s| ≤ 1 * |t - s|) ∧ dWitness 0 = 1
      ∧ dWitness 2 = -1 ∧ (0 : ℝ) ≤ 2 ∧ 2 * 1 / 1 ≤ (2 : ℝ) - 0 := by
  refine ⟨one_pos, fun s t => ?_, by norm_num [dWitness], by norm_num [dWitness], by norm_num,
    by norm_num⟩
  simp only [dWitness]
  rw [show (1 - t) - (1 - s) = -(t - s) by ring, abs_neg, one_mul]

/-! ## statements-v2

Controls for the theorems added in `statements-v2`, in the same style: a mutant taken
from a real defect in `archive/` where there is one, and a witness. -/

/-! ## lease_sound -/

/-- [0, 5] on the single axis. -/
def zeroFive : Grade Unit := fun _ => ⟨0, 5, by norm_num⟩

/-- Mutant: SirusSC's interval lift `QPrime`, whose one guard rejects ⊥
    (`guard_no_bottom`) and which never reads an interval's width, so it accepts on the
    upper bound alone. -/
noncomputable def qPrimeGate {ι : Type} (θ _β : ι → ENNReal) (g : Grade ι) : Decision :=
  verdict θ g

/-- [0, 5] is over its lease of 1 but within θ = 10, and `qPrimeGate` accepts it. -/
theorem lease_sound_mutant :
    ¬ ∀ (θ β : Unit → ENNReal) (g : Grade Unit) (i : Unit),
      θ i < (g i).hi ∨ β i < (g i).width → qPrimeGate θ β g = .reject := by
  intro hc
  have := hc θten (fun _ => 1) zeroFive () (Or.inr (by norm_num [zeroFive, Bound.width]))
  norm_num [qPrimeGate, verdict, θten, zeroFive] at this

/-- Mutant: a gate that checks only widths, as PDE I4b's unknowns cap does on its own. -/
noncomputable def widthsOnly {ι : Type} (_θ β : ι → ENNReal) (g : Grade ι) : Decision := by
  classical
  exact if ∀ i, (g i).width ≤ β i then .accept else .reject

/-- [5, 5] is within any lease but over θ = 1, and `widthsOnly` accepts it. -/
theorem lease_sound_widthsOnly_mutant :
    ¬ ∀ (θ β : Unit → ENNReal) (g : Grade Unit) (i : Unit),
      θ i < (g i).hi ∨ β i < (g i).width → widthsOnly θ β g = .reject := by
  intro hc
  have := hc θone (fun _ => 0) (k 5) () (Or.inl (by norm_num [θone, k, Bound.known]))
  simp [widthsOnly, k, Bound.known, Bound.width] at this

/-- Witness for `lease_sound`, one instance for each way to fail: [0, 5] leased 1 under
    θ = 10 is wider than its lease, and [5, 5] leased 0 under θ = 1 is over its threshold.
    The hypothesis and the conclusion for each. -/
theorem lease_sound_witness :
    ((θten () < (zeroFive ()).hi ∨ (1 : ENNReal) < (zeroFive ()).width)
        ∧ leaseVerdict θten (fun _ => 1) zeroFive = .reject)
      ∧ ((θone () < (k 5 ()).hi ∨ (0 : ENNReal) < (k 5 ()).width)
        ∧ leaseVerdict θone (fun _ => 0) (k 5) = .reject) := by
  refine ⟨⟨Or.inr (by norm_num [zeroFive, Bound.width]), ?_⟩,
    ⟨Or.inl (by norm_num [θone, k, Bound.known]), ?_⟩⟩
  · norm_num [leaseVerdict, θten, zeroFive, Bound.width]
  · norm_num [leaseVerdict, θone, k, Bound.known, Bound.width]

/-! ## lease_complete -/

/-- [0, 1] on the single axis. -/
def zeroOne : Grade Unit := fun _ => ⟨0, 1, zero_le_one⟩

/-- Mutant: SirusSC's `Q`, where an axis holds a value or ⊥, which absorbs whatever it
    combines with, and every guard rejects a ⊥ (`C_UNK_PRICED`). A reading wider than a
    point can only be ⊥ there, so it is rejected however small its lease. -/
noncomputable def pointsOnly {ι : Type} (θ _β : ι → ENNReal) (g : Grade ι) : Decision := by
  classical
  exact if ∀ i, (g i).lo = (g i).hi ∧ (g i).hi ≤ θ i then .accept else .reject

theorem lease_complete_mutant :
    ¬ ∀ (θ β : Unit → ENNReal) (g : Grade Unit), WithinLease β g →
      (∀ i, (g i).hi ≤ θ i) → pointsOnly θ β g = .accept := by
  intro hc
  have := hc θone (fun _ => 1) zeroOne (fun _ => by simp [zeroOne, Bound.width])
    (fun _ => by simp [zeroOne, θone])
  simp [pointsOnly, zeroOne] at this

/-- Witness for `lease_complete` ([0, 1] leased 1 under θ = 1): both hypotheses and the
    conclusion. -/
theorem lease_complete_witness :
    WithinLease (fun _ => 1) zeroOne ∧ (∀ i, (zeroOne i).hi ≤ θone i)
      ∧ leaseVerdict θone (fun _ => 1) zeroOne = .accept := by
  refine ⟨fun _ => by simp [zeroOne, Bound.width], fun _ => by simp [zeroOne, θone], ?_⟩
  simp [leaseVerdict, θone, zeroOne, Bound.width]

/-! ## pass_sound -/

/-- Two of JSG V's stages. -/
inductive Stg | ef | pr
  deriving DecidableEq

/-- A window whose stages are EF and PR, each issued a ticket. -/
def efPr : Multiset Stg := {.ef, .pr}

/-- RetuneDisabledInRed, issued Stage-scoped by EF: only EF may discharge it, with a
    witness that `clamp_state` isn't Red (`true`). -/
def retuneRed : DischargeMatrix Stg Unit Bool := ⟨fun _ => .ef, fun _ w => w = true⟩

/-- RequiresHitmap, Window-scoped: PR discharges it, with a witness that the hitmap is
    present and authorized (`true`). -/
def hitmap : DischargeMatrix Stg Unit Bool := ⟨fun _ => .pr, fun _ w => w = true⟩

/-- EF emits the obligation while Red, so its own witness is `false`. -/
def efEmits : StageRun Unit Stg Unit Bool := ⟨.ef, k 0, {()}, false⟩

/-- PR runs with a witness of `true`. -/
def prRuns : StageRun Unit Stg Unit Bool := ⟨.pr, k 0, 0, true⟩

/-- `pass_sound`'s claim at these fixtures, with the stage transition as a parameter so
    a wrong one can be plugged in. `PassSoundHolds M (afterStage M)` is the statement. -/
def PassSoundHolds (M : DischargeMatrix Stg Unit Bool)
    (after : Multiset (Pending Stg Unit) → StageRun Unit Stg Unit Bool →
      Multiset (Pending Stg Unit)) : Prop :=
  ∀ (θ β : Unit → ENNReal) (stages : Multiset Stg) (carried : Multiset Unit)
    (pre post : List (StageRun Unit Stg Unit Bool)) (r : StageRun Unit Stg Unit Bool),
    leaseVerdict θ β (windowGrade budget (pre ++ r :: post)) = .accept →
    (pre ++ r :: post).foldl after (windowStart stages carried) = 0 →
    ∀ p ∈ pre.foldl after (windowStart stages carried) + r.emits.map Pending.obl,
      ∃ s ∈ r :: post, M.Clears s p

/-- What JSG V's displayed transition clears, read with its matrix: the stage's own
    ticket, and any obligation its witness discharges, whichever listed stage ran. -/
def ClearsListed (M : DischargeMatrix Stg Unit Bool) (r : StageRun Unit Stg Unit Bool) :
    Pending Stg Unit → Prop
  | .ticket s => s = r.stage
  | .obl o => M.witness o r.wit

/-- Mutant: JSG V's displayed transition with its matrix, which lists PR or EF for
    RetuneDisabledInRed and leaves the issuer check to a parenthetical, so any listed
    stage with the right witness discharges it. -/
noncomputable def afterListed (M : DischargeMatrix Stg Unit Bool)
    (pend : Multiset (Pending Stg Unit)) (r : StageRun Unit Stg Unit Bool) :
    Multiset (Pending Stg Unit) := by
  classical
  exact (pend + r.emits.map Pending.obl).filter (fun p => ¬ ClearsListed M r p)

/-- EF emits RetuneDisabledInRed while Red, and PR's witness discharges it: the window
    passes, though EF, its only authority, never discharges it. -/
theorem pass_sound_mutant : ¬ PassSoundHolds retuneRed (afterListed retuneRed) := by
  intro hc
  have h1 : afterListed retuneRed (windowStart efPr 0) efEmits = {.ticket .pr, .obl ()} := by
    classical
    simp only [afterListed, windowStart, efPr, efEmits, Multiset.insert_eq_cons,
      Multiset.map_cons, Multiset.map_singleton, Multiset.map_zero, Multiset.cons_add,
      Multiset.add_zero, Multiset.singleton_add, Multiset.filter_cons, Multiset.filter_singleton]
    simp [ClearsListed, retuneRed]
  have h2 : afterListed retuneRed {.ticket .pr, .obl ()} prRuns = 0 := by
    classical
    simp only [afterListed, prRuns, Multiset.insert_eq_cons, Multiset.map_zero, Multiset.add_zero,
      Multiset.filter_cons, Multiset.filter_singleton]
    simp [ClearsListed, retuneRed]
  have := hc (fun _ => 0) (fun _ => 0) efPr 0 [] [prRuns] efEmits
    (by simp [leaseVerdict, windowGrade, seqComp, combine, combineAxis, budget, efEmits, prRuns,
        k, Bound.known, Bound.width])
    (by simp only [List.nil_append, List.foldl_cons, List.foldl_nil]; rw [h1, h2])
    (.obl ()) (by simp [windowStart, efEmits])
  simp [DischargeMatrix.Clears, DischargeMatrix.Discharges, retuneRed, efEmits, prRuns] at this

/-- With `hitmap`, EF clears its ticket and leaves RequiresHitmap pending for PR. -/
theorem hitmap_after_ef :
    afterStage hitmap (windowStart efPr (0 : Multiset Unit)) efEmits = {.ticket .pr, .obl ()} := by
  classical
  simp only [afterStage, windowStart, efPr, efEmits, Multiset.insert_eq_cons, Multiset.map_cons,
    Multiset.map_singleton, Multiset.map_zero, Multiset.cons_add, Multiset.add_zero,
    Multiset.singleton_add, Multiset.filter_cons, Multiset.filter_singleton]
  simp [DischargeMatrix.Clears, DischargeMatrix.Discharges, hitmap]

/-- PR then clears its ticket and discharges RequiresHitmap. -/
theorem hitmap_after_pr : afterStage hitmap {.ticket .pr, .obl ()} prRuns = 0 := by
  classical
  simp only [afterStage, prRuns, Multiset.insert_eq_cons, Multiset.map_zero, Multiset.add_zero,
    Multiset.filter_cons, Multiset.filter_singleton]
  simp [DischargeMatrix.Clears, DischargeMatrix.Discharges, hitmap]

/-- Witness for `pass_sound` (EF emits RequiresHitmap and PR discharges it; the run split
    at EF): the hypothesis, `hp`, and the conclusion. -/
theorem pass_sound_witness :
    Passes budget (fun _ => 0) (fun _ => 0) hitmap efPr 0 ([] ++ efEmits :: [prRuns])
      ∧ Pending.obl () ∈ pendingAfter hitmap (windowStart efPr 0)
          ([] : List (StageRun Unit Stg Unit Bool)) + efEmits.emits.map Pending.obl
      ∧ ∃ s ∈ efEmits :: [prRuns], hitmap.Clears s (.obl ()) := by
  refine ⟨⟨?_, ?_⟩, by simp [pendingAfter, windowStart, efEmits], prRuns, by simp, ?_⟩
  · simp [leaseVerdict, windowGrade, seqComp, combine, combineAxis, budget, efEmits, prRuns, k,
      Bound.known, Bound.width]
  · simp only [pendingAfter, List.nil_append, List.foldl_cons, List.foldl_nil]
    rw [hitmap_after_ef, hitmap_after_pr]
  · simp [DischargeMatrix.Clears, DischargeMatrix.Discharges, hitmap, prRuns]

/-! ## pass_complete -/

/-- Every stage may discharge every obligation, with any witness. -/
def anyStage : DischargeMatrix Unit ℕ Unit := ⟨fun _ => (), fun _ _ => True⟩

/-- A stage that adds nothing and emits nothing. -/
def idle : StageRun Unit Unit ℕ Unit := ⟨(), k 0, 0, ()⟩

/-- JSG V's Σ: the obligations pending, without the tickets. -/
def sigma (pend : Multiset (Pending Unit ℕ)) : Multiset ℕ :=
  pend.filterMap fun
    | .ticket _ => none
    | .obl o => some o

/-- JSG V's I_Σ, on its own Σ: the obligations fall in the Dershowitz–Manna order at every
    stage. -/
def ISigma (M : DischargeMatrix Unit ℕ Unit) (stages : Multiset Unit) (carried : Multiset ℕ)
    (run : List (StageRun Unit Unit ℕ Unit)) : Prop :=
  ∀ pre r post, run = pre ++ r :: post →
    Multiset.IsDershowitzMannaLT
      (sigma (afterStage M (pendingAfter M (windowStart stages carried) pre) r))
      (sigma (pendingAfter M (windowStart stages carried) pre))

/-- `pass_complete`'s claim at these fixtures, with the pass condition as a parameter.
    `PassCompleteHolds (Passes budget)` is the statement. -/
def PassCompleteHolds (passes : (Unit → ENNReal) → (Unit → ENNReal) →
    DischargeMatrix Unit ℕ Unit → Multiset Unit → Multiset ℕ →
      List (StageRun Unit Unit ℕ Unit) → Prop) : Prop :=
  ∀ θ β M stages carried (pre : List (StageRun Unit Unit ℕ Unit)) r,
    leaseVerdict θ β (windowGrade budget (pre ++ [r])) = .accept →
    (∀ p ∈ pendingAfter M (windowStart stages carried) pre + r.emits.map Pending.obl,
      M.Clears r p) →
    passes θ β M stages carried (pre ++ [r])

/-- Mutant: JSG V's I_Σ-Progress read as part of passing, as its CI check runs it on
    passing runs. It reads JSG V's Σ, which holds obligations and no tickets, and a
    window's obligations start empty, which can't fall, so no window passes. Here one
    idle stage clears its ticket and passes, but fails I_Σ. -/
theorem pass_complete_mutant :
    ¬ PassCompleteHolds (fun θ β M stages carried run =>
      Passes budget θ β M stages carried run ∧ ISigma M stages carried run) := by
  intro hc
  obtain ⟨-, hI⟩ := hc (fun _ => 0) (fun _ => 0) anyStage {()} 0 [] idle
    (by simp [leaseVerdict, windowGrade, seqComp, combine, combineAxis, budget, idle, k,
        Bound.known, Bound.width])
    (by
      intro p hp
      simp [pendingAfter, windowStart, idle] at hp
      subst hp
      simp [DischargeMatrix.Clears, idle])
  obtain ⟨X, Y, Z, hZ, -, hN, -⟩ := hI [] idle [] rfl
  have h0 : sigma (pendingAfter anyStage (windowStart {()} 0)
      ([] : List (StageRun Unit Unit ℕ Unit))) = 0 := by
    rw [Multiset.eq_zero_iff_forall_notMem]
    simp [sigma, pendingAfter, windowStart]
  rw [h0] at hN
  exact hZ (add_eq_zero.mp hN.symm).2

/-- Witness for `pass_complete` (EF emits RequiresHitmap, and the last stage, PR, clears
    its ticket and discharges it): both hypotheses and the conclusion. -/
theorem pass_complete_witness :
    leaseVerdict (fun _ => 0) (fun _ => 0) (windowGrade budget ([efEmits] ++ [prRuns])) = .accept
      ∧ (∀ p ∈ pendingAfter hitmap (windowStart efPr 0) [efEmits] + prRuns.emits.map Pending.obl,
          hitmap.Clears prRuns p)
      ∧ Passes budget (fun _ => 0) (fun _ => 0) hitmap efPr 0 ([efEmits] ++ [prRuns]) := by
  have hg : leaseVerdict (fun _ => 0) (fun _ => 0) (windowGrade budget ([efEmits] ++ [prRuns]))
      = .accept := by
    simp [leaseVerdict, windowGrade, seqComp, combine, combineAxis, budget, efEmits, prRuns, k,
      Bound.known, Bound.width]
  refine ⟨hg, ?_, hg, ?_⟩
  · intro p hp
    simp only [pendingAfter, List.foldl_cons, List.foldl_nil, hitmap_after_ef] at hp
    simp [prRuns] at hp
    rcases hp with rfl | rfl <;> simp [DischargeMatrix.Clears, DischargeMatrix.Discharges, hitmap,
        prRuns]
  · simp only [pendingAfter, List.singleton_append, List.foldl_cons, List.foldl_nil]
    rw [hitmap_after_ef, hitmap_after_pr]

/-! ## LoaderStep.inv_step and LoaderStep.progress -/

/-- Toy primitives: bytes and digests are numbers, the digest is the identity, every
    signature verifies, replay returns the probe, and a bundle's root is its length. -/
def toyPrims : Prims ℕ ℕ := ⟨id, fun _ => True, fun _ x => x, List.length⟩

/-- A boot record that passes L1–L5 and L7 under `toyPrims`, for a window with the given
    stages. Each stage's adapter grades a batch of rows by counting them, on a budget
    axis; the budget is 10 and the round-off cap 1. -/
def toyBoot {St : Type} (declared : St → Set Unit) (stages : Multiset St) :
    Boot Unit St ℕ ℕ where
  raw := 0
  rawDigest := 0
  configCert := 0
  envLock := 0
  envDigest := 0
  replayPlan := 0
  probe := 0
  probeOut := 0
  seed := 1
  ledger := []
  declared := declared
  adapter := fun _ rows => k rows.length
  epsMax := 1
  budget := fun _ => 10
  stages := stages

/-- T-Boot's state on `toyBoot` passes L1–L10. -/
theorem toy_bootState_inv {St O : Type} (declared : St → Set Unit) (stages : Multiset St)
    (carried : Multiset O) :
    LoaderInv budget toyPrims (bootState toyPrims (toyBoot declared stages) carried) := by
  refine ⟨rfl, trivial, rfl, rfl, by simp [L5, bootState, toyBoot], by simp [L6, bootState],
    ?_, by simp [L8, bootState, toyBoot], ?_, rfl⟩
  · intro st x y
    funext i
    ext <;> simp [bootState, toyBoot, combine, combineAxis, budget, k, Bound.known]
  · intro i
    simp [bootState, toyBoot, Bound.known]

/-- T-Boot's state on `toyBoot`'s record for one stage, with obligations in ℕ. -/
def toyBootState (declared : Unit → Set Unit) (carried : Multiset ℕ) :
    LoaderState Unit Unit ℕ ℕ ℕ :=
  bootState toyPrims (toyBoot declared {()}) carried

/-- The same state with the given items pending instead. -/
def toyState (declared : Unit → Set Unit) (pend : Multiset (Pending Unit ℕ)) :
    LoaderState Unit Unit ℕ ℕ ℕ :=
  { toyBootState declared 0 with pending := pend }

/-- A stage that prices one row, emits nothing, and runs with witness `()`. -/
def oneRow : StageRun Unit Unit ℕ Unit := ⟨(), k 1, 0, ()⟩

/-- Witness for `LoaderStep.inv_step` (from T-Boot's state, one stage prices a row and
    clears its ticket): the invariant before, the step, and the invariant after. -/
theorem loader_inv_step_witness :
    LoaderInv budget toyPrims (toyBootState (fun _ => Set.univ) 0)
      ∧ ∃ t, LoaderStep budget toyPrims anyStage (toyBootState (fun _ => Set.univ) 0) t
        ∧ LoaderInv budget toyPrims t := by
  refine ⟨toy_bootState_inv _ _ _, _, LoaderStep.stage _ oneRow [5] 0 7
    (by funext i; simp [oneRow, toyBootState, bootState, toyBoot, k]) (fun _ _ => Set.mem_univ _)
    (by simp [toyBootState, bootState, toyBoot])
    (fun _ => by simp [toyBootState, bootState, toyBoot, oneRow, combine, combineAxis, budget, k,
        Bound.known])
    (by simp [toyBootState, bootState, windowStart, toyBoot, oneRow]), ?_⟩
  refine ⟨rfl, trivial, rfl, rfl, by simp [L5, toyBootState, bootState, toyBoot],
    fun _ _ => Set.mem_univ _, ?_, by simp [L8, toyBootState, bootState, toyBoot], ?_, rfl⟩
  · intro st x y
    funext i
    ext <;> simp [toyBootState, bootState, toyBoot, combine, combineAxis, budget, k, Bound.known]
  · intro i
    simp [toyBootState, bootState, toyBoot, oneRow, combine, combineAxis, budget, k, Bound.known]

/-- Mutant: SCp3's T-Row (§6.3). Its premises check I1–I5 in the old state, that the row
    is typed and free of ⊥, and the budget, but neither I6 nor I8: `LoaderStep` without
    `hiso` and `hround`. -/
inductive TRowStep (M : DischargeMatrix Unit ℕ Unit) :
    LoaderState Unit Unit ℕ ℕ ℕ → LoaderState Unit Unit ℕ ℕ ℕ → Prop
  | stage (s : LoaderState Unit Unit ℕ ℕ ℕ) (r : StageRun Unit Unit ℕ Unit) (rows : List ℕ)
      (ε : ENNReal) (receipt : ℕ)
      (hprice : r.grade = s.boot.adapter r.stage rows)
      (hbudget : ∀ i, (combine budget s.q r.grade i).hi ≤ s.boot.budget i)
      (hticket : Pending.ticket r.stage ∈ s.pending) :
      TRowStep M s
        { s with
          q := combine budget s.q r.grade
          eps := s.eps + ε
          written := s.written ∪ {p | p.1 = r.stage ∧ r.grade p.2 ≠ Bound.known 0}
          bundle := s.bundle ++ [receipt]
          root := toyPrims.root (s.bundle ++ [receipt])
          pending := afterStage M s.pending r }

/-- A row whose debit adds round-off 5, past the cap of 1: T-Row accepts it, and L8 fails. -/
theorem loader_inv_step_mutant :
    ¬ ∀ s t, LoaderInv budget toyPrims s → TRowStep anyStage s t → LoaderInv budget toyPrims t := by
  intro hc
  obtain ⟨-, -, -, -, -, -, -, h8, -, -⟩ := hc _ _
    (toy_bootState_inv (fun _ => Set.univ) {()} (0 : Multiset ℕ))
    (TRowStep.stage (toyBootState (fun _ => Set.univ) 0) oneRow [5] 5 7
      (by funext i; simp [oneRow, toyBootState, bootState, toyBoot, k])
      (fun _ => by simp [toyBootState, bootState, toyBoot, oneRow, combine, combineAxis, budget,
          k, Bound.known])
      (by simp [toyBootState, bootState, windowStart, toyBoot, oneRow]))
  simp [L8, toyBootState, bootState, toyBoot] at h8

/-- Which stages SirusSC's declaration table lists: none, here. -/
def inTable (_st : Unit) : Prop := False

/-- Mutant: SirusSC's axis-leak check. `_resolve_allowed_axes` returns `None` for an
    adapter missing from the declaration table, and `_detect_axis_leaks` then checks its
    writes only against the state's axes, so it may write any of them: `LoaderStep`'s
    `hiso`, waived for a stage not in the table. -/
inductive SirusIsoStep (M : DischargeMatrix Unit ℕ Unit) :
    LoaderState Unit Unit ℕ ℕ ℕ → LoaderState Unit Unit ℕ ℕ ℕ → Prop
  | stage (s : LoaderState Unit Unit ℕ ℕ ℕ) (r : StageRun Unit Unit ℕ Unit) (rows : List ℕ)
      (ε : ENNReal) (receipt : ℕ)
      (hprice : r.grade = s.boot.adapter r.stage rows)
      (hiso : ∀ i, r.grade i ≠ Bound.known 0 →
        ¬ inTable r.stage ∨ i ∈ s.boot.declared r.stage)
      (hround : s.eps + ε ≤ s.boot.epsMax)
      (hbudget : ∀ i, (combine budget s.q r.grade i).hi ≤ s.boot.budget i)
      (hticket : Pending.ticket r.stage ∈ s.pending) :
      SirusIsoStep M s
        { s with
          q := combine budget s.q r.grade
          eps := s.eps + ε
          written := s.written ∪ {p | p.1 = r.stage ∧ r.grade p.2 ≠ Bound.known 0}
          bundle := s.bundle ++ [receipt]
          root := toyPrims.root (s.bundle ++ [receipt])
          pending := afterStage M s.pending r }

/-- A stage missing from the table, which declared no axes, writes the one axis there
    is, and L6 fails. -/
theorem loader_inv_step_sirus_mutant :
    ¬ ∀ s t, LoaderInv budget toyPrims s → SirusIsoStep anyStage s t →
      LoaderInv budget toyPrims t := by
  intro hc
  obtain ⟨-, -, -, -, -, h6, -⟩ := hc _ _ (toy_bootState_inv (fun _ => ∅) {()} (0 : Multiset ℕ))
    (SirusIsoStep.stage (toyBootState (fun _ => ∅) 0) oneRow [5] 0 7
      (by funext i; simp [oneRow, toyBootState, bootState, toyBoot, k])
      (fun _ _ => Or.inl id)
      (by simp [toyBootState, bootState, toyBoot])
      (fun _ => by simp [toyBootState, bootState, toyBoot, oneRow, combine, combineAxis, budget,
          k, Bound.known])
      (by simp [toyBootState, bootState, windowStart, toyBoot, oneRow]))
  exact h6 ((), ()) (Or.inr ⟨rfl, by simp [oneRow, k, Bound.known]⟩)

/-- RequiresHitmap is obligation 1 and OmegaPrecond, which ranks above it, obligation 2.
    Only RequiresHitmap has a witness here. -/
def hitmapOnly : DischargeMatrix Unit ℕ Unit := ⟨fun _ => (), fun o _ => o = 1⟩

/-- A stage that discharges RequiresHitmap and emits OmegaPrecond. -/
def raises : StageRun Unit Unit ℕ Unit := ⟨(), k 0, {2}, ()⟩

/-- Mutant: JSG V's progress lemma in place of the ticket, which lets a stage run if it
    discharges an obligation *or* emits only obligations smaller than ones it discharges:
    `LoaderStep` with that condition for `hticket`. -/
inductive OrStep (M : DischargeMatrix Unit ℕ Unit) :
    LoaderState Unit Unit ℕ ℕ ℕ → LoaderState Unit Unit ℕ ℕ ℕ → Prop
  | stage (s : LoaderState Unit Unit ℕ ℕ ℕ) (r : StageRun Unit Unit ℕ Unit) (rows : List ℕ)
      (ε : ENNReal) (receipt : ℕ)
      (hprice : r.grade = s.boot.adapter r.stage rows)
      (hiso : ∀ i, r.grade i ≠ Bound.known 0 → i ∈ s.boot.declared r.stage)
      (hround : s.eps + ε ≤ s.boot.epsMax)
      (hbudget : ∀ i, (combine budget s.q r.grade i).hi ≤ s.boot.budget i)
      (hprog : (∃ o, Pending.obl o ∈ s.pending ∧ M.Discharges r o) ∨
        ∀ e ∈ r.emits, ∃ o, Pending.obl o ∈ s.pending ∧ M.Discharges r o ∧ e < o) :
      OrStep M s
        { s with
          q := combine budget s.q r.grade
          eps := s.eps + ε
          written := s.written ∪ {p | p.1 = r.stage ∧ r.grade p.2 ≠ Bound.known 0}
          bundle := s.bundle ++ [receipt]
          root := toyPrims.root (s.bundle ++ [receipt])
          pending := afterStage M s.pending r }

/-- With no ticket pending, a stage discharges RequiresHitmap and emits OmegaPrecond: what
    is pending goes from {RequiresHitmap} to {OmegaPrecond}, which is not lower. -/
theorem loader_progress_mutant :
    ¬ ∀ s t, OrStep hitmapOnly s t → Multiset.IsDershowitzMannaLT t.pending s.pending := by
  intro hc
  have h := hc _ _ (OrStep.stage (toyState (fun _ => Set.univ) {.obl 1}) raises [] 0 7
    (by funext i; simp [raises, toyState, toyBootState, bootState, toyBoot, k])
    (fun _ h => absurd rfl h)
    (by simp [toyState, toyBootState, bootState, toyBoot])
    (fun _ => by simp [toyState, toyBootState, bootState, toyBoot, raises, combine, combineAxis,
        budget, k, Bound.known])
    (Or.inl ⟨1, by simp [toyState], by simp [DischargeMatrix.Discharges, hitmapOnly, raises]⟩))
  have hp : afterStage hitmapOnly ({.obl 1} : Multiset (Pending Unit ℕ)) raises = {.obl 2} := by
    classical
    simp only [afterStage, raises, Multiset.map_singleton, Multiset.singleton_add]
    simp [DischargeMatrix.Clears, DischargeMatrix.Discharges, hitmapOnly]
  simp only [toyState, hp] at h
  obtain ⟨X, Y, Z, hZ, hM, hN, hlt⟩ := h
  have hX : X = 0 := by
    have hc := congrArg Multiset.card hN
    rw [Multiset.card_add, Multiset.card_singleton] at hc
    have := Multiset.card_pos.mpr hZ
    exact Multiset.card_eq_zero.mp (by omega)
  subst hX
  rw [zero_add] at hM hN
  obtain ⟨z, hz, hlt2⟩ := hlt (.obl 2) (by rw [← hM]; exact Multiset.mem_singleton_self _)
  rw [← hN, Multiset.mem_singleton] at hz
  subst hz
  exact absurd (WithTop.coe_lt_coe.mp hlt2) (by omega)

/-- Mutant: SCp3's check rules T-AdapterAttest, T-AxisIsolation, T-AdapterMono and T-Attest,
    each written s ⇒ s (§6.3): `LoaderStep` with a step from every state to itself. -/
theorem loader_progress_selfloop_mutant :
    ¬ ∀ s t, (LoaderStep budget toyPrims anyStage s t ∨ t = s) →
      Multiset.IsDershowitzMannaLT t.pending s.pending := by
  intro hc
  obtain ⟨X, Y, Z, hZ, hM, hN, hlt⟩ :=
    hc (toyState (fun _ => Set.univ) {.ticket ()}) (toyState (fun _ => Set.univ) {.ticket ()})
      (Or.inr rfl)
  have hX : X = 0 := by
    have hc := congrArg Multiset.card hN
    simp only [toyState, Multiset.card_add, Multiset.card_singleton] at hc
    have := Multiset.card_pos.mpr hZ
    exact Multiset.card_eq_zero.mp (by omega)
  subst hX
  simp only [toyState, zero_add] at hM hN
  obtain ⟨z, hz, hlt1⟩ := hlt (.ticket ()) (by rw [← hM]; exact Multiset.mem_singleton_self _)
  rw [← hN, Multiset.mem_singleton] at hz
  subst hz
  exact lt_irrefl _ hlt1

/-- OmegaPrecond (2), carried in; a stage clears its ticket, discharges OmegaPrecond and
    emits RequiresHitmap (1), which ranks below it. -/
def onlyTwo : DischargeMatrix Unit ℕ Unit := ⟨fun _ => (), fun o _ => o = 2⟩
def lowers : StageRun Unit Unit ℕ Unit := ⟨(), k 0, {1}, ()⟩

/-- Witness for `LoaderStep.progress` (from T-Boot's state with OmegaPrecond carried in,
    the stage clears its ticket and replaces OmegaPrecond by RequiresHitmap): the step and
    the conclusion. -/
theorem loader_progress_witness :
    ∃ t, LoaderStep budget toyPrims onlyTwo (toyBootState (fun _ => Set.univ) {2}) t
      ∧ Multiset.IsDershowitzMannaLT t.pending
          (toyBootState (fun _ => Set.univ) {2}).pending := by
  refine ⟨_, LoaderStep.stage _ lowers [] 0 7
    (by funext i; simp [lowers, toyBootState, bootState, toyBoot, k]) (fun _ h => absurd rfl h)
    (by simp [toyBootState, bootState, toyBoot])
    (fun _ => by simp [toyBootState, bootState, toyBoot, lowers, combine, combineAxis, budget, k,
        Bound.known])
    (by simp [toyBootState, bootState, windowStart, toyBoot, lowers]), ?_⟩
  have hp : afterStage onlyTwo (toyBootState (fun _ => Set.univ) {2}).pending lowers
      = {.obl 1} := by
    classical
    simp only [afterStage, toyBootState, bootState, windowStart, toyBoot, lowers,
      Multiset.map_singleton, Multiset.cons_add, Multiset.singleton_add, Multiset.filter_cons,
      Multiset.filter_singleton]
    simp [DischargeMatrix.Clears, DischargeMatrix.Discharges, onlyTwo]
  simp only [hp]
  refine ⟨0, {.obl 1}, (toyBootState (fun _ => Set.univ) {2}).pending,
    by simp [toyBootState, bootState, windowStart, toyBoot], by simp, by simp, ?_⟩
  intro y hy
  rw [Multiset.mem_singleton] at hy
  subst hy
  exact ⟨.ticket (), by simp [toyBootState, bootState, windowStart, toyBoot], WithTop.coe_lt_top 1⟩

/-! ## A window run through the Loader -/

/-- The boot record for a window whose stages are EF and PR. -/
def efPrBoot : Boot Unit Stg ℕ ℕ := toyBoot (fun _ => Set.univ) efPr

/-- Witness: from T-Boot's state, the Loader runs EF and then PR, the run `pass_sound`'s
    witness uses. It ends with nothing pending and its invariant intact, and the window
    passes. EF clears only its ticket, which is the step a Loader without tickets can't
    take. -/
theorem loader_runs_window :
    ∃ s₁ s₂, LoaderStep budget toyPrims hitmap (bootState toyPrims efPrBoot (0 : Multiset Unit)) s₁
      ∧ LoaderStep budget toyPrims hitmap s₁ s₂
      ∧ s₂.pending = 0 ∧ LoaderInv budget toyPrims s₂
      ∧ Passes budget (fun _ => 0) (fun _ => 0) hitmap efPrBoot.stages 0 [efEmits, prRuns] := by
  have h₁ := LoaderStep.stage (kind := budget) (prims := toyPrims) (M := hitmap)
    (bootState toyPrims efPrBoot (0 : Multiset Unit)) efEmits [] 0 1
    (by funext i; simp [efEmits, bootState, efPrBoot, toyBoot, k]) (fun _ _ => Set.mem_univ _)
    (by simp [bootState, efPrBoot, toyBoot])
    (fun _ => by simp [bootState, efPrBoot, toyBoot, efEmits, combine, combineAxis, budget, k,
        Bound.known])
    (by simp [bootState, windowStart, efPrBoot, toyBoot, efPr, efEmits, Multiset.insert_eq_cons])
  refine ⟨_, _, h₁, LoaderStep.stage _ prRuns [] 0 2
    (by funext i; simp [prRuns, bootState, efPrBoot, toyBoot, k]) (fun _ _ => Set.mem_univ _)
    (by simp [bootState, efPrBoot, toyBoot])
    (fun _ => by simp [bootState, efPrBoot, toyBoot, efEmits, prRuns, combine, combineAxis,
        budget, k, Bound.known])
    (by
      show Pending.ticket prRuns.stage ∈ afterStage hitmap (windowStart efPr 0) efEmits
      rw [hitmap_after_ef]; simp [prRuns, Multiset.insert_eq_cons]), ?_, ?_, ?_⟩
  · show afterStage hitmap (afterStage hitmap (windowStart efPr 0) efEmits) prRuns = 0
    rw [hitmap_after_ef, hitmap_after_pr]
  · refine ⟨rfl, trivial, rfl, rfl, by simp [L5, bootState, efPrBoot, toyBoot],
      fun _ _ => Set.mem_univ _, ?_, by simp [L8, bootState, efPrBoot, toyBoot], ?_, rfl⟩
    · intro st x y
      funext i
      ext <;> simp [bootState, efPrBoot, toyBoot, combine, combineAxis, budget, k, Bound.known]
    · intro i
      simp [bootState, efPrBoot, toyBoot, efEmits, prRuns, combine, combineAxis, budget, k,
        Bound.known]
  · refine ⟨by simp [leaseVerdict, windowGrade, seqComp, combine, combineAxis, budget, efEmits,
      prRuns, k, Bound.known, Bound.width], ?_⟩
    show afterStage hitmap (afterStage hitmap (windowStart efPr 0) efEmits) prRuns = 0
    rw [hitmap_after_ef, hitmap_after_pr]

/-- Must-fail: from the same boot state, a run with no stages leaves both tickets
    pending, so the window doesn't pass. -/
theorem empty_run_fails :
    ¬ Passes budget (fun _ => 0) (fun _ => 0) hitmap efPrBoot.stages 0 [] := by
  rintro ⟨-, h⟩
  simp [pendingAfter, windowStart, efPrBoot, toyBoot, efPr] at h

/-! ## threads_spec -/

/-- Mutant: v1's residual check alone. Each later stage is checked against the residual
    the earlier ones left, but no stage before the last is checked to fit. -/
def ResidualOnly : ENNReal → List ENNReal → Prop
  | _, [] => True
  | θ, [x] => x ≤ θ
  | θ, x :: y :: rest => ResidualOnly (residual θ x) (y :: rest)

/-- θ = 1, stages 2 then 0: stage one overspends, the residual truncates to 0, and stage
    two's 0 still fits it. -/
theorem threads_spec_mutant :
    ¬ ∀ θ : ENNReal, θ ≠ ⊤ → ∀ xs : List ENNReal, (ResidualOnly θ xs ↔ xs.sum ≤ θ) := by
  intro hc
  have := (hc 1 ENNReal.one_ne_top [2, 0]).mp (by simp [ResidualOnly])
  norm_num at this

/-- Witness for `threads_spec` (θ = 10 with stages 3 then 4, which fit; θ = 1 with stages
    2 then 0, where stage one overspends): the hypothesis and the conclusion for each. -/
theorem threads_spec_witness :
    (10 : ENNReal) ≠ ⊤ ∧ (Threads 10 [3, 4] ↔ ([3, 4] : List ENNReal).sum ≤ 10)
      ∧ (1 : ENNReal) ≠ ⊤ ∧ (Threads 1 [2, 0] ↔ ([2, 0] : List ENNReal).sum ≤ 1) := by
  refine ⟨by simp, ?_, ENNReal.one_ne_top, ?_⟩
  · have h4 : (4 : ENNReal) ≤ residual 10 3 :=
      (ENNReal.le_sub_iff_add_le_left (by norm_num) (by norm_num)).mpr (by norm_num)
    exact iff_of_true ⟨by norm_num, h4, trivial⟩ (by norm_num)
  · simp only [Threads, List.sum_cons, List.sum_nil]
    constructor
    · intro h; norm_num at h
    · intro h; norm_num at h

/-! ## statements-v3

Controls for the theorems added in `statements-v3`, in the same style. Each mutant comes
from a defect in `archive/`: PDE Lemma 9.1's strict inequality, jsg-lab's raw-coordinate
radius, and JSG II's KL dual read with η as the tilt. The KL–Fisher controls use a fair
coin, whose ±c statistic has log-partition function log cosh(c x); the DRO controls use a
Gaussian loss of variance 2. -/

open MeasureTheory ProbabilityTheory InformationTheory

/-! ## cvar_tail_to_level -/

/-- Mutant: PDE Lemma 9.1's conclusion, that every cell outside the tail has E < ε_CKN.
    With every constant at 1, the tail it bounds is {X ≥ ε}. A loss equal to 1 everywhere has
    CVaR 1 at tail mass 1/2, but all of its mass is at 1. -/
theorem cvar_tail_to_level_mutant :
    ¬ ∀ (μ : Measure Unit) (α : ENNReal) (X : Unit → ENNReal), AEMeasurable X μ →
      ∀ ε, cvar μ α X ≤ ε → μ {ω | ε ≤ X ω} ≤ α := by
  intro hc
  have h1 : cvar (Measure.dirac ()) 2⁻¹ (fun _ => 1) ≤ 1 := iInf_le_of_le 1 (by simp)
  have h2 := hc (Measure.dirac ()) 2⁻¹ (fun _ => 1) aemeasurable_const 1 h1
  have h3 : {ω : Unit | (1 : ENNReal) ≤ 1} = Set.univ := by simp
  rw [h3, measure_univ] at h2
  exact absurd h2 (not_le.2 (ENNReal.inv_lt_one.2 ENNReal.one_lt_two))

/-- A quarter of the mass on `true`, the rest on `false`. -/
noncomputable def quarterMass : Measure Bool :=
  (4⁻¹ : ENNReal) • Measure.dirac true + (3 * 4⁻¹ : ENNReal) • Measure.dirac false

/-- A loss of 2 on `true` and 0 on `false`. -/
def twoOnTrue : Bool → ENNReal := fun b => if b then 2 else 0

/-- Witness for `cvar_tail_to_level` (tail mass 1/2, ε = 1): the loss is measurable; its CVaR
    is at most 1, since the level 0 gives E[X]/α = (1/2)/(1/2); and it exceeds 1 on a quarter
    of the mass, within 1/2. -/
theorem cvar_tail_to_level_witness :
    AEMeasurable twoOnTrue quarterMass ∧ cvar quarterMass 2⁻¹ twoOnTrue ≤ 1 ∧
      quarterMass {ω | 1 < twoOnTrue ω} ≤ 2⁻¹ := by
  refine ⟨Measurable.of_discrete.aemeasurable, ?_, ?_⟩
  · refine iInf_le_of_le 0 ?_
    have h : ∫⁻ ω, (twoOnTrue ω - 0) ∂quarterMass = 2⁻¹ := by
      simp only [tsub_zero, quarterMass, lintegral_add_measure, lintegral_smul_measure,
        lintegral_dirac, twoOnTrue, ↓reduceIte, Bool.false_eq_true, smul_eq_mul, mul_zero,
        add_zero]
      rw [show (4 : ENNReal) = 2 * 2 by norm_num, ENNReal.mul_inv (by simp) (by simp), mul_assoc,
        ENNReal.inv_mul_cancel (by simp) (by simp), mul_one]
    rw [h, zero_add, ENNReal.div_self (by simp) (by simp)]
  · have h : {ω | (1 : ENNReal) < twoOnTrue ω} = {true} := by
      ext b
      cases b <;> simp [twoOnTrue]
    have h2 : quarterMass {true} = 4⁻¹ := by simp [quarterMass]
    rw [h, h2]
    exact ENNReal.inv_le_inv.2 (by norm_num)

/-! ## kl_fisher_local -/

/-- A fair coin. -/
noncomputable def coin : Measure Bool :=
  (2⁻¹ : ENNReal) • (Measure.dirac true + Measure.dirac false)

instance : IsProbabilityMeasure coin := by
  constructor
  simp only [coin, Measure.smul_apply, Measure.add_apply, measure_univ, smul_eq_mul]
  rw [one_add_one_eq_two, ENNReal.inv_mul_cancel (by simp) (by simp)]

lemma integral_coin (f : Bool → ℝ) : ∫ ω, f ω ∂coin = (f true + f false) / 2 := by
  rw [coin, integral_smul_measure, integral_add_measure Integrable.of_finite Integrable.of_finite,
    integral_dirac, integral_dirac]
  simp [ENNReal.toReal_inv]
  ring

/-- The statistic ±c on the coin. -/
noncomputable def pm (c : ℝ) : Bool → ℝ := fun b => if b then c else -c

lemma logPartition_pm (c x : ℝ) : logPartition coin (pm c) x = Real.log (Real.cosh (c * x)) := by
  rw [logPartition, integral_coin, Real.cosh_eq]
  simp [pm, RCLike.inner_apply]

lemma hasDerivAt_tanh' (x : ℝ) : HasDerivAt Real.tanh (1 / Real.cosh x ^ 2) x := by
  have h := (Real.hasDerivAt_sinh x).div (Real.hasDerivAt_cosh x) (Real.cosh_pos x).ne'
  have he : Real.sinh / Real.cosh = Real.tanh :=
    funext fun y => (Real.tanh_eq_sinh_div_cosh y).symm
  rw [he] at h
  convert h using 1
  have h1 : Real.cosh x * Real.cosh x - Real.sinh x * Real.sinh x = 1 := by
    have := Real.cosh_sq_sub_sinh_sq x
    nlinarith
  rw [h1]

lemma hasDerivAt_logCosh (y : ℝ) :
    HasDerivAt (fun y => Real.log (Real.cosh y)) (Real.tanh y) y := by
  have h := (Real.hasDerivAt_cosh y).log (Real.cosh_pos y).ne'
  rwa [← Real.tanh_eq_sinh_div_cosh] at h

/-- The coin's mixed cumulant, c tanh(c x). -/
noncomputable def coinκ (c : ℝ) : ℝ → ℝ := fun x => c * Real.tanh (c * x)

/-- The coin's Fisher information, c² / cosh²(c x). -/
noncomputable def coinH (c : ℝ) : ℝ → ℝ →L[ℝ] ℝ :=
  fun x => (c ^ 2 / Real.cosh (c * x) ^ 2) • (1 : ℝ →L[ℝ] ℝ)

lemma coin_hasGradientAt (c x : ℝ) : HasGradientAt (logPartition coin (pm c)) (coinκ c x) x := by
  have he : logPartition coin (pm c) = fun y => Real.log (Real.cosh (c * y)) :=
    funext (logPartition_pm c)
  rw [he]
  apply HasDerivAt.hasGradientAt'
  have h := (hasDerivAt_logCosh (c * x)).comp x ((hasDerivAt_id x).const_mul c)
  exact h.congr_deriv (by simp only [coinκ, mul_one]; ring)

lemma coin_hasFDerivAt (c x : ℝ) : HasFDerivAt (coinκ c) (coinH c x) x := by
  have h := ((hasDerivAt_tanh' (c * x)).comp x ((hasDerivAt_id x).const_mul c)).const_mul c
  have h2 : HasDerivAt (coinκ c) (c ^ 2 / Real.cosh (c * x) ^ 2) x :=
    h.congr_deriv (by ring)
  rw [hasDerivAt_iff_hasFDerivAt] at h2
  convert h2 using 1
  ext
  simp [coinH]

lemma tanh_nonneg' {y : ℝ} (hy : 0 ≤ y) : 0 ≤ Real.tanh y := by
  rw [Real.tanh_eq_sinh_div_cosh]
  exact div_nonneg (Real.sinh_nonneg_iff.2 hy) (Real.cosh_pos y).le

lemma tanh_le_self' {y : ℝ} (hy : 0 ≤ y) : Real.tanh y ≤ y := by
  have hcont : ContinuousOn Real.tanh (Set.Icc 0 y) :=
    fun x _ => (hasDerivAt_tanh' x).continuousAt.continuousWithinAt
  have := image_le_of_deriv_right_le_deriv_boundary (f := Real.tanh)
    (f' := fun x => 1 / Real.cosh x ^ 2) (a := 0) (b := y) hcont
    (fun x _ => (hasDerivAt_tanh' x).hasDerivWithinAt) (B := id) (B' := fun _ => 1)
    (by simp) continuousOn_id (fun x _ => (hasDerivAt_id x).hasDerivWithinAt)
    (fun x _ => by
      rw [div_le_one (by positivity)]
      nlinarith [Real.one_le_cosh x]) (show y ∈ Set.Icc 0 y from ⟨hy, le_rfl⟩)
  simpa using this

lemma tanh_sq_eq (y : ℝ) : Real.tanh y ^ 2 = 1 - 1 / Real.cosh y ^ 2 := by
  rw [Real.tanh_eq_sinh_div_cosh, div_pow]
  have hc : Real.cosh y ^ 2 ≠ 0 := pow_ne_zero 2 (Real.cosh_pos y).ne'
  field_simp
  have := Real.cosh_sq_sub_sinh_sq y
  linarith

lemma tanh_sq_le {y : ℝ} (hy : 0 ≤ y) : Real.tanh y ^ 2 ≤ y := by
  have h1 := tanh_le_self' hy
  have h2 := tanh_nonneg' hy
  have h3 := (Real.tanh_lt_one y).le
  nlinarith

/-- The Fisher information moves at most c³x from c² on [0, ∞). -/
lemma coinH_sub {c x : ℝ} (hc : 0 ≤ c) (hx : 0 ≤ x) : ‖coinH c x - coinH c 0‖ ≤ c ^ 3 * ‖x‖ := by
  have h : coinH c x - coinH c 0 = (c ^ 2 / Real.cosh (c * x) ^ 2 - c ^ 2) • (1 : ℝ →L[ℝ] ℝ) := by
    simp only [coinH, mul_zero, Real.cosh_zero, one_pow, div_one]
    exact (sub_smul _ _ _).symm
  rw [h, norm_smul, norm_one, mul_one, Real.norm_eq_abs, Real.norm_of_nonneg hx]
  have h1 : c ^ 2 / Real.cosh (c * x) ^ 2 - c ^ 2 = -(c ^ 2 * Real.tanh (c * x) ^ 2) := by
    rw [tanh_sq_eq]
    ring
  rw [h1, abs_neg, abs_of_nonneg (by positivity)]
  have h2 := tanh_sq_le (mul_nonneg hc hx)
  calc c ^ 2 * Real.tanh (c * x) ^ 2 ≤ c ^ 2 * (c * x) := by gcongr
    _ = c ^ 3 * x := by ring

/-- KL divergence of a tilted probability measure from its base. -/
lemma klDiv_tilted_self' {Ω : Type} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    {f : Ω → ℝ} (hexp : Integrable (fun ω => Real.exp (f ω)) μ) (hf : AEMeasurable f μ)
    (hfi : Integrable f (μ.tilted f)) :
    klDiv (μ.tilted f) μ =
      ENNReal.ofReal (∫ ω, f ω ∂(μ.tilted f) - Real.log (∫ ω, Real.exp (f ω) ∂μ)) := by
  have : IsProbabilityMeasure (μ.tilted f) := isProbabilityMeasure_tilted hexp
  have hac : μ.tilted f ≪ μ := tilted_absolutelyContinuous μ f
  have h1 : llr (μ.tilted f) μ =ᵐ[μ] fun ω => f ω - Real.log (∫ z, Real.exp (f z) ∂μ) := by
    filter_upwards [llr_tilted_left (Measure.AbsolutelyContinuous.refl μ) hexp hf, llr_self μ]
      with ω h1 h2
    rw [h1, h2]
    simp
  have h2 : llr (μ.tilted f) μ =ᵐ[μ.tilted f]
      fun ω => f ω - Real.log (∫ z, Real.exp (f z) ∂μ) := hac.ae_le h1
  have hint : Integrable (llr (μ.tilted f) μ) (μ.tilted f) :=
    (hfi.sub (integrable_const _)).congr h2.symm
  rw [klDiv_of_ac_of_integrable hac hint, integral_congr_ae h2,
    integral_sub hfi (integrable_const _)]
  simp

lemma klDiv_coin (c θ : ℝ) : klDiv (expFamily coin (pm c) θ) coin =
    ENNReal.ofReal (c * θ * Real.tanh (c * θ) - Real.log (Real.cosh (c * θ))) := by
  have hexp : Integrable (fun ω => Real.exp (inner ℝ θ (pm c ω))) coin := Integrable.of_finite
  have : IsProbabilityMeasure (coin.tilted fun ω => inner ℝ θ (pm c ω)) :=
    isProbabilityMeasure_tilted hexp
  rw [expFamily, klDiv_tilted_self' coin hexp Measurable.of_discrete.aemeasurable
      Integrable.of_finite, integral_tilted, integral_coin, integral_coin,
    Real.tanh_eq, Real.cosh_eq]
  congr 1
  simp only [pm, RCLike.inner_apply, conj_trivial, ↓reduceIte, Bool.false_eq_true,
    smul_eq_mul, neg_mul]
  have hp : 0 < Real.exp (c * θ) + Real.exp (-(c * θ)) := by positivity
  field_simp
  ring

lemma tanh_log_two : Real.tanh (Real.log 2) = 3 / 5 := by
  rw [Real.tanh_eq, Real.exp_neg, Real.exp_log two_pos]
  norm_num

lemma cosh_log_two : Real.cosh (Real.log 2) = 5 / 4 := by
  rw [Real.cosh_eq, Real.exp_neg, Real.exp_log two_pos]
  norm_num

lemma exp_two_log_two : Real.exp (2 * Real.log 2) = 4 := by
  rw [show 2 * Real.log 2 = Real.log 2 + Real.log 2 by ring, Real.exp_add, Real.exp_log two_pos]
  norm_num

lemma tanh_two_log_two : Real.tanh (2 * Real.log 2) = 15 / 17 := by
  rw [Real.tanh_eq, Real.exp_neg, exp_two_log_two]
  norm_num

lemma cosh_two_log_two : Real.cosh (2 * Real.log 2) = 17 / 8 := by
  rw [Real.cosh_eq, Real.exp_neg, exp_two_log_two]
  norm_num

lemma interior_coin (T : Bool → ℝ) :
    interior {x : ℝ | Integrable (fun ω => Real.exp (inner ℝ x (T ω))) coin} = Set.univ := by
  rw [show {x : ℝ | Integrable (fun ω => Real.exp (inner ℝ x (T ω))) coin} = Set.univ from
    Set.eq_univ_of_forall fun _ => Integrable.of_finite]
  exact interior_univ

/-- Witness for `kl_fisher_local` (the fair coin with statistic ±1, which is whitened;
    L = 1, ε = 7/10, θ = log 2): every hypothesis, then the conclusion, where the KL
    divergence (3/5) log 2 − log(5/4) ≈ 0.19 lies between 0.054 and 0.306. -/
theorem kl_fisher_local_witness :
    (∀ x ∈ segment ℝ 0 (Real.log 2), HasGradientAt (logPartition coin (pm 1)) (coinκ 1 x) x) ∧
    (∀ x ∈ segment ℝ 0 (Real.log 2), HasFDerivAt (coinκ 1) (coinH 1 x) x) ∧
    coinκ 1 0 = 0 ∧
    (∀ x ∈ segment ℝ 0 (Real.log 2), ‖coinH 1 x - 1‖ ≤ 1 * ‖x‖) ∧
    Real.log 2 ∈ interior {x : ℝ | Integrable (fun ω => Real.exp (inner ℝ x (pm 1 ω))) coin} ∧
    1 * ‖Real.log 2‖ ≤ 7 / 10 ∧ (7 / 10 : ℝ) ≤ 1 ∧
    ENNReal.ofReal ((1 - 7 / 10) / 2 * ‖coinκ 1 (Real.log 2)‖ ^ 2) ≤
        klDiv (expFamily coin (pm 1) (Real.log 2)) coin ∧
      klDiv (expFamily coin (pm 1) (Real.log 2)) coin ≤
        ENNReal.ofReal ((1 + 7 / 10) / 2 * ‖coinκ 1 (Real.log 2)‖ ^ 2) := by
  have hlog := Real.log_two_gt_d9
  have hlog' := Real.log_two_lt_d9
  have hseg : ∀ x ∈ segment ℝ 0 (Real.log 2), 0 ≤ x := by
    intro x hx
    rw [segment_eq_Icc (by linarith)] at hx
    exact hx.1
  have hκ : ‖coinκ 1 (Real.log 2)‖ = 3 / 5 := by
    simp [coinκ, tanh_log_two]
  have h54lo := Real.one_sub_inv_le_log_of_pos (show (0 : ℝ) < 5 / 4 by norm_num)
  have h54hi := Real.log_le_sub_one_of_pos (show (0 : ℝ) < 5 / 4 by norm_num)
  refine ⟨fun x _ => coin_hasGradientAt 1 x, fun x _ => coin_hasFDerivAt 1 x,
    by simp [coinκ], fun x hx => ?_, by rw [interior_coin]; trivial, ?_, by norm_num, ?_, ?_⟩
  · have h := coinH_sub zero_le_one (hseg x hx)
    have h0 : coinH 1 0 = 1 := by simp [coinH]
    rw [h0] at h
    simpa using h
  · rw [Real.norm_of_nonneg (by linarith)]
    linarith
  · rw [klDiv_coin, hκ]
    apply ENNReal.ofReal_le_ofReal
    simp only [one_mul, tanh_log_two, cosh_log_two]
    norm_num at h54lo h54hi ⊢
    linarith
  · rw [klDiv_coin, hκ]
    apply ENNReal.ofReal_le_ofReal
    simp only [one_mul, tanh_log_two, cosh_log_two]
    norm_num at h54lo h54hi ⊢
    linarith

/-- JSG I's bound in raw coordinates, as jsg-lab's `FisherContext` (`stats/fisher.py`) applies
    it, at the fair coin: the Fisher information at 0 is F = H 0 1, the cumulants are measured
    in its inverse, and the radius comes from H's Lipschitz constant without whitening. With
    H 0 = 1 this is `kl_fisher_local` at the coin. -/
def KLFisherRaw : Prop :=
  ∀ (T : Bool → ℝ) (κ : ℝ → ℝ) (H : ℝ → ℝ →L[ℝ] ℝ) (L ε θ : ℝ),
    (∀ x ∈ segment ℝ 0 θ, HasGradientAt (logPartition coin T) (κ x) x) →
    (∀ x ∈ segment ℝ 0 θ, HasFDerivAt κ (H x) x) → κ 0 = 0 →
    (∀ x ∈ segment ℝ 0 θ, ‖H x - H 0‖ ≤ L * ‖x‖) →
    θ ∈ interior {x | Integrable (fun ω => Real.exp (inner ℝ x (T ω))) coin} →
    L * ‖θ‖ ≤ ε → ε ≤ 1 →
    ENNReal.ofReal ((1 - ε) / 2 * (κ θ ^ 2 / H 0 1)) ≤ klDiv (expFamily coin T θ) coin ∧
      klDiv (expFamily coin T θ) coin ≤ ENNReal.ofReal ((1 + ε) / 2 * (κ θ ^ 2 / H 0 1))

/-- Mutant: `FisherContext`'s raw coordinates. Its radius r = ε / L_ψ takes L_ψ as the
    largest third absolute moment of the raw features, which for a ±1/4 feature is 1/64; with
    its ε = 0.1, r = 6.4. At θ = 8 log 2 ≈ 5.5, inside r, the KL divergence
    (81/17) log 2 − log 17 ≈ 0.47 exceeds (1 + ε)/2 · κ²/F = (11/20)(15/17)² ≈ 0.43. -/
theorem kl_fisher_local_mutant : ¬ KLFisherRaw := by
  intro hc
  have hlog := Real.log_two_gt_d9
  have hlog' := Real.log_two_lt_d9
  have hθ : (0 : ℝ) ≤ 8 * Real.log 2 := by linarith
  have hseg : ∀ x ∈ segment ℝ 0 (8 * Real.log 2), 0 ≤ x := by
    intro x hx
    rw [segment_eq_Icc hθ] at hx
    exact hx.1
  have h := (hc (pm (1 / 4)) (coinκ (1 / 4)) (coinH (1 / 4)) (1 / 64) (1 / 10) (8 * Real.log 2)
    (fun x _ => coin_hasGradientAt _ x) (fun x _ => coin_hasFDerivAt _ x) (by simp [coinκ])
    (fun x hx => by
      have := coinH_sub (show (0 : ℝ) ≤ 1 / 4 by norm_num) (hseg x hx)
      norm_num at this ⊢
      exact this)
    (by rw [interior_coin]; trivial)
    (by rw [Real.norm_of_nonneg hθ]; linarith) (by norm_num)).2
  have hcθ : 1 / 4 * (8 * Real.log 2) = 2 * Real.log 2 := by ring
  rw [klDiv_coin] at h
  simp only [coinκ, coinH, hcθ, tanh_two_log_two, cosh_two_log_two, mul_zero, Real.cosh_zero]
    at h
  rw [ENNReal.ofReal_le_ofReal_iff (by norm_num)] at h
  -- log (17/8) = log 2 + log (17/16) ≤ log 2 + 1/16
  have h1716 := Real.log_le_sub_one_of_pos (show (0 : ℝ) < 17 / 16 by norm_num)
  have hsplit : Real.log (17 / 8) = Real.log 2 + Real.log (17 / 16) := by
    rw [← Real.log_mul (by norm_num) (by norm_num)]
    norm_num
  rw [hsplit] at h
  norm_num at h h1716
  linarith

/-! ## dro_envelope -/

/-- (1/η) log E[e^{ηℓ}] for a Gaussian loss ℓ of variance 2. -/
noncomputable def gaussTilt (η : ℝ) : ℝ := 1 / η * Real.log (mgf id (gaussianReal 0 2) η)

lemma gaussTilt_eq {η : ℝ} (hη : η ≠ 0) : gaussTilt η = η := by
  rw [gaussTilt, mgf_id_gaussianReal, Real.log_exp]
  field_simp
  push_cast
  ring

/-- η log E[e^{ℓ/η}] for the same loss: the KL dual's g. -/
noncomputable def gaussDual (η : ℝ) : ℝ := η * Real.log (mgf id (gaussianReal 0 2) (1 / η))

lemma gaussDual_eq {η : ℝ} (hη : η ≠ 0) : gaussDual η = 1 / η := by
  rw [gaussDual, mgf_id_gaussianReal, Real.log_exp]
  field_simp
  push_cast
  ring

/-- The bounds read with η as the tilt. -/
noncomputable def tiltDual (S : Set ℝ) (k : ℝ → ℝ) (ρ : ℝ) : ℝ := ⨅ η : S, ρ / (η : ℝ) + k η

/-- The envelope claim with the bounds read in the tilt. -/
def TiltEnvelope : Prop :=
  ∀ (S : Set ℝ) (k ηstar : ℝ → ℝ) (ρ₀ : ℝ),
    (∀ᶠ ρ in nhds ρ₀, ηstar ρ ∈ S ∧ ∀ η ∈ S, ρ / ηstar ρ + k (ηstar ρ) ≤ ρ / η + k η) →
    ContinuousAt ηstar ρ₀ → HasDerivAt (tiltDual S k) (ηstar ρ₀) ρ₀

/-- AM–GM in the two forms the controls use. -/
lemma two_sqrt_le {ρ η : ℝ} (hρ : 0 < ρ) (hη : 0 < η) :
    2 * Real.sqrt ρ ≤ ρ / η + η ∧ 2 * Real.sqrt ρ ≤ η * ρ + 1 / η := by
  have hs := Real.sq_sqrt hρ.le
  have hs0 := Real.sqrt_nonneg ρ
  constructor
  · rw [div_add' _ _ _ hη.ne', le_div_iff₀ hη]
    nlinarith [sq_nonneg (Real.sqrt ρ - η)]
  · rw [show η * ρ + 1 / η = (η * η * ρ + 1) / η by field_simp, le_div_iff₀ hη]
    nlinarith [sq_nonneg (η * Real.sqrt ρ - 1)]

/-- Mutant: JSG II's KL dual with η read as the tilt, as in its e^{ηℓ}. For a Gaussian loss of
    variance 2 the bounds are ρ/η + η, the dual is 2√ρ and the minimizing tilt is √ρ: at
    ρ = 4 the slope is 1/2, but η* = 2. -/
theorem dro_envelope_mutant : ¬ TiltEnvelope := by
  intro hc
  have hval : ∀ ρ : ℝ, 0 < ρ → tiltDual (Set.Ioi 0) gaussTilt ρ = 2 * Real.sqrt ρ := by
    intro ρ hρ
    have hsq : 0 < Real.sqrt ρ := Real.sqrt_pos.2 hρ
    apply le_antisymm
    · refine ciInf_le_of_le ⟨0, ?_⟩ ⟨Real.sqrt ρ, hsq⟩ ?_
      · rintro _ ⟨η, rfl⟩
        have := η.2
        simp only [Set.mem_Ioi] at this
        dsimp only
        rw [gaussTilt_eq this.ne']
        positivity
      · simp only
        rw [gaussTilt_eq hsq.ne', Real.div_sqrt]
        ring_nf
        exact le_rfl
    · have : Nonempty (Set.Ioi (0 : ℝ)) := ⟨⟨1, Set.mem_Ioi.2 one_pos⟩⟩
      refine le_ciInf fun η => ?_
      have hη : (0 : ℝ) < η := η.2
      rw [gaussTilt_eq hη.ne']
      exact (two_sqrt_le hρ hη).1
  have hmin : ∀ᶠ ρ in nhds (4 : ℝ), Real.sqrt ρ ∈ Set.Ioi 0 ∧
      ∀ η ∈ Set.Ioi 0, ρ / Real.sqrt ρ + gaussTilt (Real.sqrt ρ) ≤ ρ / η + gaussTilt η := by
    filter_upwards [lt_mem_nhds (show (0 : ℝ) < 4 by norm_num)] with ρ hρ
    have hsq : 0 < Real.sqrt ρ := Real.sqrt_pos.2 hρ
    refine ⟨hsq, fun η hη => ?_⟩
    rw [gaussTilt_eq hsq.ne', gaussTilt_eq (ne_of_gt hη), Real.div_sqrt]
    have := (two_sqrt_le hρ hη).1
    linarith
  have h := hc (Set.Ioi 0) gaussTilt Real.sqrt 4 hmin Real.continuous_sqrt.continuousAt
  have h2 : HasDerivAt (fun ρ => 2 * Real.sqrt ρ) (1 / 2) 4 := by
    have := (Real.hasDerivAt_sqrt (show (4 : ℝ) ≠ 0 by norm_num)).const_mul 2
    convert this using 1
    rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
    norm_num
  have heq : tiltDual (Set.Ioi 0) gaussTilt =ᶠ[nhds 4] fun ρ => 2 * Real.sqrt ρ := by
    filter_upwards [lt_mem_nhds (show (0 : ℝ) < 4 by norm_num)] with ρ hρ
    exact hval ρ hρ
  have h3 := (h.congr_of_eventuallyEq heq.symm).unique h2
  rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)] at h3
  norm_num at h3

/-- The KL dual's minimizing multiplier for that loss, η*(ρ) = 1/√ρ. -/
noncomputable def invSqrt (ρ : ℝ) : ℝ := 1 / Real.sqrt ρ

/-- Witness for `dro_envelope` (the KL dual of the same Gaussian loss, ρ₀ = 1): its bounds
    are ηρ + 1/η, minimized by η*(ρ) = 1/√ρ, which is continuous; the dual is 2√ρ, whose
    slope at 1 is η*(1) = 1. -/
theorem dro_envelope_witness :
    (∀ᶠ ρ in nhds (1 : ℝ), invSqrt ρ ∈ Set.Ioi 0 ∧
      ∀ η ∈ Set.Ioi (0 : ℝ), invSqrt ρ * ρ + gaussDual (invSqrt ρ) ≤ η * ρ + gaussDual η) ∧
    ContinuousAt invSqrt 1 ∧ HasDerivAt (dualValue (Set.Ioi 0) gaussDual) (invSqrt 1) 1 := by
  unfold invSqrt
  have hval : ∀ ρ : ℝ, 0 < ρ → dualValue (Set.Ioi 0) gaussDual ρ = 2 * Real.sqrt ρ := by
    intro ρ hρ
    have hsq : 0 < Real.sqrt ρ := Real.sqrt_pos.2 hρ
    have hinv : 0 < 1 / Real.sqrt ρ := by positivity
    apply le_antisymm
    · refine ciInf_le_of_le ⟨0, ?_⟩ ⟨1 / Real.sqrt ρ, hinv⟩ ?_
      · rintro _ ⟨η, rfl⟩
        have := η.2
        simp only [Set.mem_Ioi] at this
        dsimp only
        rw [gaussDual_eq this.ne']
        positivity
      · simp only
        rw [gaussDual_eq hinv.ne']
        field_simp
        rw [Real.sq_sqrt hρ.le]
        ring_nf
        exact le_rfl
    · have : Nonempty (Set.Ioi (0 : ℝ)) := ⟨⟨1, Set.mem_Ioi.2 one_pos⟩⟩
      refine le_ciInf fun η => ?_
      have hη : (0 : ℝ) < η := η.2
      rw [gaussDual_eq hη.ne']
      exact (two_sqrt_le hρ hη).2
  refine ⟨?_, ?_, ?_⟩
  · filter_upwards [lt_mem_nhds (show (0 : ℝ) < 1 by norm_num)] with ρ hρ
    have hsq : 0 < Real.sqrt ρ := Real.sqrt_pos.2 hρ
    have hinv : 0 < 1 / Real.sqrt ρ := by positivity
    refine ⟨hinv, fun η hη => ?_⟩
    rw [gaussDual_eq hinv.ne', gaussDual_eq (ne_of_gt hη)]
    have := (two_sqrt_le hρ hη).2
    have h1 : 1 / Real.sqrt ρ * ρ + 1 / (1 / Real.sqrt ρ) = 2 * Real.sqrt ρ := by
      field_simp
      rw [Real.sq_sqrt hρ.le]
      ring
    linarith
  · exact (continuousAt_const.div Real.continuous_sqrt.continuousAt (by simp))
  · have h2 : HasDerivAt (fun ρ => 2 * Real.sqrt ρ) 1 1 := by
      have := (Real.hasDerivAt_sqrt (show (1 : ℝ) ≠ 0 by norm_num)).const_mul 2
      convert this using 1
      simp
    have heq : dualValue (Set.Ioi 0) gaussDual =ᶠ[nhds 1] fun ρ => 2 * Real.sqrt ρ := by
      filter_upwards [lt_mem_nhds (show (0 : ℝ) < 1 by norm_num)] with ρ hρ
      exact hval ρ hρ
    simpa using h2.congr_of_eventuallyEq heq

end JSG.Tests.Mutants
