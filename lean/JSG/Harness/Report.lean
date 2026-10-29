import JSG.Defs

/-!
The harness's report (guide/EXECUTABLE_GATE.md §3, "What a report says"): which axes of a
grade are outside their threshold or their lease, and why. The harness only prints it.

The report is proved to list exactly the axes the lease verdict rejects on, so it is empty
exactly when that verdict accepts (`report_eq_nil`). A policy with no leases is the lease
verdict with every lease ∞, which is the plain verdict (`xleaseVerdict_top`).
-/

namespace JSG.Harness

open JSG

/-- Why an axis is outside the gate. -/
inductive Reason
  /-- The axis is unknown, [0, ∞]. -/
  | unknown
  /-- Its upper end is above its threshold. -/
  | overThreshold
  /-- It is within its threshold but wider than its lease. -/
  | overLease
  deriving DecidableEq, Repr

/-- Why an axis outside the gate is outside it: unknown if it is [0, ∞], otherwise above its
    threshold if it is, and otherwise wider than its lease. -/
def reason (θ : WithTop ℚ≥0) (b : XBound) : Reason :=
  if b.lo = 0 ∧ b.hi = ⊤ then .unknown else if θ < b.hi then .overThreshold else .overLease

/-- The report on a grade over n axes: each axis outside its threshold or its lease, in
    order, with its reason. -/
def report {n : ℕ} (θ β : Fin n → WithTop ℚ≥0) (g : XGrade (Fin n)) : List (Fin n × Reason) :=
  (List.finRange n).filterMap fun i =>
    if θ i < (g i).hi ∨ β i < (g i).width then some (i, reason (θ i) (g i)) else none

/-- An axis is in the report exactly when it is above its threshold or wider than its
    lease. -/
theorem mem_report {n : ℕ} (θ β : Fin n → WithTop ℚ≥0) (g : XGrade (Fin n)) (i : Fin n) :
    (∃ r, (i, r) ∈ report θ β g) ↔ θ i < (g i).hi ∨ β i < (g i).width := by
  unfold report
  constructor
  · rintro ⟨r, hr⟩
    rw [List.mem_filterMap] at hr
    obtain ⟨j, -, hj⟩ := hr
    split_ifs at hj with h
    simp only [Option.some.injEq, Prod.mk.injEq] at hj
    obtain ⟨rfl, -⟩ := hj
    exact h
  · intro h
    refine ⟨reason (θ i) (g i), ?_⟩
    rw [List.mem_filterMap]
    exact ⟨i, List.mem_finRange i, by simp [h]⟩

/-- The report is empty exactly when the lease verdict accepts. -/
theorem report_eq_nil {n : ℕ} (θ β : Fin n → WithTop ℚ≥0) (g : XGrade (Fin n)) :
    report θ β g = [] ↔ xleaseVerdict θ β g = .accept := by
  rw [List.eq_nil_iff_forall_not_mem]
  unfold xleaseVerdict
  constructor
  · intro h
    split_ifs with hall
    · rfl
    · exfalso
      apply hall
      intro i
      by_contra hi
      rw [not_and_or, not_le, not_le] at hi
      obtain ⟨r, hr⟩ := (mem_report θ β g i).2 hi
      exact h _ hr
  · intro h p hp
    split_ifs at h with hall
    obtain ⟨i, r⟩ := p
    rcases (mem_report θ β g i).1 ⟨r, hp⟩ with h1 | h1
    · exact absurd (hall i).1 (not_le.2 h1)
    · exact absurd (hall i).2 (not_le.2 h1)

/-- With every lease ∞, the lease verdict is the plain verdict. -/
theorem xleaseVerdict_top {n : ℕ} (θ : Fin n → WithTop ℚ≥0) (g : XGrade (Fin n)) :
    xleaseVerdict θ (fun _ => ⊤) g = xverdict θ g := by
  unfold xleaseVerdict xverdict
  simp

end JSG.Harness
