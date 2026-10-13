#!/usr/bin/env bash
# Comparator: each theorem in lean/JSG/Proofs/ must prove exactly its frozen
# statement in JSG.Statements, using only propext, Quot.sound and Classical.choice.
# A self-test runs first: its correct solution must pass, and its mutant (a weaker
# statement under the frozen name) must be rejected for that reason.
# Needs comparator, lean4export and landrun on PATH (scripts/build-comparator-tools.sh).
# Linux only.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
lean_dir="$root/lean"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

step() { printf '\n== %s\n' "$1"; }

# targets <root module> <module prefix>: theorems declared in modules under the prefix.
targets() { (cd "$lean_dir" && lake env lean --run ComparatorTargets.lean "$1" "$2"); }

# write_config <file> <challenge> <solution> <theorem>...
# definition_names stays empty, so every definition a statement uses is compared in full.
write_config() {
  python3 - "$@" <<'PY'
import json, sys
path, challenge, solution, *names = sys.argv[1:]
with open(path, "w") as f:
    json.dump({"challenge_module": challenge, "solution_module": solution,
               "theorem_names": names, "definition_names": [],
               "permitted_axioms": ["propext", "Quot.sound", "Classical.choice"]}, f, indent=2)
PY
}

run_comparator() { (cd "$lean_dir" && lake env comparator "$1"); }

step "Self-test: the correct solution must pass"
mapfile -t self < <(targets JSG.Tests.Comparator.Solution JSG.Tests.Comparator.Solution)
if [ "${#self[@]}" -eq 0 ]; then echo "FAIL: the self-test solution has no theorems"; exit 1; fi
write_config "$work/self.json" JSG.Tests.Comparator.Challenge JSG.Tests.Comparator.Solution "${self[@]}"
run_comparator "$work/self.json"

step "Self-test: the mutant must be rejected"
write_config "$work/mutant.json" JSG.Tests.Comparator.Challenge JSG.Tests.Comparator.Mutant "${self[@]}"
if out="$(run_comparator "$work/mutant.json" 2>&1)"; then
  printf '%s\n' "$out"
  echo "FAIL: Comparator accepted the mutant"
  exit 1
fi
if ! printf '%s\n' "$out" | grep -q 'theorem statement do not match'; then
  printf '%s\n' "$out"
  echo "FAIL: the mutant was rejected, but not for its statement"
  exit 1
fi
echo "ok: rejected because its statement differs from the challenge"

step "Proofs against the frozen statements"
mapfile -t proved < <(targets JSG.Solution JSG.Proofs)
if [ "${#proved[@]}" -eq 0 ]; then
  echo "skipped: no theorems in lean/JSG/Proofs/ yet"
else
  write_config "$work/jsg.json" JSG.Statements JSG.Solution "${proved[@]}"
  run_comparator "$work/jsg.json"
fi

step "Frozen theorems not yet proved"
mapfile -t frozen < <(targets JSG.Statements JSG.Statements)
missing=()
for t in "${frozen[@]}"; do
  if ! printf '%s\n' "${proved[@]}" | grep -qxF -- "$t"; then missing+=("$t"); fi
done
if [ "${#missing[@]}" -eq 0 ]; then echo "none"; else printf '  %s\n' "${missing[@]}"; fi
