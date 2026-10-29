import JSG.Harness.Main

/-!
The executable gate's harness (guide/EXECUTABLE_GATE.md §1). Run it from `lean/`:

    lake env lean --run Gate.lean report FILE

It runs `lake env lean --run`, the way `ComparatorTargets.lean` runs, so it needs no
executable target in `lakefile.toml`, which the statements check covers. Its commands live
in `JSG.Harness.Main`, where the axiom audit and the token scan reach them.
-/

def main (args : List String) : IO UInt32 := JSG.Harness.run args
