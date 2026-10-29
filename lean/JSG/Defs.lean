import Mathlib

/-!
Definitions for the frozen statements in `JSG.Statements` (core v2, from the master
guide's Lean stubs). The proofs import this module too, so Comparator sees the same
definitions on both sides.
-/

namespace JSG

/-! ## 1. Graded values -/

/-- Floors carry per-window rates (combine by max);
    budgets carry cumulative spends (combine by +). -/
inductive Kind | floor | budget

/-- An axis value is an interval in [0, ∞]; the verdict reads `hi`. -/
@[ext] structure Bound where
  lo : ENNReal
  hi : ENNReal
  le : lo ≤ hi

def Bound.known (x : ENNReal) : Bound := ⟨x, x, le_rfl⟩
def Bound.unknown : Bound := ⟨0, ⊤, le_top⟩

def combineAxis : Kind → Bound → Bound → Bound
  | .floor,  a, b => ⟨max a.lo b.lo, max a.hi b.hi, max_le_max a.le b.le⟩
  | .budget, a, b => ⟨a.lo + b.lo, a.hi + b.hi, add_le_add a.le b.le⟩

variable {ι : Type} (kind : ι → Kind)

abbrev Grade (ι : Type) := ι → Bound

def combine (g h : Grade ι) : Grade ι := fun i => combineAxis (kind i) (g i) (h i)

/-- Sequential composition. Core v2 makes it `combine`; naming it separately lets
    JSG V's rule be stated as a mutant of `interchange` (QUEUE.md, Q1). -/
def seqComp (g h : Grade ι) : Grade ι := combine kind g h

/-- Parallel composition, also `combine` in core v2. -/
def parComp (g h : Grade ι) : Grade ι := combine kind g h

/-- Interchange for a pair of composition operators: two pipelines run side by side
    grade the same as their stages run side by side, one stage after another. -/
def Interchange (seq par : Grade ι → Grade ι → Grade ι) : Prop :=
  ∀ a b c d, par (seq a b) (seq c d) = seq (par a c) (par b d)

/-! ## 2. Verdicts and residuals -/

inductive Decision | reject | accept
  deriving DecidableEq

/-- Accept iff every upper bound is within its threshold. -/
noncomputable def verdict (θ : ι → ENNReal) (g : Grade ι) : Decision := by
  classical
  exact if ∀ i, (g i).hi ≤ θ i then .accept else .reject

/-- Budget left for later stages; ENNReal subtraction truncates at 0. -/
def residual (θ x : ENNReal) : ENNReal := θ - x

/-- Raw evidence plus free-form metrics such as confidence scores. -/
structure Evidence (E : Type) where
  record  : E
  metrics : List (String × Float)

/-- No confidence inflation, stated where it can fail: an obligation on every grader. -/
def Noninterfering {E : Type} (gradeOf : Evidence E → Grade ι) : Prop :=
  ∀ r m m', gradeOf ⟨r, m⟩ = gradeOf ⟨r, m'⟩
-- Mutant: a grader that narrows `hi` when a confidence metric is high.

/-! ## 3. Loader: safety and progress, kept separate -/

structure Loader (S O : Type) [Preorder O] where
  step     : S → S → Prop
  Inv      : S → Prop                                  -- L1–L10
  inv_step : ∀ s t, Inv s → step s t → Inv t
  pending  : S → Multiset O
  progress : ∀ s t, step s t → Multiset.IsDershowitzMannaLT (pending t) (pending s)

/-! ## 4. Frontier charge -/

variable {E : Type} [NormedAddCommGroup E]

/-- Total variation: charge every jump at the finest resolution. -/
noncomputable def charge (A : ENNReal) (jumps : List E) : ENNReal :=
  A * (jumps.map (fun v => (‖v‖₊ : ENNReal))).sum

/-! ## 5. Policy lattice -/

variable {P : Type} [CompleteLattice P]   -- larger = stricter

/-- Baseline met with the weakenings active now. -/
def effective (B : P) (active : Set P) : P := B ⊓ sInf active

/-- A threshold dial is larger when stricter, so it stores the inverse of the threshold
    the verdict reads: dial 0 means no limit (θ = ⊤), and dial ⊤ means θ = 0. -/
noncomputable def threshold (dial : ι → ENNReal) : ι → ENNReal := fun i => (dial i)⁻¹

/-- JSG IV's fold, kept to document its defect: the nightly check cannot fail. -/
def fold (Rmax lam : ℝ) (rs : List ℝ) : ℝ :=
  rs.foldl (fun x y => min Rmax (x + lam * y)) 0

/-! ## 6. Calibration -/

/-- Accept every must-pass input, reject every must-fail input, sets disjoint. -/
def Calibrated {Inp : Type} (gate : Inp → Decision) (MP MF : Set Inp) : Prop :=
  Disjoint MP MF ∧ (∀ x ∈ MP, gate x = .accept) ∧ (∀ x ∈ MF, gate x = .reject)
-- Mutant: the always-REJECT gate fails this as soon as MP is nonempty.

/-- The CI gate on must-fail sets: a new version keeps every failure class
    unless the removal is signed, that is, made in a new statements version with a
    CHANGELOG line marking the weakening. Must-fail classes are hard floors:
    runtime weakenings can't remove them. -/
def mfGate {C : Type} (signed : Set C → Prop) (old new : Set C) : Prop :=
  old ⊆ new ∨ signed (old \ new)

/-! ## statements-v2

Sections 8 to 11 were added for `statements-v2` (guide/CHANGELOG.md); nothing above them
changed. -/

/-! ## 8. Leases (PDE I4b) -/

/-- An interval's width: how much of the axis is still unknown. An unknown, [0, ∞], has
    width ∞, and a point has width 0. -/
def Bound.width (b : Bound) : ENNReal := b.hi - b.lo

/-- PDE I4b's lease, read on intervals: every axis is known to within its lease β. An
    axis wider than its lease is a breach. -/
def WithinLease (β : ι → ENNReal) (g : Grade ι) : Prop := ∀ i, (g i).width ≤ β i

/-- The verdict with PDE I4b's lease check: accept iff every axis is within both its
    threshold and its lease. -/
noncomputable def leaseVerdict (θ β : ι → ENNReal) (g : Grade ι) : Decision := by
  classical
  exact if ∀ i, (g i).hi ≤ θ i ∧ (g i).width ≤ β i then .accept else .reject

/-! ## 9. Typed obligations (JSG V §3) -/

variable {St O W : Type}

/-- JSG V's published discharge matrix. Each obligation has an authority, the one stage
    that may discharge it (for a Stage-scoped obligation, its issuer), and a witness type
    W(o), read as a check on the witness a stage produces. -/
structure DischargeMatrix (St O W : Type) where
  authority : O → St
  witness   : O → W → Prop

/-- One stage's part in a window: the stage, the grade it adds, the obligations it emits,
    and its witness. -/
structure StageRun (ι St O W : Type) where
  stage : St
  grade : Grade ι
  emits : Multiset O
  wit   : W

/-- A stage discharges `o` when it is `o`'s authority and its witness has type W(o). -/
def DischargeMatrix.Discharges (M : DischargeMatrix St O W) (r : StageRun ι St O W)
    (o : O) : Prop :=
  M.authority o = r.stage ∧ M.witness o r.wit

/-- An item a window has pending: a stage's ticket, issued at boot and cleared when that
    stage runs, or an obligation. -/
inductive Pending (St O : Type)
  | ticket (s : St)
  | obl (o : O)

/-- A pending item's rank: every ticket ranks above every obligation, and obligations
    rank as they do in JSG V's type order. -/
def Pending.rank : Pending St O → WithTop O
  | .ticket _ => ⊤
  | .obl o => (o : WithTop O)

/-- Pending items are ordered by rank. -/
instance [Preorder O] : Preorder (Pending St O) := Preorder.lift Pending.rank

/-- What a stage clears when it runs: its own ticket, and every obligation it
    discharges. -/
def DischargeMatrix.Clears (M : DischargeMatrix St O W) (r : StageRun ι St O W) :
    Pending St O → Prop
  | .ticket s => s = r.stage
  | .obl o => M.Discharges r o

/-- JSG V's stage transition: add the obligations the stage emits, then remove everything
    it clears. -/
noncomputable def afterStage (M : DischargeMatrix St O W) (pend : Multiset (Pending St O))
    (r : StageRun ι St O W) : Multiset (Pending St O) := by
  classical
  exact (pend + r.emits.map Pending.obl).filter (fun p => ¬ M.Clears r p)

/-- What is still pending after a run of stages, from what was pending at its start. -/
noncomputable def pendingAfter (M : DischargeMatrix St O W) (pend₀ : Multiset (Pending St O))
    (run : List (StageRun ι St O W)) : Multiset (Pending St O) :=
  run.foldl (afterStage M) pend₀

/-- What a window has pending at its start: a ticket for each of its stages, and the
    obligations carried in. -/
def windowStart (stages : Multiset St) (carried : Multiset O) : Multiset (Pending St O) :=
  stages.map Pending.ticket + carried.map Pending.obl

/-- A window's grade: its stages' grades combined in sequence, from the known 0. -/
def windowGrade (run : List (StageRun ι St O W)) : Grade ι :=
  run.foldl (fun g r => seqComp kind g r.grade) (fun _ => Bound.known 0)

/-- JSG V's verdict on a window (§3), with PDE I4b's leases: it passes iff its grade is
    within its thresholds and leases, every one of its stages has run, and no obligation
    is left. -/
def Passes (θ β : ι → ENNReal) (M : DischargeMatrix St O W) (stages : Multiset St)
    (carried : Multiset O) (run : List (StageRun ι St O W)) : Prop :=
  leaseVerdict θ β (windowGrade kind run) = .accept ∧
    pendingAfter M (windowStart stages carried) run = 0

/-! ## 10. A concrete Loader (SCp3 §3 and §6; JSG V §3) -/

variable {Bytes D : Type}

/-- The primitives SCp3's checks call, abstracted: a canonical digest (BLAKE3-256 over
    canon/v1 bytes), signature verification in the pinned identity graph, re-execution
    under a ReplayPlan, and a receipt bundle's Merkle root. -/
structure Prims (Bytes D : Type) where
  digest : Bytes → D
  sigOK  : Bytes → Prop
  replay : Bytes → Bytes → Bytes
  root   : List Bytes → D

/-- What T-Boot pins for a run (SCp3 §6.3 and §7). No step changes it. -/
structure Boot (ι St Bytes D : Type) where
  raw        : Bytes                      -- L1: the raw data and its pinned digest
  rawDigest  : D
  configCert : Bytes                      -- L2: the ConfigCert
  envLock    : Bytes                      -- L3: the EnvLock suite and its pinned digest
  envDigest  : D
  replayPlan : Bytes                      -- L4: the ReplayPlan, a probe and its output
  probe      : Bytes
  probeOut   : Bytes
  seed       : D                          -- L5: the run seed and the seeds already used
  ledger     : List D
  declared   : St → Set ι                 -- L6: the axes each stage's adapter declared
  adapter    : St → List Bytes → Grade ι  -- L7: each stage's adapter, from rows to a grade
  epsMax     : ENNReal                    -- L8: the cap on accumulated round-off
  budget     : ι → ENNReal                -- L9: the budgets B, per axis
  stages     : Multiset St                -- the stages the run has, each issued a ticket

/-- A Loader state (SCp3 Definition 6.1, cut down): the boot record, the acceptance grade
    q, the round-off so far, the (stage, axis) pairs written so far, the receipt bundle
    with the root recorded for it, and what is pending. -/
structure LoaderState (ι St O Bytes D : Type) where
  boot    : Boot ι St Bytes D
  q       : Grade ι
  eps     : ENNReal
  written : Set (St × ι)
  bundle  : List Bytes
  root    : D
  pending : Multiset (Pending St O)

variable (prims : Prims Bytes D)

/-- The state T-Boot leaves: nothing graded, no round-off, nothing written, an empty
    bundle with its root, and pending a ticket for each stage it pinned and the
    obligations carried in. -/
def bootState (b : Boot ι St Bytes D) (carried : Multiset O) : LoaderState ι St O Bytes D :=
  ⟨b, fun _ => Bound.known 0, 0, ∅, [], prims.root [], windowStart b.stages carried⟩

/-- L1, SCp3's I1 RAW_DIGEST_MATCH: the raw data hashes to its pinned digest. -/
def L1 (s : LoaderState ι St O Bytes D) : Prop := prims.digest s.boot.raw = s.boot.rawDigest

/-- L2, I2 CONFIG_CERT_VALID: the ConfigCert's signatures verify. -/
def L2 (s : LoaderState ι St O Bytes D) : Prop := prims.sigOK s.boot.configCert

/-- L3, I3 ENVLOCK_PINNED: the EnvLock suite matches its pinned digest. -/
def L3 (s : LoaderState ι St O Bytes D) : Prop :=
  prims.digest s.boot.envLock = s.boot.envDigest

/-- L4, I4 REPLAY_PLAN_VALID: re-executing the probe under the ReplayPlan reproduces its
    output. -/
def L4 (s : LoaderState ι St O Bytes D) : Prop :=
  prims.replay s.boot.replayPlan s.boot.probe = s.boot.probeOut

/-- L5, I5 SEED_IS_FRESH: the run seed hasn't been used before. -/
def L5 (s : LoaderState ι St O Bytes D) : Prop := s.boot.seed ∉ s.boot.ledger

/-- L6, I6 AXIS_ISOLATION: every axis written so far was declared by the stage that
    wrote it. -/
def L6 (s : LoaderState ι St O Bytes D) : Prop := ∀ p ∈ s.written, p.2 ∈ s.boot.declared p.1

/-- L7, I7 ADAPTER_MONOTONE, its homomorphism half: adapting two batches of rows together
    grades the same as combining their grades. -/
def L7 (s : LoaderState ι St O Bytes D) : Prop :=
  ∀ st x y, s.boot.adapter st (x ++ y) = combine kind (s.boot.adapter st x) (s.boot.adapter st y)

/-- L8, I8 ROUNDING_GUARD: the round-off accumulated so far is within its cap. -/
def L8 (s : LoaderState ι St O Bytes D) : Prop := s.eps ≤ s.boot.epsMax

/-- L9, I9 FRONTIER_BUDGET: every axis's upper bound is within its budget. -/
def L9 (s : LoaderState ι St O Bytes D) : Prop := ∀ i, (s.q i).hi ≤ s.boot.budget i

/-- L10, I10 AUDIT_BUNDLE_COMPLETE: the receipt bundle's Merkle root is the one recorded. -/
def L10 (s : LoaderState ι St O Bytes D) : Prop := prims.root s.bundle = s.root

/-- The Loader's invariant: L1–L10, SCp3's ten baseline checks, all pass. -/
def LoaderInv (s : LoaderState ι St O Bytes D) : Prop :=
  L1 prims s ∧ L2 prims s ∧ L3 prims s ∧ L4 prims s ∧ L5 s ∧ L6 s ∧ L7 kind s ∧ L8 s ∧ L9 s ∧
    L10 prims s

/-- One step of the concrete Loader: a stage runs (JSG V §3), guarded fail-closed as in
    SCp3 §6.3, so a step whose premises fail isn't enabled and the run stops there. A run
    starts from `bootState`, and a stage runs on its ticket, so at most once. The step
    appends the stage's receipt and records the bundle's new root. -/
inductive LoaderStep (M : DischargeMatrix St O W) :
    LoaderState ι St O Bytes D → LoaderState ι St O Bytes D → Prop
  | stage (s : LoaderState ι St O Bytes D) (r : StageRun ι St O W) (rows : List Bytes)
      (ε : ENNReal) (receipt : Bytes)
      -- the stage's adapter prices its rows (T-Row)
      (hprice : r.grade = s.boot.adapter r.stage rows)
      -- it writes only axes its adapter declared (I6)
      (hiso : ∀ i, r.grade i ≠ Bound.known 0 → i ∈ s.boot.declared r.stage)
      -- round-off stays within its cap (I8)
      (hround : s.eps + ε ≤ s.boot.epsMax)
      -- the new grade stays within the budgets (T-Row, I9)
      (hbudget : ∀ i, (combine kind s.q r.grade i).hi ≤ s.boot.budget i)
      -- its ticket is still pending: it hasn't run yet
      (hticket : Pending.ticket r.stage ∈ s.pending) :
      LoaderStep M s
        { s with
          q := combine kind s.q r.grade
          eps := s.eps + ε
          written := s.written ∪ {p | p.1 = r.stage ∧ r.grade p.2 ≠ Bound.known 0}
          bundle := s.bundle ++ [receipt]
          root := prims.root (s.bundle ++ [receipt])
          pending := afterStage M s.pending r }

/-! ## 11. Residual threading -/

/-- Thread a budget θ through stages, in order: each stage must fit within what the
    earlier ones left. An overspent stage fails its own check, so the 0 that `residual`
    truncates to never decides the outcome (QUEUE.md, Q5). -/
def Threads : ENNReal → List ENNReal → Prop
  | _, [] => True
  | θ, x :: xs => x ≤ θ ∧ Threads (residual θ x) xs

/-! ## statements-v3

Sections 12 to 14 were added for `statements-v3` (guide/CHANGELOG.md); nothing above them
changed. -/

open MeasureTheory

/-! ## 12. CVaR (PDE §9) -/

variable {Ω : Type} [MeasurableSpace Ω]

/-- Conditional value-at-risk at tail mass α, in Rockafellar–Uryasev form: the infimum, over
    levels t, of t + E[(X − t)₊]/α. For a probability measure and α in (0, 1) it is the mean
    of X over its worst α of mass, which PDE §9 writes CVaR₁₋α. The loss is nonnegative, so
    it and its CVaR lie in [0, ∞]. -/
noncomputable def cvar (μ : Measure Ω) (α : ENNReal) (X : Ω → ENNReal) : ENNReal :=
  ⨅ t : ENNReal, t + (∫⁻ ω, (X ω - t) ∂μ) / α

/-! ## 13. Exponential families (JSG I, Theorem 2) -/

variable {V : Type} [NormedAddCommGroup V] [InnerProductSpace ℝ V]

/-- JSG I's exponential family through P₀ = μ, for a dictionary of statistics T valued in V:
    P_θ has density proportional to exp⟪θ, T⟫ with respect to μ. -/
noncomputable def expFamily (μ : Measure Ω) (T : Ω → V) (θ : V) : Measure Ω :=
  μ.tilted fun ω => inner ℝ θ (T ω)

/-- Its log-partition function, ψ(θ) = log E_μ[exp⟪θ, T⟫]. Its gradient is the mixed
    cumulants κ(θ) = E_{P_θ}[T], and its Hessian is the Fisher information. -/
noncomputable def logPartition (μ : Measure Ω) (T : Ω → V) (θ : V) : ℝ :=
  Real.log (∫ ω, Real.exp (inner ℝ θ (T ω)) ∂μ)

/-! ## 14. Dual values (JSG II, ρ-sensitivity) -/

/-- A dual value at radius ρ: the infimum, over multipliers η in S, of the bounds ηρ + g(η).
    JSG II's KL dual is this with S = (0, ∞) and g(η) = η log E_P[exp(ℓ/η)]; its smoothed
    Wasserstein dual takes S = [0, ∞) and g(η) = E_P[φ̃_η]. -/
noncomputable def dualValue (S : Set ℝ) (g : ℝ → ℝ) (ρ : ℝ) : ℝ :=
  ⨅ η : S, (η : ℝ) * ρ + g η

/-! ## statements-v4

Section 15 was added for `statements-v4` (guide/CHANGELOG.md); nothing above it changed. -/

/-! ## 15. Executable twins (guide/EXECUTABLE_GATE.md §1) -/

/-- An exact value's place in [0, ∞]: ∞ stays ∞, and each nonnegative rational is itself.
    The twins below compute in `WithTop ℚ≥0`, whose order and arithmetic are decidable;
    this cast is how each one is compared with its frozen definition. -/
noncomputable def xcast (x : WithTop ℚ≥0) : ENNReal := WithTop.map (fun q : ℚ≥0 => (q : NNReal)) x

/-- The executable twin of `Bound`: an interval in [0, ∞] with exact ends. -/
structure XBound where
  lo : WithTop ℚ≥0
  hi : WithTop ℚ≥0
  le : lo ≤ hi

/-- The bound a twin stands for: both ends cast into `ENNReal`. -/
noncomputable def XBound.toBound (b : XBound) : Bound :=
  ⟨xcast b.lo, xcast b.hi, (WithTop.map_le_iff _ NNRat.cast_le).2 b.le⟩

/-- The twin of `Bound.known`. -/
def XBound.known (x : WithTop ℚ≥0) : XBound := ⟨x, x, le_rfl⟩

/-- The twin of `Bound.unknown`. -/
def XBound.unknown : XBound := ⟨0, ⊤, le_top⟩

/-- The twin of `combineAxis`: max on floors, + on budgets. -/
def xcombineAxis : Kind → XBound → XBound → XBound
  | .floor,  a, b => ⟨max a.lo b.lo, max a.hi b.hi, max_le_max a.le b.le⟩
  | .budget, a, b => ⟨a.lo + b.lo, a.hi + b.hi, add_le_add a.le b.le⟩

/-- The twin of `Grade`. -/
abbrev XGrade (ι : Type) := ι → XBound

/-- The grade a twin stands for, axis by axis. -/
noncomputable def XGrade.toGrade (g : XGrade ι) : Grade ι := fun i => (g i).toBound

/-- The twin of `combine`. Core v2 makes `seqComp` and `parComp` both `combine`, so this is
    their twin too. -/
def xcombine (g h : XGrade ι) : XGrade ι := fun i => xcombineAxis (kind i) (g i) (h i)

/-- The twin of `verdict`, for finitely many axes, which it checks one by one. -/
def xverdict [Fintype ι] (θ : ι → WithTop ℚ≥0) (g : XGrade ι) : Decision :=
  if ∀ i, (g i).hi ≤ θ i then .accept else .reject

/-- The twin of `residual`. Subtraction in `WithTop ℚ≥0` truncates at 0, as in `ENNReal`. -/
def xresidual (θ x : WithTop ℚ≥0) : WithTop ℚ≥0 := θ - x

/-- The twin of `Threads`: a test that returns `true` when the budget threads through the
    stages. -/
def xthreads : WithTop ℚ≥0 → List (WithTop ℚ≥0) → Bool
  | _, [] => true
  | θ, x :: xs => decide (x ≤ θ) && xthreads (xresidual θ x) xs

/-- The twin of `Bound.width`. -/
def XBound.width (b : XBound) : WithTop ℚ≥0 := b.hi - b.lo

/-- The twin of `leaseVerdict`, for finitely many axes. -/
def xleaseVerdict [Fintype ι] (θ β : ι → WithTop ℚ≥0) (g : XGrade ι) : Decision :=
  if ∀ i, (g i).hi ≤ θ i ∧ (g i).width ≤ β i then .accept else .reject

end JSG
