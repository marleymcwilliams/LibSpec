import JSG.Pilot.Sample

/-!
The proofs behind the pilot's first report (guide/EXECUTABLE_GATE.md §3), each checked by the
kernel with `decide +kernel`, which isn't native evaluation:
- the sample's closure is settled, and no manuscript in it is accepted today;
- the three withdrawn manuscripts are not accepted on known axes alone: not even with every
  unknown resolved in their favour;
- the synthetic must-pass records are accepted and the must-fail records are not, and both
  sets are `Calibrated`, in the frozen definition's sense.
-/

namespace JSG.Pilot

open JSG

/-! ### The must-fail test's best case -/

/-- A record's best case: every unknown resolved in the manuscript's favour, and every known
    fact kept. A challenge that isn't rejected counts as accepted: one not yet run, one whose
    build failed, one too large to check, and one the kernels disagreed on. A missing
    formalization counts as one, accepted, that permits only the three axioms; and a missing
    reviewer, review, priority check or reading of its dependencies as done. A withdrawal, a
    Comparator rejection and an extra permitted axiom stay. -/
def Raw.bestCase (r : Raw) : Raw :=
  { r with
    challenges :=
      if r.challenges.isEmpty then [⟨.accepted, threeAxioms⟩]
      else r.challenges.map fun c =>
        if c.result = .rejected then c else { c with result := .accepted }
    fidelityBy := some (r.fidelityBy.getD "best case")
    reviewed := true
    noveltyChecked := true
    depsRead := true }

/-- A release with every record at its best case, and the same dependency edges. -/
def Release.bestCase {n : ℕ} (R : Release n) : Release n :=
  { R with raw := fun m => (R.raw m).bestCase }

/-! ### The sample -/

namespace Sample

/-- The sample's withdrawn manuscripts. -/
def withdrawn : List (Fin size) :=
  (List.finRange size).filter fun m => (release.raw m).withdrawnOn.isSome

/-- They are the three that were withdrawn on October 6, 2026. -/
theorem withdrawn_eq : withdrawn = [0, 1, 8] := by decide +kernel

theorem settled : release.Settled := by decide +kernel

/-- No manuscript in the sample is accepted today. -/
theorem none_accepted : ∀ m, release.verdict m = .reject := by decide +kernel

theorem bestCase_settled : release.bestCase.Settled := by decide +kernel

/-- The must-fail test: the withdrawn manuscripts are not accepted on known axes alone. -/
theorem withdrawn_not_accepted_on_known_axes :
    ∀ m ∈ withdrawn, release.bestCase.verdict m = .reject := by decide +kernel

/-- So the sample is calibrated, with no real must-pass manuscript yet and the withdrawn ones
    as its must-fail set. -/
theorem calibrated : Calibrated release.verdict ∅ {m | m ∈ withdrawn} :=
  ⟨Set.empty_disjoint _, fun _ h => absurd h (Set.notMem_empty _),
    fun m _ => none_accepted m⟩

end Sample

/-! ### The synthetic records -/

namespace Synthetic

/-- A record with every axis known to be 0. -/
def allZero : Raw :=
  { withdrawnOn := none, challenges := [⟨.accepted, threeAxioms⟩],
    fidelityBy := some "a named reviewer", reviewed := true, noveltyChecked := true,
    depsRead := true }

abbrev size : ℕ := 9

/-- What each synthetic record is. Those in parentheses support the others. -/
def name : Fin size → String :=
  !["every axis known and within θ",
    "a complete formalization resting on an unreviewed manuscript and a withdrawn one",
    "(an unreviewed manuscript)",
    "(a withdrawn manuscript)",
    "one unknown axis",
    "a formalization Comparator rejects",
    "a challenge that permits an extra axiom",
    "two steps from a withdrawn manuscript, with its formalization not complete",
    "(the middle link)"]

/-- The synthetic records (EXECUTABLE_GATE.md §3). -/
def release : Release size where
  raw := ![allZero, allZero, { allZero with reviewed := false },
    { allZero with withdrawnOn := some "January 1, 2026" },
    { allZero with noveltyChecked := false },
    { allZero with challenges := [⟨.rejected, threeAxioms⟩] },
    { allZero with challenges := [⟨.accepted, threeAxioms ++ ["sorryAx"]⟩] },
    { allZero with challenges := [⟨.notRun, threeAxioms⟩] },
    { allZero with challenges := [⟨.notRun, threeAxioms⟩] }]
  deps := ![[], [2, 3], [], [], [], [], [], [8], [3]]

def mustPass : List (Fin size) := [0, 1]

def mustFail : List (Fin size) := [4, 5, 6, 7]

theorem settled : release.Settled := by decide +kernel

theorem must_pass_accepted : ∀ m ∈ mustPass, release.verdict m = .accept := by decide +kernel

theorem must_fail_rejected : ∀ m ∈ mustFail, release.verdict m = .reject := by decide +kernel

/-- The two-step record reports `dependency_withdrawn` through its middle link. -/
theorem two_step_through_middle :
    (release.report 7).lookup .dependencyWithdrawn = some (.through 8) := by decide +kernel

theorem disjoint : ∀ m ∈ mustPass, m ∉ mustFail := by decide +kernel

/-- The synthetic sets are calibrated. -/
theorem calibrated : Calibrated release.verdict {m | m ∈ mustPass} {m | m ∈ mustFail} :=
  ⟨Set.disjoint_left.2 fun m h1 h2 => disjoint m h1 h2,
    fun m h => must_pass_accepted m h, fun m h => must_fail_rejected m h⟩

end Synthetic

end JSG.Pilot
