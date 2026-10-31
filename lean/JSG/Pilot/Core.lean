import JSG.Harness.Corpus

/-!
The pilot's logic (guide/EXECUTABLE_GATE.md §3): the step from a manuscript's raw record to
its grade, the carry-over rule, and the dependency closure, over the twins. The collectors
supply only raw records and dependency edges, and everything the verdict or the report
depends on is here.

Proved, with only the three axioms:
- masking never adds doubt (`mask_within`);
- combining with a dependency never lowers a manuscript's doubt (`combine_within`), so every
  round of the closure keeps each manuscript's own record (`own_within_closure`);
- so no dependency can rescue a manuscript its own record rejects (`no_rescue`);
- nothing carries into a manuscript whose formalization is complete
  (`closure_of_complete`);
- the report is empty exactly when the verdict accepts (`report_eq_nil`).

That the closure settles within as many rounds as there are manuscripts isn't proved in
general here. For each set of records, its data module proves by `decide +kernel` that the
closure is a fixed point (`Release.Settled`).
-/

namespace JSG.Pilot

open JSG JSG.Harness

/-! ### The axes -/

/-- The pilot's seven axes, all floors. -/
inductive Axis
  | withdrawn
  | dependencyWithdrawn
  | formalProof
  | statementFidelity
  | axioms
  | independentReview
  | novelty
  deriving DecidableEq, Repr

/-- Every axis, in the order a report lists them. -/
def Axis.all : List Axis :=
  [.withdrawn, .dependencyWithdrawn, .formalProof, .statementFidelity, .axioms,
   .independentReview, .novelty]

theorem Axis.mem_all (a : Axis) : a ∈ Axis.all := by cases a <;> simp [Axis.all]

instance : Fintype Axis := Fintype.ofList Axis.all Axis.mem_all

/-- An axis's name, as the reports and EXECUTABLE_GATE.md write it. -/
def Axis.name : Axis → String
  | .withdrawn => "withdrawn"
  | .dependencyWithdrawn => "dependency_withdrawn"
  | .formalProof => "formal_proof"
  | .statementFidelity => "statement_fidelity"
  | .axioms => "axioms"
  | .independentReview => "independent_review"
  | .novelty => "novelty"

/-- Every axis is a floor axis. -/
def floors : Axis → Kind := fun _ => .floor

/-- The pilot's thresholds: θ = 0 on every axis, with no leases (QUEUE.md, Q12). -/
def θ0 : Axis → WithTop ℚ≥0 := fun _ => 0

/-! ### From a raw record to a grade -/

/-- What is known of a manuscript's formalization, from its challenges' facts. -/
inductive Formal
  /-- The full-strength Comparator accepts a challenge for its top-line claim. -/
  | accepted
  /-- It rejects one. -/
  | rejected
  /-- Challenges exist and none is rejected, but not all are accepted: one hasn't run yet, its
      build failed, it was too large to check, or the kernels disagreed. -/
  | unknown
  /-- No challenge exists. -/
  | noChallenge
  deriving DecidableEq, Repr

/-- Our full-strength Comparator run on a challenge, as its trusted log records it
    (guide/EXECUTABLE_GATE.md §4). Only `accepted` and `rejected` are evidence; the rest
    leave `formal_proof` unknown. -/
inductive RunResult
  /-- Comparator accepted it, with nanoda and Lean's kernel. -/
  | accepted
  /-- Comparator rejected it, on one of its own rejections. -/
  | rejected
  /-- Its build or export failed, or it was stopped: by a crash, a signal or the memory
      limit. -/
  | buildError
  /-- It timed out as the first in its job, or with the full 5-hour cap. -/
  | tooLarge
  /-- nanoda failed while Lean's kernel accepted. -/
  | kernelsDisagree
  /-- No trusted run has finished it yet. -/
  | notRun
  deriving DecidableEq, Repr

/-- One of a manuscript's challenges, as the collectors read it. -/
structure ChallengeFacts where
  /-- Our full-strength Comparator run's result. -/
  result : RunResult
  /-- The axioms its configuration permits. -/
  permitted : List String
  deriving DecidableEq, Repr

/-- A manuscript's raw record: only facts, as the collectors read them. -/
structure Raw where
  /-- The date of its withdrawal notice, if it has one. -/
  withdrawnOn : Option String
  /-- The challenges on its family's docs page that cover it. -/
  challenges : List ChallengeFacts
  /-- The named reviewer who confirmed that its challenges state its top-line claim. -/
  fidelityBy : Option String
  /-- Whether an independent review is published. -/
  reviewed : Bool
  /-- Whether its priority has been checked against the literature. -/
  noveltyChecked : Bool
  /-- Whether its dependencies have been read, so that its dependency edges are complete. -/
  depsRead : Bool
  deriving DecidableEq, Repr

/-- The three axioms a challenge may permit. -/
def threeAxioms : List String := ["propext", "Quot.sound", "Classical.choice"]

/-- Whether a challenge permits exactly the three axioms. -/
def ChallengeFacts.exact (c : ChallengeFacts) : Bool :=
  c.permitted.all (· ∈ threeAxioms) && threeAxioms.all (· ∈ c.permitted)

/-- What is known of a manuscript's formalization: no challenge; rejected if Comparator
    rejected any of its challenges; accepted if it accepted all of them; and otherwise
    unknown. -/
def Raw.formal (r : Raw) : Formal :=
  if r.challenges.isEmpty then .noChallenge
  else if r.challenges.any (·.result = .rejected) then .rejected
  else if r.challenges.all (·.result = .accepted) then .accepted
  else .unknown

/-- Whether its challenges permit exactly the three axioms, or `none` without a challenge. -/
def Raw.axiomsOk (r : Raw) : Option Bool :=
  if r.challenges.isEmpty then none else some (r.challenges.all ChallengeFacts.exact)

/-- A manuscript's formalization is complete when its own `formal_proof`, `axioms` and
    `statement_fidelity` are all known to be 0, so its statement has been checked. -/
def complete (r : Raw) : Bool :=
  r.formal = .accepted && r.axiomsOk = some true && r.fidelityBy.isSome

/-- The grade a raw record gives, before anything carries (EXECUTABLE_GATE.md §3's first
    table). `dependency_withdrawn` starts at [0, 0] if the formalization is complete, as
    unknown until the dependencies are read, and at [0, 0] once they are. -/
def ownGrade (r : Raw) : XGrade Axis
  | .withdrawn => if r.withdrawnOn.isSome then XBound.known ⊤ else XBound.known 0
  | .dependencyWithdrawn =>
    if complete r || r.depsRead then XBound.known 0 else XBound.unknown
  | .formalProof => match r.formal with
    | .accepted => XBound.known 0
    | .rejected => XBound.known 1
    | .unknown | .noChallenge => XBound.unknown
  | .statementFidelity => if r.fidelityBy.isSome then XBound.known 0 else XBound.unknown
  | .axioms => match r.axiomsOk with
    | some true => XBound.known 0
    | some false => XBound.known 1
    | none => XBound.unknown
  | .independentReview => if r.reviewed then XBound.known 0 else XBound.unknown
  | .novelty => if r.noveltyChecked then XBound.known 0 else XBound.unknown

/-! ### The carry-over rule (Q14) -/

/-- Which axes carry a dependency's doubt: none into a complete formalization, and otherwise
    every axis but `withdrawn`, which feeds `dependency_withdrawn` instead, and `novelty`. -/
def carries (complete : Bool) : Axis → Bool
  | .withdrawn | .novelty => false
  | _ => !complete

/-- A dependency's grade as it passes on: its own `withdrawn` read into the
    `dependency_withdrawn` it passes on. -/
def passOn (d : XGrade Axis) : XGrade Axis := fun a =>
  if a = .dependencyWithdrawn then xcombineAxis .floor (d .withdrawn) (d .dependencyWithdrawn)
  else d a

/-- Keep the axes that carry; every other axis becomes [0, 0]. -/
def mask (keep : Axis → Bool) (g : XGrade Axis) : XGrade Axis := fun a =>
  if keep a then g a else XBound.known 0

/-- What a dependency's grade carries into a manuscript, given whether the manuscript's
    formalization is complete. -/
def carry (complete : Bool) (d : XGrade Axis) : XGrade Axis := mask (carries complete) (passOn d)

/-- The `m`-th entry of a list of length `n`. Generated data uses it to index its lists. -/
def nth {α : Type} (l : List α) {n : ℕ} (h : l.length = n) (m : Fin n) : α :=
  l[m.val]'(h ▸ m.isLt)

/-- So what holds of every entry of the list holds of each `nth` one, which lets a proof
    check a long list once instead of indexing it at every `m`. -/
theorem nth_mem {α : Type} (l : List α) {n : ℕ} (h : l.length = n) (m : Fin n) :
    nth l h m ∈ l :=
  List.getElem_mem _

/-! ### The dependency closure -/

/-- A release: n manuscripts, each with its raw record and the manuscripts it rests on. -/
structure Release (n : ℕ) where
  raw : Fin n → Raw
  deps : Fin n → List (Fin n)

namespace Release

variable {n : ℕ} (R : Release n)

/-- A manuscript's own grade. -/
def own (m : Fin n) : XGrade Axis := ownGrade (R.raw m)

/-- One round: a manuscript's own grade, combined with what each of its dependencies' grades
    in `G` carries into it. -/
def step (G : Fin n → XGrade Axis) (m : Fin n) : XGrade Axis :=
  (R.deps m).foldl (fun g d => xcombine floors g (carry (complete (R.raw m)) (G d))) (R.own m)

/-- The closure: as many rounds as there are manuscripts, from their own grades. -/
def closure : Fin n → XGrade Axis := R.step^[n] R.own

/-- A manuscript's verdict: its closure under θ = 0 on every axis. -/
def verdict (m : Fin n) : Decision := xverdict θ0 (R.closure m)

/-- The closure is a fixed point: one more round changes nothing. -/
def Settled : Prop := ∀ m, R.step R.closure m = R.closure m

instance : Decidable R.Settled := by unfold Settled; infer_instance

end Release

/-! ### Properties -/

/-- One bound within another, at both ends. -/
def Within (a b : XBound) : Prop := a.lo ≤ b.lo ∧ a.hi ≤ b.hi

theorem within_refl (a : XBound) : Within a a := ⟨le_rfl, le_rfl⟩

theorem within_trans {a b c : XBound} (h1 : Within a b) (h2 : Within b c) : Within a c :=
  ⟨le_trans h1.1 h2.1, le_trans h1.2 h2.2⟩

/-- Masking never adds doubt. -/
theorem mask_within (keep : Axis → Bool) (g : XGrade Axis) (a : Axis) :
    Within (mask keep g a) (g a) := by
  unfold mask
  split_ifs
  · exact within_refl _
  · exact ⟨zero_le, zero_le⟩

/-- Combining with a dependency never lowers a manuscript's doubt, on either kind of axis. -/
theorem combine_within {ι : Type} (kind : ι → Kind) (g h : XGrade ι) (i : ι) :
    Within (g i) (xcombine kind g h i) := by
  unfold xcombine
  cases kind i
  · exact ⟨le_max_left _ _, le_max_left _ _⟩
  · exact ⟨le_self_add, le_self_add⟩

/-- Every round keeps a manuscript's own record. -/
theorem own_within_step {n : ℕ} (R : Release n) (G : Fin n → XGrade Axis) (m : Fin n)
    (a : Axis) : Within (R.own m a) (R.step G m a) := by
  unfold Release.step
  generalize R.own m = g0
  induction R.deps m generalizing g0 with
  | nil => exact within_refl _
  | cons d ds ih =>
    simp only [List.foldl_cons]
    exact within_trans (combine_within floors g0 _ a) (ih _)

/-- So the closure keeps each manuscript's own record. -/
theorem own_within_closure {n : ℕ} (R : Release n) (m : Fin n) (a : Axis) :
    Within (R.own m a) (R.closure m a) := by
  unfold Release.closure
  cases n with
  | zero => exact m.elim0
  | succ k =>
    rw [Function.iterate_succ_apply']
    exact own_within_step R _ m a

/-- More doubt never turns a rejection into an acceptance. -/
theorem reject_of_within {ι : Type} [Fintype ι] (θ : ι → WithTop ℚ≥0) {g g' : XGrade ι}
    (hw : ∀ i, Within (g i) (g' i)) (h : xverdict θ g = .reject) :
    xverdict θ g' = .reject := by
  unfold xverdict at *
  split_ifs at h with h1
  split_ifs with h2
  · exact absurd (fun i => le_trans (hw i).2 (h2 i)) h1
  · rfl

/-- No dependency can rescue a manuscript its own record rejects. -/
theorem no_rescue {n : ℕ} (R : Release n) (m : Fin n) (h : xverdict θ0 (R.own m) = .reject) :
    R.verdict m = .reject :=
  reject_of_within θ0 (own_within_closure R m) h

/-- Combining with [0, 0] on every axis changes nothing on a floor. -/
theorem xcombine_floors_zero (g : XGrade Axis) :
    xcombine floors g (fun _ => XBound.known 0) = g := by
  funext a
  show xcombineAxis .floor (g a) (XBound.known 0) = g a
  generalize g a = b
  obtain ⟨lo, hi, h⟩ := b
  simp [xcombineAxis, XBound.known]

/-- Nothing carries into a complete formalization. -/
theorem carry_complete (d : XGrade Axis) : carry true d = fun _ => XBound.known 0 := by
  funext a
  cases a <;> rfl

/-- A manuscript that rests on nothing keeps its own grade in every round. -/
theorem step_nil {n : ℕ} (R : Release n) (G : Fin n → XGrade Axis) (m : Fin n)
    (h : R.deps m = []) : R.step G m = R.own m := by
  unfold Release.step
  rw [h]
  rfl

/-- The closure settles once a second round changes nothing, so a release need only check
    that round, not all `n`. -/
theorem settled_of_stable {n : ℕ} (R : Release n)
    (h : ∀ m, R.step (R.step R.own) m = R.step R.own m) : R.Settled := by
  have hs : R.step (R.step R.own) = R.step R.own := funext h
  have hk : ∀ k, R.step^[k + 1] R.own = R.step R.own := by
    intro k
    induction k with
    | zero => rfl
    | succ k ih => rw [Function.iterate_succ_apply', ih, hs]
  unfold Release.Settled Release.closure
  intro m
  cases n with
  | zero => exact m.elim0
  | succ k => rw [hk k, hs]

/-- So a complete formalization's round is its own grade. -/
theorem step_of_complete {n : ℕ} (R : Release n) (G : Fin n → XGrade Axis) (m : Fin n)
    (hc : complete (R.raw m) = true) : R.step G m = R.own m := by
  unfold Release.step
  rw [hc]
  simp only [carry_complete, xcombine_floors_zero]
  generalize R.deps m = l
  induction l with
  | nil => rfl
  | cons d ds ih =>
    simp only [List.foldl_cons]
    exact ih

/-- And its closure is its own grade. -/
theorem closure_of_complete {n : ℕ} (R : Release n) (m : Fin n)
    (hc : complete (R.raw m) = true) : R.closure m = R.own m := by
  unfold Release.closure
  cases n with
  | zero => exact m.elim0
  | succ k =>
    rw [Function.iterate_succ_apply']
    exact step_of_complete R _ m hc

/-! ### The report -/

/-- Why an axis is above its threshold. -/
inductive Why (n : ℕ)
  /-- The manuscript's own record has no evidence on it yet. -/
  | unknown
  /-- Its own record's evidence fails. -/
  | evidence
  /-- The doubt carried over from this dependency. -/
  | through (d : Fin n)
  deriving DecidableEq, Repr

namespace Release

variable {n : ℕ} (R : Release n)

/-- Why an axis of a manuscript's closure is above its threshold. A known failure comes
    before an unknown, and the manuscript's own record before its dependencies: its own
    evidence if that fails; otherwise the first dependency whose carried doubt is known to fail;
    otherwise its own unknown; otherwise the first dependency whose carried doubt is unknown. -/
def why (m : Fin n) (a : Axis) : Why n :=
  let carried (d : Fin n) := carry (complete (R.raw m)) (R.closure d) a
  if θ0 a < (R.own m a).lo then .evidence
  else match (R.deps m).find? fun d => decide (θ0 a < (carried d).lo) with
  | some d => .through d
  | none =>
    if θ0 a < (R.own m a).hi then .unknown
    else match (R.deps m).find? fun d => decide (θ0 a < (carried d).hi) with
      | some d => .through d
      | none => .unknown

/-- The report on a manuscript: each axis of its closure above its threshold, in order, with
    why. -/
def report (m : Fin n) : List (Axis × Why n) :=
  Axis.all.filterMap fun a =>
    if θ0 a < (R.closure m a).hi then some (a, R.why m a) else none

end Release

/-- The report is empty exactly when the verdict accepts. -/
theorem report_eq_nil {n : ℕ} (R : Release n) (m : Fin n) :
    R.report m = [] ↔ R.verdict m = .accept := by
  unfold Release.report Release.verdict xverdict
  rw [List.filterMap_eq_nil_iff]
  constructor
  · intro h
    split_ifs with hall
    · rfl
    · exfalso
      apply hall
      intro a
      have := h a (Axis.mem_all a)
      by_contra hlt
      simp [lt_of_not_ge hlt] at this
  · intro h a _
    split_ifs at h with hall
    simp [not_lt.2 (hall a)]

end JSG.Pilot
