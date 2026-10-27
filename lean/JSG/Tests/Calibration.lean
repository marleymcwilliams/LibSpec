import JSG.Defs

/-!
Calibration controls for the v1 gate, `verdict`: the guard against vacuity that the
master guide's "Positive controls" asks for. Complete evidence within θ must ACCEPT;
evidence with an unknown axis, or with a value over θ, must REJECT. The always-REJECT
gate fails this check (`JSG.Tests.Mutants.calibrated_mutant`).

Boundary cases: an axis exactly at its threshold is in `mustPass` (the known 1 under
θ = 1). Two more follow `verdict_calibrated`: an unknown on an infinite threshold, which
must pass, and two budget stages that each pass on their own but fail once combined.
-/

namespace JSG.Tests.Calibration

open JSG

/-- The threshold on the single axis. -/
def θ : Unit → ENNReal := fun _ => 1

/-- Must-pass inputs: complete evidence within θ. -/
def mustPass : Set (Grade Unit) := {fun _ => Bound.known 0, fun _ => Bound.known 1}

/-- Must-fail inputs: an unknown axis, and a known value over θ. -/
def mustFail : Set (Grade Unit) := {fun _ => Bound.unknown, fun _ => Bound.known 2}

theorem verdict_calibrated : Calibrated (verdict θ) mustPass mustFail := by
  refine ⟨Set.disjoint_left.2 fun g hp hf => ?_, fun g hg => ?_, fun g hg => ?_⟩
  · simp only [mustPass, mustFail, Set.mem_insert_iff, Set.mem_singleton_iff] at hp hf
    rcases hp with rfl | rfl <;> rcases hf with h | h <;>
      have := congrFun h () <;> norm_num [Bound.known, Bound.unknown, Bound.ext_iff] at this
  · simp only [mustPass, Set.mem_insert_iff, Set.mem_singleton_iff] at hg
    rcases hg with rfl | rfl <;> norm_num [verdict, θ, Bound.known]
  · simp only [mustFail, Set.mem_insert_iff, Set.mem_singleton_iff] at hg
    rcases hg with rfl | rfl <;> norm_num [verdict, θ, Bound.known, Bound.unknown]

/-! ## Boundary cases -/

/-- An unknown on an infinite threshold must pass: with no limit on the axis, even
    [0, ∞] is within it. -/
theorem unknown_on_infinite_threshold_passes :
    verdict (fun _ : Unit => ⊤) (fun _ => Bound.unknown) = .accept := by
  simp [verdict, Bound.unknown]

/-- Every axis is a budget axis. -/
def budget : Unit → Kind := fun _ => .budget

/-- The threshold 10 on the single axis. -/
def θ10 : Unit → ENNReal := fun _ => 10

/-- Two budget stages that each pass on their own fail once combined: 6 and 7 are each
    within θ = 10, but they add to 13. -/
theorem budget_stages_fail_together :
    verdict θ10 (fun _ => Bound.known 6) = .accept
      ∧ verdict θ10 (fun _ => Bound.known 7) = .accept
      ∧ verdict θ10 (combine budget (fun _ => Bound.known 6) (fun _ => Bound.known 7))
          = .reject := by
  refine ⟨?_, ?_, ?_⟩ <;> norm_num [verdict, θ10, combine, combineAxis, budget, Bound.known]

end JSG.Tests.Calibration
