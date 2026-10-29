import JSG.Harness.Corpus

/-!
Executable mutants, the differential tests' negative controls (guide/EXECUTABLE_GATE.md §2).
Each is the oracle with one function replaced by a twin of a mutant from
`Tests/Mutants.lean`, so it runs through the same test as any other implementation.
`Tests/Differential.lean` proves that the exhaustive vectors catch every one.

The mutants of definitions without twins (the obligations, the Loader, the frontier charge,
the policy lattice and the analysis layer) wait for their twins, if any.

`sirusModel` is what SirusSC's `specchain` does where it has code, with its ⊥ read as the
unknown. It predicts exactly where SirusSC must disagree with the oracle.
-/

namespace JSG.Harness

open JSG

/-- The pairs of a threshold and a bound, axis by axis. A missing threshold is ∞. -/
def withCaps (θ : List (WithTop ℚ≥0)) (g : List XBound) : List (WithTop ℚ≥0 × XBound) :=
  g.mapIdx fun i b => (θ.getD i ⊤, b)

/-- Whether a bound is the unknown, [0, ∞]: SirusSC's ⊥. -/
def isUnknown (b : XBound) : Bool := decide (b.lo = 0 ∧ b.hi = ⊤)

/-- Combines two grades axis by axis with one rule. -/
def zipCombine (f : Kind → XBound → XBound → XBound) (ks : List Kind) (g h : List XBound) :
    List XBound :=
  g.mapIdx fun i a => f (ks.getD i .floor) a (h.getD i XBound.unknown)

/-- Half of a value; ∞ stays ∞. -/
def half : WithTop ℚ≥0 → WithTop ℚ≥0
  | ⊤ => ⊤
  | (q : ℚ≥0) => ((q / 2 : ℚ≥0) : WithTop ℚ≥0)

/-! ### Mutants of `combine` -/

/-- `combine_comm`'s mutant: the later grade replaces the earlier one. -/
def overwrite : Impl := { oracle with combine := fun _ _ h => h }

/-- `combine_assoc`'s mutant: budgets average, (a + b) / 2. -/
def avgCombine : Impl :=
  { oracle with combine := zipCombine fun k a b => match k with
      | .floor => xcombineAxis .floor a b
      | .budget => mkB (half (a.lo + b.lo)) (half (a.hi + b.hi)) }

/-- `interchange`'s mutant: JSG V's sequential rule, max on every axis. -/
def jsgVSeq : Impl := { oracle with combine := zipCombine fun _ => xcombineAxis .floor }

/-- `interchange`'s second mutant: SCp2's sequential rule, + on every axis. -/
def scp2Seq : Impl := { oracle with combine := zipCombine fun _ => xcombineAxis .budget }

/-- `xcombine_agrees`'s mutant: SirusSC's `Interval.join` and `Interval.plus`, where ⊥ absorbs. -/
def absorbCombine : Impl :=
  { oracle with combine := zipCombine fun k a b =>
      if isUnknown a || isUnknown b then XBound.unknown else xcombineAxis k a b }

/-! ### Mutants of `verdict` -/

/-- `verdict_sound`'s mutant: a verdict that reads `lo`. -/
def verdictLo : Impl :=
  { oracle with verdict := fun θ g =>
      if (withCaps θ g).all fun (t, b) => decide (b.lo ≤ t) then .accept else .reject }

/-- `verdict_sound`'s second mutant: a gate that rejects only unknowns, an axis with
    `hi = ∞` under a finite threshold. -/
def unknownOnly : Impl :=
  { oracle with verdict := fun θ g =>
      if (withCaps θ g).any fun (t, b) => decide (b.hi = ⊤ ∧ t < ⊤) then .reject else .accept }

/-- `verdict_complete`'s mutant: the always-REJECT gate. -/
def alwaysReject : Impl := { oracle with verdict := fun _ _ => .reject }

/-- `xverdict_agrees`'s mutant: SirusSC's `Q.leq`, which skips an axis holding ⊥. -/
def leqSkipsUnknown : Impl :=
  { oracle with verdict := fun θ g =>
      if (withCaps θ g).all fun (t, b) => isUnknown b || decide (b.hi ≤ t) then .accept
      else .reject }

/-! ### Mutants of `residual` and `Threads` -/

/-- `residual_spec`'s and `xresidual_agrees`'s mutant: each stage checked against the full θ. -/
def residualFull : Impl := { oracle with residual := fun θ _ => θ }

/-- v1's residual check alone, which checks only the last stage's fit. -/
def residualOnlyThreads : WithTop ℚ≥0 → List (WithTop ℚ≥0) → Bool
  | _, [] => true
  | θ, [x] => decide (x ≤ θ)
  | θ, x :: y :: rest => residualOnlyThreads (xresidual θ x) (y :: rest)

/-- `threads_spec`'s and `xthreads_agrees`'s mutant. -/
def residualOnly : Impl := { oracle with threads := residualOnlyThreads }

/-! ### Mutants of `leaseVerdict` -/

/-- `lease_sound`'s and `xleaseVerdict_agrees`'s mutant: SirusSC's `QPrime`, which never reads
    a width. -/
def qPrimeGate : Impl := { oracle with lease := fun θ _ g => oracle.verdict θ g }

/-- `lease_sound`'s second mutant: a gate that checks only widths. -/
def widthsOnly : Impl :=
  { oracle with lease := fun _ β g =>
      if (withCaps β g).all fun (l, b) => decide (b.width ≤ l) then .accept else .reject }

/-- `lease_complete`'s mutant: SirusSC's `Q`, which accepts points only. -/
def pointsOnly : Impl :=
  { oracle with lease := fun θ _ g =>
      if (withCaps θ g).all fun (t, b) => decide (b.lo = b.hi ∧ b.hi ≤ t) then .accept
      else .reject }

/-! ### Mutants of `Bound.width`, `Bound.known` and `Bound.unknown` -/

/-- `xwidth_agrees`'s mutant: ∞ whenever the upper end is, as in floating point. -/
def floatWidth : Impl :=
  { oracle with width := fun b => if b.hi = ⊤ then ⊤ else b.hi - b.lo }

/-- `xknown_agrees`'s mutant: a reading taken as an upper bound only, [0, x]. -/
def upperOnly : Impl := { oracle with known := fun x => ⟨0, x, zero_le⟩ }

/-- `xunknown_agrees`'s mutant: the unknown at the bottom of the order, [0, 0]. -/
def bottomUnknown : Impl := { oracle with unknown := XBound.known 0 }

/-- Every executable mutant, by name. -/
def mutants : List (String × Impl) :=
  [("overwrite", overwrite), ("avgCombine", avgCombine), ("jsgVSeq", jsgVSeq),
   ("scp2Seq", scp2Seq), ("absorbCombine", absorbCombine), ("verdictLo", verdictLo),
   ("unknownOnly", unknownOnly), ("alwaysReject", alwaysReject),
   ("leqSkipsUnknown", leqSkipsUnknown), ("residualFull", residualFull),
   ("residualOnly", residualOnly), ("qPrimeGate", qPrimeGate), ("widthsOnly", widthsOnly),
   ("pointsOnly", pointsOnly), ("floatWidth", floatWidth), ("upperOnly", upperOnly),
   ("bottomUnknown", bottomUnknown)]

/-! ### SirusSC, where it has code -/

/-- SirusSC's `specchain`, with its ⊥ read as the unknown:
    - **combine:** `Interval.join` on floors and `Interval.plus` on budgets, where ⊥ absorbs;
    - **verdict:** `Q.leq` against the thresholds, which skips an axis holding ⊥;
    - **lease verdict:** `QPrime`'s one guard, `guard_no_bottom`, which rejects any ⊥, and
      then `Q.leq` on the upper ends. No width is read.

    It has no code for residuals, threading, widths, or known and unknown values, so its
    adapter answers none of those. -/
def sirusModel : Impl :=
  { oracle with
    combine := absorbCombine.combine
    verdict := leqSkipsUnknown.verdict
    lease := fun θ _ g =>
      if g.any isUnknown then .reject
      else if (withCaps θ g).all fun (t, b) => decide (b.hi ≤ t) then .accept else .reject }

/-- The operations SirusSC's adapter answers. -/
def sirusAnswers : Vec → Bool
  | .combine .. | .verdict .. | .lease .. => true
  | _ => false

end JSG.Harness
