import JSG.Defs
import JSG.Lemmas.Twins

/-!
Milestone 4 proofs: the executable twins that `statements-v4` added, each proved to agree
with its frozen definition. Each theorem restates its frozen statement in `JSG.Statements`
under the same name, and CI's Comparator run checks that it proves exactly that statement.
The cast lemmas are in `JSG.Lemmas.Twins`.
-/

namespace JSG

variable {ι : Type} (kind : ι → Kind)

theorem xknown_agrees (x : WithTop ℚ≥0) : (XBound.known x).toBound = Bound.known (xcast x) := rfl

theorem xunknown_agrees : XBound.unknown.toBound = Bound.unknown := by
  ext <;> simp [XBound.toBound, XBound.unknown, Bound.unknown, xcast_zero, xcast_top]

theorem xcombine_agrees (g h : XGrade ι) :
    (xcombine kind g h).toGrade = combine kind g.toGrade h.toGrade := by
  funext i
  simp only [XGrade.toGrade, xcombine, combine]
  cases kind i <;> ext <;> simp [xcombineAxis, combineAxis, XBound.toBound, xcast_max, xcast_add]

theorem xverdict_agrees [Fintype ι] (θ : ι → WithTop ℚ≥0) (g : XGrade ι) :
    xverdict θ g = verdict (xcast ∘ θ) g.toGrade := by
  unfold xverdict verdict
  simp only [XGrade.toGrade, XBound.toBound, Function.comp_apply, xcast_le_iff]

theorem xresidual_agrees (θ x : WithTop ℚ≥0) :
    xcast (xresidual θ x) = residual (xcast θ) (xcast x) := xcast_sub θ x

theorem xthreads_agrees (θ : WithTop ℚ≥0) (xs : List (WithTop ℚ≥0)) :
    xthreads θ xs = true ↔ Threads (xcast θ) (xs.map xcast) := by
  induction xs generalizing θ with
  | nil => simp [xthreads, Threads]
  | cons x xs ih => simp [xthreads, Threads, ih, xcast_le_iff, ← xresidual_agrees]

theorem xwidth_agrees (b : XBound) : xcast b.width = b.toBound.width := xcast_sub b.hi b.lo

theorem xleaseVerdict_agrees [Fintype ι] (θ β : ι → WithTop ℚ≥0) (g : XGrade ι) :
    xleaseVerdict θ β g = leaseVerdict (xcast ∘ θ) (xcast ∘ β) g.toGrade := by
  unfold xleaseVerdict leaseVerdict
  simp only [XGrade.toGrade, Function.comp_apply, ← xwidth_agrees]
  simp only [XBound.toBound, xcast_le_iff]

end JSG
