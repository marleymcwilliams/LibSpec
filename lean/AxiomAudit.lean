import JSG.Solution
import JSG.Tests.Smoke
import JSG.Tests.Mutants
import JSG.Tests.Calibration

/-!
Axiom audit, run by `scripts/check.sh`.
The script fails if anything audited here depends on an axiom other than `propext`,
`Classical.choice` or `Quot.sound` (including `sorryAx`).
- Proofs: list every closed theorem by name. Statements still proved by `sorry` stay
  off this list until their milestone.
- Controls: `#audit_module` audits every theorem a test module declares, so a mutant,
  witness or calibration added later is covered without being listed. It fails if the
  module isn't imported or declares no theorem, so a renamed module can't pass empty.

It imports the proofs (`JSG.Solution`) rather than `JSG`: each proof restates its
theorem under the frozen name, so the proofs and `JSG.Statements` can't be imported
together. The test modules import only `JSG.Defs`, so they can sit beside the proofs.
-/

open Lean in
/-- Prints `#print axioms`, in the same format, for every theorem module `m` declares. -/
elab "#audit_module " m:ident : command => do
  let env ← getEnv
  let some idx := env.getModuleIdx? m.getId
    | throwError "#audit_module: {m.getId} is not imported"
  let some data := env.header.moduleData[idx]?
    | throwError "#audit_module: no module data for {m.getId}"
  let thms := data.constants.filterMap fun
    | .thmInfo t => if t.name.isInternal then none else some t.name
    | _ => none
  if thms.isEmpty then
    throwError "#audit_module: {m.getId} declares no theorems"
  for n in thms do
    let axioms ← collectAxioms n
    if axioms.isEmpty then
      logInfo m!"'{n}' does not depend on any axioms"
    else
      logInfo m!"'{n}' depends on axioms: {axioms.qsort Name.lt |>.map MessageData.ofConstName |>.toList}"

#print axioms JSG.Tests.smoke
#print axioms JSG.combine_comm

#audit_module JSG.Tests.Mutants
#audit_module JSG.Tests.Calibration
