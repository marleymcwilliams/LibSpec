#!/usr/bin/env bash
# Phase 7's trusted Comparator runs on one shard of the openai/math release
# (guide/EXECUTABLE_GATE.md §4). Run it only in the trusted job, after scripts/pilot_deps.py has
# rebuilt the release's dependencies from the pin, the build outputs that came through
# LibSpec's tooling are frozen, and scripts/pilot_tree.py has verified the untrusted job's
# tree against the rebuild.
#
# It never runs the release's lakefile outside the sandbox: no `lake env`, `lake update` or
# `lake build` in the release. Comparator builds both modules inside its landrun sandbox,
# inside the systemd-run wrapper, and LEAN_PATH comes from the directories.
#
# The exports' LEAN_PATH starts with the trusted copies: the toolchain's library, then each
# frozen package's outputs through its read-only mount outside .lake (PILOT_TRUSTED_LIB, made by
# scripts/pilot-trusted-lib.sh). Lean resolves a module through the first entry holding its
# top-level directory, so nothing a build plants in .lake can stand in for Mathlib or Init.
# Before the first challenge, and after each one before its result is printed, Lean's own
# resolution must still find every trusted root in its trusted copy (scripts/pilot_resolve.lean).
#
# Before the first challenge it proves that the wrapper's memory limit and Comparator's
# sandbox are in force (scripts/sandbox-check.sh), and stops otherwise.
#
# Each challenge is capped at the full cap, or at what is left of the job's time if that is less.
# The full cap is 5 hours unless PILOT_FULL_CAP sets it (the workflow's cap_seconds input). A
# challenge that times out as the first in its job, or with the full cap, is too large to check
# yet, at the cap its result records. One that times out after others, with less than the full
# cap, is cut off, and gets one rerun in a job of its own (solo-<name>).
#
# Each challenge's unit gets MemoryMax (13G) and MemorySwapMax: no swap unless PILOT_SWAP_MAX
# allows some (the workflow's swap_gb input). Every other unit of the wrapper, the probes and the
# sandbox check among them, gets no swap whatever PILOT_SWAP_MAX says, so swap can't pass a probe.
# With swap allowed, further probes show it reaches a unit and that the limit still stops one.
# Each challenge's "result:" line, its "swap:" line and results.json say what swap it was allowed.
#
# After each challenge, an unmarked "unit:" line says how its unit ended and its memory peak,
# from scripts/pilot-unit-end.sh. A unit the memory limit stopped is outOfMemory, which stays
# unknown. A probe before the first challenge shows that this record works.
#
# Then an unmarked "sample:" line gives what a loop outside the sandbox saw while the unit ran:
# the setting of LEAN_NUM_THREADS, the most Lean processes at once, the largest one's memory, and
# nanoda's and the whole unit's anonymous memory. It holds numbers only, nothing of the release's.
# PILOT_LEAN_THREADS sets LEAN_NUM_THREADS for the challenges; left empty, Lean chooses.
#
# Nothing of the release's is printed unmarked: Comparator's output is prefixed line by line,
# and names from the release's config are printed with repr. The unmarked "result:" lines are
# the evidence (pilot/shard_results.py reads them).
#
# usage: bash scripts/pilot-shard.sh SHARD RELEASE_DIR OUT_DIR
# Needs JOB_START (the job's start, in seconds since the epoch), Linux with a systemd user
# manager, and comparator, lean4export, landrun and nanoda_bin on PATH. PILOT_FROZEN names a
# file listing the frozen build directories, one per line, and PILOT_TRUSTED_LIB the directory
# of their read-only mounts. PILOT_FULL_CAP, in seconds, and PILOT_SWAP_MAX, 0 or a size such as
# 16G, are optional. Tests may set PILOT_PLAN, PILOT_BUDGET, PILOT_MIN_START, PILOT_MEMORY_MAX and
# PILOT_SAMPLE_SECONDS (scripts/test-pilot-shard.sh).
set -euo pipefail

shard="$1"
release="$2"
out="$3"
root="$(cd "$(dirname "$0")/.." && pwd)"
lean_dir="$release/lean"
plan="${PILOT_PLAN:-$root/pilot/data/shard-plan.json}"
full_cap="${PILOT_FULL_CAP:-18000}"          # 5 hours unless raised, the cap on one challenge
swap_max="${PILOT_SWAP_MAX:-0}"               # MemorySwapMax for each challenge's unit
deadline=$((JOB_START + ${PILOT_BUDGET:-20400}))  # 340 minutes: 15 of the job's 355 are left
min_start="${PILOT_MIN_START:-300}"           # don't start a challenge with less than this left
memory_max="${PILOT_MEMORY_MAX:-13G}"         # below the runner's 16 GB, so only it is killed
sample_seconds="${PILOT_SAMPLE_SECONDS:-5}"   # how often the sampler looks at a running unit
lean_threads="${PILOT_LEAN_THREADS:-}"        # LEAN_NUM_THREADS for the challenges, if set
mkdir -p "$out/logs"
tsv="$out/results.tsv"
: > "$tsv"

step() { printf '\n== %s\n' "$1"; }
free_mb() { df -BM --output=avail / | tail -n 1 | tr -dc '0-9'; }
helper() { python3 "$root/scripts/pilot_shard.py" "$@"; }

step "Environment"
[ "$(uname -s)" = Linux ] || { echo "FAIL: needs Linux (landrun uses Landlock)"; exit 1; }
for tool in comparator lean4export landrun nanoda_bin systemd-run lean lake git python3; do
  command -v "$tool" > /dev/null || { echo "FAIL: $tool not on PATH"; exit 1; }
done
systemctl --user show-environment > /dev/null 2>&1 ||
  { echo "FAIL: no systemd user manager (try: sudo loginctl enable-linger \"\$USER\")"; exit 1; }
echo "kernel: $(uname -r)"
echo "lean: $(command -v lean)"
threads_env=()
if [ -n "$lean_threads" ]; then
  [[ "$lean_threads" =~ ^[1-9][0-9]*$ ]] || { echo "FAIL: PILOT_LEAN_THREADS isn't a positive number"; exit 1; }
  threads_env=(-E LEAN_NUM_THREADS="$lean_threads")
fi
echo "lean threads: ${lean_threads:-default}"
[[ "$full_cap" =~ ^[1-9][0-9]*$ ]] || { echo "FAIL: PILOT_FULL_CAP isn't a positive number of seconds"; exit 1; }
echo "full cap: $full_cap s"
[[ "$swap_max" =~ ^(0|[1-9][0-9]*[MG])$ ]] || { echo "FAIL: PILOT_SWAP_MAX isn't 0 or a size such as 16G"; exit 1; }
echo "swap: $swap_max for each challenge's unit, none for the probes"
names="$(helper challenges "$plan" "$shard")"
mapfile -t challenges <<< "$names"
echo "shard: $shard (${#challenges[@]} challenges)"
trusted="${PILOT_TRUSTED_LIB:?the read-only mounts of the frozen outputs are needed}"
[ -d "$trusted" ] || { echo "FAIL: no directory of trusted mounts: $trusted"; exit 1; }
toolchain_lib="$(lean --print-prefix)/lib/lean"
LEAN_PATH="$(helper leanpath "$lean_dir" "$trusted" "$toolchain_lib")"
export LEAN_PATH
frozen=()
if [ -n "${PILOT_FROZEN:-}" ]; then mapfile -t frozen < "$PILOT_FROZEN"; fi
for m in "$trusted"/*; do [ -d "$m" ] && frozen+=("$m"); done
# resolved: Lean's resolution of every trusted root, as the exports resolve them.
resolved() { helper resolution "$trusted" "$toolchain_lib" "$root/scripts/pilot_resolve.lean"; }

# in_wrapper <command>...: a command inside the systemd-run wrapper, in the release's lean/.
# MAX_SECONDS caps how long it may run, MEMORY how much memory it may use, and SWAP how much of it
# may be in swap: none unless SWAP is set. UNIT_END names a file for scripts/pilot-unit-end.sh to
# record how the unit ended.
in_wrapper() {
  local end=()
  if [ -n "${UNIT_END:-}" ]; then
    end=(--property="ExecStopPost=$(command -v bash) $root/scripts/pilot-unit-end.sh $UNIT_END")
  fi
  systemd-run --user --quiet --collect --wait --pipe \
    --property=RestrictAddressFamilies=~AF_UNIX \
    --property=NoNewPrivileges=yes \
    --property=RuntimeMaxSec="${MAX_SECONDS:-infinity}" \
    --property=MemoryMax="${MEMORY:-$memory_max}" \
    --property=MemorySwapMax="${SWAP:-0}" \
    ${end[@]+"${end[@]}"} \
    -E PATH="$PATH" -E HOME="$HOME" -E LEAN_PATH="$LEAN_PATH" ${threads_env[@]+"${threads_env[@]}"} \
    --working-directory "$lean_dir" \
    -- "$@"
}

step "The wrapper is in force"
unix_socket='import socket; socket.socket(socket.AF_UNIX)'
python3 -c "$unix_socket" || { echo "FAIL: AF_UNIX sockets don't open even outside the wrapper"; exit 1; }
if in_wrapper python3 -c "$unix_socket" 2> /dev/null; then
  echo "FAIL: an AF_UNIX socket opened inside the wrapper"
  exit 1
fi
echo "ok: AF_UNIX sockets open outside the wrapper and are refused inside it"
if in_wrapper sudo -n true 2> /dev/null; then
  echo "FAIL: sudo gained privileges inside the wrapper"
  exit 1
fi
echo "ok: sudo gains no privileges inside the wrapper"
# swap_of_unit: the kernel's memory.swap.max for a unit of the wrapper, as it has the unit's
# settings, read from inside it.
swap_of_unit() { in_wrapper bash -c 'cat "/sys/fs/cgroup$(cut -d: -f3 /proc/self/cgroup)/memory.swap.max"'; }
# The memory probes below run with no swap, whatever the challenges get, so a probe can't pass, or
# fail, because its unit swapped.
probe_swap="$(MEMORY=256M swap_of_unit)"
[ "$probe_swap" = 0 ] ||
  { echo "FAIL: the memory probes' units may use swap: memory.swap.max=$probe_swap"; exit 1; }
echo "ok: the memory probes' units may use no swap (memory.swap.max=0)"
allocate='import sys; b = bytearray(int(sys.argv[1]) << 20); b[::4096] = b"x" * len(b[::4096])'
MEMORY=256M in_wrapper python3 -c "$allocate" 64 ||
  { echo "FAIL: a unit with a 256 MB memory limit couldn't allocate 64 MB"; exit 1; }
probe="$out/logs/memory-probe.unit"
if UNIT_END="$probe" MEMORY=256M in_wrapper python3 -c "$allocate" 512 2> /dev/null; then
  echo "FAIL: a unit with a 256 MB memory limit allocated 512 MB: the limit isn't enforced"
  exit 1
fi
echo "ok: a memory limit on the wrapper's unit is enforced (each challenge gets $memory_max, and $swap_max of swap)"
helper unit-out-of-memory "$probe" ||
  { echo "FAIL: a unit the memory limit stopped wasn't recorded as one: $(helper unit "$probe")"; exit 1; }
echo "ok: a unit the memory limit stops is recorded as out of memory: $(helper unit "$probe")"

step "The challenges' swap allowance is in force"
case "$swap_max" in
  0) want_swap=0 ;;
  *M) want_swap=$((${swap_max%M} << 20)) ;;
  *G) want_swap=$((${swap_max%G} << 30)) ;;
esac
challenge_swap="$(SWAP="$swap_max" swap_of_unit)"
[ "$challenge_swap" = "$want_swap" ] ||
  { echo "FAIL: a challenge's unit has memory.swap.max=$challenge_swap, not $want_swap ($swap_max)"; exit 1; }
echo "ok: each challenge's unit may use $swap_max of swap (memory.swap.max=$challenge_swap)"
if [ "$swap_max" != 0 ]; then
  # Swap must reach a unit, or a run with swap would only repeat one without. Then, with swap,
  # the memory limit must still stop a unit, and that must still be recorded as out of memory.
  swap_probe="$out/logs/swap-probe.unit"
  UNIT_END="$swap_probe" MEMORY=256M SWAP=256M in_wrapper python3 -c "$allocate" 384 ||
    { echo "FAIL: a unit with a 256 MB memory limit and 256 MB of swap couldn't allocate 384 MB: $(helper unit "$swap_probe")"; exit 1; }
  swapped="$(helper swap-line "$swap_probe" 256M | sed -n 's/.* swap_peak_mb=\([0-9]*\)$/\1/p')"
  [ "${swapped:-0}" -ge 64 ] ||
    { echo "FAIL: that unit put ${swapped:-no} MB in swap, not the 128 MB it had to"; exit 1; }
  echo "ok: a unit with a 256 MB memory limit and 256 MB of swap allocated 384 MB, $swapped MB of it in swap"
  swap_oom="$out/logs/swap-oom-probe.unit"
  if UNIT_END="$swap_oom" MEMORY=256M SWAP=256M in_wrapper python3 -c "$allocate" 1024 2> /dev/null; then
    echo "FAIL: a unit with a 256 MB memory limit and 256 MB of swap allocated 1024 MB"
    exit 1
  fi
  helper unit-out-of-memory "$swap_oom" ||
    { echo "FAIL: with swap, a unit the memory limit stopped wasn't recorded as one: $(helper unit "$swap_oom")"; exit 1; }
  echo "ok: with swap, the memory limit still stops a unit, recorded as out of memory: $(helper unit "$swap_oom")"
fi

step "The sandbox is in force"
in_wrapper bash "$root/scripts/sandbox-check.sh" "$lean_dir" ${frozen[@]+"${frozen[@]}"}

step "The exports resolve the trusted copies"
resolved

i=0
for c in "${challenges[@]}"; do
  step "Challenge $c"
  first=$((i == 0 ? 1 : 0))
  i=$((i + 1))
  left=$((deadline - $(date +%s)))
  cap=$((left < full_cap ? left : full_cap))
  if [ "$cap" -lt "$min_start" ]; then
    printf '%s\tnotStarted\t0\t%s\t%s\tthe job ran out of time first\n' "$c" "$cap" "$(free_mb)" >> "$tsv"
    echo "result: $c: notStarted, with $left s of the job left, swap $swap_max"
    helper results "$tsv" "$shard" "$out/results.json" "$swap_max"
    continue
  fi
  config="$out/logs/$c.config.json"
  helper config "$lean_dir" "$c" "$config" > /dev/null
  log="$out/logs/$c.log"
  exit_file="$out/logs/$c.exit"
  unit_file="$out/logs/$c.unit"
  sample_file="$out/logs/$c.sample"
  cgroup_file="$out/logs/$c.cgroup"
  rm -f "$exit_file" "$unit_file" "$sample_file" "$cgroup_file"
  # Not through helper: that's a function, so $! would be a subshell, and the kill would miss python3.
  python3 "$root/scripts/pilot_shard.py" sample "$cgroup_file" "$sample_file" "$sample_seconds" "${lean_threads:-default}" > /dev/null 2>&1 &
  sampler=$!
  t0=$(date +%s)
  # The shell around Comparator records its exit status, outside the sandbox, where nothing
  # the release builds can write. A unit stopped at its cap or by the memory limit leaves none.
  UNIT_END="$unit_file" MAX_SECONDS=$cap SWAP="$swap_max" in_wrapper bash -c \
    'cut -d: -f3 /proc/self/cgroup > "$4"; comparator "$1" > "$2" 2>&1; echo "$?" > "$3"' \
    pilot-shard "$config" "$log" "$exit_file" "$cgroup_file" || true
  t1=$(date +%s)
  kill "$sampler" 2> /dev/null || true
  wait "$sampler" 2> /dev/null || true
  res="$(helper classify "$log" "$exit_file" "$((t1 - t0))" "$cap" "$full_cap" "$first" "$unit_file")"
  status="${res%%$'\t'*}"
  detail="${res#*$'\t'}"
  # The release's output, marked on every line, so no line of it can pass for ours.
  if [ -f "$log" ]; then tail -n 20 "$log" | tr '\r' ' ' | sed 's/^/    comparator| /'; fi
  # The exports ran during that challenge. They must have resolved the trusted copies.
  resolved || { echo "FAIL: after $c, the exports no longer resolve the trusted copies"; exit 1; }
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$c" "$status" "$((t1 - t0))" "$cap" "$(free_mb)" "$detail" >> "$tsv"
  echo "unit: $c: $(helper unit "$unit_file")"
  echo "sample: $c: $(helper sample-line "$sample_file")"
  echo "swap: $c: $(helper swap-line "$unit_file" "$swap_max")"
  echo "result: $c: $status in $((t1 - t0)) s (cap $cap s), swap $swap_max, $(free_mb) MB free; $detail"
  if [ "$status" = kernelsDisagree ]; then
    echo "::warning title=Kernels disagree::$c: nanoda failed while Lean's kernel accepted ($detail)"
  fi
  helper results "$tsv" "$shard" "$out/results.json" "$swap_max"
done

step "Results"
helper results "$tsv" "$shard" "$out/results.json" "$swap_max"
echo "pilot-shard.sh: done ($shard, ${#challenges[@]} challenges)"
