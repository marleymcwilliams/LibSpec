#!/usr/bin/env bash
# Proves that Comparator's landrun sandbox is in force (guide/EXECUTABLE_GATE.md §4).
#
# Comparator always passes --best-effort to landrun, and go-landlock's best-effort mode "will
# succeed without error even when Landlock is not available at all". So a sandbox that isn't
# there would fail silently. This runs landrun with the flags Comparator's buildLandrunArgs
# gives a `lake build`, and requires:
# - a write inside PROJECT_DIR/.lake to work;
# - a write outside it, in PROJECT_DIR and in $HOME, to fail;
# - for each FROZEN_DIR, creating a file in it and changing a file in it to fail.
# It exits 1 otherwise. Run it inside the systemd-run wrapper, as Comparator runs.
#
# usage: bash scripts/sandbox-check.sh PROJECT_DIR [FROZEN_DIR...]
set -euo pipefail

project="$(cd "$1" && pwd)"
shift
prefix="$(cd "$project" && lean --print-prefix)"
git_bin="$(command -v git)"
mkdir -p "$project/.lake"
# Comparator's buildLandrunArgs for safeLakeBuild, with its envPass, readablePaths,
# writablePaths and executablePaths.
args=(--best-effort --ro / --rw /dev -ldd -add-exec
      --env PATH --env HOME --env LEAN_ABORT_ON_PANIC
      --ro "$project" --rwx "$project/.lake" --rox "$prefix" --rox "$git_bin")

# writes <file>: whether a sandboxed shell can write to file, by creating it or appending to it.
writes() { landrun "${args[@]}" -- /bin/sh -c 'echo probe >> "$1"' sh "$1" 2> /dev/null; }
fail() { echo "FAIL: $1"; exit 1; }

inside="$project/.lake/.sandbox-probe-$$"
outside="$project/.sandbox-probe-$$"
home="$HOME/.sandbox-probe-$$"
rm -f "$inside" "$outside" "$home"
writes "$inside" || fail "a sandboxed write inside .lake failed, so the probe itself is broken"
rm -f "$inside"
if writes "$outside"; then rm -f "$outside"; fail "a sandboxed write outside .lake worked: Landlock isn't in force"; fi
if writes "$home"; then rm -f "$home"; fail "a sandboxed write into \$HOME worked: Landlock isn't in force"; fi
echo "ok: inside landrun, a write inside .lake works, and writes outside it fail"

for d in "$@"; do
  [ -d "$d" ] || fail "no such directory to check: $d"
  new="$d/.sandbox-probe-$$"
  if writes "$new"; then fail "a sandboxed write created a file in a frozen directory: $d"; fi
  old="$(find "$d" -type f | sed -n 1p)"
  if [ -n "$old" ] && writes "$old"; then fail "a sandboxed write changed a frozen file in $d"; fi
done
[ "$#" -eq 0 ] || echo "ok: inside landrun, writes into the $# frozen build directories fail"
