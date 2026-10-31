import JSG.Pilot.Calibration
import JSG.Pilot.CatalogueCalibration

/-!
The pilot's report in words (QUEUE.md, Q12): "not accepted: evidence incomplete on …", never
"rejected", since the verdict is about the evidence, not the mathematics. `firstReport` is
the first report, on the sample and the synthetic records, which `Gate.lean pilot` prints,
and `catalogueReport` the report on the whole release, which `Gate.lean pilot catalogue`
prints.
-/

namespace JSG.Pilot

open JSG

/-- Why a challenge's run leaves `formal_proof` unknown, in words. -/
def RunResult.why : RunResult → String
  | .buildError => "its build failed or was stopped"
  | .tooLarge => "too large to check yet"
  | .kernelsDisagree => "the kernels disagree: nanoda failed while Lean's kernel accepted"
  | _ => "no trusted Comparator result yet"

/-- Why an axis is above its threshold, in words, given the manuscript's raw record and the
    names of the manuscripts it rests on. An unknown `formal_proof` names why each of its
    challenges that isn't accepted leaves it unknown. -/
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
      else "unknown: " ++ "; ".intercalate
        ((r.challenges.filter (·.result ≠ RunResult.accepted)).map (·.result.why)).eraseDups
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

/-! ### The report on the whole release -/

/-- Each distinct string in a list, with how often it occurs, in order of first occurrence. -/
def tally (xs : List String) : List (String × ℕ) :=
  xs.foldl (fun acc x =>
    if acc.any (·.1 == x) then acc.map fun (y, k) => (y, if y == x then k + 1 else k)
    else acc ++ [(x, 1)]) []

/-- "1 manuscript", "2 manuscripts". -/
def manuscripts (k : ℕ) : String :=
  if k = 1 then "1 manuscript" else s!"{k} manuscripts"

/-- The report on every manuscript of the release, as Markdown: what's missing on each axis,
    the distinct reports, each manuscript's, and the folders that aren't graded. -/
def catalogueReport : String :=
  let R := Catalogue.release
  let name := Catalogue.title
  let ms := List.finRange Catalogue.size
  let reports := tally (ms.map (reportWords R name))
  let number (m : Fin Catalogue.size) : ℕ :=
    reports.findIdx (·.1 == reportWords R name m) + 1
  let byAxis := Axis.all.filterMap fun a =>
    let whys := ms.filterMap fun m =>
      ((R.report m).find? (·.1 == a)).map fun (_, w) => whyWords name (R.raw m) a w
    let counts := (tally whys).map fun (w, k) => s!"{w}: {k}"
    if whys.isEmpty then none
    else some s!"| `{a.name}` | {whys.length} | {"; ".intercalate counts} |"
  let reportList := reports.mapIdx fun i (w, k) => s!"{i + 1}. **{manuscripts k}:** {w}"
  let key (m : Fin Catalogue.size) : String := (Catalogue.family m).getD "" ++ " " ++ name m
  let rows := (ms.mergeSort fun a b => !decide (key b < key a)).map fun m =>
    s!"| {(Catalogue.family m).getD "—"} | {name m} | {(R.raw m).challenges.length} | " ++
      s!"{number m} |"
  let earlier := Catalogue.earlierVersions.map fun (f, ls) => s!"| {f} | {", ".intercalate ls} |"
  let links := Catalogue.docsLinks.map fun (f, e) =>
    s!"- `{f}`: its family's docs page links `{e}`, an earlier version with the same title, " ++
      "so the page's challenges count for the listed one. A named reviewer still has to " ++
      "check their statements against it."
  let listed := Catalogue.size - Catalogue.withdrawn.length
  "\n".intercalate (
    ["# The pilot's report on the release", "",
     s!"openai/math at `7ef5c0c`, θ = 0 on every axis, no leases. It grades " ++
       s!"{Catalogue.size} manuscripts: the {listed} that `CONTENTS.md` lists, and the " ++
       s!"{Catalogue.withdrawn.length} withdrawn ones it no longer lists. Every verdict is " ++
       "proved by the kernel (`JSG.Pilot.CatalogueCalibration`): none is accepted today, so " ++
       "each report says what evidence is missing.", "",
     Catalogue.comparatorNote, "",
     "## What's missing, by axis", "",
     "A report names every axis that holds its manuscript back, so a manuscript counts under " ++
       "each one.", "",
     "| Axis | Manuscripts | Why, and how many |", "| --- | --- | --- |"] ++ byAxis ++
    ["", "## The reports", "", "Every manuscript's report is one of these.", ""] ++
      reportList ++
    ["", "## Every manuscript", "",
     "By family. The withdrawn ones, which `CONTENTS.md` no longer lists, come first. " ++
       "Challenges counts the Comparator challenges on the family's docs page that cover it.",
     "",
     "| Family | Manuscript | Challenges | Report |", "| --- | --- | --- | --- |"] ++ rows ++
    ["", "## Not graded", "",
     s!"{Catalogue.earlierVersions.length} folders under `preprints/` are earlier versions of " ++
       "listed manuscripts: the same title, with an earlier date. They aren't graded.", "",
     "| Earlier version | Listed as |", "| --- | --- |"] ++ earlier ++
    ["", "## Notes", ""] ++ links) ++ "\n"

end JSG.Pilot
