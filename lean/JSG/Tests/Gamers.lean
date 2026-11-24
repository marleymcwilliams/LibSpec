import JSG.Defs
import JSG.Tests.Mutants

/-!
Gamers and a kill matrix for the ordinal core's ten theorems, which decision 0 hardens.
guide/STATEMENTS_REVIEW.md's section "Gamers and the kill matrix: the ordinal core" gives the
search's bounds, the matrix and what each finding means.

* A **gamer** satisfies every restated copy that mentions what it changes, yet does what a
  passage of `archive/` says the model must not. It comes with proofs of those copies and one
  instance of what it does wrong.
* A **mutant** changes one place in one definition the ten use. A **kill** proves a restated
  copy's negation at one instance, on one axis, as `JSG.Tests.Mutants` does. A **survivor** is a
  mutant no theorem kills, and each copy that mentions what it changes is proved to hold for it.

Its last part is `statements-v6`'s: `narrows_unknown`, which that version adds, kills the
survivor `narrowsToLo`.

Like `JSG.Tests.Mutants`, this file imports only the definitions and those controls, so nothing
here leans on the proofs of the frozen theorems.
-/

namespace JSG.Tests.Gamers

open JSG JSG.Tests.Mutants

/-! ## Restated copies proved once, for every definition with a property

`combineWith f` is `combine` with its floor case replaced by `f`. Each lemma after it proves a
restated copy for every definition with the property it names, so most of the proofs below for a
gamer or a mutant are one line. -/

/-- `combineAxis` with its floor case replaced by `f`, and its budget case as frozen. -/
def axisWith (f : Bound → Bound → Bound) : Kind → Bound → Bound → Bound
  | .floor, a, b => f a b
  | .budget, a, b => combineAxis .budget a b

/-- `combine` with `axisWith f` on every axis. -/
def combineWith (f : Bound → Bound → Bound) {ι : Type} (kind : ι → Kind) (g h : Grade ι) :
    Grade ι :=
  fun i => axisWith f (kind i) (g i) (h i)

/-- `no_flip` holds for every verdict, since a noninterfering grader gives the same grade either
    way. So it kills no mutant or gamer of the verdict. -/
theorem no_flip_holds_any {ι E : Type} (V : (ι → ENNReal) → Grade ι → Decision)
    (θ : ι → ENNReal) (gradeOf : Evidence E → Grade ι) (hni : Noninterfering gradeOf) (r : E)
    (m m' : List (String × Float)) : V θ (gradeOf ⟨r, m⟩) = V θ (gradeOf ⟨r, m'⟩) := by
  rw [hni r m m']

/-- `verdict_sound` holds for any verdict that accepts only grades whose upper ends are all
    within their thresholds. -/
theorem verdict_sound_of_hi {ι : Type} (V : (ι → ENNReal) → Grade ι → Decision)
    (hV : ∀ θ g, V θ g = .accept → ∀ i, (g i).hi ≤ θ i) (θ : ι → ENNReal) (g : Grade ι) (i : ι)
    (hover : θ i < (g i).hi) : V θ g = .reject := by
  cases hd : V θ g with
  | reject => rfl
  | accept => exact absurd (hV θ g hd i) (not_le.mpr hover)

/-- The frozen verdict accepts only grades whose upper ends are all within their thresholds. -/
theorem verdict_hi {ι : Type} (θ : ι → ENNReal) (g : Grade ι) (hacc : verdict θ g = .accept)
    (i : ι) : (g i).hi ≤ θ i := by
  unfold verdict at hacc
  split_ifs at hacc with hall
  exact hall i

/-- `accept_bounds_truth` holds for any verdict that accepts only grades whose upper ends are
    all within their thresholds, even when the grades bound the true values from above only. -/
theorem accept_bounds_truth_of_hi {ι : Type} (V : (ι → ENNReal) → Grade ι → Decision)
    (hV : ∀ θ g, V θ g = .accept → ∀ i, (g i).hi ≤ θ i) (kind : ι → Kind) (θ : ι → ENNReal)
    (g h : Grade ι) (x y z : ι → ENNReal) (hxu : ∀ i, x i ≤ (g i).hi)
    (hyu : ∀ i, y i ≤ (h i).hi) (hz : ∀ i, ComposesNoWorse (kind i) (x i) (y i) (z i))
    (hacc : V θ (combine kind g h) = .accept) : ∀ i, z i ≤ θ i := by
  intro i
  have hi : (combineAxis (kind i) (g i) (h i)).hi ≤ θ i := hV θ _ hacc i
  have hzi := hz i
  have hxi := hxu i
  have hyi := hyu i
  revert hi hzi
  cases kind i with
  | floor => intro hi hzi; exact le_trans hzi (le_trans (max_le_max hxi hyi) hi)
  | budget => intro hi hzi; exact le_trans hzi (le_trans (add_le_add hxi hyi) hi)

/-- `accept_bounds_truth` holds for any floor case whose upper end is at least the larger of its
    operands' upper ends. -/
theorem accept_bounds_truth_of_floor_hi (f : Bound → Bound → Bound)
    (hf : ∀ a b, max a.hi b.hi ≤ (f a b).hi) {ι : Type} (kind : ι → Kind) (θ : ι → ENNReal)
    (g h : Grade ι) (x y z : ι → ENNReal) (hx : Encloses g x) (hy : Encloses h y)
    (hz : ∀ i, ComposesNoWorse (kind i) (x i) (y i) (z i))
    (hacc : verdict θ (combineWith f kind g h) = .accept) : ∀ i, z i ≤ θ i := by
  unfold verdict at hacc
  split_ifs at hacc with hall
  intro i
  have hi : (axisWith f (kind i) (g i) (h i)).hi ≤ θ i := hall i
  have hzi := hz i
  have hxi := (hx i).2
  have hyi := (hy i).2
  revert hi hzi
  cases kind i with
  | floor => intro hi hzi; exact le_trans hzi (le_trans (max_le_max hxi hyi) (le_trans (hf _ _) hi))
  | budget => intro hi hzi; exact le_trans hzi (le_trans (add_le_add hxi hyi) hi)

/-- `combine_respects_narrowing` holds for any floor case that respects narrowing. -/
theorem combine_respects_narrowing_of_floor (f : Bound → Bound → Bound)
    (hf : ∀ a a' b b' : Bound, a.lo ≤ a'.lo → a'.hi ≤ a.hi → b.lo ≤ b'.lo → b'.hi ≤ b.hi →
      (f a b).lo ≤ (f a' b').lo ∧ (f a' b').hi ≤ (f a b).hi)
    {ι : Type} (kind : ι → Kind) {g g' h h' : Grade ι} (hg : Narrows g' g) (hh : Narrows h' h) :
    Narrows (combineWith f kind g' h') (combineWith f kind g h) := by
  intro i
  obtain ⟨hglo, hghi⟩ := hg i
  obtain ⟨hhlo, hhhi⟩ := hh i
  show (axisWith f (kind i) (g i) (h i)).lo ≤ (axisWith f (kind i) (g' i) (h' i)).lo
    ∧ (axisWith f (kind i) (g' i) (h' i)).hi ≤ (axisWith f (kind i) (g i) (h i)).hi
  cases kind i with
  | floor => exact hf _ _ _ _ hglo hghi hhlo hhhi
  | budget => exact ⟨add_le_add hglo hhlo, add_le_add hghi hhhi⟩

/-- `narrowing_keeps_accept` holds for any narrowing that never raises an upper end. -/
theorem narrowing_keeps_accept_of_hi {ι : Type} (N : Grade ι → Grade ι → Prop)
    (hN : ∀ g' g, N g' g → ∀ i, (g' i).hi ≤ (g i).hi) (θ : ι → ENNReal) {g g' : Grade ι}
    (hacc : verdict θ g = .accept) (hn : N g' g) : verdict θ g' = .accept := by
  unfold verdict at hacc ⊢
  split_ifs at hacc with hall
  split_ifs with h'
  · rfl
  · exact absurd (fun i => le_trans (hN g' g hn i) (hall i)) h'

/-- `definitelyFails_spec` holds for any narrowing whose upper ends stay at or above the lower
    ends they narrow, and under which the point at each lower end narrows the grade. -/
theorem definitelyFails_spec_of {ι : Type} (N : Grade ι → Grade ι → Prop)
    (hup : ∀ g' g, N g' g → ∀ i, (g i).lo ≤ (g' i).hi)
    (hpt : ∀ g : Grade ι, N (fun i => Bound.known (g i).lo) g) (θ : ι → ENNReal) (g : Grade ι) :
    DefinitelyFails θ g ↔ ∀ g' : Grade ι, N g' g → verdict θ g' = .reject := by
  constructor
  · rintro ⟨i, hi⟩ g' hn
    unfold verdict
    split_ifs with hall
    · exact absurd (hall i) (not_le.mpr (lt_of_lt_of_le hi (hup g' g hn i)))
    · rfl
  · intro h
    by_contra hnf
    have hlo : ∀ i, (g i).lo ≤ θ i := fun i => not_lt.mp fun hlt => hnf ⟨i, hlt⟩
    have hrej := h _ (hpt g)
    unfold verdict at hrej
    split_ifs at hrej with hall
    exact hall hlo

/-! ## Gamers

A fresh-context subagent looked for one gamer in each layer. It was given only the ten theorems,
their definitions, and the passages of `archive/` that guide/STATEMENTS_REVIEW.md cites for them.
It found four, two in the first layer. Two of them are also survivors of the kill matrix below,
found independently: `unknownZero` and `narrowsHiInside`. It found none for `DefinitelyFails`,
which `definitelyFails_spec` fixes once `Narrows` and `verdict` are fixed. -/

/-! ### Graded values: missing evidence read as zero -/

/-- Gamer, and the matrix's mutant of `Bound.unknown`: ⊤ read as 0. SirusSC's `Q` reads a missing
    coordinate as its axis's identity, 0 or −∞, and its loader's guard looks only for the ⊥
    sentinel (`specchain/algebra/q.py`, `specchain/loader/loader.py`). No theorem of the ten
    mentions `Bound.unknown`, so each restated copy is the frozen theorem itself. -/
def unknownZero : Bound := ⟨0, 0, le_rfl⟩

/-- What it does wrong. SCp1's Remark 2.4 says missing evidence "must descend to ⊥ and persist
    through aggregation". Here, on a budget under θ = 5, the unknown combined with the known 3 is
    accepted. The frozen unknown gives [3, ∞], which is rejected. -/
theorem unknownZero_wrong :
    verdict (fun _ => 5) (combine budget (fun _ => unknownZero) (k 3)) = .accept
      ∧ verdict (fun _ => 5) (combine budget unk (k 3)) = .reject := by
  constructor
  · norm_num [verdict, combine, combineAxis, budget, unknownZero, k, Bound.known]
  · simp [verdict, combine, combineAxis, budget, unk, k, Bound.unknown, Bound.known]

/-! ### Graded values: floors summed -/

/-- Gamer: the floor case sums, as SirusSC's `Q.sequential` does on "both axis families"
    (`specchain/algebra/q.py`). It is `JSG.Tests.Mutants.scp2Seq` used for parallel composition
    too; `interchange_scp2_mutant` kills that only when parallel composition takes the max. -/
def floorAdd (a b : Bound) : Bound := ⟨a.lo + b.lo, a.hi + b.hi, add_le_add a.le b.le⟩

theorem combine_comm_holds_floorAdd {ι : Type} (kind : ι → Kind) (g h : Grade ι) :
    combineWith floorAdd kind g h = combineWith floorAdd kind h g := by
  funext i
  simp only [combineWith]
  cases kind i <;> exact Bound.ext (add_comm _ _) (add_comm _ _)

theorem combine_assoc_holds_floorAdd {ι : Type} (kind : ι → Kind) (g h l : Grade ι) :
    combineWith floorAdd kind (combineWith floorAdd kind g h) l
      = combineWith floorAdd kind g (combineWith floorAdd kind h l) := by
  funext i
  simp only [combineWith]
  cases kind i <;> exact Bound.ext (add_assoc _ _ _) (add_assoc _ _ _)

theorem interchange_holds_floorAdd {ι : Type} (kind : ι → Kind) :
    Interchange (combineWith floorAdd kind) (combineWith floorAdd kind) := by
  intro a b c d
  funext i
  simp only [combineWith]
  cases kind i <;> exact Bound.ext (add_add_add_comm _ _ _ _) (add_add_add_comm _ _ _ _)

theorem accept_bounds_truth_holds_floorAdd {ι : Type} (kind : ι → Kind) (θ : ι → ENNReal)
    (g h : Grade ι) (x y z : ι → ENNReal) (hx : Encloses g x) (hy : Encloses h y)
    (hz : ∀ i, ComposesNoWorse (kind i) (x i) (y i) (z i))
    (hacc : verdict θ (combineWith floorAdd kind g h) = .accept) : ∀ i, z i ≤ θ i :=
  accept_bounds_truth_of_floor_hi floorAdd (fun _ _ => max_le le_self_add le_add_self) kind θ
    g h x y z hx hy hz hacc

theorem combine_respects_narrowing_holds_floorAdd {ι : Type} (kind : ι → Kind)
    {g g' h h' : Grade ι} (hg : Narrows g' g) (hh : Narrows h' h) :
    Narrows (combineWith floorAdd kind g' h') (combineWith floorAdd kind g h) :=
  combine_respects_narrowing_of_floor floorAdd
    (fun _ _ _ _ h1 h2 h3 h4 => ⟨add_le_add h1 h3, add_le_add h2 h4⟩) kind hg hh

/-- What it does wrong. SCp1's Proposition 2.3(c) asks for "Axiswise idempotence: (q ∧ q)ᵢ = qᵢ
    iff i ∈ M", and a floor is a max-axis. Here, on a floor under θ = 7, two stages at the known
    rate 5 combine to [10, 10], which is rejected. The frozen [5, 5] is accepted. -/
theorem floorAdd_wrong :
    verdict (fun _ => 7) (combineWith floorAdd floor (k 5) (k 5)) = .reject
      ∧ verdict (fun _ => 7) (combine floor (k 5) (k 5)) = .accept := by
  constructor
  · norm_num [verdict, combineWith, axisWith, floorAdd, floor, k, Bound.known]
  · norm_num [verdict, combine, combineAxis, floor, k, Bound.known]

/-! ### The verdict: only complete evidence accepted -/

/-- Gamer: the verdict accepts only points within θ: `JSG.Tests.Mutants.pointsOnly` with no lease,
    read from SirusSC's `Q`, where an axis holds a value or ⊥ and every guard rejects ⊥
    (`C_UNK_PRICED`). A reading wider than a point is rejected, however far within θ. -/
noncomputable def pointsVerdict {ι : Type} (θ : ι → ENNReal) (g : Grade ι) : Decision := by
  classical
  exact if ∀ i, (g i).lo = (g i).hi ∧ (g i).hi ≤ θ i then .accept else .reject

/-- `pointsVerdict` is `pointsOnly` for any lease, which it never reads. -/
theorem pointsVerdict_eq {ι : Type} (θ β : ι → ENNReal) (g : Grade ι) :
    pointsVerdict θ g = pointsOnly θ β g := rfl

theorem pointsVerdict_hi {ι : Type} (θ : ι → ENNReal) (g : Grade ι)
    (hacc : pointsVerdict θ g = .accept) (i : ι) : (g i).hi ≤ θ i := by
  unfold pointsVerdict at hacc
  split_ifs at hacc with hall
  exact (hall i).2

theorem verdict_sound_holds_pointsVerdict {ι : Type} (θ : ι → ENNReal) (g : Grade ι) (i : ι)
    (hover : θ i < (g i).hi) : pointsVerdict θ g = .reject :=
  verdict_sound_of_hi pointsVerdict pointsVerdict_hi θ g i hover

theorem verdict_complete_holds_pointsVerdict {ι : Type} (θ : ι → ENNReal) (g : Grade ι)
    (hk : ∀ i, (g i).lo = (g i).hi) (hin : ∀ i, (g i).lo ≤ θ i) :
    pointsVerdict θ g = .accept := by
  unfold pointsVerdict
  split_ifs with h
  · rfl
  · exact absurd (fun i => ⟨hk i, by rw [← hk i]; exact hin i⟩) h

theorem accept_bounds_truth_holds_pointsVerdict {ι : Type} (kind : ι → Kind) (θ : ι → ENNReal)
    (g h : Grade ι) (x y z : ι → ENNReal) (hx : Encloses g x) (hy : Encloses h y)
    (hz : ∀ i, ComposesNoWorse (kind i) (x i) (y i) (z i))
    (hacc : pointsVerdict θ (combine kind g h) = .accept) : ∀ i, z i ≤ θ i :=
  accept_bounds_truth_of_hi pointsVerdict pointsVerdict_hi kind θ g h x y z (fun i => (hx i).2)
    (fun i => (hy i).2) hz hacc

/-- A grade that narrows a point is that point, so an accepted point stays accepted. -/
theorem narrowing_keeps_accept_holds_pointsVerdict {ι : Type} (θ : ι → ENNReal)
    {g g' : Grade ι} (hacc : pointsVerdict θ g = .accept) (hn : Narrows g' g) :
    pointsVerdict θ g' = .accept := by
  unfold pointsVerdict at hacc ⊢
  split_ifs at hacc with hall
  split_ifs with h'
  · rfl
  · refine absurd (fun i => ?_) h'
    obtain ⟨hpt, hθ⟩ := hall i
    obtain ⟨hlo, hhi⟩ := hn i
    have h1 : (g' i).hi ≤ (g' i).lo := le_trans hhi (le_trans (le_of_eq hpt.symm) hlo)
    exact ⟨le_antisymm (g' i).le h1, le_trans hhi hθ⟩

theorem definitelyFails_spec_holds_pointsVerdict {ι : Type} (θ : ι → ENNReal) (g : Grade ι) :
    DefinitelyFails θ g ↔ ∀ g' : Grade ι, Narrows g' g → pointsVerdict θ g' = .reject := by
  constructor
  · rintro ⟨i, hi⟩ g' hn
    exact verdict_sound_holds_pointsVerdict θ g' i
      (lt_of_lt_of_le hi (le_trans (hn i).1 (g' i).le))
  · intro h
    by_contra hnf
    have hlo : ∀ i, (g i).lo ≤ θ i := fun i => not_lt.mp fun hlt => hnf ⟨i, hlt⟩
    have hrej := h (fun i => Bound.known (g i).lo) fun i => ⟨le_rfl, (g i).le⟩
    unfold pointsVerdict at hrej
    split_ifs at hrej with hall
    exact hall fun i => ⟨rfl, hlo i⟩

/-- [2, 3] on the single axis. -/
def twoThree : Grade Unit := fun _ => ⟨2, 3, by norm_num⟩

/-- What it does wrong, by the subagent's reading of SCp1, whose rejection certificate names "the
    violated invariant": under θ = 10, [2, 3] has no axis over its threshold, yet is rejected, and
    learning its worst case, the known 3, turns that into an acceptance. `verdict` accepts
    [2, 3]. -/
theorem pointsVerdict_wrong :
    pointsVerdict (fun _ => 10) twoThree = .reject ∧ Narrows (k 3) twoThree
      ∧ pointsVerdict (fun _ => 10) (k 3) = .accept
      ∧ verdict (fun _ => 10) twoThree = .accept := by
  refine ⟨?_, fun _ => ⟨by norm_num [twoThree, k, Bound.known], le_rfl⟩, ?_, ?_⟩
  · norm_num [pointsVerdict, twoThree]
  · norm_num [pointsVerdict, k, Bound.known]
  · norm_num [verdict, twoThree]

/-! ### Narrowing: only the upper end kept inside -/

/-- Gamer, and the matrix's mutant of `Narrows` with `lo` to `hi` in the first conjunct's `g'`:
    only the narrowing's upper end must lie inside. A one-token slip, tempting because the
    verdict reads `hi`. Invented. -/
def narrowsHiInside {ι : Type} (g' g : Grade ι) : Prop :=
  ∀ i, (g i).lo ≤ (g' i).hi ∧ (g' i).hi ≤ (g i).hi

theorem combine_respects_narrowing_holds_narrowsHiInside {ι : Type} (kind : ι → Kind)
    {g g' h h' : Grade ι} (hg : narrowsHiInside g' g) (hh : narrowsHiInside h' h) :
    narrowsHiInside (combine kind g' h') (combine kind g h) := by
  intro i
  obtain ⟨hg1, hg2⟩ := hg i
  obtain ⟨hh1, hh2⟩ := hh i
  show (combineAxis (kind i) (g i) (h i)).lo ≤ (combineAxis (kind i) (g' i) (h' i)).hi
    ∧ (combineAxis (kind i) (g' i) (h' i)).hi ≤ (combineAxis (kind i) (g i) (h i)).hi
  cases kind i with
  | floor => exact ⟨max_le_max hg1 hh1, max_le_max hg2 hh2⟩
  | budget => exact ⟨add_le_add hg1 hh1, add_le_add hg2 hh2⟩

theorem narrowing_keeps_accept_holds_narrowsHiInside {ι : Type} (θ : ι → ENNReal)
    {g g' : Grade ι} (hacc : verdict θ g = .accept) (hn : narrowsHiInside g' g) :
    verdict θ g' = .accept :=
  narrowing_keeps_accept_of_hi narrowsHiInside (fun _ _ hn i => (hn i).2) θ hacc hn

theorem definitelyFails_spec_holds_narrowsHiInside {ι : Type} (θ : ι → ENNReal) (g : Grade ι) :
    DefinitelyFails θ g ↔ ∀ g' : Grade ι, narrowsHiInside g' g → verdict θ g' = .reject :=
  definitelyFails_spec_of narrowsHiInside (fun _ _ hn i => (hn i).1)
    (fun g i => ⟨le_rfl, (g i).le⟩) θ g

/-- [0, 8] on the single axis. -/
def zeroEight : Grade Unit := fun _ => ⟨0, 8, zero_le⟩

/-- What it does wrong, read from SCp1's Definition 7.1, not quoted: more input never falls below
    what was established. Under θ = 5 the known 8 fails definitely, but [0, 8] narrows it, and
    the accepted known 0 narrows [0, 8]: two rounds of "more evidence" accept a known violation. -/
theorem narrowsHiInside_wrong :
    DefinitelyFails (fun _ => 5) (k 8) ∧ narrowsHiInside zeroEight (k 8)
      ∧ narrowsHiInside (k 0) zeroEight ∧ verdict (fun _ => 5) (k 0) = .accept
      ∧ ¬ Narrows zeroEight (k 8) := by
  refine ⟨⟨(), by norm_num [k, Bound.known]⟩, fun _ => ⟨le_rfl, le_rfl⟩,
    fun _ => ⟨le_rfl, zero_le⟩, by simp [verdict, k, Bound.known], fun h => ?_⟩
  have := (h ()).1
  norm_num [zeroEight, k, Bound.known] at this

/-! ## The kill matrix

First-order mutants, one change at a time: max ↔ +, `hi` ↔ `lo`, ≤ ↔ <, one conjunct dropped, and
`Bound.unknown`'s ⊤ read as 0. `verdictLo` and `rejectIsFinal`, and three of their kills, are
`JSG.Tests.Mutants`'s, and `unknownZero` and `narrowsHiInside` are with the gamers above. Three
mutants break `lo ≤ hi`, so can't be built, and five only strengthen a hypothesis of
`accept_bounds_truth`, so can't be killed; guide/STATEMENTS_REVIEW.md lists them. -/

/-! ### `combineAxis`'s floor case -/

/-- Max to + in the upper end: the floor case adds upper ends. A survivor. -/
def floorHiAdd (a b : Bound) : Bound :=
  ⟨max a.lo b.lo, a.hi + b.hi, max_le (le_trans a.le le_self_add) (le_trans b.le le_add_self)⟩

/-- `lo` to `hi` in the lower end's first argument. -/
def floorLoLeftHi (a b : Bound) : Bound := ⟨max a.hi b.lo, max a.hi b.hi, max_le_max le_rfl b.le⟩

/-- `lo` to `hi` in the lower end's second argument. -/
def floorLoRightHi (a b : Bound) : Bound := ⟨max a.lo b.hi, max a.hi b.hi, max_le_max a.le le_rfl⟩

/-- `hi` to `lo` in the upper end's first argument. -/
def floorHiLeftLo (a b : Bound) : Bound := ⟨max a.lo b.lo, max a.lo b.hi, max_le_max le_rfl b.le⟩

/-- `hi` to `lo` in the upper end's second argument. -/
def floorHiRightLo (a b : Bound) : Bound := ⟨max a.lo b.lo, max a.hi b.lo, max_le_max a.le le_rfl⟩

theorem combine_comm_kills_floorLoLeftHi :
    ¬ ∀ g h : Grade Unit,
      combineWith floorLoLeftHi floor g h = combineWith floorLoLeftHi floor h g := by
  intro hc
  have := (congrArg (fun g => (g ()).lo) (hc (k 0) zeroOne)).ge
  simp [combineWith, axisWith, floorLoLeftHi, floor, k, zeroOne, Bound.known] at this

theorem combine_respects_narrowing_kills_floorLoLeftHi :
    ¬ ∀ g g' h h' : Grade Unit, Narrows g' g → Narrows h' h →
      Narrows (combineWith floorLoLeftHi floor g' h') (combineWith floorLoLeftHi floor g h) := by
  intro hc
  have := (hc zeroOne (k 0) (k 0) (k 0) (fun _ => ⟨le_rfl, zero_le_one⟩)
    (fun _ => ⟨le_rfl, le_rfl⟩) ()).1
  simp [combineWith, axisWith, floorLoLeftHi, floor, k, zeroOne, Bound.known] at this

theorem combine_comm_kills_floorLoRightHi :
    ¬ ∀ g h : Grade Unit,
      combineWith floorLoRightHi floor g h = combineWith floorLoRightHi floor h g := by
  intro hc
  have := (congrArg (fun g => (g ()).lo) (hc (k 0) zeroOne)).le
  simp [combineWith, axisWith, floorLoRightHi, floor, k, zeroOne, Bound.known] at this

theorem combine_respects_narrowing_kills_floorLoRightHi :
    ¬ ∀ g g' h h' : Grade Unit, Narrows g' g → Narrows h' h →
      Narrows (combineWith floorLoRightHi floor g' h') (combineWith floorLoRightHi floor g h) := by
  intro hc
  have := (hc (k 0) (k 0) zeroOne (k 0) (fun _ => ⟨le_rfl, le_rfl⟩)
    (fun _ => ⟨le_rfl, zero_le_one⟩) ()).1
  simp [combineWith, axisWith, floorLoRightHi, floor, k, zeroOne, Bound.known] at this

theorem combine_comm_kills_floorHiLeftLo :
    ¬ ∀ g h : Grade Unit,
      combineWith floorHiLeftLo floor g h = combineWith floorHiLeftLo floor h g := by
  intro hc
  have := (congrArg (fun g => (g ()).hi) (hc (k 0) zeroOne)).le
  simp [combineWith, axisWith, floorHiLeftLo, floor, k, zeroOne, Bound.known] at this

theorem accept_bounds_truth_kills_floorHiLeftLo :
    ¬ ∀ (θ : Unit → ENNReal) (g h : Grade Unit) (x y z : Unit → ENNReal),
      Encloses g x → Encloses h y → (∀ i, ComposesNoWorse (floor i) (x i) (y i) (z i)) →
      verdict θ (combineWith floorHiLeftLo floor g h) = .accept → ∀ i, z i ≤ θ i := by
  intro hc
  have := hc (fun _ => 0) zeroOne (k 0) (fun _ => 1) (fun _ => 0) (fun _ => 1)
    (fun _ => ⟨zero_le_one, le_rfl⟩) (fun _ => ⟨le_rfl, le_rfl⟩) (fun _ => le_max_left _ _)
    (by simp [verdict, combineWith, axisWith, floorHiLeftLo, floor, k, zeroOne, Bound.known]) ()
  norm_num at this

theorem combine_respects_narrowing_kills_floorHiLeftLo :
    ¬ ∀ g g' h h' : Grade Unit, Narrows g' g → Narrows h' h →
      Narrows (combineWith floorHiLeftLo floor g' h') (combineWith floorHiLeftLo floor g h) := by
  intro hc
  have := (hc zeroOne (k 1) (k 0) (k 0) (fun _ => ⟨zero_le_one, le_rfl⟩)
    (fun _ => ⟨le_rfl, le_rfl⟩) ()).2
  simp [combineWith, axisWith, floorHiLeftLo, floor, k, zeroOne, Bound.known] at this

theorem combine_comm_kills_floorHiRightLo :
    ¬ ∀ g h : Grade Unit,
      combineWith floorHiRightLo floor g h = combineWith floorHiRightLo floor h g := by
  intro hc
  have := (congrArg (fun g => (g ()).hi) (hc (k 0) zeroOne)).ge
  simp [combineWith, axisWith, floorHiRightLo, floor, k, zeroOne, Bound.known] at this

theorem accept_bounds_truth_kills_floorHiRightLo :
    ¬ ∀ (θ : Unit → ENNReal) (g h : Grade Unit) (x y z : Unit → ENNReal),
      Encloses g x → Encloses h y → (∀ i, ComposesNoWorse (floor i) (x i) (y i) (z i)) →
      verdict θ (combineWith floorHiRightLo floor g h) = .accept → ∀ i, z i ≤ θ i := by
  intro hc
  have := hc (fun _ => 0) (k 0) zeroOne (fun _ => 0) (fun _ => 1) (fun _ => 1)
    (fun _ => ⟨le_rfl, le_rfl⟩) (fun _ => ⟨zero_le_one, le_rfl⟩) (fun _ => le_max_right _ _)
    (by simp [verdict, combineWith, axisWith, floorHiRightLo, floor, k, zeroOne, Bound.known]) ()
  norm_num at this

theorem combine_respects_narrowing_kills_floorHiRightLo :
    ¬ ∀ g g' h h' : Grade Unit, Narrows g' g → Narrows h' h →
      Narrows (combineWith floorHiRightLo floor g' h') (combineWith floorHiRightLo floor g h) := by
  intro hc
  have := (hc (k 0) (k 0) zeroOne (k 1) (fun _ => ⟨le_rfl, le_rfl⟩)
    (fun _ => ⟨zero_le_one, le_rfl⟩) ()).2
  simp [combineWith, axisWith, floorHiRightLo, floor, k, zeroOne, Bound.known] at this

/-- `floorHiAdd` is a real change: [0, 1] with itself on a floor is [0, 2], not [0, 1]. -/
theorem floorHiAdd_differs :
    combineWith floorHiAdd floor zeroOne zeroOne ≠ combine floor zeroOne zeroOne := by
  intro h
  have := congrArg (fun g => (g ()).hi) h
  norm_num [combineWith, axisWith, floorHiAdd, combine, combineAxis, floor, zeroOne] at this

theorem combine_comm_holds_floorHiAdd {ι : Type} (kind : ι → Kind) (g h : Grade ι) :
    combineWith floorHiAdd kind g h = combineWith floorHiAdd kind h g := by
  funext i
  simp only [combineWith]
  cases kind i
  · exact Bound.ext (max_comm _ _) (add_comm _ _)
  · exact Bound.ext (add_comm _ _) (add_comm _ _)

theorem combine_assoc_holds_floorHiAdd {ι : Type} (kind : ι → Kind) (g h l : Grade ι) :
    combineWith floorHiAdd kind (combineWith floorHiAdd kind g h) l
      = combineWith floorHiAdd kind g (combineWith floorHiAdd kind h l) := by
  funext i
  simp only [combineWith]
  cases kind i
  · exact Bound.ext (max_assoc _ _ _) (add_assoc _ _ _)
  · exact Bound.ext (add_assoc _ _ _) (add_assoc _ _ _)

theorem interchange_holds_floorHiAdd {ι : Type} (kind : ι → Kind) :
    Interchange (combineWith floorHiAdd kind) (combineWith floorHiAdd kind) := by
  intro a b c d
  funext i
  simp only [combineWith]
  cases kind i
  · exact Bound.ext (max_max_max_comm _ _ _ _) (add_add_add_comm _ _ _ _)
  · exact Bound.ext (add_add_add_comm _ _ _ _) (add_add_add_comm _ _ _ _)

theorem accept_bounds_truth_holds_floorHiAdd {ι : Type} (kind : ι → Kind) (θ : ι → ENNReal)
    (g h : Grade ι) (x y z : ι → ENNReal) (hx : Encloses g x) (hy : Encloses h y)
    (hz : ∀ i, ComposesNoWorse (kind i) (x i) (y i) (z i))
    (hacc : verdict θ (combineWith floorHiAdd kind g h) = .accept) : ∀ i, z i ≤ θ i :=
  accept_bounds_truth_of_floor_hi floorHiAdd (fun _ _ => max_le le_self_add le_add_self) kind θ
    g h x y z hx hy hz hacc

theorem combine_respects_narrowing_holds_floorHiAdd {ι : Type} (kind : ι → Kind)
    {g g' h h' : Grade ι} (hg : Narrows g' g) (hh : Narrows h' h) :
    Narrows (combineWith floorHiAdd kind g' h') (combineWith floorHiAdd kind g h) :=
  combine_respects_narrowing_of_floor floorHiAdd
    (fun _ _ _ _ h1 h2 h3 h4 => ⟨max_le_max h1 h3, add_le_add h2 h4⟩) kind hg hh

theorem accept_bounds_truth_holds_floorLoLeftHi {ι : Type} (kind : ι → Kind) (θ : ι → ENNReal)
    (g h : Grade ι) (x y z : ι → ENNReal) (hx : Encloses g x) (hy : Encloses h y)
    (hz : ∀ i, ComposesNoWorse (kind i) (x i) (y i) (z i))
    (hacc : verdict θ (combineWith floorLoLeftHi kind g h) = .accept) : ∀ i, z i ≤ θ i :=
  accept_bounds_truth_of_floor_hi floorLoLeftHi (fun _ _ => le_rfl) kind θ g h x y z hx hy hz hacc

theorem accept_bounds_truth_holds_floorLoRightHi {ι : Type} (kind : ι → Kind) (θ : ι → ENNReal)
    (g h : Grade ι) (x y z : ι → ENNReal) (hx : Encloses g x) (hy : Encloses h y)
    (hz : ∀ i, ComposesNoWorse (kind i) (x i) (y i) (z i))
    (hacc : verdict θ (combineWith floorLoRightHi kind g h) = .accept) : ∀ i, z i ≤ θ i :=
  accept_bounds_truth_of_floor_hi floorLoRightHi (fun _ _ => le_rfl) kind θ g h x y z hx hy hz
    hacc

/-! ### `verdict` -/

/-- ≤ to <: accept only when every upper end is below its threshold. -/
noncomputable def verdictLt {ι : Type} (θ : ι → ENNReal) (g : Grade ι) : Decision := by
  classical
  exact if ∀ i, (g i).hi < θ i then .accept else .reject

/-- One conjunct dropped: the check skips axis `j`. On one axis it accepts every grade. -/
noncomputable def verdictSkip {ι : Type} (j : ι) (θ : ι → ENNReal) (g : Grade ι) : Decision := by
  classical
  exact if ∀ i, i ≠ j → (g i).hi ≤ θ i then .accept else .reject

theorem accept_bounds_truth_kills_verdictLo :
    ¬ ∀ (θ : Unit → ENNReal) (g h : Grade Unit) (x y z : Unit → ENNReal),
      Encloses g x → Encloses h y → (∀ i, ComposesNoWorse (floor i) (x i) (y i) (z i)) →
      verdictLo θ (combine floor g h) = .accept → ∀ i, z i ≤ θ i := by
  intro hc
  have := hc (fun _ => 0) (k 0) zeroOne (fun _ => 0) (fun _ => 1) (fun _ => 1)
    (fun _ => ⟨le_rfl, le_rfl⟩) (fun _ => ⟨zero_le_one, le_rfl⟩) (fun _ => le_max_right _ _)
    (by simp [verdictLo, combine, combineAxis, floor, k, zeroOne, Bound.known]) ()
  norm_num at this

theorem verdict_complete_kills_verdictLt :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit),
      (∀ i, (g i).lo = (g i).hi) → (∀ i, (g i).lo ≤ θ i) → verdictLt θ g = .accept := by
  intro hc
  have := hc (fun _ => 0) (k 0) (fun _ => rfl) (fun _ => le_rfl)
  simp [verdictLt, k, Bound.known] at this

theorem definitelyFails_spec_kills_verdictLt :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit),
      DefinitelyFails θ g ↔ ∀ g' : Grade Unit, Narrows g' g → verdictLt θ g' = .reject := by
  intro hc
  obtain ⟨_, h⟩ := (hc (fun _ => 0) (k 0)).mpr fun g' _ => by simp [verdictLt]
  simp [k, Bound.known] at h

theorem verdictLt_hi {ι : Type} (θ : ι → ENNReal) (g : Grade ι)
    (hacc : verdictLt θ g = .accept) (i : ι) : (g i).hi ≤ θ i := by
  unfold verdictLt at hacc
  split_ifs at hacc with hall
  exact (hall i).le

theorem verdict_sound_holds_verdictLt {ι : Type} (θ : ι → ENNReal) (g : Grade ι) (i : ι)
    (hover : θ i < (g i).hi) : verdictLt θ g = .reject :=
  verdict_sound_of_hi verdictLt verdictLt_hi θ g i hover

theorem accept_bounds_truth_holds_verdictLt {ι : Type} (kind : ι → Kind) (θ : ι → ENNReal)
    (g h : Grade ι) (x y z : ι → ENNReal) (hx : Encloses g x) (hy : Encloses h y)
    (hz : ∀ i, ComposesNoWorse (kind i) (x i) (y i) (z i))
    (hacc : verdictLt θ (combine kind g h) = .accept) : ∀ i, z i ≤ θ i :=
  accept_bounds_truth_of_hi verdictLt verdictLt_hi kind θ g h x y z (fun i => (hx i).2)
    (fun i => (hy i).2) hz hacc

theorem verdict_sound_kills_verdictSkip :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit) (i : Unit),
      θ i < (g i).hi → verdictSkip () θ g = .reject := by
  intro hc
  have := hc (fun _ => 0) (k 1) () (by simp [k, Bound.known])
  simp [verdictSkip] at this

theorem accept_bounds_truth_kills_verdictSkip :
    ¬ ∀ (θ : Unit → ENNReal) (g h : Grade Unit) (x y z : Unit → ENNReal),
      Encloses g x → Encloses h y → (∀ i, ComposesNoWorse (floor i) (x i) (y i) (z i)) →
      verdictSkip () θ (combine floor g h) = .accept → ∀ i, z i ≤ θ i := by
  intro hc
  have := hc (fun _ => 0) (k 0) (k 1) (fun _ => 0) (fun _ => 1) (fun _ => 1)
    (fun _ => ⟨le_rfl, le_rfl⟩) (fun _ => ⟨le_rfl, le_rfl⟩) (fun _ => le_max_right _ _)
    (by simp [verdictSkip]) ()
  norm_num at this

theorem definitelyFails_spec_kills_verdictSkip :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit),
      DefinitelyFails θ g ↔ ∀ g' : Grade Unit, Narrows g' g → verdictSkip () θ g' = .reject := by
  intro hc
  have := (hc (fun _ => 0) (k 1)).mp ⟨(), by simp [k, Bound.known]⟩ (k 1)
    (fun _ => ⟨le_rfl, le_rfl⟩)
  simp [verdictSkip] at this

/-! ### `Narrows` -/

/-- `lo` to `hi` in the first conjunct's `g`: only the point at `g`'s upper end narrows it. -/
def narrowsToHi {ι : Type} (g' g : Grade ι) : Prop :=
  ∀ i, (g i).hi ≤ (g' i).lo ∧ (g' i).hi ≤ (g i).hi

/-- `hi` to `lo` in the second conjunct's `g'`: only the lower end must lie inside. -/
def narrowsLoInside {ι : Type} (g' g : Grade ι) : Prop :=
  ∀ i, (g i).lo ≤ (g' i).lo ∧ (g' i).lo ≤ (g i).hi

/-- `hi` to `lo` in the second conjunct's `g`: only the point at `g`'s lower end narrows it. A
    survivor. -/
def narrowsToLo {ι : Type} (g' g : Grade ι) : Prop :=
  ∀ i, (g i).lo ≤ (g' i).lo ∧ (g' i).hi ≤ (g i).lo

/-- ≤ to < in the first conjunct. -/
def narrowsLoStrict {ι : Type} (g' g : Grade ι) : Prop :=
  ∀ i, (g i).lo < (g' i).lo ∧ (g' i).hi ≤ (g i).hi

/-- ≤ to < in the second conjunct. -/
def narrowsHiStrict {ι : Type} (g' g : Grade ι) : Prop :=
  ∀ i, (g i).lo ≤ (g' i).lo ∧ (g' i).hi < (g i).hi

/-- The second conjunct dropped: only the lower end must rise. -/
def narrowsLoOnly {ι : Type} (g' g : Grade ι) : Prop := ∀ i, (g i).lo ≤ (g' i).lo

/-- The first conjunct dropped: only the upper end must fall. -/
def narrowsHiOnly {ι : Type} (g' g : Grade ι) : Prop := ∀ i, (g' i).hi ≤ (g i).hi

/-- Under θ = 0, [0, 1] doesn't fail definitely, but the only grade `narrowsToHi` lets narrow it,
    the known 1, is rejected. -/
theorem definitelyFails_spec_kills_narrowsToHi :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit),
      DefinitelyFails θ g ↔ ∀ g' : Grade Unit, narrowsToHi g' g → verdict θ g' = .reject := by
  intro hc
  obtain ⟨_, h⟩ := (hc (fun _ => 0) zeroOne).mpr fun g' hn => by
    have h1 : (1 : ENNReal) ≤ (g' ()).hi := le_trans (hn ()).1 (g' ()).le
    unfold verdict
    split_ifs with hall
    · exact absurd (le_trans h1 (hall ())) (by norm_num)
    · rfl
  simp [zeroOne] at h

theorem narrowing_keeps_accept_kills_narrowsLoInside :
    ¬ ∀ (θ : Unit → ENNReal) (g g' : Grade Unit),
      verdict θ g = .accept → narrowsLoInside g' g → verdict θ g' = .accept := by
  intro hc
  have := hc (fun _ => 0) (k 0) zeroOne (by simp [verdict, k, Bound.known])
    (fun _ => ⟨le_rfl, le_rfl⟩)
  simp [verdict, zeroOne] at this

/-- Under θ = 0, the known 0 doesn't fail definitely, but nothing `narrowsLoStrict`-narrows it,
    so every narrowing is rejected, vacuously. -/
theorem definitelyFails_spec_kills_narrowsLoStrict :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit),
      DefinitelyFails θ g ↔ ∀ g' : Grade Unit, narrowsLoStrict g' g → verdict θ g' = .reject := by
  intro hc
  obtain ⟨_, h⟩ := (hc (fun _ => 0) (k 0)).mpr fun g' hn =>
    absurd (lt_of_lt_of_le (hn ()).1 (le_trans (g' ()).le (hn ()).2)) (lt_irrefl _)
  simp [k, Bound.known] at h

theorem definitelyFails_spec_kills_narrowsHiStrict :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit),
      DefinitelyFails θ g ↔ ∀ g' : Grade Unit, narrowsHiStrict g' g → verdict θ g' = .reject := by
  intro hc
  obtain ⟨_, h⟩ := (hc (fun _ => 0) (k 0)).mpr fun g' hn =>
    absurd (hn ()).2 (by simp [k, Bound.known])
  simp [k, Bound.known] at h

theorem narrowing_keeps_accept_kills_narrowsLoOnly :
    ¬ ∀ (θ : Unit → ENNReal) (g g' : Grade Unit),
      verdict θ g = .accept → narrowsLoOnly g' g → verdict θ g' = .accept := by
  intro hc
  have := hc (fun _ => 0) (k 0) zeroOne (by simp [verdict, k, Bound.known]) (fun _ => le_rfl)
  simp [verdict, zeroOne] at this

theorem definitelyFails_spec_kills_narrowsHiOnly :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit),
      DefinitelyFails θ g ↔ ∀ g' : Grade Unit, narrowsHiOnly g' g → verdict θ g' = .reject := by
  intro hc
  have := (hc (fun _ => 0) (k 1)).mp ⟨(), by simp [k, Bound.known]⟩ (k 0) (fun _ => zero_le_one)
  simp [verdict, k, Bound.known] at this

/-- `narrowsToLo` is a real change: [0, 1] doesn't narrow itself under it. -/
theorem narrowsToLo_differs : Narrows zeroOne zeroOne ∧ ¬ narrowsToLo zeroOne zeroOne := by
  refine ⟨fun _ => ⟨le_rfl, le_rfl⟩, fun h => ?_⟩
  have := (h ()).2
  simp [zeroOne] at this

theorem combine_respects_narrowing_holds_narrowsToLo {ι : Type} (kind : ι → Kind)
    {g g' h h' : Grade ι} (hg : narrowsToLo g' g) (hh : narrowsToLo h' h) :
    narrowsToLo (combine kind g' h') (combine kind g h) := by
  intro i
  obtain ⟨hg1, hg2⟩ := hg i
  obtain ⟨hh1, hh2⟩ := hh i
  show (combineAxis (kind i) (g i) (h i)).lo ≤ (combineAxis (kind i) (g' i) (h' i)).lo
    ∧ (combineAxis (kind i) (g' i) (h' i)).hi ≤ (combineAxis (kind i) (g i) (h i)).lo
  cases kind i with
  | floor => exact ⟨max_le_max hg1 hh1, max_le_max hg2 hh2⟩
  | budget => exact ⟨add_le_add hg1 hh1, add_le_add hg2 hh2⟩

theorem narrowing_keeps_accept_holds_narrowsToLo {ι : Type} (θ : ι → ENNReal)
    {g g' : Grade ι} (hacc : verdict θ g = .accept) (hn : narrowsToLo g' g) :
    verdict θ g' = .accept :=
  narrowing_keeps_accept_of_hi narrowsToLo (fun _ g hn i => le_trans (hn i).2 (g i).le) θ hacc hn

theorem definitelyFails_spec_holds_narrowsToLo {ι : Type} (θ : ι → ENNReal) (g : Grade ι) :
    DefinitelyFails θ g ↔ ∀ g' : Grade ι, narrowsToLo g' g → verdict θ g' = .reject :=
  definitelyFails_spec_of narrowsToLo (fun g' _ hn i => le_trans (hn i).1 (g' i).le)
    (fun _ _ => ⟨le_rfl, le_rfl⟩) θ g

theorem narrowing_keeps_accept_holds_narrowsToHi {ι : Type} (θ : ι → ENNReal) {g g' : Grade ι}
    (hacc : verdict θ g = .accept) (hn : narrowsToHi g' g) : verdict θ g' = .accept :=
  narrowing_keeps_accept_of_hi narrowsToHi (fun _ _ hn i => (hn i).2) θ hacc hn

theorem definitelyFails_spec_holds_narrowsLoInside {ι : Type} (θ : ι → ENNReal) (g : Grade ι) :
    DefinitelyFails θ g ↔ ∀ g' : Grade ι, narrowsLoInside g' g → verdict θ g' = .reject :=
  definitelyFails_spec_of narrowsLoInside (fun g' _ hn i => le_trans (hn i).1 (g' i).le)
    (fun g i => ⟨le_rfl, (g i).le⟩) θ g

theorem narrowing_keeps_accept_holds_narrowsLoStrict {ι : Type} (θ : ι → ENNReal)
    {g g' : Grade ι} (hacc : verdict θ g = .accept) (hn : narrowsLoStrict g' g) :
    verdict θ g' = .accept :=
  narrowing_keeps_accept_of_hi narrowsLoStrict (fun _ _ hn i => (hn i).2) θ hacc hn

theorem narrowing_keeps_accept_holds_narrowsHiStrict {ι : Type} (θ : ι → ENNReal)
    {g g' : Grade ι} (hacc : verdict θ g = .accept) (hn : narrowsHiStrict g' g) :
    verdict θ g' = .accept :=
  narrowing_keeps_accept_of_hi narrowsHiStrict (fun _ _ hn i => (hn i).2.le) θ hacc hn

theorem definitelyFails_spec_holds_narrowsLoOnly {ι : Type} (θ : ι → ENNReal) (g : Grade ι) :
    DefinitelyFails θ g ↔ ∀ g' : Grade ι, narrowsLoOnly g' g → verdict θ g' = .reject :=
  definitelyFails_spec_of narrowsLoOnly (fun g' _ hn i => le_trans (hn i) (g' i).le)
    (fun _ _ => le_rfl) θ g

theorem narrowing_keeps_accept_holds_narrowsHiOnly {ι : Type} (θ : ι → ENNReal)
    {g g' : Grade ι} (hacc : verdict θ g = .accept) (hn : narrowsHiOnly g' g) :
    verdict θ g' = .accept :=
  narrowing_keeps_accept_of_hi narrowsHiOnly (fun _ _ hn i => hn i) θ hacc hn

/-! ### `Encloses` -/

/-- The first conjunct dropped: the grade bounds the value from above only. A survivor. -/
def enclosesHiOnly {ι : Type} (g : Grade ι) (x : ι → ENNReal) : Prop := ∀ i, x i ≤ (g i).hi

/-- The second conjunct dropped: the grade bounds the value from below only. -/
def enclosesLoOnly {ι : Type} (g : Grade ι) (x : ι → ENNReal) : Prop := ∀ i, (g i).lo ≤ x i

theorem accept_bounds_truth_kills_enclosesLoOnly :
    ¬ ∀ (θ : Unit → ENNReal) (g h : Grade Unit) (x y z : Unit → ENNReal),
      enclosesLoOnly g x → enclosesLoOnly h y →
      (∀ i, ComposesNoWorse (floor i) (x i) (y i) (z i)) →
      verdict θ (combine floor g h) = .accept → ∀ i, z i ≤ θ i := by
  intro hc
  have := hc (fun _ => 0) (k 0) (k 0) (fun _ => 0) (fun _ => 1) (fun _ => 1)
    (fun _ => le_rfl) (fun _ => zero_le_one) (fun _ => le_max_right _ _)
    (by simp [verdict, combine, combineAxis, floor, k, Bound.known]) ()
  norm_num at this

/-- `enclosesHiOnly` is a real change: the known 1 bounds 0 from above, but doesn't enclose it. -/
theorem enclosesHiOnly_differs :
    enclosesHiOnly (k 1) (fun _ => 0) ∧ ¬ Encloses (k 1) (fun _ => 0) := by
  refine ⟨fun _ => zero_le_one, fun h => ?_⟩
  have := (h ()).1
  simp [k, Bound.known] at this

/-- `accept_bounds_truth` holds with `enclosesHiOnly`, on any axes: its proof reads only the upper
    halves of `Encloses`, so the theorem holds under that weaker hypothesis. -/
theorem accept_bounds_truth_holds_enclosesHiOnly {ι : Type} (kind : ι → Kind) (θ : ι → ENNReal)
    (g h : Grade ι) (x y z : ι → ENNReal) (hx : enclosesHiOnly g x) (hy : enclosesHiOnly h y)
    (hz : ∀ i, ComposesNoWorse (kind i) (x i) (y i) (z i))
    (hacc : verdict θ (combine kind g h) = .accept) : ∀ i, z i ≤ θ i :=
  accept_bounds_truth_of_hi verdict verdict_hi kind θ g h x y z hx hy hz hacc

/-! ### `ComposesNoWorse`'s floor case -/

/-- Max to + in the floor case: a floor's true values may add, as a budget's do. -/
def composesSum : Kind → ENNReal → ENNReal → ENNReal → Prop
  | .floor,  x, y, z => z ≤ x + y
  | .budget, x, y, z => z ≤ x + y

/-- Under θ = 1, two stages graded [0, 1] whose true values are 1 each combine on a floor to
    [0, 1], which is accepted, but `composesSum` lets the composite's true value be 2. -/
theorem accept_bounds_truth_kills_composesSum :
    ¬ ∀ (θ : Unit → ENNReal) (g h : Grade Unit) (x y z : Unit → ENNReal),
      Encloses g x → Encloses h y → (∀ i, composesSum (floor i) (x i) (y i) (z i)) →
      verdict θ (combine floor g h) = .accept → ∀ i, z i ≤ θ i := by
  intro hc
  have := hc θone zeroOne zeroOne (fun _ => 1) (fun _ => 1) (fun _ => 2)
    (fun _ => ⟨zero_le_one, le_rfl⟩) (fun _ => ⟨zero_le_one, le_rfl⟩)
    (fun _ => by norm_num [composesSum, floor])
    (by simp [verdict, combine, combineAxis, floor, zeroOne, θone]) ()
  norm_num [θone] at this

/-! ### `DefinitelyFails` -/

/-- < to ≤: an axis whose lower end reaches its threshold fails definitely. -/
def definitelyFailsLe {ι : Type} (θ : ι → ENNReal) (g : Grade ι) : Prop := ∃ i, θ i ≤ (g i).lo

/-- Under θ = 0, `definitelyFailsLe` counts the known 0 as a definite failure, though it is
    accepted. -/
theorem definitelyFails_spec_kills_definitelyFailsLe :
    ¬ ∀ (θ : Unit → ENNReal) (g : Grade Unit),
      definitelyFailsLe θ g ↔ ∀ g' : Grade Unit, Narrows g' g → verdict θ g' = .reject := by
  intro hc
  have := (hc (fun _ => 0) (k 0)).mp ⟨(), le_rfl⟩ (k 0) (fun _ => ⟨le_rfl, le_rfl⟩)
  simp [verdict, k, Bound.known] at this

/-! ## statements-v6: `narrows_unknown`

`statements-v6` adds `narrows_unknown`: every grade narrows the grade that is unknown on every
axis. Of the matrix's survivors, it kills `unknownZero`, the same change as its mutant in
`JSG.Tests.Mutants`, and `narrowsToLo`, below. -/

/-- Under `narrowsToLo`, only the point at a grade's lower end narrows it, so the known 1 doesn't
    narrow the unknown. -/
theorem narrows_unknown_kills_narrowsToLo :
    ¬ ∀ g : Grade Unit, narrowsToLo g (fun _ => Bound.unknown) := by
  intro h
  have := (h (k 1) ()).2
  norm_num [k, Bound.known, Bound.unknown] at this

end JSG.Tests.Gamers
