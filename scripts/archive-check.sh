#!/usr/bin/env bash
# Fails if archive/ isn't the tree it was frozen at, in what's committed or in the working tree.
# CLAUDE.md makes archive/ read-only, and nothing else in CI looks at it: the statements check
# covers only the statements and what they depend on. Changing the tree below is the human's call.
#
# usage: bash scripts/archive-check.sh [ROOT DIR EXPECTED_TREE]
# The arguments are for scripts/test-archive-check.sh.
set -euo pipefail

root="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
dir="${2:-archive}"
expected="${3:-c2f6dac87b38162fc6b24add2e28dc4bd85ed627}"

actual="$(git -C "$root" rev-parse "HEAD:$dir" 2> /dev/null || echo none)"
if [ "$actual" != "$expected" ]; then
  echo "FAIL: $dir/ at HEAD is tree $actual, not $expected"
  exit 1
fi
changed="$(git -C "$root" status --porcelain -- "$dir")"
if [ -n "$changed" ]; then
  echo "FAIL: $dir/ has uncommitted changes:"
  printf '%s\n' "$changed" | head -n 20
  exit 1
fi
echo "ok: $dir/ is tree $expected, with nothing uncommitted"
