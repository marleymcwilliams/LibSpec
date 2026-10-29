#!/usr/bin/env bash
# The executable gate's differential tests (guide/EXECUTABLE_GATE.md §2), after `lake build`:
#   1. the harness's golden examples, under the report command;
#   2. the corpus against its own answers, which round-trips every vector and answer
#      through the JSON and checks them against the twins;
#   3. SirusSC's code, which must disagree with the oracle exactly where its known defects
#      predict (`sirusModel`): the harness's own control.
# The negative controls, each mutant caught by the corpus, are theorems in
# lean/JSG/Tests/Differential.lean, so `lake build` already checked them.
# Runs locally (Git Bash on Windows, with PYTHON=python) and in CI. Exits non-zero on any
# failure.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
lean_dir="$root/lean"
python="${PYTHON:-python3}"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

step() { printf '\n== %s\n' "$1"; }
gate() { (cd "$lean_dir" && lake env lean --run Gate.lean "$@"); }

step "Golden examples (the report command)"
for input in "$lean_dir"/JSG/Harness/examples/*.json; do
  case "$input" in *.expected.json) continue ;; esac
  expected="${input%.json}.expected.json"
  gate report "$input" > "$work/out.json"
  "$python" - "$work/out.json" "$expected" <<'PY'
import json, sys
got, want = (json.load(open(p, encoding="utf-8")) for p in sys.argv[1:])
if got != want:
    sys.exit(f"FAIL: {sys.argv[2]}: got {json.dumps(got)}")
PY
  echo "ok: $(basename "$input")"
done

step "Corpus"
gate corpus > "$work/corpus.json"
"$python" -c 'import json, sys; print(len(json.load(open(sys.argv[1]))["vectors"]), "vectors")' \
  "$work/corpus.json"

step "The corpus against its own answers"
gate diff "$work/corpus.json" "$work/corpus.json"

step "SirusSC: disagreements exactly where its known defects predict"
"$python" "$root/scripts/sirusc_adapter.py" "$work/corpus.json" > "$work/sirusc.json"
gate diff "$work/corpus.json" "$work/sirusc.json" --expect sirus

echo
echo "differential.sh: passed"
