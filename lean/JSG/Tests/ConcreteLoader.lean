import JSG.Proofs.Milestone2
import JSG.Tests.Mutants

/-!
The concrete Loader, built as a `Loader` from its two Milestone 2 theorems,
`LoaderStep.inv_step` and `LoaderStep.progress`. `Loader.safe` and `Loader.terminates`
then apply to it, in general and on the toy window of `Tests/Mutants.lean`. It is concrete
in its rules and checks and generic in its cryptographic primitives (QUEUE.md, Q7).
-/

namespace JSG.Tests.ConcreteLoader

open JSG JSG.Tests.Mutants

/-- What a window has pending is well-founded whenever its obligations are: every ticket
    ranks above every obligation, so ranks in `WithTop O` are well-founded. -/
instance {St O : Type} [Preorder O] [WellFoundedLT O] : WellFoundedLT (Pending St O) :=
  InvImage.wf Pending.rank (wellFounded_lt (α := WithTop O))

/-- The concrete Loader: its step is `LoaderStep`, its invariant L1–L10 (`LoaderInv`), and
    its obligations what each state has pending. Its two proof fields are Milestone 2's
    theorems. -/
def concrete {ι : Type} (kind : ι → Kind) {St O W Bytes D : Type} [Preorder O]
    (prims : Prims Bytes D) (M : DischargeMatrix St O W) :
    Loader (LoaderState ι St O Bytes D) (Pending St O) where
  step := LoaderStep kind prims M
  Inv := LoaderInv kind prims
  inv_step := LoaderStep.inv_step kind prims M
  pending s := s.pending
  progress := LoaderStep.progress kind prims M

/-- `Loader.safe` for the concrete Loader: every state reachable from one that passes
    L1–L10 passes them too. -/
theorem concrete_safe {ι : Type} (kind : ι → Kind) {St O W Bytes D : Type} [Preorder O]
    (prims : Prims Bytes D) (M : DischargeMatrix St O W) {s t : LoaderState ι St O Bytes D}
    (hs : LoaderInv kind prims s) (hr : Relation.ReflTransGen (LoaderStep kind prims M) s t) :
    LoaderInv kind prims t :=
  Loader.safe (concrete kind prims M) hs hr

/-- `Loader.terminates` for the concrete Loader: when the obligations' order is
    well-founded, it has no infinite run. -/
theorem concrete_terminates {ι : Type} (kind : ι → Kind) {St O W Bytes D : Type}
    [Preorder O] [WellFoundedLT O] (prims : Prims Bytes D) (M : DischargeMatrix St O W) :
    WellFounded (fun t s => LoaderStep kind prims M s t) :=
  Loader.terminates (concrete kind prims M)

/-- On `Mutants`' toy Loader, with one stage and obligations in ℕ: every state it reaches
    from T-Boot's state passes L1–L10. -/
theorem toy_safe {t : LoaderState Unit Unit ℕ ℕ ℕ}
    (hr : Relation.ReflTransGen (LoaderStep budget toyPrims anyStage)
      (toyBootState (fun _ => Set.univ) 0) t) :
    LoaderInv budget toyPrims t :=
  concrete_safe budget toyPrims anyStage (toy_bootState_inv _ _ _) hr

/-- The same toy Loader has no infinite run. -/
theorem toy_terminates : WellFounded (fun t s => LoaderStep budget toyPrims anyStage s t) :=
  concrete_terminates budget toyPrims anyStage

end JSG.Tests.ConcreteLoader
