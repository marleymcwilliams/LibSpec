import Lean

/-!
Prints the theorems a Comparator config must list, one per line, sorted.
Run by `scripts/comparator.sh`:

    lake env lean --run ComparatorTargets.lean <RootModule> <ModulePrefix>

It imports `<RootModule>` and prints every theorem declared in a module whose name
starts with `<ModulePrefix>`. Internal names and the theorems Lean generates on
demand (equation lemmas, `ext`, `injEq`, induction principles) are skipped, so a
proof file that unfolds a definition doesn't add a target the challenge lacks.
-/

open Lean

/-- Last name components that Lean generates for definitions and structures. -/
def generatedSuffixes : List String :=
  ["eq_def", "eq_unfold", "induct", "induct_unfolding", "mutual_induct", "fun_cases",
   "ext", "ext_iff", "inj", "injEq", "sizeOf_spec", "congr_simp"]

def isGenerated (n : Name) : Bool :=
  match n with
  | .str _ s => generatedSuffixes.contains s || (s.startsWith "eq_" && (s.drop 3).all Char.isDigit)
  | _ => false

def main (args : List String) : IO UInt32 := do
  let [rootArg, prefixArg] := args
    | IO.eprintln "usage: lake env lean --run ComparatorTargets.lean <RootModule> <ModulePrefix>"
      return 2
  let root := rootArg.toName
  let pre := prefixArg.toName
  initSearchPath (← findSysroot)
  let env ← importModules #[{ module := root }] {}
  let modules := env.header.moduleNames
  let mut found : Array String := #[]
  for (name, info) in env.constants.map₁.toList do
    if let .thmInfo _ := info then
      if !name.isInternal && !isGenerated name then
        if let some idx := env.getModuleIdxFor? name then
          if let some mod := modules[idx.toNat]? then
            if pre.isPrefixOf mod then
              found := found.push name.toString
  for n in found.qsort (· < ·) do
    IO.println n
  return 0
