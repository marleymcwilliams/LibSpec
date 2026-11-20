import JSG.Defs

/-!
Milestone 5 proofs: the core's gap statements that `statements-v5` added. They say what an
accept means for the true values behind a grade, how the verdict behaves as evidence narrows,
and when a rejection is definite. Each theorem restates its frozen statement in
`JSG.Statements` under the same name, and CI's Comparator run checks that it proves exactly
that statement. They need no helper lemma.
-/

namespace JSG

variable {ι : Type} (kind : ι → Kind)

theorem accept_bounds_truth (θ : ι → ENNReal) (g h : Grade ι) (x y z : ι → ENNReal)
    (hx : Encloses g x) (hy : Encloses h y)
    (hz : ∀ i, ComposesNoWorse (kind i) (x i) (y i) (z i))
    (hacc : verdict θ (combine kind g h) = .accept) : ∀ i, z i ≤ θ i := by
  unfold verdict at hacc
  split_ifs at hacc with hall
  intro i
  have hi : (combineAxis (kind i) (g i) (h i)).hi ≤ θ i := hall i
  have hzi := hz i
  have hxi := (hx i).2
  have hyi := (hy i).2
  revert hi hzi
  cases kind i with
  | floor =>
    intro hi hzi
    exact le_trans hzi (le_trans (max_le_max hxi hyi) hi)
  | budget =>
    intro hi hzi
    exact le_trans hzi (le_trans (add_le_add hxi hyi) hi)

theorem combine_respects_narrowing {g g' h h' : Grade ι} (hg : Narrows g' g)
    (hh : Narrows h' h) : Narrows (combine kind g' h') (combine kind g h) := by
  intro i
  obtain ⟨hglo, hghi⟩ := hg i
  obtain ⟨hhlo, hhhi⟩ := hh i
  show (combineAxis (kind i) (g i) (h i)).lo ≤ (combineAxis (kind i) (g' i) (h' i)).lo ∧
    (combineAxis (kind i) (g' i) (h' i)).hi ≤ (combineAxis (kind i) (g i) (h i)).hi
  cases kind i with
  | floor => exact ⟨max_le_max hglo hhlo, max_le_max hghi hhhi⟩
  | budget => exact ⟨add_le_add hglo hhlo, add_le_add hghi hhhi⟩

theorem narrowing_keeps_accept (θ : ι → ENNReal) {g g' : Grade ι}
    (hacc : verdict θ g = .accept) (hn : Narrows g' g) : verdict θ g' = .accept := by
  unfold verdict at hacc ⊢
  split_ifs at hacc with hall
  split_ifs with h'
  · rfl
  · exact absurd (fun i => le_trans (hn i).2 (hall i)) h'

theorem definitelyFails_spec (θ : ι → ENNReal) (g : Grade ι) :
    DefinitelyFails θ g ↔ ∀ g' : Grade ι, Narrows g' g → verdict θ g' = .reject := by
  constructor
  · rintro ⟨i, hi⟩ g' hn
    unfold verdict
    split_ifs with hall
    · exact absurd (hall i) (not_le.mpr (lt_of_lt_of_le hi (le_trans (hn i).1 (g' i).le)))
    · rfl
  · intro h
    by_contra hnf
    have hlo : ∀ i, (g i).lo ≤ θ i := fun i => not_lt.mp fun hlt => hnf ⟨i, hlt⟩
    have hrej := h (fun i => Bound.known (g i).lo) fun i => ⟨le_rfl, (g i).le⟩
    unfold verdict at hrej
    split_ifs at hrej with hall
    exact hall hlo

end JSG
