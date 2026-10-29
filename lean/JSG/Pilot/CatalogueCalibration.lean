import JSG.Pilot.Calibration
import JSG.Pilot.Catalogue

/-!
The proofs behind the pilot's report on the whole release (guide/EXECUTABLE_GATE.md §3), each
checked by the kernel with `decide +kernel`, which isn't native evaluation:
- no manuscript in the catalogue is accepted today, since none is accepted on its own record,
  and no dependency can rescue one (`no_rescue`);
- the three withdrawn manuscripts are not accepted on known axes alone, so the catalogue is
  `Calibrated`, with them as its must-fail set;
- its closure is settled, since a second round changes nothing (`settled_of_stable`).

Looking up one manuscript's record walks the list to it, so the proofs check each list once,
or look up only the few manuscripts they name, rather than look up all 724 at every step.
-/

namespace JSG.Pilot.Catalogue

open JSG JSG.Pilot

/-! ### No manuscript is accepted -/

/-- Every record rejects on its own: none has a published independent review yet. -/
theorem own_rejects_all : ∀ r ∈ raws, xverdict θ0 (ownGrade r) = .reject := by decide +kernel

/-- So each manuscript's own grade rejects. -/
theorem own_rejects (m : Fin size) : xverdict θ0 (release.own m) = .reject :=
  own_rejects_all _ (nth_mem raws (by decide +kernel) m)

/-- So no manuscript in the catalogue is accepted today. -/
theorem none_accepted : ∀ m, release.verdict m = .reject :=
  fun m => no_rescue release m (own_rejects m)

/-! ### The withdrawn manuscripts -/

/-- The catalogue's withdrawn manuscripts. -/
def withdrawn : List (Fin size) := [119, 120, 645]

/-- They are exactly the manuscripts with a withdrawal notice. -/
theorem mem_withdrawn : ∀ m, m ∈ withdrawn ↔ (release.raw m).withdrawnOn.isSome := by
  decide +kernel

/-- They are the sample's three, each withdrawn on October 6, 2026. -/
theorem withdrawn_folders :
    withdrawn.map (fun m => (folder m, (release.raw m).withdrawnOn)) =
      [("Algebraicity-of-Kuga-Satake-Correspondences-for-K3-Surfaces-October-3-2026",
          some "October 6, 2026"),
       ("Algebraicity-of-Weil-classes-on-split-abelian-eightfolds-September-18-2026",
          some "October 6, 2026"),
       ("The-rational-Hodge-conjecture-for-products-of-K3-surfaces-October-4-2026",
          some "October 6, 2026")] := by
  decide +kernel

/-- Their own records reject, even in the best case. -/
theorem withdrawn_own_rejects :
    ∀ m ∈ withdrawn, xverdict θ0 (release.bestCase.own m) = .reject := by
  decide +kernel

/-- The must-fail test: the withdrawn manuscripts are not accepted on known axes alone. -/
theorem withdrawn_not_accepted_on_known_axes :
    ∀ m ∈ withdrawn, release.bestCase.verdict m = .reject :=
  fun m h => no_rescue release.bestCase m (withdrawn_own_rejects m h)

/-- So the catalogue is calibrated, with no real must-pass manuscript yet and the withdrawn
    ones as its must-fail set. -/
theorem calibrated : Calibrated release.verdict ∅ {m | m ∈ withdrawn} :=
  ⟨Set.empty_disjoint _, fun _ h => absurd h (Set.notMem_empty _),
    fun m _ => none_accepted m⟩

/-! ### The closure settles -/

/-- Only the two K3 papers rest on another manuscript: the eightfolds paper. -/
theorem deps_eq : ∀ m, release.deps m = [] ∨ m ∈ [119, 645] := by decide +kernel

/-- For those two, a second round changes nothing. -/
theorem stable_linked : ∀ m ∈ ([119, 645] : List (Fin size)),
    release.step (release.step release.own) m = release.step release.own m := by
  decide +kernel

/-- So for every manuscript, a second round of the closure changes nothing. -/
theorem stable :
    ∀ m, release.step (release.step release.own) m = release.step release.own m := by
  intro m
  rcases deps_eq m with h | h
  · exact (step_nil release _ m h).trans (step_nil release _ m h).symm
  · exact stable_linked m h

theorem settled : release.Settled := settled_of_stable release stable

end JSG.Pilot.Catalogue
