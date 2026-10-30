#!/usr/bin/env bash
# The openai/math release's lean/, at the pilot's pinned commit, checked out as files. Git runs
# none of the release's code. Phase 7's untrusted and trusted jobs each fetch it themselves
# (guide/EXECUTABLE_GATE.md §4).
#
# usage: bash scripts/pilot-release.sh RELEASE_DIR
set -euo pipefail

COMMIT=7ef5c0cc5ca4b0e072b7a050fca09ab24bc6fa3a
root="$(cd "$(dirname "$0")/.." && pwd)"
release="$1"

rm -rf "$release"
git init -q "$release"
git -C "$release" remote add origin https://github.com/openai/math.git
git -C "$release" sparse-checkout set --cone lean
git -C "$release" fetch -q --depth 1 --filter=blob:none origin "$COMMIT"
git -C "$release" -c advice.detachedHead=false checkout -q FETCH_HEAD
[ "$(git -C "$release" rev-parse HEAD)" = "$COMMIT" ] || { echo "FAIL: not at $COMMIT"; exit 1; }

# The release must name LibSpec's own toolchain, so elan installs nothing the release chose.
# Nothing of the release's is printed: on a mismatch, only that it differs.
if ! cmp -s "$release/lean/lean-toolchain" "$root/lean/lean-toolchain"; then
  echo "FAIL: the release's lean-toolchain isn't LibSpec's"
  exit 1
fi
echo "release: $COMMIT, toolchain $(cat "$root/lean/lean-toolchain"), the same as LibSpec's"
