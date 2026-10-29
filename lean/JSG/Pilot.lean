import JSG.Pilot.Core
import JSG.Pilot.Sample
import JSG.Pilot.Calibration
import JSG.Pilot.Words

/-!
Root of the executable gate's pilot (guide/EXECUTABLE_GATE.md §3), for the axiom audit
(`lean/AxiomAudit.lean`). Import every file in `JSG/Pilot/` here. The audit fails if a pilot
module on disk isn't imported. Pilot modules import only `JSG.Defs` and the harness, never
`JSG.Statements`, so they can sit beside the proofs.
-/
