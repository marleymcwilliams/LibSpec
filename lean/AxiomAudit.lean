import JSG.Solution
import JSG.Tests
import JSG.Harness
import JSG.Pilot

/-!
Axiom audit, run by `scripts/check.sh`.
The script fails if anything audited here depends on an axiom other than `propext`,
`Classical.choice` or `Quot.sound` (including `sorryAx`).

`#audit_sweep` audits every theorem in every module it finds on disk under
`JSG/Proofs/`, `JSG/Lemmas/`, `JSG/Tests/`, `JSG/Harness/` and `JSG/Pilot/`, so a new
proof, lemma, test, harness or pilot module is audited without anyone editing this file. It
leaves out the Comparator fixtures in `JSG/Tests/Comparator/`, which contain `sorry` by
design. It reaches the modules through four roots: `JSG.Solution`, which imports every
proof file (and so the lemmas they use), `JSG.Tests`, which imports every test file,
`JSG.Harness`, which imports every harness file, and `JSG.Pilot`, which imports every pilot
file. It fails, and this file doesn't compile, if
- a module on disk isn't imported through those roots;
- a proof, lemma or test module declares no theorem;
- it finds no proof module or no test module;
- a theorem named after it wasn't among those it audited.

A harness or pilot module holds the executable gate's code or data, so it may declare no
theorem. Every theorem it does declare is audited like the rest.

The by-name list from before the sweep stays, and the sweep must cover it; it can go
once you're satisfied that it does.

It imports the proofs (`JSG.Solution`) rather than `JSG`: each proof restates its
theorem under the frozen name, so the proofs and `JSG.Statements` can't be imported
together. The test modules import only `JSG.Defs`, so they can sit beside the proofs.
-/

open Lean Elab Command

/-- The module a file under `base` holds: `JSG/Tests/Mutants.lean` holds
    `JSG.Tests.Mutants`. -/
def auditModuleName (base file : System.FilePath) : Name :=
  ((file.withExtension "").components.drop base.components.length).foldl Name.mkStr .anonymous

/-- The modules on disk under `base/JSG/dir`, sorted, skipping directories named `skip`. -/
def auditModulesOnDisk (base : System.FilePath) (dir : String) (skip : Option String := none) :
    IO (Array Name) := do
  let root := base / "JSG" / dir
  unless ← root.isDir do return #[]
  let files ← root.walkDir (enter := fun d => pure (d.fileName != skip))
  return files.filter (·.extension == some "lean") |>.map (auditModuleName base)
    |>.qsort Name.lt

/-- Prints `#print axioms`, in the same format, for every theorem module `m` declares, and
    returns their names. Fails if `m` isn't imported, or if it declares no theorem and
    `requireTheorems` is set. -/
def auditModule (m : Name) (requireTheorems : Bool := true) : CommandElabM (Array Name) := do
  let env ← getEnv
  let some idx := env.getModuleIdx? m
    | throwError "axiom audit: {m} is not imported"
  let some data := env.header.moduleData[idx]?
    | throwError "axiom audit: no module data for {m}"
  let thms := data.constants.filterMap fun
    | .thmInfo t => if t.name.isInternal then none else some t.name
    | _ => none
  if thms.isEmpty && requireTheorems then
    throwError "axiom audit: {m} declares no theorems"
  for n in thms do
    let axioms ← collectAxioms n
    if axioms.isEmpty then
      logInfo m!"'{n}' does not depend on any axioms"
    else
      logInfo m!"'{n}' depends on axioms: {axioms.qsort Name.lt |>.map MessageData.ofConstName |>.toList}"
  return thms

/-- Audits every theorem in every proof, lemma, test, harness and pilot module on disk (see
    the module docstring). Each name after it must be among the audited theorems. -/
elab "#audit_sweep" required:ident* : command => do
  let base := (System.FilePath.mk (← getFileName)).parent.getD "."
  let proofs ← auditModulesOnDisk base "Proofs"
  let lemmas ← auditModulesOnDisk base "Lemmas"
  let tests ← auditModulesOnDisk base "Tests" (skip := some "Comparator")
  let harness ← auditModulesOnDisk base "Harness"
  let pilot ← auditModulesOnDisk base "Pilot"
  if proofs.isEmpty then
    throwError "axiom audit: no proof module under {base / "JSG" / "Proofs"}"
  if tests.isEmpty then
    throwError "axiom audit: no test module under {base / "JSG" / "Tests"}"
  let env ← getEnv
  let root (m : Name) : String :=
    if (`JSG.Tests).isPrefixOf m then "lean/JSG/Tests.lean"
    else if (`JSG.Harness).isPrefixOf m then "lean/JSG/Harness.lean"
    else if (`JSG.Pilot).isPrefixOf m then "lean/JSG/Pilot.lean"
    else "lean/JSG/Solution.lean"
  let unreached := (proofs ++ lemmas ++ tests ++ harness ++ pilot).filter fun m =>
    (env.getModuleIdx? m).isNone
  unless unreached.isEmpty do
    throwError m!"axiom audit: these modules are on disk but not imported, so they would \
      go unaudited: {unreached.toList.map fun m => s!"{m} (import it from {root m})"}"
  let mut audited : NameSet := {}
  let mut count : Nat := 0
  for m in proofs ++ lemmas ++ tests do
    for n in ← auditModule m do
      audited := audited.insert n
      count := count + 1
  for m in harness ++ pilot do
    for n in ← auditModule m (requireTheorems := false) do
      audited := audited.insert n
      count := count + 1
  for r in required do
    unless audited.contains r.getId do
      throwError "axiom audit: {r.getId} wasn't among the audited theorems"
  let swept := proofs ++ lemmas ++ tests ++ harness ++ pilot
  logInfo m!"axiom audit: {count} theorems in {swept.size} modules"

#print axioms JSG.Tests.smoke
#print axioms JSG.combine_comm

#audit_sweep JSG.Tests.smoke JSG.combine_comm
