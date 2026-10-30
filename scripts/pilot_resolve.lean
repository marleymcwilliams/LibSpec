import Lean

/-!
Prints where Lean resolves each module named on the command line, the way lean4export resolves
the modules it exports: `initSearchPath (← findSysroot)`, so LEAN_PATH first and the toolchain's
own library after it, then `findOLean`. Phase 7's trusted job checks that the exports resolve
Mathlib, its dependencies and Lean's core to the trusted copies (scripts/pilot_shard.py
resolution). Run it with `lean --run scripts/pilot_resolve.lean MODULE...`.
-/

open Lean in
def main (mods : List String) : IO Unit := do
  initSearchPath (← findSysroot)
  for m in mods do
    IO.println s!"resolves: {m} {← findOLean m.toName}"
