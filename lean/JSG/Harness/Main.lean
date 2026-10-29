import JSG.Harness.Json

/-!
The harness's commands, which `lean/Gate.lean` runs:

    lake env lean --run Gate.lean report FILE

Each reads JSON from FILE, or from standard input when FILE is `-`, calls the proved twins,
and writes JSON to standard output. They parse, call and print, and hold no logic of their
own (guide/EXECUTABLE_GATE.md §1).
-/

namespace JSG.Harness

open Lean

def usage : String :=
  "usage: lake env lean --run Gate.lean report FILE\n" ++
  "  report FILE   the verdict and report on one grade under one policy"

/-- Reads FILE, or standard input when FILE is `-`. -/
def readInput (path : String) : IO String :=
  if path = "-" then do (← IO.getStdin).readToEnd else IO.FS.readFile path

/-- Parses the input as JSON, applies `f`, and prints the result, or the error on standard
    error with exit code 1. -/
def runJson (path : String) (f : Json → Except String Json) : IO UInt32 := do
  let text ← readInput path
  match Json.parse text >>= f with
  | .ok out =>
    IO.println out.pretty
    pure 0
  | .error e =>
    IO.eprintln s!"Gate.lean: {e}"
    pure 1

def run (args : List String) : IO UInt32 := do
  match args with
  | ["report", path] => runJson path reportJson
  | _ =>
    IO.eprintln usage
    pure 2

end JSG.Harness
