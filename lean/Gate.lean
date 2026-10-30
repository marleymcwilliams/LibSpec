import JSG.Harness.Main
import JSG.Pilot.Words

/-!
The executable gate's harness (guide/EXECUTABLE_GATE.md §1). Run it from `lean/`:

    lake env lean --run Gate.lean report FILE
    lake env lean --run Gate.lean pilot
    lake env lean --run Gate.lean pilot catalogue

It runs `lake env lean --run`, the way `ComparatorTargets.lean` runs, so it needs no
executable target in `lakefile.toml`, which the statements check covers. Its commands live
in `JSG.Harness.Main`, and the pilot's report in `JSG.Pilot.Words`, where the axiom audit
and the token scan reach them.
-/

def main (args : List String) : IO UInt32 :=
  match args with
  | ["pilot"] => do
    IO.print JSG.Pilot.firstReport
    pure 0
  | ["pilot", "catalogue"] => do
    IO.print JSG.Pilot.catalogueReport
    pure 0
  | _ => JSG.Harness.run args
