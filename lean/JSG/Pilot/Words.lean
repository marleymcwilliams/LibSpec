import JSG.Pilot.Calibration

/-!
The pilot's report in words (QUEUE.md, Q12): "not accepted: evidence incomplete on …", never
"rejected", since the verdict is about the evidence, not the mathematics. `firstReport` is
the first report, on the sample and the synthetic records, which `Gate.lean pilot` prints.
-/

namespace JSG.Pilot

open JSG

/-- Why an axis is above its threshold, in words, given the manuscript's raw record and the
    names of the manuscripts it rests on. -/
def whyWords {n : ℕ} (name : Fin n → String) (r : Raw) (a : Axis) : Why n → String
  | .through d => s!"through {name d}"
  | .evidence => match a with
    | .withdrawn => s!"its authors withdrew it on {r.withdrawnOn.getD "an unrecorded date"}"
    | .formalProof => "Comparator rejected its formalization"
    | .axioms => "its challenge permits an axiom beyond the three"
    | _ => "its evidence fails"
  | .unknown => match a with
    | .dependencyWithdrawn => "unknown: its dependencies aren't read yet"
    | .formalProof =>
      if r.challenges.isEmpty then "unknown: no formalization"
      else "unknown: no trusted Comparator result yet"
    | .statementFidelity => "unknown: no named reviewer has checked its statement"
    | .axioms => "unknown: no challenge"
    | _ => "unknown"

/-- A manuscript's report in words. It is "accepted" exactly when the verdict accepts
    (`report_eq_nil`). -/
def reportWords {n : ℕ} (R : Release n) (name : Fin n → String) (m : Fin n) : String :=
  match R.report m with
  | [] => "accepted: every axis is known to be within its threshold"
  | items => "not accepted: evidence incomplete on " ++ ", ".intercalate
      (items.map fun (a, w) => s!"`{a.name}` ({whyWords name (R.raw m) a w})")

/-- The first report, as Markdown. -/
def firstReport : String :=
  let sample := (List.finRange Sample.size).map fun m =>
    let fam := (Sample.family m).getD "—"
    s!"| {Sample.title m} | {fam} | {reportWords Sample.release Sample.title m} |"
  let synth := (List.finRange Synthetic.size).map fun m =>
    let set := if m ∈ Synthetic.mustPass then "must-pass"
      else if m ∈ Synthetic.mustFail then "must-fail" else "support"
    s!"| {Synthetic.name m} | {set} | {reportWords Synthetic.release Synthetic.name m} |"
  "\n".intercalate (
    ["# The pilot's first report", "",
     "openai/math at `7ef5c0c`, θ = 0 on every axis, no leases. Every verdict below is " ++
       "proved by the kernel (`JSG.Pilot.Calibration`).", "",
     "## The sample", "", Sample.comparatorNote, "",
     "| Manuscript | Family | Report |", "| --- | --- | --- |"] ++ sample ++
    ["", "## The synthetic records", "",
     "| Record | Set | Report |", "| --- | --- | --- |"] ++ synth) ++ "\n"

end JSG.Pilot
