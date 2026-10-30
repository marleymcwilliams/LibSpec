#!/usr/bin/env bash
# Phase 7's trusted Comparator runs on one shard of the openai/math release
# (guide/EXECUTABLE_GATE.md §4). Run it only in the trusted job, after scripts/pilot_deps.py has
# rebuilt the release's dependencies from the pin and scripts/pilot_tree.py has verified the
# untrusted job's tree against that rebuild.
#
# It never runs the release's lakefile outside the sandbox: no `lake env`, `lake update` or
# `lake build` in the release. Comparator builds both modules inside its landrun sandbox,
# inside the systemd-run wrapper, and LEAN_PATH comes from the directories, not from `lake env`.
#
# Each challenge is capped at 5 hours, or at what is left of the job's time budget if that is
# less. A challenge stopped at the full 5 hours is too large to check yet. One stopped earlier,
# because its job ran out of time, is cut off, and gets one rerun in a job of its own (solo-<name>).
#
# usage: bash scripts/pilot-shard.sh SHARD RELEASE_DIR OUT_DIR
# Needs JOB_START (the job's start, in seconds since the epoch), Linux with a systemd user
# manager, and comparator, lean4export, landrun and nanoda_bin on PATH.
set -euo pipefail

shard="$1"
release="$2"
out="$3"
root="$(cd "$(dirname "$0")/.." && pwd)"
lean_dir="$release/lean"
plan="$root/pilot/data/shard-plan.json"
full_cap=18000             # 5 hours, the cap on one challenge
deadline=$((JOB_START + 340 * 60))  # leaves 15 minutes of the job's 355 for its results
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
LEAN_PATH="$(helper leanpath "$lean_dir")"
export LEAN_PATH

# in_wrapper <command>...: a command inside the systemd-run wrapper, in the release's lean/.
# MAX_SECONDS caps how long it may run.
in_wrapper() {
  systemd-run --user --quiet --collect --wait --pipe \
    --property=RestrictAddressFamilies=~AF_UNIX \
    --property=NoNewPrivileges=yes \
    --property=RuntimeMaxSec="${MAX_SECONDS:-infinity}" \
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

for c in "${challenges[@]}"; do
  step "Challenge $c"
  left=$((deadline - $(date +%s)))
  cap=$((left < full_cap ? left : full_cap))
  if [ "$cap" -lt 300 ]; then
    printf '%s\tnotStarted\t0\t%s\t%s\n' "$c" "$cap" "$(free_mb)" >> "$tsv"
    echo "result: $c: notStarted, with $left s of the job left"
    helper results "$tsv" "$shard" "$out/results.json"
    continue
  fi
  config="$out/logs/$c.config.json"
  solution="$(helper config "$lean_dir" "$c" "$config")"
  t0=$(date +%s)
  code=0
  MAX_SECONDS=$cap in_wrapper comparator "$config" > "$out/logs/$c.log" 2>&1 || code=$?
  t1=$(date +%s)
  status="$(helper classify "$out/logs/$c.log" "$solution" "$code" "$((t1 - t0))" \
    "$cap" "$full_cap")"
  tail -n 20 "$out/logs/$c.log"
  printf '%s\t%s\t%s\t%s\t%s\n' "$c" "$status" "$((t1 - t0))" "$cap" "$(free_mb)" >> "$tsv"
  echo "result: $c: $status in $((t1 - t0)) s (cap $cap s), $(free_mb) MB free"
  helper results "$tsv" "$shard" "$out/results.json"
done

step "Results"
helper results "$tsv" "$shard" "$out/results.json"
cat "$out/results.json"
echo
echo "pilot-shard.sh: done ($shard, ${#challenges[@]} challenges)"
