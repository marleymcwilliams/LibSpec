#!/usr/bin/env bash
# Untrusted. Runs the openai/math release's own lakefile, through `lake update`, which clones
# its dependencies at their pinned commits and applies its compatibility patches. Run it only
# in Phase 7's untrusted job: a disposable runner, off main, with a read-only token, no
# credentials in its checkout, and read-only cache access. The trusted job never builds from
# what it leaves; it only compares it with its own rebuild (guide/EXECUTABLE_GATE.md §4).
#
# usage: bash scripts/pilot-fetch.sh RELEASE_DIR   (after scripts/pilot-release.sh RELEASE_DIR)
set -euo pipefail

cd "$1/lean"
# Mathlib's post-update hook would fetch its build cache here. The tree the trusted job
# compares leaves build outputs out, so this job doesn't need it.
MATHLIB_NO_CACHE_ON_UPDATE=1 lake update
du -sh .lake/packages | sed 's/^/packages: /'
