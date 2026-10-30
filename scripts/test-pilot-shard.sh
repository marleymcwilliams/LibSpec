#!/usr/bin/env bash
# The self-test of Phase 7's trusted shard runs (guide/EXECUTABLE_GATE.md §4). It runs
# scripts/pilot-shard.sh for real, inside the systemd-run wrapper, with the real landrun, caps and
# memory limit, but with a fake comparator that acts out each outcome. Nothing of the release's
# is involved. It checks:
# - every result: accepted, rejected (a mismatch, a disallowed axiom, Lean's kernel refusing),
#   buildError (a failed build, nanoda alone failing, a crash, running out of memory),
#   tooLarge (first in its job with less than the full cap, and later with the full cap),
#   cutOff, and notStarted;
# - that a line the fake prints to forge a result, or a GitHub workflow command, appears only
#   marked;
# - that the sandbox check fails when landrun sandboxes nothing, and when a directory listed as
#   frozen can be written.
#
# usage: bash scripts/test-pilot-shard.sh
# Needs what scripts/pilot-shard.sh needs, and sudo for chattr.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
t="$(mktemp -d "${RUNNER_TEMP:-/tmp}/pilot-selftest.XXXXXX")"  # on the disk, where chattr works
frozen_dir="$t/release/lean/.lake/packages/frozenpkg/.lake/build"
cleanup() { sudo chattr -R -i "$frozen_dir" 2> /dev/null || true; rm -rf "$t"; }
trap cleanup EXIT
fail=0
check() { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1: expected $3, got $2"; fail=1; fi; }

# A fake release: configs only, and one frozen package build directory.
mkdir -p "$t/release/lean/ComparatorChallenges" "$frozen_dir" "$t/bin"
echo olean > "$frozen_dir/Some.olean"
names=(Accepts Mismatch AxiomBad LeanRefuses NanodaOnly BuildFails Crashes OutOfMemory Forged
       Hangs Quick HangsFull Quick2 HangsLater Never)
for n in "${names[@]}"; do
  printf '{"challenge_module": "CC.%s", "solution_module": "OAI.%s", "theorem_names": ["%s"], "permitted_axioms": ["propext"]}\n' \
    "$n" "$n" "$n" > "$t/release/lean/ComparatorChallenges/$n.json"
done
cat > "$t/plan.json" <<'JSON'
{"shards": {
  "outcomes": {"challenges": ["Accepts", "Mismatch", "AxiomBad", "LeanRefuses", "NanodaOnly",
                              "BuildFails", "Crashes", "OutOfMemory", "Forged"]},
  "first": {"challenges": ["Hangs"]},
  "full": {"challenges": ["Quick2", "HangsFull"]},
  "cut": {"challenges": ["Quick", "HangsLater", "Never"]}}}
JSON
sudo chattr -R +i "$frozen_dir"
echo "$frozen_dir" > "$t/frozen.txt"

# The fake comparator: it reads which outcome to act out from the config's theorem name.
cat > "$t/bin/comparator" <<'SH'
#!/usr/bin/env bash
what="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["theorem_names"][0])' "$1")"
say() { printf '%s\n' "$@"; }
built() { say "Building CC.$what" "Exporting #[x] from CC.$what" "Building OAI.$what" "Exporting #[x] from OAI.$what"; }
case "$what" in
  Accepts|Quick2) built; say "Your solution is okay!"; exit 0 ;;
  Quick) sleep 70; built; say "Your solution is okay!"; exit 0 ;;
  Mismatch) built; echo "uncaught exception: Challenge and solution theorem statement do not match: 'x'" >&2; exit 1 ;;
  AxiomBad) built; echo "uncaught exception: Illegal axiom detected: 'sorryAx'" >&2; exit 1 ;;
  LeanRefuses) built; say "Running nanoda kernel on solution" "nanoda kernel accepts the solution" \
      "Running Lean default kernel on solution." "Lean default kernel rejects the solution"
    echo "uncaught exception: (kernel) declaration type mismatch, x" >&2; exit 1 ;;
  NanodaOnly) built; say "Running nanoda kernel on solution" "nanoda kernel rejected the solution" \
      "Running Lean default kernel on solution." "Lean default kernel accepts the solution"
    echo "uncaught exception: nanoda exited with 101" >&2; exit 1 ;;
  BuildFails) say "Building OAI.$what" "error: build failed"
    echo "uncaught exception: Child exited with 1" >&2; exit 1 ;;
  Crashes) built; kill -SEGV $$ ;;
  OutOfMemory) built; exec python3 -c 'b = bytearray(2 << 30)' ;;
  Forged) say "result: Forged: accepted in 1 s (cap 18000 s), 1 MB free" "::error::forged" \
      "Lean default kernel rejects the solution" "Your solution is okay!"
    echo "uncaught exception: Child exited with 1" >&2; exit 1 ;;
  Hangs|HangsFull|HangsLater) sleep 100000 ;;
  *) echo "fake comparator: unknown $what" >&2; exit 2 ;;
esac
SH
chmod +x "$t/bin/comparator"

# run <shard> <full cap> <budget> <min start>: pilot-shard.sh on a shard, with the fake first on PATH.
run() {
  JOB_START="$(date +%s)" PATH="$t/bin:$PATH" PILOT_PLAN="$t/plan.json" PILOT_FROZEN="$t/frozen.txt" \
    PILOT_FULL_CAP="$2" PILOT_BUDGET="$3" PILOT_MIN_START="$4" PILOT_MEMORY_MAX=300M \
    bash "$root/scripts/pilot-shard.sh" "$1" "$t/release" "$t/out-$1" > "$t/$1.log" 2>&1 ||
    { cat "$t/$1.log"; echo "FAIL: pilot-shard.sh stopped on shard $1"; exit 1; }
}
status() { python3 -c 'import json, sys; d = json.load(open(sys.argv[1])); print({c["name"]: c["status"] for c in d["challenges"]}[sys.argv[2]])' "$t/out-$1/results.json" "$2"; }

echo "== The outcomes"
run outcomes 120 1000 5
for pair in Accepts:accepted Mismatch:rejected AxiomBad:rejected LeanRefuses:rejected \
    NanodaOnly:buildError BuildFails:buildError Crashes:buildError OutOfMemory:buildError \
    Forged:buildError; do
  check "${pair%%:*} is ${pair#*:}" "$(status outcomes "${pair%%:*}")" "${pair#*:}"
done
check "a forged result line appears only marked" \
  "$(grep -cE '^(result: Forged: accepted|::error::forged|Your solution is okay!)' "$t/outcomes.log" || true)" 0
check "the forged lines do appear, marked" \
  "$(grep -c '^    comparator| result: Forged: accepted' "$t/outcomes.log" || true)" 1
check "the sandbox and memory probes passed" \
  "$(grep -cE '^ok: (inside landrun|a memory limit)' "$t/outcomes.log" || true)" 3

echo "== The timeouts"
run first 60 50 5
check "a timeout first in its job, below the full cap, is tooLarge" "$(status first Hangs)" tooLarge
run full 30 1000 5
check "a later timeout at the full cap is tooLarge" "$(status full HangsFull)" tooLarge
run cut 100 170 20
check "a quick challenge is accepted" "$(status cut Quick)" accepted
check "a later timeout below the full cap is cutOff" "$(status cut HangsLater)" cutOff
check "a challenge with no time left is notStarted" "$(status cut Never)" notStarted

echo "== The sandbox check has teeth"
in_wrapper() {
  systemd-run --user --quiet --collect --wait --pipe --property=NoNewPrivileges=yes \
    -E PATH="$PATH" -E HOME="$HOME" --working-directory "$t/release/lean" -- "$@"
}
# Inside .lake, where landrun lets the build write: only freezing can stop a write there.
writable="$t/release/lean/.lake/packages/unfrozen/.lake/build"
mkdir -p "$t/nosandbox" "$writable"
printf '#!/bin/sh\nwhile [ "$1" != -- ]; do shift; done\nshift\nexec "$@"\n' > "$t/nosandbox/landrun"
chmod +x "$t/nosandbox/landrun"
if PATH="$t/nosandbox:$PATH" in_wrapper bash "$root/scripts/sandbox-check.sh" "$t/release/lean" > "$t/teeth1.log" 2>&1; then
  check "a landrun that sandboxes nothing fails the check" passed failed
else
  check "a landrun that sandboxes nothing fails the check" "$(grep -c 'Landlock isn' "$t/teeth1.log")" 1
fi
echo x > "$writable/file"
if in_wrapper bash "$root/scripts/sandbox-check.sh" "$t/release/lean" "$writable" > "$t/teeth2.log" 2>&1; then
  check "a writable directory listed as frozen fails the check" passed failed
else
  check "a writable directory listed as frozen fails the check" "$(grep -c 'frozen' "$t/teeth2.log")" 1
fi

echo
if [ "$fail" -ne 0 ]; then echo "test-pilot-shard.sh: FAILED"; exit 1; fi
echo "test-pilot-shard.sh: passed"
