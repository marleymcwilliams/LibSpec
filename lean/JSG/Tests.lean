import JSG.Tests.Smoke
import JSG.Tests.Mutants
import JSG.Tests.Calibration
import JSG.Tests.ConcreteLoader
import JSG.Tests.Differential

/-!
Root of the test modules, for the axiom audit (`lean/AxiomAudit.lean`). Import every
file in `JSG/Tests/` here, except the Comparator fixtures in `JSG/Tests/Comparator/`,
which contain `sorry` by design. The audit fails if a test file on disk isn't imported.
-/
