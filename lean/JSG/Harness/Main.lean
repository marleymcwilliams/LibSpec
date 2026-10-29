import JSG.Harness.Mutants

/-!
The harness's commands, which `lean/Gate.lean` runs:

    lake env lean --run Gate.lean report FILE
    lake env lean --run Gate.lean corpus
    lake env lean --run Gate.lean diff CORPUS ANSWERS [--expect sirus]

Each reads JSON from its files, or from standard input for a file named `-`, calls the proved
twins, and writes JSON to standard output. They parse, call and print, and hold no logic of their
own (guide/EXECUTABLE_GATE.md §1).
-/

namespace JSG.Harness

open Lean

def usage : String :=
  "usage: lake env lean --run Gate.lean COMMAND\n" ++
  "  report FILE           the verdict and report on one grade under one policy\n" ++
  "  corpus                every test vector, with the oracle's answer\n" ++
  "  diff CORPUS ANSWERS   where ANSWERS differs from the oracle; exit 1 if anywhere\n" ++
  "    --expect sirus      exit 1 unless it differs exactly where SirusSC's model does"

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

/-- Reads and parses a JSON file, or standard input for `-`. -/
def readJson (path : String) : IO (Except String Json) := do
  return Json.parse (← readInput path)

def run (args : List String) : IO UInt32 := do
  match args with
  | ["report", path] => runJson path reportJson
  | ["corpus"] =>
    IO.println corpusJson.compress
    pure 0
  | "diff" :: c :: a :: rest =>
    let model ← match rest with
      | [] => pure none
      | ["--expect", "sirus"] => pure (some sirusModel)
      | _ =>
        IO.eprintln usage
        return 2
    let cj ← readJson c
    let aj ← readJson a
    match (do diffJson (← cj) (← aj) model) with
    | .ok (out, ok) =>
      IO.println out.compress
      pure (if ok then 0 else 1)
    | .error e =>
      IO.eprintln s!"Gate.lean: {e}"
      pure 2
  | _ =>
    IO.eprintln usage
    pure 2

end JSG.Harness
