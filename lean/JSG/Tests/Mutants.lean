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

end JSG.Tests.Mutants
