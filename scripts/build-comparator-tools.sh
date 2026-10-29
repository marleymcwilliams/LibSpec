#!/usr/bin/env bash
# Builds Comparator's tools into <dest>/bin: comparator, lean4export and landrun, and with
# --with-nanoda also nanoda_bin, the nanoda kernel the full-strength run enables.
# comparator is pinned to its v4.34.0 tag, whose manifest pins lean4export v4.34.0.
# Both Lean tools are built with this repo's lean-toolchain: lean4export reads our
# .olean files, which load only under the exact Lean version that wrote them.
# Needs git, go and elan, and cargo for nanoda. Linux only (landrun uses Landlock).
set -euo pipefail

COMPARATOR_REV=d03acab154d269c06e60e4de7e4cc85deebff94b # tag v4.34.0
LANDRUN_REV=811cfff51ceaf3d9843708aa6d22e9b84ccac8b4    # main, 2026-10-13
NANODA_REV=d0a02cc5defadd683f62f9d078f41688314fa31f     # master, 2026-10-27 (0.4.30)

root="$(cd "$(dirname "$0")/.." && pwd)"
dest="${1:?usage: build-comparator-tools.sh <dest> [--with-nanoda]}"
with_nanoda="${2:-}"
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

if [ "$with_nanoda" = "--with-nanoda" ]; then
  git clone -q https://github.com/ammkrn/nanoda_lib "$src/nanoda"
  git -C "$src/nanoda" checkout -q "$NANODA_REV"
  (cd "$src/nanoda" && cargo build --release --locked)
  cp "$src/nanoda/target/release/nanoda_bin" "$dest/bin/"
elif [ -n "$with_nanoda" ]; then
  echo "unknown option: $with_nanoda" >&2
  exit 2
fi

ls -l "$dest/bin"
