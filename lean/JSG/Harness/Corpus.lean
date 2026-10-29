import JSG.Harness.Json

/-!
The differential tests' corpus (guide/EXECUTABLE_GATE.md §2). A vector is one call of one
twin with its inputs. An implementation answers each vector, and the oracle is the proved
twins themselves. Another implementation passes when it gives the oracle's answer on every
vector it supports.

The corpus has three parts:
1. **From the controls:** the witnesses and the mutants' counterexamples in
   `Tests/Mutants.lean`, as vectors.
2. **Exhaustive small vectors:** endpoints in {0, 1, 2, ∞}, thresholds and leases in
   {0, 1, ∞}, up to three axes, grouped by operation.
3. **Seeded random vectors:** grades of three to seven axes, and runs of up to six stages,
   with values such as 1/2 and 3/2, from a fixed seed.
-/

namespace JSG.Harness

open JSG Lean

instance : DecidableEq Kind := fun a b => by
  cases a <;> cases b
  · exact isTrue rfl
  · exact isFalse (by intro h; cases h)
  · exact isFalse (by intro h; cases h)
  · exact isTrue rfl

/-- Two bounds are equal when their ends are. -/
instance : DecidableEq XBound := fun a b =>
  if h : a.lo = b.lo ∧ a.hi = b.hi then
    isTrue (by cases a; cases b; simp only at h; obtain ⟨rfl, rfl⟩ := h; rfl)
  else isFalse (by rintro rfl; exact h ⟨rfl, rfl⟩)

/-- One call of one twin, with its inputs. A grade is a list, one bound per axis. -/
inductive Vec
  | known (x : WithTop ℚ≥0)
  | unknown
  | combine (kinds : List Kind) (g h : List XBound)
  | verdict (θ : List (WithTop ℚ≥0)) (g : List XBound)
  | lease (θ β : List (WithTop ℚ≥0)) (g : List XBound)
  | residual (θ x : WithTop ℚ≥0)
  | threads (θ : WithTop ℚ≥0) (xs : List (WithTop ℚ≥0))
  | width (b : XBound)

/-- An implementation's answer to a vector. -/
inductive Ans
  | bound (b : XBound)
  | grade (gs : List XBound)
  | decision (d : Decision)
  | value (v : WithTop ℚ≥0)
  | bool (b : Bool)
  deriving DecidableEq

/-- An implementation of the twinned definitions, over grades as lists. -/
structure Impl where
  known : WithTop ℚ≥0 → XBound
  unknown : XBound
  combine : List Kind → List XBound → List XBound → List XBound
  verdict : List (WithTop ℚ≥0) → List XBound → Decision
  lease : List (WithTop ℚ≥0) → List (WithTop ℚ≥0) → List XBound → Decision
  residual : WithTop ℚ≥0 → WithTop ℚ≥0 → WithTop ℚ≥0
  threads : WithTop ℚ≥0 → List (WithTop ℚ≥0) → Bool
  width : XBound → WithTop ℚ≥0

/-- An implementation's answer to a vector. -/
def Impl.answer (m : Impl) : Vec → Ans
  | .known x => .bound (m.known x)
  | .unknown => .bound m.unknown
  | .combine ks g h => .grade (m.combine ks g h)
  | .verdict θ g => .decision (m.verdict θ g)
  | .lease θ β g => .decision (m.lease θ β g)
  | .residual θ x => .value (m.residual θ x)
  | .threads θ xs => .bool (m.threads θ xs)
  | .width b => .value (m.width b)

/-- The oracle: the frozen twins, each called on a list grade as a grade over its positions.
    A missing threshold or lease is ∞. -/
def oracle : Impl where
  known := XBound.known
  unknown := XBound.unknown
  combine ks g h := List.ofFn (xcombine (fun i : Fin g.length => ks.getD i .floor)
    (fun i => g.get i) (fun i => h.getD i XBound.unknown))
  verdict θ g := xverdict (fun i : Fin g.length => θ.getD i ⊤) (fun i => g.get i)
  lease θ β g := xleaseVerdict (fun i : Fin g.length => θ.getD i ⊤) (fun i => β.getD i ⊤)
    (fun i => g.get i)
  residual := xresidual
  threads := xthreads
  width := XBound.width

/-- Whether an implementation's answer to a vector differs from the oracle's. -/
def disagrees (m : Impl) (v : Vec) : Bool := m.answer v != oracle.answer v

/-- A bound with its ends in either order. -/
def mkB (a b : WithTop ℚ≥0) : XBound :=
  if h : a ≤ b then ⟨a, b, h⟩ else ⟨b, a, le_of_lt (lt_of_not_ge h)⟩

/-- A known value, as a bound. -/
def kb (x : WithTop ℚ≥0) : XBound := XBound.known x

/-! ### Part 1: from the controls -/

/-- The witnesses and mutant counterexamples of `Tests/Mutants.lean`, as vectors. -/
def controls : List Vec :=
  [ -- combine_comm, combine_assoc and the two interchange mutants
    .combine [.budget] [kb 0] [kb 1], .combine [.budget] [kb 1] [kb 0],
    .combine [.budget] [kb 1] [kb 2], .combine [.budget] [kb 1] [kb 1],
    .combine [.floor] [kb 1] [kb 1],
    -- verdict_sound, its witness, and verdict_complete
    .verdict [0] [XBound.unknown], .verdict [1] [kb 2], .verdict [10] [mkB 5 ⊤],
    .verdict [0] [kb 0], .verdict [1] [kb 1],
    -- residual_spec and threads_spec
    .residual 1 1, .residual 1 0, .threads 1 [2, 0], .threads 10 [3, 4],
    -- lease_sound and lease_complete
    .lease [10] [1] [mkB 0 5], .lease [1] [0] [kb 5], .lease [1] [1] [mkB 0 1],
    -- statements-v4's controls
    .known 1, .known ⊤, .unknown, .combine [.floor] [XBound.unknown] [kb 1],
    .verdict [1] [XBound.unknown], .width (kb ⊤) ]

/-! ### Part 2: exhaustive small vectors -/

/-- Endpoints. -/
def vals : List (WithTop ℚ≥0) := [0, 1, 2, ⊤]

/-- Thresholds and leases. -/
def caps : List (WithTop ℚ≥0) := [0, 1, ⊤]

/-- Every bound with endpoints in `vals`: ten of them. -/
def bounds : List XBound :=
  vals.flatMap fun lo => vals.filterMap fun hi => if h : lo ≤ hi then some ⟨lo, hi, h⟩ else none

def kinds : List Kind := [.floor, .budget]

/-- Four bounds for the two-axis combinations. -/
def small : List XBound := [kb 0, kb 1, XBound.unknown, mkB 1 2]

/-- Six bounds for the three-axis verdicts. -/
def six : List XBound := [kb 0, kb 1, mkB 0 1, XBound.unknown, kb ⊤, mkB 2 ⊤]

def exKnown : List Vec := vals.map .known ++ [.unknown]

def exWidth : List Vec := bounds.map .width

def exResidual : List Vec := vals.flatMap fun t => vals.map fun x => .residual t x

/-- Every run of up to two stages, under every budget. -/
def exThreads : List Vec :=
  vals.flatMap fun t => ([[]] ++ (vals.map fun x => [x]) ++
    (vals.flatMap fun x => vals.map fun y => [x, y])).map fun xs => .threads t xs

/-- One axis of each kind, and two axes of different kinds in either order. -/
def exCombine : List Vec :=
  (kinds.flatMap fun k => bounds.flatMap fun a => bounds.map fun b => .combine [k] [a] [b]) ++
  ([[Kind.floor, .budget], [.budget, .floor]].flatMap fun ks =>
    small.flatMap fun a => small.flatMap fun b => small.flatMap fun c => small.map fun d =>
      .combine ks [a, b] [c, d])

/-- One and two axes under every threshold, and three axes under a shared one. -/
def exVerdict : List Vec :=
  (caps.flatMap fun t => bounds.map fun a => .verdict [t] [a]) ++
  (caps.flatMap fun t => caps.flatMap fun u => bounds.flatMap fun a => bounds.map fun b =>
    .verdict [t, u] [a, b]) ++
  (caps.flatMap fun t => six.flatMap fun a => six.flatMap fun b => six.map fun c =>
    .verdict [t, t, t] [a, b, c])

/-- One axis under every threshold and lease, and two under a shared pair. -/
def exLease : List Vec :=
  (caps.flatMap fun t => caps.flatMap fun l => bounds.map fun a => .lease [t] [l] [a]) ++
  (caps.flatMap fun t => caps.flatMap fun l => bounds.flatMap fun a => bounds.map fun b =>
    .lease [t, t] [l, l] [a, b])

def exhaustive : List Vec :=
  exKnown ++ exWidth ++ exResidual ++ exThreads ++ exCombine ++ exVerdict ++ exLease

/-! ### Part 3: seeded random vectors -/

/-- A 64-bit linear congruential generator, so the random part is the same everywhere. -/
def lcg (s : ℕ) : ℕ := (s * 6364136223846793005 + 1442695040888963407) % 2 ^ 64

abbrev Rand := StateM ℕ

/-- A number below n, from the generator's high bits. -/
def draw (n : ℕ) : Rand ℕ := modifyGet fun s => let s' := lcg s; ((s' / 2 ^ 33) % n, s')

def rvals : List (WithTop ℚ≥0) :=
  [0, ((1 / 2 : ℚ≥0) : WithTop ℚ≥0), 1, ((3 / 2 : ℚ≥0) : WithTop ℚ≥0), 2, 3, 5, ⊤]

def rval : Rand (WithTop ℚ≥0) := do return rvals.getD (← draw rvals.length) ⊤

def rbound : Rand XBound := do return mkB (← rval) (← rval)

def rlist {α : Type} (n : ℕ) (x : Rand α) : Rand (List α) := (List.range n).mapM fun _ => x

def rvec : Rand Vec := do
  match ← draw 5 with
  | 0 =>
    let n := 3 + (← draw 5)
    return .combine (← rlist n do return kinds.getD (← draw 2) .floor) (← rlist n rbound)
      (← rlist n rbound)
  | 1 =>
    let n := 3 + (← draw 5)
    return .verdict (← rlist n rval) (← rlist n rbound)
  | 2 =>
    let n := 3 + (← draw 5)
    return .lease (← rlist n rval) (← rlist n rval) (← rlist n rbound)
  | 3 => return .threads (← rval) (← rlist (← draw 7) rval)
  | _ => return .residual (← rval) (← rval)

/-- 400 vectors from the seed 2026. -/
def random : List Vec := ((List.range 400).mapM fun _ => rvec).run' 2026

/-- The whole corpus, each vector with the part it comes from. -/
def corpus : List (String × Vec) :=
  controls.map ("controls", ·) ++ exhaustive.map ("exhaustive", ·) ++ random.map ("random", ·)

/-! ### JSON -/

def gradeToJson (g : List XBound) : Json := Json.arr (g.toArray.map boundToJson)

def valsToJson (l : List (WithTop ℚ≥0)) : Json := Json.arr (l.toArray.map valToJson)

def vecToJson : Vec → Json
  | .known x => Json.mkObj [("op", .str "known"), ("x", valToJson x)]
  | .unknown => Json.mkObj [("op", .str "unknown")]
  | .combine ks g h => Json.mkObj [("op", .str "combine"),
      ("kinds", Json.arr (ks.toArray.map kindToJson)), ("g", gradeToJson g),
      ("h", gradeToJson h)]
  | .verdict θ g => Json.mkObj [("op", .str "verdict"), ("thresholds", valsToJson θ),
      ("grade", gradeToJson g)]
  | .lease θ β g => Json.mkObj [("op", .str "lease"), ("thresholds", valsToJson θ),
      ("leases", valsToJson β), ("grade", gradeToJson g)]
  | .residual θ x => Json.mkObj [("op", .str "residual"), ("theta", valToJson θ),
      ("x", valToJson x)]
  | .threads θ xs => Json.mkObj [("op", .str "threads"), ("theta", valToJson θ),
      ("stages", valsToJson xs)]
  | .width b => Json.mkObj [("op", .str "width"), ("bound", boundToJson b)]

def listOf {α : Type} (f : Json → Except String α) (j : Json) : Except String (List α) := do
  return (← arrOfJson f j).toList

def vecOfJson (j : Json) : Except String Vec := do
  let field (k : String) := j.getObjVal? k
  match ← (← field "op").getStr? with
  | "known" => return .known (← valOfJson (← field "x"))
  | "unknown" => return .unknown
  | "combine" =>
    return (.combine (← listOf kindOfJson (← field "kinds"))
      (← listOf boundOfJson (← field "g")) (← listOf boundOfJson (← field "h")))
  | "verdict" =>
    return (.verdict (← listOf valOfJson (← field "thresholds"))
      (← listOf boundOfJson (← field "grade")))
  | "lease" =>
    return (.lease (← listOf valOfJson (← field "thresholds"))
      (← listOf valOfJson (← field "leases")) (← listOf boundOfJson (← field "grade")))
  | "residual" => return .residual (← valOfJson (← field "theta")) (← valOfJson (← field "x"))
  | "threads" =>
    return (.threads (← valOfJson (← field "theta")) (← listOf valOfJson (← field "stages")))
  | "width" => return .width (← boundOfJson (← field "bound"))
  | op => throw s!"unknown op: {op}"

def ansToJson : Ans → Json
  | .bound b => boundToJson b
  | .grade g => gradeToJson g
  | .decision d => decisionToJson d
  | .value v => valToJson v
  | .bool b => Json.bool b

/-- Reads an answer, of the type the vector's operation gives. -/
def ansOfJson (v : Vec) (j : Json) : Except String Ans :=
  match v with
  | .known _ | .unknown => return .bound (← boundOfJson j)
  | .combine .. => return .grade (← listOf boundOfJson j)
  | .verdict .. | .lease .. => return .decision (← decisionOfJson j)
  | .residual .. | .width _ => return .value (← valOfJson j)
  | .threads .. => return .bool (← j.getBool?)

/-- The `corpus` command's output: every vector, numbered, with its part and the oracle's
    answer. -/
def corpusJson : Json :=
  Json.mkObj [("vectors", Json.arr ((List.range corpus.length).zip corpus |>.toArray.map
    fun (i, part, v) => Json.mkObj [("id", toJson i), ("part", .str part),
      ("vector", vecToJson v), ("answer", ansToJson (oracle.answer v))]))]

/-- Reads the numbered entries of a corpus or an answer file: `{"answers": […]}`, or the
    corpus's own `{"vectors": […]}`, whose answers are the oracle's. -/
def entries (j : Json) : Except String (Array Json) :=
  match j.getObjVal? "answers" with
  | .ok a => a.getArr?
  | .error _ => do (← j.getObjVal? "vectors").getArr?

/-- The `diff` command: recomputes the oracle's answer to every vector in the corpus,
    compares each answer the other file gives (`null` means unsupported, and is skipped), and
    lists the vectors where they differ. Without a model, the flag says whether there were
    none. With one, it also lists the answered vectors where the model differs from the
    oracle, and the flag says whether the two lists are the same. -/
def diffJson (corpusJ answersJ : Json) (model : Option Impl := none) :
    Except String (Json × Bool) := do
  let vecs ← (← entries corpusJ).mapM fun e => do
    return ((← (← e.getObjVal? "id").getNat?), ← vecOfJson (← e.getObjVal? "vector"))
  let mut compared := 0
  let mut skipped := 0
  let mut differ : Array Nat := #[]
  let mut expected : Array Nat := #[]
  for e in ← entries answersJ do
    let id ← (← e.getObjVal? "id").getNat?
    let some (_, v) := (vecs[id]?.filter (·.1 = id)).orElse fun _ => vecs.find? (·.1 = id)
      | throw s!"no vector {id} in the corpus"
    match e.getObjVal? "answer" with
    | .ok .null | .error _ => skipped := skipped + 1
    | .ok a =>
      compared := compared + 1
      if (← ansOfJson v a) != oracle.answer v then differ := differ.push id
      if let some m := model then
        if disagrees m v then expected := expected.push id
  let base := [("vectors", toJson vecs.size), ("compared", toJson compared),
    ("skipped", toJson skipped), ("disagreementCount", toJson differ.size),
    ("disagreements", Json.arr (differ.map fun i => toJson i))]
  match model with
  | none => return (Json.mkObj base, differ.isEmpty)
  | some _ =>
    let same := differ == expected
    return (Json.mkObj (base ++ [("expectedCount", toJson expected.size),
      ("expected", Json.arr (expected.map fun i => toJson i)), ("asExpected", Json.bool same)]),
      same)

end JSG.Harness
