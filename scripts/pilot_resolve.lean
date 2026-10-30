import Lean

/-!
Prints where Lean resolves each module named on the command line, the way lean4export resolves
the modules it exports: `initSearchPath (← findSysroot)`, so LEAN_PATH first and the toolchain's
own library after it, then `findOLean`. Phase 7's trusted job checks that the exports resolve
Mathlib, its dependencies and Lean's core to the trusted copies (scripts/pilot_shard.py
resolution). Run it with `lean --run scripts/pilot_resolve.lean MODULE...`.

`--path P` puts P where LEAN_PATH goes, for a run with LEAN_PATH unset. The self-test uses it for
a planted path, through which the resolver's own `import Lean` would load the planted Init.
-/

open Lean in
def main (args : List String) : IO Unit := do
  let sp : System.SearchPath := match args with
    | "--path" :: p :: _ => System.SearchPath.parse p
    | _ => []
  let mods := match args with
    | "--path" :: _ :: mods => mods
    | mods => mods
  initSearchPath (← findSysroot) sp
  for m in mods do
    IO.println s!"resolves: {m} {← findOLean m.toName}"
