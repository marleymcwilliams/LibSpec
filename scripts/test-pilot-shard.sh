#!/usr/bin/env bash
# The self-test of Phase 7's trusted shard runs (guide/EXECUTABLE_GATE.md §4). It runs
# scripts/pilot-shard.sh for real, inside the systemd-run wrapper, with the real landrun, caps and
# memory limit, but with a fake comparator that acts out each outcome. Nothing of the release's
# is involved. It checks:
# - every result: accepted, rejected (a mismatch, a disallowed axiom, Lean's kernel refusing),
#   kernelsDisagree (nanoda alone failing, flagged), buildError (a failed build, nanoda killed
#   by SIGKILL, a crash, running out of memory), tooLarge (first in its job with less than the
#   full cap, and later with the full cap), cutOff, and notStarted;
# - that a line the fake prints to forge a result, or a GitHub workflow command, appears only
#   marked;
# - that the sandbox check fails when landrun sandboxes nothing, and when a directory listed as
#   frozen can be written;
# - that from inside landrun a build can plant a Mathlib/ and an Init/ in the release's build
#   directory and rename a frozen package, and that the exports still resolve Mathlib and Init
#   to the trusted copies, where the old LEAN_PATH would have resolved the planted ones.
#
# usage: bash scripts/test-pilot-shard.sh
# Needs what scripts/pilot-shard.sh needs, and sudo for chattr and mount.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
t="$(mktemp -d "${RUNNER_TEMP:-/tmp}/pilot-selftest.XXXXXX")"  # on the disk, where chattr works
lean="$t/release/lean"
cleanup() {
  bash "$root/scripts/pilot-trusted-lib.sh" unmount "$t/trusted" 2> /dev/null || true
  sudo chattr -R -i "$t" 2> /dev/null || true
  rm -rf "$t"
}
trap cleanup EXIT
fail=0
check() { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1: expected $3, got $2"; fail=1; fi; }

# A fake release: configs, a trusted Mathlib and one more frozen package.
mkdir -p "$lean/ComparatorChallenges" "$t/bin"
math="$lean/.lake/packages/mathlib/.lake/build"
other="$lean/.lake/packages/frozenpkg/.lake/build"
mkdir -p "$math/lib/lean/Mathlib" "$other/lib/lean/FrozenPkg"
echo trusted > "$math/lib/lean/Mathlib.olean"
echo trusted > "$math/lib/lean/Mathlib/Basic.olean"
echo trusted > "$other/lib/lean/FrozenPkg/Some.olean"
names=(Accepts Mismatch AxiomBad LeanRefuses NanodaOnly NanodaKilled BuildFails Crashes
       OutOfMemory Forged Hangs Quick HangsFull Quick2 HangsLater Never)
for n in "${names[@]}"; do
  printf '{"challenge_module": "CC.%s", "solution_module": "OAI.%s", "theorem_names": ["%s"], "permitted_axioms": ["propext"]}\n' \
    "$n" "$n" "$n" > "$lean/ComparatorChallenges/$n.json"
done
cat > "$t/plan.json" <<'JSON'
{"shards": {
  "outcomes": {"challenges": ["Accepts", "Mismatch", "AxiomBad", "LeanRefuses", "NanodaOnly",
                              "NanodaKilled", "BuildFails", "Crashes", "OutOfMemory", "Forged"]},
  "first": {"challenges": ["Hangs"]},
  "full": {"challenges": ["Quick2", "HangsFull"]},
  "cut": {"challenges": ["Quick", "HangsLater", "Never"]}}}
JSON
printf '%s\n' "$math" "$other" > "$t/frozen.txt"
while IFS= read -r d; do sudo chattr -R +i "$d"; done < "$t/frozen.txt"
bash "$root/scripts/pilot-trusted-lib.sh" mount "$t/frozen.txt" "$t/trusted"

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
  NanodaKilled) built; say "Running nanoda kernel on solution" "nanoda kernel rejected the solution" \
      "Running Lean default kernel on solution." "Lean default kernel accepts the solution"
    echo "uncaught exception: nanoda exited with 137" >&2; exit 1 ;;
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
    PILOT_TRUSTED_LIB="$t/trusted" PILOT_FULL_CAP="$2" PILOT_BUDGET="$3" PILOT_MIN_START="$4" \
    PILOT_MEMORY_MAX=300M bash "$root/scripts/pilot-shard.sh" "$1" "$t/release" "$t/out-$1" > "$t/$1.log" 2>&1 ||
    { cat "$t/$1.log"; echo "FAIL: pilot-shard.sh stopped on shard $1"; exit 1; }
}
status() { python3 -c 'import json, sys; d = json.load(open(sys.argv[1])); print({c["name"]: c["status"] for c in d["challenges"]}[sys.argv[2]])' "$t/out-$1/results.json" "$2"; }

echo "== The outcomes"
run outcomes 120 1000 5
for pair in Accepts:accepted Mismatch:rejected AxiomBad:rejected LeanRefuses:rejected \
    NanodaOnly:kernelsDisagree NanodaKilled:buildError BuildFails:buildError Crashes:buildError \
    OutOfMemory:buildError Forged:buildError; do
  check "${pair%%:*} is ${pair#*:}" "$(status outcomes "${pair%%:*}")" "${pair#*:}"
done
check "a disagreement of the kernels is flagged" \
  "$(grep -c '^::warning title=Kernels disagree::NanodaOnly' "$t/outcomes.log" || true)" 1
check "a forged result line appears only marked" \
  "$(grep -cE '^(result: Forged: accepted|::error::forged|Your solution is okay!)' "$t/outcomes.log" || true)" 0
check "the forged lines do appear, marked" \
  "$(grep -c '^    comparator| result: Forged: accepted' "$t/outcomes.log" || true)" 1
check "the sandbox and memory probes passed" \
  "$(grep -cE '^ok: (inside landrun|a memory limit)' "$t/outcomes.log" || true)" 3
check "the exports resolved the trusted copies, before and after each challenge" \
  "$(grep -c '^ok: the exports resolve' "$t/outcomes.log" || true)" 11

echo "== The timeouts"
run first 60 50 5
check "a timeout first in its job, below the full cap, is tooLarge" "$(status first Hangs)" tooLarge
run full 30 1000 5
check "a later timeout at the full cap is tooLarge" "$(status full HangsFull)" tooLarge
run cut 100 170 20
check "a quick challenge is accepted" "$(status cut Quick)" accepted
check "a later timeout below the full cap is cutOff" "$(status cut HangsLater)" cutOff
check "a challenge with no time left is notStarted" "$(status cut Never)" notStarted

in_wrapper() {
  systemd-run --user --quiet --collect --wait --pipe --property=NoNewPrivileges=yes \
    -E PATH="$PATH" -E HOME="$HOME" --working-directory "$lean" -- "$@"
}

echo "== The sandbox check has teeth"
# Inside .lake, where landrun lets the build write: only freezing can stop a write there.
writable="$lean/.lake/packages/unfrozen/.lake/build"
mkdir -p "$t/nosandbox" "$writable"
printf '#!/bin/sh\nwhile [ "$1" != -- ]; do shift; done\nshift\nexec "$@"\n' > "$t/nosandbox/landrun"
chmod +x "$t/nosandbox/landrun"
if PATH="$t/nosandbox:$PATH" in_wrapper bash "$root/scripts/sandbox-check.sh" "$lean" > "$t/teeth1.log" 2>&1; then
  check "a landrun that sandboxes nothing fails the check" passed failed
else
  check "a landrun that sandboxes nothing fails the check" "$(grep -c 'Landlock isn' "$t/teeth1.log")" 1
fi
echo x > "$writable/file"
if in_wrapper bash "$root/scripts/sandbox-check.sh" "$lean" "$writable" > "$t/teeth2.log" 2>&1; then
  check "a writable directory listed as frozen fails the check" passed failed
else
  check "a writable directory listed as frozen fails the check" "$(grep -c 'frozen' "$t/teeth2.log")" 1
fi

echo "== A planted Mathlib and a renamed frozen package can't stand in for the trusted copies"
# From inside landrun, with the flags Comparator gives a build, as a build could.
prefix="$(cd "$lean" && lean --print-prefix)"
in_wrapper landrun --best-effort --ro / --rw /dev -ldd -add-exec --env PATH --env HOME \
  --ro "$lean" --rwx "$lean/.lake" --rox "$prefix" --rox "$(command -v git)" -- /bin/sh -c '
    set -e
    b=.lake/build/lib/lean
    mkdir -p "$b/Mathlib" "$b/Init"
    echo planted > "$b/Mathlib.olean"
    echo planted > "$b/Mathlib/Basic.olean"
    echo planted > "$b/Init/Prelude.olean"
    mv .lake/packages/mathlib .lake/packages/mathlib.moved
    mkdir -p .lake/packages/mathlib/.lake/build/lib/lean/Mathlib
    echo planted > .lake/packages/mathlib/.lake/build/lib/lean/Mathlib/Basic.olean
    echo "planted and renamed"' > "$t/attack.log" 2>&1 || true
check "inside landrun, a build can plant Mathlib/ and Init/ and rename a frozen package" \
  "$(grep -c 'planted and renamed' "$t/attack.log")" 1
toolchain_lib="$prefix/lib/lean"
exports="$(python3 "$root/scripts/pilot_shard.py" leanpath "$lean" "$t/trusted" "$toolchain_lib")"
where() { LEAN_PATH="$1" lean --run "$root/scripts/pilot_resolve.lean" "$2" | sed -n 's/^resolves: [^ ]* //p'; }
check "the exports resolve Mathlib.Basic to the trusted copy" \
  "$(where "$exports" Mathlib.Basic)" "$t/trusted/mathlib/lib/lean/Mathlib/Basic.olean"
check "the exports resolve Init.Prelude to the toolchain's" \
  "$(where "$exports" Init.Prelude)" "$toolchain_lib/Init/Prelude.olean"
old="$lean/.lake/build/lib/lean:$lean/.lake/packages/mathlib/.lake/build/lib/lean"
check "the old LEAN_PATH would have resolved the planted Mathlib" \
  "$(where "$old" Mathlib.Basic)" "$lean/.lake/build/lib/lean/Mathlib/Basic.olean"
check "the old LEAN_PATH would have resolved the planted Init" \
  "$(where "$old" Init.Prelude)" "$lean/.lake/build/lib/lean/Init/Prelude.olean"
if LEAN_PATH="$exports" python3 "$root/scripts/pilot_shard.py" resolution "$t/trusted" "$toolchain_lib" \
    "$root/scripts/pilot_resolve.lean" > "$t/resolution.log" 2>&1; then
  check "the job's own resolution check still passes after the attack" ok ok
else
  cat "$t/resolution.log"
  check "the job's own resolution check still passes after the attack" failed ok
fi

echo
if [ "$fail" -ne 0 ]; then echo "test-pilot-shard.sh: FAILED"; exit 1; fi
echo "test-pilot-shard.sh: passed"
