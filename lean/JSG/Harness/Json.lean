import JSG.Harness.Report
import Lean.Data.Json

/-!
JSON for the harness: reading and writing exact values, bounds, axis kinds and decisions,
and the `report` command's input and output. Parsing and printing are tested, not proved
(guide/EXECUTABLE_GATE.md §1).

A value is a string, so it stays exact: `"inf"` for ∞, `"3"`, or `"3/4"`. A bound is
`{"lo": …, "hi": …}`, the string `"unknown"` for [0, ∞], or a single value for a known point.
-/

namespace JSG.Harness

open JSG Lean

/-- A value as the harness writes it: `"inf"`, or a rational in lowest terms. -/
def valToString : WithTop ℚ≥0 → String
  | ⊤ => "inf"
  | (q : ℚ≥0) => if q.den = 1 then toString q.num else s!"{q.num}/{q.den}"

/-- Reads a value written as `"inf"`, a natural number, or `"p/q"` with q positive. -/
def valOfString (s : String) : Except String (WithTop ℚ≥0) :=
  if s = "inf" then pure ⊤ else
  match s.splitOn "/" with
  | [p] => match p.toNat? with
    | some p => pure ((p : ℚ≥0) : WithTop ℚ≥0)
    | none => throw s!"not a value: {s}"
  | [p, q] => match p.toNat?, q.toNat? with
    | some p, some (q + 1) => pure (((p : ℚ≥0) / ((q + 1 : ℕ) : ℚ≥0) : ℚ≥0) : WithTop ℚ≥0)
    | _, _ => throw s!"not a value: {s}"
  | _ => throw s!"not a value: {s}"

def valToJson (v : WithTop ℚ≥0) : Json := .str (valToString v)

/-- Reads a value from a JSON string, or from a JSON natural number. -/
def valOfJson (j : Json) : Except String (WithTop ℚ≥0) :=
  match j with
  | .str s => valOfString s
  | _ => match j.getNat? with
    | .ok n => pure ((n : ℚ≥0) : WithTop ℚ≥0)
    | .error _ => throw s!"not a value: {j.compress}"

def boundToJson (b : XBound) : Json := Json.mkObj [("lo", valToJson b.lo), ("hi", valToJson b.hi)]

/-- Reads a bound: `{"lo": …, "hi": …}` with lo ≤ hi, `"unknown"`, or a single value. -/
def boundOfJson (j : Json) : Except String XBound := do
  match j with
  | .str "unknown" => pure XBound.unknown
  | .obj _ =>
    let lo ← valOfJson (← j.getObjVal? "lo")
    let hi ← valOfJson (← j.getObjVal? "hi")
    if h : lo ≤ hi then pure ⟨lo, hi, h⟩
    else throw s!"a bound's lo must not exceed its hi: {j.compress}"
  | _ => pure (XBound.known (← valOfJson j))

def kindToJson : Kind → Json
  | .floor => .str "floor"
  | .budget => .str "budget"

def kindOfJson (j : Json) : Except String Kind :=
  match j with
  | .str "floor" => pure .floor
  | .str "budget" => pure .budget
  | _ => throw s!"not a kind (floor or budget): {j.compress}"

def decisionToJson : Decision → Json
  | .accept => .str "accept"
  | .reject => .str "reject"

def decisionOfJson (j : Json) : Except String Decision :=
  match j with
  | .str "accept" => pure .accept
  | .str "reject" => pure .reject
  | _ => throw s!"not a decision (accept or reject): {j.compress}"

/-- Reads a JSON array with a reader for its entries. -/
def arrOfJson {α : Type} (f : Json → Except String α) (j : Json) : Except String (Array α) := do
  (← j.getArr?).mapM f

/-- The words a report uses for each reason. -/
def Reason.words : Reason → String
  | .unknown => "unknown"
  | .overThreshold => "above its threshold"
  | .overLease => "wider than its lease"

/-- The `report` command: reads `{"axes": […], "grade": […], "thresholds": […]}`, with an
    optional `"leases": […]` (every lease ∞ when it's missing), and writes the verdict, the
    report in words, and each axis outside the gate with its reason. -/
def reportJson (input : Json) : Except String Json := do
  let g ← arrOfJson boundOfJson (← input.getObjVal? "grade")
  let n := g.size
  let θs ← arrOfJson valOfJson (← input.getObjVal? "thresholds")
  let βs ← match input.getObjVal? "leases" with
    | .ok j => arrOfJson valOfJson j
    | .error _ => pure (Array.replicate n ⊤)
  let names ← match input.getObjVal? "axes" with
    | .ok j => arrOfJson (fun j => j.getStr?) j
    | .error _ => pure ((Array.range n).map fun i => s!"axis {i + 1}")
  unless θs.size = n ∧ βs.size = n ∧ names.size = n do
    throw s!"the grade has {n} axes, but there are {θs.size} thresholds, {βs.size} leases \
      and {names.size} axis names"
  let θ : Fin n → WithTop ℚ≥0 := fun i => θs.getD i ⊤
  let β : Fin n → WithTop ℚ≥0 := fun i => βs.getD i ⊤
  let grade : XGrade (Fin n) := fun i => g[i]
  let d := xleaseVerdict θ β grade
  let outside := report θ β grade
  let name (i : Fin n) : String := names.getD i s!"axis {i.val + 1}"
  let words := match d with
    | .accept => "accepted: every axis is within its threshold and its lease"
    | .reject => "not accepted: evidence incomplete on " ++
        ", ".intercalate (outside.map fun (i, r) => s!"{name i} ({r.words})")
  pure <| Json.mkObj [("verdict", decisionToJson d), ("report", .str words),
    ("outside", Json.arr (outside.toArray.map fun (i, r) =>
      Json.mkObj [("axis", .str (name i)), ("reason", .str r.words)]))]

end JSG.Harness
