#!/usr/bin/env bash
# Builds Comparator's tools into <dest>/bin: comparator, lean4export and landrun.
# comparator is pinned to its v4.34.0 tag, whose manifest pins lean4export v4.34.0.
# Both Lean tools are built with this repo's lean-toolchain: lean4export reads our
# .olean files, which load only under the exact Lean version that wrote them.
# Needs git, go and elan. Linux only (landrun uses Landlock).
set -euo pipefail

COMPARATOR_REV=d03acab154d269c06e60e4de7e4cc85deebff94b # tag v4.34.0
LANDRUN_REV=811cfff51ceaf3d9843708aa6d22e9b84ccac8b4    # main, 2026-10-13

root="$(cd "$(dirname "$0")/.." && pwd)"
dest="${1:?usage: build-comparator-tools.sh <dest>}"
src="$(mktemp -d)"
trap 'rm -rf "$src"' EXIT
mkdir -p "$dest/bin"

git clone -q https://github.com/leanprover/comparator "$src/comparator"
git -C "$src/comparator" checkout -q "$COMPARATOR_REV"
cp "$root/lean/lean-toolchain" "$src/comparator/lean-toolchain"
(cd "$src/comparator" && lake build lean4export comparator)
cp "$src/comparator/.lake/build/bin/comparator" "$dest/bin/"
cp "$src/comparator/.lake/packages/lean4export/.lake/build/bin/lean4export" "$dest/bin/"

git clone -q https://github.com/Zouuup/landrun "$src/landrun"
git -C "$src/landrun" checkout -q "$LANDRUN_REV"
(cd "$src/landrun" && go build -o "$dest/bin/landrun" ./cmd/landrun)

ls -l "$dest/bin"
