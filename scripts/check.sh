#!/usr/bin/env bash
# Build, forbidden-token scan, axiom audit, and statements-unchanged check.
# Runs locally (Git Bash on Windows) and in CI. Exits non-zero on any failure.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
lean_dir="$root/lean"
fail=0

step() { printf '\n== %s\n' "$1"; }

step "Build"
(cd "$lean_dir" && lake build)

step "Forbidden tokens in Proofs, Lemmas and Tests"
dirs=()
for d in Proofs Lemmas Tests; do
  if [ -d "$lean_dir/JSG/$d" ]; then dirs+=("$lean_dir/JSG/$d"); fi
done
pattern='\bsorry\b|\badmit\b|native_decide|decide \+native|^[[:space:]]*axiom[[:space:]]'
if grep -rnE --include='*.lean' "$pattern" "${dirs[@]}"; then
  echo "FAIL: forbidden token found"
  fail=1
else
  echo "ok"
fi

step "Axiom audit (lean/AxiomAudit.lean)"
if out="$(cd "$lean_dir" && lake env lean AxiomAudit.lean 2>&1)"; then
  printf '%s\n' "$out"
  # Join wrapped lines, then pull out every axiom named in a "depends on axioms: [...]" list.
  bad="$(printf '%s\n' "$out" | tr '\n' ' ' \
    | grep -oE 'depends on axioms: \[[^]]*\]' \
    | sed -E 's/.*\[(.*)\]/\1/' | tr ',' '\n' | sed -E 's/^ +| +$//g' \
    | grep -vxE 'propext|Classical\.choice|Quot\.sound' | sort -u || true)"
  if [ -n "$bad" ]; then
    echo "FAIL: disallowed axioms:"
    printf '  %s\n' $bad
    fail=1
  else
    echo "ok"
  fi
else
  printf '%s\n' "$out"
  echo "FAIL: AxiomAudit.lean did not compile"
  fail=1
fi

step "Statements unchanged since the latest statements-v* tag"
tag="$(git -C "$root" tag -l 'statements-v*' --sort=-v:refname | head -n 1)"
if [ -z "$tag" ]; then
  echo "skipped: no statements-v* tag yet (created in Phase 2)"
elif git -C "$root" diff --exit-code "$tag" -- lean/JSG/Statements.lean; then
  echo "ok ($tag)"
else
  echo "FAIL: lean/JSG/Statements.lean differs from $tag"
  fail=1
fi

echo
if [ "$fail" -ne 0 ]; then echo "check.sh: FAILED"; else echo "check.sh: passed"; fi
exit "$fail"
