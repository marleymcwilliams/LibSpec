import JSG.Defs

/-!
The frozen statements (core v2, from the master guide's Lean stubs). Every definition
they use lives in `JSG.Defs`. Each theorem names a mutant: a plausible wrong
implementation that fails it, proved in `JSG.Tests.Mutants`.
-/

namespace JSG

/-! ## 1. Graded values -/

variable {ι : Type} (kind : ι → Kind)

/-- Combining two grades gives the same grade in either order, whatever kind each
    axis has. -/
theorem combine_comm (g h : Grade ι) : combine kind g h = combine kind h g := by sorry
-- Mutant: overwrite, where the later stage's grade replaces the earlier one.

/-- How three grades are grouped doesn't change their combination, whatever kind
    each axis has. -/
theorem combine_assoc (g h k : Grade ι) :
    combine kind (combine kind g h) k = combine kind g (combine kind h k) := by sorry
-- Mutant: averaging budgets, (a + b) / 2, is commutative but not associative.

/-- Sequential and parallel composition agree: interchange is an equation. -/
theorem interchange : Interchange (seqComp kind) (parComp kind) := by sorry
-- Mutant: JSG V's rule (max on every axis in sequence, + on budgets in parallel).

/-! ## 2. Verdicts and residuals -/

/-- Soundness: an axis whose upper bound exceeds its threshold rejects the whole
    grade. An unknown, [0, ∞], rejects whenever its threshold is finite, and so does
    anything it combines into, such as [5, ∞]. -/
theorem verdict_sound (θ : ι → ENNReal) (g : Grade ι) (i : ι)
    (hover : θ i < (g i).hi) : verdict θ g = .reject := by sorry
-- Mutant: a verdict that reads `lo` instead of `hi` accepts unknowns. A bare threshold
-- check under SCp1's order does the same, since that order puts ⊥ below every value
-- (a known defect in the master guide). A gate that rejects only unknowns fails it
-- too: it accepts [2, 2] under θ = 1.

/-- Completeness: complete evidence within θ is accepted. -/
theorem verdict_complete (θ : ι → ENNReal) (g : Grade ι)
    (hk : ∀ i, (g i).lo = (g i).hi) (hin : ∀ i, (g i).lo ≤ θ i) :
    verdict θ g = .accept := by sorry
-- Mutant: the always-REJECT gate, which satisfies every safety theorem here.

/-- When θ is finite and stage one fits within it, checking stage two against the
    residual it leaves is the same as checking the total. -/
theorem residual_spec (θ x y : ENNReal) (hθ : θ ≠ ⊤) (hx : x ≤ θ) :
    y ≤ residual θ x ↔ x + y ≤ θ := by sorry
-- Mutant: checking each stage against the full θ accepts x = y = θ.

/-- No confidence inflation: with a noninterfering grader, metrics cannot flip the verdict. -/
theorem no_flip {E : Type} (θ : ι → ENNReal) (gradeOf : Evidence E → Grade ι)
    (hni : Noninterfering gradeOf) (r : E) (m m' : List (String × Float)) :
    verdict θ (gradeOf ⟨r, m⟩) = verdict θ (gradeOf ⟨r, m'⟩) := by
  rw [hni r m m']
-- Mutant: the same grader; Mutants.lean exhibits metrics that flip its verdict.

/-! ## 3. Loader: safety and progress, kept separate -/

/-- Every state reachable from one that satisfies the invariant satisfies it too.
    This holds for any Loader; it says nothing about a concrete one until one is built. -/
theorem Loader.safe {S O : Type} [Preorder O] (L : Loader S O) {s t : S}
    (hs : L.Inv s) (hr : Relation.ReflTransGen L.step s t) : L.Inv t := by sorry
-- Mutant: a step that skips one L-check still terminates but breaks this.

/-- Progress: no infinite run. -/
theorem Loader.terminates {S O : Type} [Preorder O] [WellFoundedLT O]
    (L : Loader S O) : WellFounded (fun t s => L.step s t) := by sorry
-- Mutant: a retry that re-emits the same obligation cannot satisfy `progress`.

/-! ## 4. Frontier charge -/

variable {E : Type} [NormedAddCommGroup E]

/-- Additive under concatenation, so regrouping can't change it. -/
theorem charge_append (A : ENNReal) (j₁ j₂ : List E) :
    charge A (j₁ ++ j₂) = charge A j₁ + charge A j₂ := by sorry
-- Mutant: v1's merged-jump charge A · ‖Σ jumps‖, under which [v] ++ [-v] costs 0
-- but [v] and [-v] cost 2A‖v‖.

/-- Chattering costs twice a single jump: `[v, -v]` is charged 2·A·‖v‖, which is 0
    only when A = 0 or v = 0. -/
theorem charge_chatter (A : ENNReal) (v : E) :
    charge A [v, -v] = 2 * A * (‖v‖₊ : ENNReal) := by sorry
-- Mutant: v1's merged-jump charge, under which (v, -v) costs 0.

/-! ## 5. Policy lattice -/

variable {P : Type} [CompleteLattice P]   -- larger = stricter

/-- Expiry can only make the policy stricter. -/
theorem expiry_tightens (B : P) {a a' : Set P} (h : a' ⊆ a) :
    effective B a ≤ effective B a' := by sorry
-- Mutant: "revert to the most recent policy", which can land on a weaker one.

/-- The bridge: a stricter dial never admits more inputs. Dials are larger when
    stricter, and `threshold` turns a dial into the threshold the verdict reads. -/
theorem bridge {Inp : Type} (gradeOf : Inp → Grade ι) {dial₁ dial₂ : ι → ENNReal}
    (h : dial₁ ≤ dial₂) :
    {x | verdict (threshold dial₂) (gradeOf x) = .accept}
      ⊆ {x | verdict (threshold dial₁) (gradeOf x) = .accept} := by sorry
-- Mutant: a threshold dial stored un-inverted (`id` in place of `threshold`), so
-- "stricter" raises θ.

/-- For any weight and readings, and any nonnegative cap, JSG IV's capped fold never
    exceeds the cap, so its nightly check can never fail. This documents a defect, not
    a guarantee. -/
theorem fold_check_vacuous (Rmax lam : ℝ) (h : 0 ≤ Rmax) (rs : List ℝ) :
    fold Rmax lam rs ≤ Rmax := by sorry
-- Mutant: the uncapped fold, a plain weighted sum, whose nightly check can fail;
-- the cap is what makes the check vacuous.

/-! ## 6. Calibration -/

/-- Every failure class that leaves the must-fail set leaves in a signed step: in a
    history the gate accepts, if a class is in MF at step s and gone at step t, some
    step u between them removed it, and that removal was signed. -/
theorem mfGate_signed {C : Type} (signed : Set C → Prop) (MF : ℕ → Set C)
    (hg : ∀ t, mfGate signed (MF t) (MF (t + 1))) {s t : ℕ} (hst : s ≤ t) {c : C}
    (hs : c ∈ MF s) (ht : c ∉ MF t) :
    ∃ u, s ≤ u ∧ u < t ∧ c ∈ MF u \ MF (u + 1) ∧ signed (MF u \ MF (u + 1)) := by sorry
-- Mutant: a gate that accepts every change, run on Draft0–7's history, which dropped
-- GOLDEN_RULE_BREACH with nothing signed. That class sits outside the v1 gate
-- (decisions/RAILS.md); the history still breaks the gate's rule.

/-! ## 7. No-Zeno kernel (analysis layer, corrected form) -/

/-- If the signed distance moves no faster than `Smax`,
    going from `+r` to `-r` takes at least `2r / Smax`. -/
theorem dwell_lower_bound {d : ℝ → ℝ} {Smax r t₁ t₂ : ℝ} (hS : 0 < Smax)
    (hlip : ∀ s t, |d t - d s| ≤ Smax * |t - s|)
    (h₁ : d t₁ = r) (h₂ : d t₂ = -r) (ht : t₁ ≤ t₂) :
    2 * r / Smax ≤ t₂ - t₁ := by sorry
-- Mutant: JSG I's version, which assumes |ḋ| ≥ α at the frontier instead of a speed
-- bound; a trajectory with |ḋ| = 100α crosses far faster than the claimed τ_min.

/-! ## statements-v2

Sections 8 to 11 were added for `statements-v2` (guide/CHANGELOG.md); nothing above them
changed. -/

/-! ## 8. Leases (PDE I4b) -/

/-- Soundness for leased evidence: an axis over its threshold, or wider than its lease,
    rejects the whole grade. -/
theorem lease_sound (θ β : ι → ENNReal) (g : Grade ι) (i : ι)
    (hout : θ i < (g i).hi ∨ β i < (g i).width) : leaseVerdict θ β g = .reject := by sorry
-- Mutant: SirusSC's interval lift `QPrime`, whose one guard rejects ⊥
-- (`guard_no_bottom`) and which never reads a width: [0, 5] passes on an axis leased 1
-- under θ = 10. A gate that checks only widths, as PDE I4b's unknowns cap does on its
-- own, fails it too: it accepts [5, 5] under θ = 1.

/-- Completeness for leased evidence: if every axis is within both its threshold and its
    lease, the grade is accepted. -/
theorem lease_complete (θ β : ι → ENNReal) (g : Grade ι) (hlease : WithinLease β g)
    (hin : ∀ i, (g i).hi ≤ θ i) : leaseVerdict θ β g = .accept := by sorry
-- Mutant: SirusSC's `Q`, where an axis holds a value or ⊥ and every guard rejects ⊥
-- (`C_UNK_PRICED`). A reading wider than a point can only be ⊥ there, so [0, 1] leased 1
-- is rejected under θ = 1.

/-! ## 9. Typed obligations (JSG V §3) -/

variable {St O W : Type}

/-- Pass-soundness: split a passing window's run at any stage. Everything pending before
    that stage, or emitted by it, is cleared by that stage or a later one: a ticket by
    its own stage, and an obligation by its authority, with a witness of its type. -/
theorem pass_sound (θ β : ι → ENNReal) (M : DischargeMatrix St O W) (stages : Multiset St)
    (carried : Multiset O) (pre post : List (StageRun ι St O W)) (r : StageRun ι St O W)
    (hpass : Passes kind θ β M stages carried (pre ++ r :: post)) {p : Pending St O}
    (hp : p ∈ pendingAfter M (windowStart stages carried) pre + r.emits.map Pending.obl) :
    ∃ s ∈ r :: post, M.Clears s p := by sorry
-- Mutant: JSG V's displayed transition with its matrix, which lists PR or EF for
-- RetuneDisabledInRed and leaves the issuer check to a parenthetical: PR discharges one
-- that EF issued Stage-scoped, which only EF may discharge.

/-- Completeness: a window passes if its grade is within its thresholds and leases, and
    its last stage clears everything still pending, the obligations it emits included. -/
theorem pass_complete (θ β : ι → ENNReal) (M : DischargeMatrix St O W) (stages : Multiset St)
    (carried : Multiset O) (pre : List (StageRun ι St O W)) (r : StageRun ι St O W)
    (hgrade : leaseVerdict θ β (windowGrade kind (pre ++ [r])) = .accept)
    (hlast : ∀ p ∈ pendingAfter M (windowStart stages carried) pre + r.emits.map Pending.obl,
      M.Clears r p) :
    Passes kind θ β M stages carried (pre ++ [r]) := by sorry
-- Mutant: JSG V's I_Σ-Progress read as part of passing, as its CI check runs it on
-- passing runs, on JSG V's Σ, which holds obligations but no tickets: Σ must fall in the
-- Dershowitz–Manna order at every stage. A window's obligations start empty, which
-- can't fall, so no window passes.

/-! ## 10. A concrete Loader (SCp3 §3 and §6; JSG V §3) -/

variable {Bytes D : Type}

/-- Safety for the concrete Loader: every step preserves its invariant, L1–L10. With
    `LoaderStep.progress`, this makes it a `Loader`, so `Loader.safe` covers its runs. -/
theorem LoaderStep.inv_step (prims : Prims Bytes D) (M : DischargeMatrix St O W)
    (s t : LoaderState ι St O Bytes D) (hs : LoaderInv kind prims s)
    (h : LoaderStep kind prims M s t) : LoaderInv kind prims t := by sorry
-- Mutant: SCp3's T-Row, whose premises check I1–I5 and the budget but not I8, leaving it
-- to T-Accept: a row whose debit pushes round-off past ε_max is accepted, and L8 fails.
-- SirusSC's axis-leak check fails it too: an adapter missing from its declaration table
-- may write any axis, and L6 fails.

/-- Progress for the concrete Loader: every step lowers what is pending in the
    Dershowitz–Manna order. With `LoaderStep.inv_step`, this makes it a `Loader`, so when
    the order on obligations is well-founded, `Loader.terminates` rules out an infinite
    run. -/
theorem LoaderStep.progress [Preorder O] (prims : Prims Bytes D) (M : DischargeMatrix St O W)
    (s t : LoaderState ι St O Bytes D) (h : LoaderStep kind prims M s t) :
    Multiset.IsDershowitzMannaLT t.pending s.pending := by sorry
-- Mutant: JSG V's progress lemma in place of the ticket, which lets a stage run if it
-- discharges an obligation *or* emits only smaller ones: a stage that discharges
-- RequiresHitmap and emits OmegaPrecond, which ranks above it, raises what is pending.
-- SCp3's check rules fail it too, since T-AdapterAttest, T-AxisIsolation, T-AdapterMono
-- and T-Attest each step s ⇒ s.

/-! ## 11. Residual threading -/

/-- When θ is finite, threading it through any number of stages accepts exactly when
    their total is within θ. An overspent stage fails its own check, so the threading
    fails there, whatever the later stages spend. -/
theorem threads_spec (θ : ENNReal) (hθ : θ ≠ ⊤) (xs : List ENNReal) :
    Threads θ xs ↔ xs.sum ≤ θ := by sorry
-- Mutant: v1's residual check alone, which checks each later stage against what the
-- earlier ones left but not that they fit. Once stage one overspends, the residual
-- truncates to 0, which a stage of 0 still fits (θ = 1, stages 2 then 0).

end JSG
