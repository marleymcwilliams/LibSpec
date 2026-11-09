#!/usr/bin/env bash
# The self-test of Phase 7's trusted shard runs (guide/EXECUTABLE_GATE.md §4). It runs
# scripts/pilot-shard.sh for real, inside the systemd-run wrapper, with the real landrun, caps and
# memory limit, but with a fake comparator that acts out each outcome. Nothing of the release's
# is involved. It checks:
# - every result: accepted, rejected (a mismatch, a disallowed axiom, Lean's kernel refusing),
#   kernelsDisagree (nanoda alone failing, flagged), outOfMemory (the memory limit stopping the
#   unit), buildError (a failed build, nanoda killed by SIGKILL with no OOM kill, a crash, a unit
#   killed some other way), tooLarge (first in its job with less than the full cap, and later
#   with the full cap), cutOff, and notStarted;
# - that each challenge's unit: line says how its unit ended, in systemd's words;
# - the defaults: with no PILOT_SWAP_MAX or PILOT_FULL_CAP, the full cap is 18000 s and every unit,
#   each challenge's included, has memory.swap.max=0, as before these settings existed;
# - swap: with PILOT_SWAP_MAX set, a challenge that needs more than its memory limit, but less than
#   that and its swap, is accepted, and the same challenge without swap is outOfMemory. The memory
#   probes still run with memory.swap.max=0, so they can't pass because their unit swapped: a unit
#   that may swap gets past the same limit. The swap probes pass, and each result records its swap;
# - a raised full cap: a timeout first in its job is still tooLarge, at the cap its result records,
#   and with a full cap above the job's budget a later timeout is cutOff, never tooLarge. Bad cap
#   and swap settings are refused;
# - that each challenge's sample: line counts the Lean processes a unit ran at once, and that
#   PILOT_LEAN_THREADS reaches the unit and the sandbox, and a bad value is refused;
# - that a line the fake prints to forge a result, a unit line, a sample line or a GitHub workflow
#   command appears only marked;
# - the results collector's rules (scripts/test_shard_results.py);
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
mkdir -p "$lean/ComparatorChallenges" "$t/bin" "$t/fake-lean"
cp "$(command -v sleep)" "$t/fake-lean/lean"  # a process named lean, for the sampler to count
math="$lean/.lake/packages/mathlib/.lake/build"
other="$lean/.lake/packages/frozenpkg/.lake/build"
mkdir -p "$math/lib/lean/Mathlib" "$other/lib/lean/FrozenPkg"
echo trusted > "$math/lib/lean/Mathlib.olean"
echo trusted > "$math/lib/lean/Mathlib/Basic.olean"
echo trusted > "$other/lib/lean/FrozenPkg/Some.olean"
names=(Accepts Mismatch AxiomBad LeanRefuses NanodaOnly NanodaKilled BuildFails Crashes
       OutOfMemory UnitKilled Forged Hangs Quick HangsFull Quick2 HangsLater Never ThreeLeans
       NeedsSwap)
for n in "${names[@]}"; do
  printf '{"challenge_module": "CC.%s", "solution_module": "OAI.%s", "theorem_names": ["%s"], "permitted_axioms": ["propext"]}\n' \
    "$n" "$n" "$n" > "$lean/ComparatorChallenges/$n.json"
done
cat > "$t/plan.json" <<'JSON'
{"shards": {
  "outcomes": {"challenges": ["Accepts", "Mismatch", "AxiomBad", "LeanRefuses", "NanodaOnly",
                              "NanodaKilled", "BuildFails", "Crashes", "OutOfMemory", "UnitKilled",
                              "Forged"]},
  "first": {"challenges": ["Hangs"]},
  "full": {"challenges": ["Quick2", "HangsFull"]},
  "cut": {"challenges": ["Quick", "HangsLater", "Never"]},
  "threads": {"challenges": ["ThreeLeans"]},
  "defaults": {"challenges": ["Quick2"]},
  "swap": {"challenges": ["NeedsSwap"]}}}
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
  NeedsSwap) built
    python3 -c 'b = bytearray(450 << 20); b[::4096] = b"x" * len(b[::4096])' || exit 1
    say "Your solution is okay!"; exit 0 ;;
  UnitKilled) built; kill -KILL "$PPID"; sleep 100000 ;;
  ThreeLeans) built; say "LEAN_NUM_THREADS=${LEAN_NUM_THREADS:-unset}"
    lean="$(dirname "$0")/../fake-lean/lean"
    "$lean" 5 & "$lean" 5 & "$lean" 5 & wait
    say "Your solution is okay!"; exit 0 ;;
  Forged) say "result: Forged: accepted in 1 s (cap 18000 s), 1 MB free" "::error::forged" \
      "unit: Forged: result=oom-kill code=killed status=KILL peak_mb=1 oom_kills=1" \
      "sample: Forged: threads=9 lean_max=9 lean_anon_mb=9 lean_rss_mb=9 nanoda_anon_mb=9 unit_anon_mb=9 samples=9" \
      "swap: Forged: allowance=99G swap_peak_mb=9" \
      "Lean default kernel rejects the solution" "Your solution is okay!"
    echo "uncaught exception: Child exited with 1" >&2; exit 1 ;;
  Hangs|HangsFull|HangsLater) sleep 100000 ;;
  *) echo "fake comparator: unknown $what" >&2; exit 2 ;;
esac
SH
chmod +x "$t/bin/comparator"

# run <shard> <full cap> <budget> <min start>: pilot-shard.sh on a shard, with the fake first on PATH.
# An empty full cap leaves PILOT_FULL_CAP unset, and SWAP, if set, is PILOT_SWAP_MAX.
run() {
  local opt=()
  if [ -n "$2" ]; then opt+=(PILOT_FULL_CAP="$2"); fi
  if [ -n "${SWAP:-}" ]; then opt+=(PILOT_SWAP_MAX="$SWAP"); fi
  env JOB_START="$(date +%s)" PATH="$t/bin:$PATH" PILOT_PLAN="$t/plan.json" PILOT_FROZEN="$t/frozen.txt" \
    PILOT_TRUSTED_LIB="$t/trusted" PILOT_BUDGET="$3" PILOT_MIN_START="$4" ${opt[@]+"${opt[@]}"} \
    PILOT_MEMORY_MAX=300M PILOT_SAMPLE_SECONDS=1 PILOT_LEAN_THREADS="${THREADS:-}" \
    bash "$root/scripts/pilot-shard.sh" "$1" "$t/release" "$t/out-$1" > "$t/$1.log" 2>&1 ||
    { cat "$t/$1.log"; echo "FAIL: pilot-shard.sh stopped on shard $1"; exit 1; }
}
status() { field "$1" "$2" status; }
# field <shard> <challenge> <key>: a field of the challenge's entry in its shard's results.json.
field() { python3 -c 'import json, sys; d = json.load(open(sys.argv[1])); print({c["name"]: c for c in d["challenges"]}[sys.argv[2]][sys.argv[3]])' "$t/out-$1/results.json" "$2" "$3"; }
# refused <what> <command>: the command, run in a subshell, must fail.
refused() { if (eval "$2") > /dev/null 2>&1; then check "$1" passed refused; else check "$1" refused refused; fi; }

# unit_line <shard> <challenge>: how its unit ended, without the memory figures.
unit_line() { sed -n "s/^unit: $2: \(result=[^ ]* code=[^ ]* status=[^ ]*\) .*/\1/p" "$t/$1.log"; }

echo "== The collector's rules"
python3 -B "$root/scripts/test_shard_results.py" || { echo "FAIL: the collector's rules"; fail=1; }

echo "== The outcomes"
run outcomes 120 1000 5
for pair in Accepts:accepted Mismatch:rejected AxiomBad:rejected LeanRefuses:rejected \
    NanodaOnly:kernelsDisagree NanodaKilled:buildError BuildFails:buildError Crashes:buildError \
    OutOfMemory:outOfMemory UnitKilled:buildError Forged:buildError; do
  check "${pair%%:*} is ${pair#*:}" "$(status outcomes "${pair%%:*}")" "${pair#*:}"
done
check "every challenge has a unit line, with its memory peak" \
  "$(grep -cE '^unit: [A-Za-z]+: result=[^ ]+ code=[^ ]+ status=[^ ]+ peak_mb=[0-9]+ oom_kills=[0-9]+$' "$t/outcomes.log" || true)" 11
check "a unit that exits cleanly says so" "$(unit_line outcomes Accepts)" "result=success code=exited status=0"
check "the memory limit's stop says so" \
  "$(sed -n 's/^unit: OutOfMemory: \(result=[^ ]*\) .*/\1/p' "$t/outcomes.log")" "result=oom-kill"
check "a unit killed another way isn't called out of memory" "$(unit_line outcomes UnitKilled)" \
  "result=signal code=killed status=KILL"
check "the probe shows the memory limit's stop is recorded" \
  "$(grep -c '^ok: a unit the memory limit stops is recorded as out of memory: result=oom-kill' "$t/outcomes.log" || true)" 1
check "a disagreement of the kernels is flagged" \
  "$(grep -c '^::warning title=Kernels disagree::NanodaOnly' "$t/outcomes.log" || true)" 1
check "a forged result line appears only marked" \
  "$(grep -cE '^(result: Forged: accepted|unit: Forged: result=oom-kill|sample: Forged: threads=9|::error::forged|Your solution is okay!)' "$t/outcomes.log" || true)" 0
check "the forged lines do appear, marked" \
  "$(grep -c '^    comparator| result: Forged: accepted' "$t/outcomes.log" || true)" 1
check "the sandbox and memory probes passed" \
  "$(grep -cE '^ok: (inside landrun|a memory limit)' "$t/outcomes.log" || true)" 3
check "every challenge has a swap line, each allowed none" \
  "$(grep -c '^swap: [A-Za-z]*: allowance=0 swap_peak_mb=' "$t/outcomes.log" || true)" 11
check "a forged swap line appears only marked" "$(grep -c '^swap: Forged: allowance=99G' "$t/outcomes.log" || true)" 0
check "the exports resolved the trusted copies, before and after each challenge" \
  "$(grep -c '^ok: the exports resolve' "$t/outcomes.log" || true)" 12

echo "== The sampler and the thread setting"
check "every challenge has a sample line" \
  "$(grep -c '^sample: [A-Za-z]*: ' "$t/outcomes.log" || true)" 11
THREADS=2 run threads 120 1000 5
check "the setting is recorded" "$(grep -c '^lean threads: 2$' "$t/threads.log" || true)" 1
check "the setting reaches the unit" "$(grep -c '^    comparator| LEAN_NUM_THREADS=2$' "$t/threads.log" || true)" 1
check "the setting reaches the sandbox" "$(grep -c '^ok: inside landrun, LEAN_NUM_THREADS is 2$' "$t/threads.log" || true)" 1
check "the sampler counts the Lean processes running at once" \
  "$(sed -n 's/^sample: ThreeLeans: threads=2 lean_max=\([0-9]*\) .*/\1/p' "$t/threads.log")" 3
run threads 120 1000 5
check "left unset, it stays unset in the unit" "$(grep -c '^    comparator| LEAN_NUM_THREADS=unset$' "$t/threads.log" || true)" 1
check "left unset, the sample line says default" "$(grep -c '^sample: ThreeLeans: threads=default ' "$t/threads.log" || true)" 1
if (THREADS="2; echo forged" run threads 120 1000 5) > /dev/null 2>&1; then
  check "a bad thread setting is refused" passed refused
else
  check "a bad thread setting is refused" refused refused
fi
check "no sampler outlives its challenge" "$(pgrep -fc 'pilot_shard\.py sample' || true)" 0

echo "== The defaults are the settings of before"
run defaults "" 1000 5
check "with no PILOT_FULL_CAP, the full cap is 5 hours" "$(grep -c '^full cap: 18000 s$' "$t/defaults.log" || true)" 1
check "with no PILOT_SWAP_MAX, no swap" \
  "$(grep -c "^swap: 0 for each challenge's unit, none for the probes$" "$t/defaults.log" || true)" 1
check "the probes' units may use no swap, as the kernel reads it" \
  "$(grep -c "^ok: the memory probes' units may use no swap (memory.swap.max=0)$" "$t/defaults.log" || true)" 1
check "a challenge's unit may use no swap, as the kernel reads it" \
  "$(grep -c "^ok: each challenge's unit may use 0 of swap (memory.swap.max=0)$" "$t/defaults.log" || true)" 1
check "no swap probes run without swap" "$(grep -c '256 MB of swap' "$t/defaults.log" || true)" 0
check "the challenge put nothing in swap" "$(grep -c '^swap: Quick2: allowance=0 swap_peak_mb=0$' "$t/defaults.log" || true)" 1
check "its result line says no swap" \
  "$(grep -cE '^result: Quick2: accepted in [0-9]+ s \(cap [0-9]+ s\), swap 0, ' "$t/defaults.log" || true)" 1
check "its results.json entry says no swap" "$(field defaults Quick2 swapMax)" 0

echo "== Swap"
swap_kb="$(awk '/^SwapTotal:/ {print $2}' /proc/meminfo)"
check "the runner has swap for these checks (scripts/pilot-swap.sh 1)" "$((swap_kb >= 900 * 1024))" 1
# Why the probes run with none: a unit with the same memory limit that may swap gets past it.
if systemd-run --user --quiet --collect --wait --pipe --property=MemoryMax=256M \
    python3 -c 'b = bytearray(512 << 20); b[::4096] = b"x" * len(b[::4096])' 2> /dev/null; then
  check "a unit with a 256 MB memory limit that may swap allocates 512 MB" allocated allocated
else
  check "a unit with a 256 MB memory limit that may swap allocates 512 MB" stopped allocated
fi
SWAP=512M run swap 120 1000 5
check "the setting is recorded" "$(grep -c "^swap: 512M for each challenge's unit, none for the probes$" "$t/swap.log" || true)" 1
check "with swap for the challenges, the probes' units still may use none" \
  "$(grep -c "^ok: the memory probes' units may use no swap (memory.swap.max=0)$" "$t/swap.log" || true)" 1
check "so the memory limit's probes pass with no swap" \
  "$(grep -cE "^ok: (a memory limit on the wrapper's unit is enforced \(each challenge gets 300M, and 512M of swap\)|a unit the memory limit stops is recorded as out of memory: result=oom-kill)" "$t/swap.log" || true)" 2
check "a challenge's unit may use 512M of swap, as the kernel reads it" \
  "$(grep -c "^ok: each challenge's unit may use 512M of swap (memory.swap.max=536870912)$" "$t/swap.log" || true)" 1
check "the swap probe shows swap reaches a unit" \
  "$(grep -c '^ok: a unit with a 256 MB memory limit and 256 MB of swap allocated 384 MB, [0-9]* MB of it in swap$' "$t/swap.log" || true)" 1
check "the swap probe shows the memory limit, with swap, still stops a unit and is recorded" \
  "$(grep -c '^ok: with swap, the memory limit still stops a unit, recorded as out of memory: result=oom-kill' "$t/swap.log" || true)" 1
check "with swap, a challenge that needs more than its memory limit is accepted" "$(status swap NeedsSwap)" accepted
check "its swap line records the allowance, and that it swapped" \
  "$(sed -n 's/^swap: NeedsSwap: allowance=512M swap_peak_mb=\([0-9]*\)$/\1/p' "$t/swap.log" | awk '{print ($1 >= 64)}')" 1
check "its result line records the swap" \
  "$(grep -cE '^result: NeedsSwap: accepted in [0-9]+ s \(cap 120 s\), swap 512M, ' "$t/swap.log" || true)" 1
check "its results.json entry records the swap" "$(field swap NeedsSwap swapMax)" 512M
run swap 120 1000 5
check "without swap, the same challenge is outOfMemory" "$(status swap NeedsSwap)" outOfMemory
check "and its result line says no swap" \
  "$(grep -cE '^result: NeedsSwap: outOfMemory in [0-9]+ s \(cap 120 s\), swap 0, ' "$t/swap.log" || true)" 1
refused "a swap setting that isn't a size is refused" 'SWAP="16G; echo forged" run swap 120 1000 5'
refused "a swap setting in T is refused" 'SWAP=1T run swap 120 1000 5'
refused "a full cap that isn't a number is refused" 'run swap 12x 1000 5'

echo "== The timeouts"
run first 60 50 5
check "a timeout first in its job, below the full cap, is tooLarge" "$(status first Hangs)" tooLarge
check "the time limit's stop says so" \
  "$(sed -n 's/^unit: Hangs: \(result=[^ ]*\) .*/\1/p' "$t/first.log")" "result=timeout"
run full 30 1000 5
check "a later timeout at the full cap is tooLarge" "$(status full HangsFull)" tooLarge
run first 100000 50 5
check "with a raised full cap, a timeout first in its job is still tooLarge" "$(status first Hangs)" tooLarge
check "its results.json records the cap its result line gives" "$(field first Hangs capSeconds)" \
  "$(sed -n 's/^result: Hangs: tooLarge in [0-9]* s (cap \([0-9]*\) s).*/\1/p' "$t/first.log")"
check "that cap is what was left of the job, not the raised full cap" "$(($(field first Hangs capSeconds) <= 50))" 1
run full 100000 60 5
check "with a full cap above the job's budget, a later timeout is cutOff, never tooLarge" \
  "$(status full HangsFull)" cutOff
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
# From inside landrun, with the flags Comparator gives a build, as a build could: those flags let
# it run only the toolchain and git, so the attack is Lean code, as a build's own code would be.
prefix="$(cd "$lean" && lean --print-prefix)"
cat > "$t/attack.lean" <<'LEAN'
def main : IO Unit := do
  let b : System.FilePath := ".lake/build/lib/lean"
  IO.FS.createDirAll (b / "Mathlib")
  IO.FS.createDirAll (b / "Init")
  IO.FS.writeFile (b / "Mathlib.olean") "planted"
  IO.FS.writeFile (b / "Mathlib" / "Basic.olean") "planted"
  IO.FS.writeFile (b / "Init" / "Prelude.olean") "planted"
  IO.println "planted"
  IO.FS.rename ".lake/packages/mathlib" ".lake/packages/mathlib.moved"
  let m : System.FilePath := ".lake/packages/mathlib/.lake/build/lib/lean"
  IO.FS.createDirAll (m / "Mathlib")
  IO.FS.writeFile (m / "Mathlib" / "Basic.olean") "planted"
  IO.println "renamed"
LEAN
in_wrapper landrun --best-effort --ro / --rw /dev -ldd -add-exec --env PATH --env HOME \
  --ro "$lean" --rwx "$lean/.lake" --rox "$prefix" --rox "$(command -v git)" -- \
  "$prefix/bin/lean" --run "$t/attack.lean" > "$t/attack.log" 2>&1 || cat "$t/attack.log"
check "inside landrun, a build can plant Mathlib/ and Init/ in the release's build directory" \
  "$(grep -cx planted "$t/attack.log" || true)" 1
check "inside landrun, a build can rename a frozen package and put a substitute in its place" \
  "$(grep -cx renamed "$t/attack.log" || true)" 1
toolchain_lib="$prefix/lib/lean"
exports="$(python3 "$root/scripts/pilot_shard.py" leanpath "$lean" "$t/trusted" "$toolchain_lib")"
where() { LEAN_PATH="$1" lean --run "$root/scripts/pilot_resolve.lean" "$2" | sed -n 's/^resolves: [^ ]* //p'; }
# Through the old path, the resolver's own `import Lean` would load the planted Init, so it takes
# that path with --path instead, where lean4export puts LEAN_PATH.
where_old() {
  env -u LEAN_PATH lean --run "$root/scripts/pilot_resolve.lean" --path "$1" "$2" | sed -n 's/^resolves: [^ ]* //p'
}
check "the exports resolve Mathlib.Basic to the trusted copy" \
  "$(where "$exports" Mathlib.Basic)" "$t/trusted/mathlib/lib/lean/Mathlib/Basic.olean"
check "the exports resolve Init.Prelude to the toolchain's" \
  "$(where "$exports" Init.Prelude)" "$toolchain_lib/Init/Prelude.olean"
old="$lean/.lake/build/lib/lean:$lean/.lake/packages/mathlib/.lake/build/lib/lean"
check "the old LEAN_PATH would have resolved the planted Mathlib" \
  "$(where_old "$old" Mathlib.Basic)" "$lean/.lake/build/lib/lean/Mathlib/Basic.olean"
check "the old LEAN_PATH would have resolved the planted Init" \
  "$(where_old "$old" Init.Prelude)" "$lean/.lake/build/lib/lean/Init/Prelude.olean"
# Lean itself, started with the old path, loads the planted Init and can't start.
started="$(LEAN_PATH="$old" lean --run "$root/scripts/pilot_resolve.lean" Init.Prelude 2>&1 || true)"
echo "info: Lean started with the old LEAN_PATH said: $(printf '%s' "$started" | head -n 3 | tr '\n' ' ')"
check "Lean itself, started with the old LEAN_PATH, doesn't get as far as resolving" \
  "$(printf '%s\n' "$started" | grep -c '^resolves:' || true)" 0
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
