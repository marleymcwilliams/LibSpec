import JSG.Defs

/-!
Calibration controls for the v1 gate, `verdict`: the guard against vacuity that the
master guide's "Positive controls" asks for. Complete evidence within θ must ACCEPT;
evidence with an unknown axis, or with a value over θ, must REJECT. The always-REJECT
gate fails this check (`JSG.Tests.Mutants.calibrated_mutant`).
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

end JSG.Tests.Calibration
