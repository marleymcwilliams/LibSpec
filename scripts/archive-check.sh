#!/usr/bin/env bash
# Fails if archive/ is back, or if fixtures/sirusc/ isn't the tree it was copied as, in what's
# committed or in the working tree. archive/ reads at the v1.1 tag now (guide/README.md), and
# fixtures/sirusc/ is its SirusSC/specchain/algebra/ there, byte for byte: the two files that
# scripts/sirusc_adapter.py runs in the differential test. Changing the tree below is the
# human's call.
#
# usage: bash scripts/archive-check.sh [ROOT DIR EXPECTED_TREE]
# The arguments are for scripts/test-archive-check.sh.
set -euo pipefail

root="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
dir="${2:-fixtures/sirusc}"
expected="${3:-b6fa9d4944d910b14cd9b36f89b1279f67a93cf8}"

# Committed, staged, or untracked and not ignored. An ignored file isn't in the repository.
back="$( { git -C "$root" ls-tree -r --name-only HEAD -- archive
           git -C "$root" ls-files --cached --others --exclude-standard -- archive; } | sort -u)"
if [ -n "$back" ]; then
  echo "FAIL: archive/ belongs only at the v1.1 tag, but these are in the repository:"
  printf '%s\n' "$back" | head -n 20
  exit 1
fi
actual="$(git -C "$root" rev-parse -q --verify "HEAD:$dir" || echo none)"
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
echo "ok: no archive/, and $dir/ is tree $expected, with nothing uncommitted"
