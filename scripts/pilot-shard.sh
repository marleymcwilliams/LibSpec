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
# Each challenge is capped at 5 hours, or at what is left of the job's time if that is less.
# A challenge that times out as the first in its job, or with the full cap, is too large to
# check yet. One that times out after others, with less than the full cap, is cut off, and
# gets one rerun in a job of its own (solo-<name>).
#
# Nothing of the release's is printed unmarked: Comparator's output is prefixed line by line,
# and names from the release's config are printed with repr. The unmarked "result:" lines are
# the evidence (pilot/shard_results.py reads them).
#
# usage: bash scripts/pilot-shard.sh SHARD RELEASE_DIR OUT_DIR
# Needs JOB_START (the job's start, in seconds since the epoch), Linux with a systemd user
# manager, and comparator, lean4export, landrun and nanoda_bin on PATH. PILOT_FROZEN names a
# file listing the frozen build directories, one per line, and PILOT_TRUSTED_LIB the directory
# of their read-only mounts. Tests may set PILOT_PLAN,
# PILOT_FULL_CAP, PILOT_BUDGET, PILOT_MIN_START and PILOT_MEMORY_MAX
# (scripts/test-pilot-shard.sh).
set -euo pipefail

shard="$1"
release="$2"
out="$3"
root="$(cd "$(dirname "$0")/.." && pwd)"
lean_dir="$release/lean"
plan="${PILOT_PLAN:-$root/pilot/data/shard-plan.json}"
full_cap="${PILOT_FULL_CAP:-18000}"          # 5 hours, the cap on one challenge
deadline=$((JOB_START + ${PILOT_BUDGET:-20400}))  # 340 minutes: 15 of the job's 355 are left
min_start="${PILOT_MIN_START:-300}"           # don't start a challenge with less than this left
memory_max="${PILOT_MEMORY_MAX:-13G}"         # below the runner's 16 GB, so only it is killed
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
# MAX_SECONDS caps how long it may run, and MEMORY how much memory it may use.
in_wrapper() {
  systemd-run --user --quiet --collect --wait --pipe \
    --property=RestrictAddressFamilies=~AF_UNIX \
    --property=NoNewPrivileges=yes \
    --property=RuntimeMaxSec="${MAX_SECONDS:-infinity}" \
    --property=MemoryMax="${MEMORY:-$memory_max}" \
    --property=MemorySwapMax=0 \
    -E PATH="$PATH" -E HOME="$HOME" -E LEAN_PATH="$LEAN_PATH" \
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
allocate='import sys; b = bytearray(int(sys.argv[1]) << 20); b[::4096] = b"x" * len(b[::4096])'
MEMORY=256M in_wrapper python3 -c "$allocate" 64 ||
  { echo "FAIL: a unit with a 256 MB memory limit couldn't allocate 64 MB"; exit 1; }
if MEMORY=256M in_wrapper python3 -c "$allocate" 512 2> /dev/null; then
  echo "FAIL: a unit with a 256 MB memory limit allocated 512 MB: the limit isn't enforced"
  exit 1
fi
echo "ok: a memory limit on the wrapper's unit is enforced (each challenge gets $memory_max)"

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
    echo "result: $c: notStarted, with $left s of the job left"
    helper results "$tsv" "$shard" "$out/results.json"
    continue
  fi
  config="$out/logs/$c.config.json"
  helper config "$lean_dir" "$c" "$config" > /dev/null
  log="$out/logs/$c.log"
  exit_file="$out/logs/$c.exit"
  rm -f "$exit_file"
  t0=$(date +%s)
  # The shell around Comparator records its exit status, outside the sandbox, where nothing
  # the release builds can write. A unit stopped at its cap or by the memory limit leaves none.
  MAX_SECONDS=$cap in_wrapper bash -c 'comparator "$1" > "$2" 2>&1; echo "$?" > "$3"' \
    pilot-shard "$config" "$log" "$exit_file" || true
  t1=$(date +%s)
  res="$(helper classify "$log" "$exit_file" "$((t1 - t0))" "$cap" "$full_cap" "$first")"
  status="${res%%$'\t'*}"
  detail="${res#*$'\t'}"
  # The release's output, marked on every line, so no line of it can pass for ours.
  if [ -f "$log" ]; then tail -n 20 "$log" | tr '\r' ' ' | sed 's/^/    comparator| /'; fi
  # The exports ran during that challenge. They must have resolved the trusted copies.
  resolved || { echo "FAIL: after $c, the exports no longer resolve the trusted copies"; exit 1; }
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$c" "$status" "$((t1 - t0))" "$cap" "$(free_mb)" "$detail" >> "$tsv"
  echo "result: $c: $status in $((t1 - t0)) s (cap $cap s), $(free_mb) MB free; $detail"
  if [ "$status" = kernelsDisagree ]; then
    echo "::warning title=Kernels disagree::$c: nanoda failed while Lean's kernel accepted ($detail)"
  fi
  helper results "$tsv" "$shard" "$out/results.json"
done

step "Results"
helper results "$tsv" "$shard" "$out/results.json"
echo "pilot-shard.sh: done ($shard, ${#challenges[@]} challenges)"
