import JSG.Harness.Report
import JSG.Harness.Json
import JSG.Harness.Corpus
import JSG.Harness.Mutants
import JSG.Harness.Main

/-!
Root of the executable gate's harness (guide/EXECUTABLE_GATE.md §1 and §2), for the axiom
audit (`lean/AxiomAudit.lean`). Import every file in `JSG/Harness/` here. The audit fails if
a harness module on disk isn't imported. Harness modules import only `JSG.Defs`, never
`JSG.Statements`, so they can sit beside the proofs.
-/
