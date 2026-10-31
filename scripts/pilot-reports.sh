#!/usr/bin/env bash
# Checks that the pilot's committed reports are what Gate.lean prints from their data now
# (guide/EXECUTABLE_GATE.md §3): pilot/reports/first-sample.md from JSG.Pilot.Sample and the
# synthetic records, and pilot/reports/catalogue.md from JSG.Pilot.Catalogue. Their verdicts
# are the ones the pilot's proofs check, so a report that differs is out of date.
#
# usage: bash scripts/pilot-reports.sh OUT_DIR
# It writes the generated reports, and a diff for each that differs, to OUT_DIR, and fails if
# either differs. Run it after `lake build`, from anywhere.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
out="${1:?usage: pilot-reports.sh OUT_DIR}"
mkdir -p "$out"
out="$(cd "$out" && pwd)"

cd "$root/lean"
lake env lean --run Gate.lean pilot > "$out/first-sample.md"
lake env lean --run Gate.lean pilot catalogue > "$out/catalogue.md"

fail=0
for r in first-sample catalogue; do
  if diff -u "$root/pilot/reports/$r.md" "$out/$r.md" > "$out/$r.diff"; then
    rm -f "$out/$r.diff"
    echo "ok: pilot/reports/$r.md is what Gate.lean prints"
  else
    echo "FAIL: pilot/reports/$r.md differs from what Gate.lean prints (the first 60 lines):"
    head -n 60 "$out/$r.diff"
    fail=1
  fi
done
exit "$fail"
