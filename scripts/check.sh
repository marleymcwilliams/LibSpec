#!/usr/bin/env bash
# Build, forbidden-token scan, axiom audit, statements-unchanged check, and links.
# Runs locally (Git Bash on Windows) and in CI. Exits non-zero on any failure.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
lean_dir="$root/lean"
fail=0

step() { printf '\n== %s\n' "$1"; }

step "Build"
(cd "$lean_dir" && lake build)

step "Forbidden tokens in Proofs, Lemmas, Tests, Harness and Pilot, and Gate.lean"
dirs=()
for d in Proofs Lemmas Tests Harness Pilot; do
  if [ -d "$lean_dir/JSG/$d" ]; then dirs+=("$lean_dir/JSG/$d"); fi
done
# The harness's entry point sits beside the checks in lean/, outside those directories.
if [ -f "$lean_dir/Gate.lean" ]; then dirs+=("$lean_dir/Gate.lean"); fi
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

# Every file the statements' meaning depends on: Statements.lean, each project
# module it imports (transitively; a missing one is still listed, so deleting it
# shows up in the diff), the Lean toolchain, the Mathlib pin and the lakefile.
statement_files() {
  local queue=(JSG.Statements) seen=" " mod file imp
  while [ "${#queue[@]}" -gt 0 ]; do
    mod="${queue[0]}"
    queue=("${queue[@]:1}")
    case "$seen" in *" $mod "*) continue ;; esac
    seen="$seen$mod "
    file="lean/${mod//.//}.lean"
    echo "$file"
    [ -f "$root/$file" ] || continue
    while read -r imp; do
      case "$imp" in JSG | JSG.*) queue+=("$imp") ;; esac
    done < <(sed -nE 's/^[[:space:]]*((public|private)[[:space:]]+)?(meta[[:space:]]+)?import[[:space:]]+(all[[:space:]]+)?([^[:space:]]+).*/\5/p' "$root/$file")
  done
  printf '%s\n' lean/lean-toolchain lean/lake-manifest.json lean/lakefile.toml
}

# Diffs the covered files against the latest statements-v* tag. origin is asked too:
# once a tag exists there, a clone that lacks it fails here instead of skipping.
# CI must be able to reach origin.
statements_check() {
  local local_tag remote_tag="" remote_out remote_ok=1
  local_tag="$(git -C "$root" tag -l 'statements-v*' | sort -V | tail -n 1)"
  if remote_out="$(git -C "$root" ls-remote --tags --refs origin 'statements-v*' 2>/dev/null)"; then
    remote_tag="$(printf '%s\n' "$remote_out" | sed -n 's#.*refs/tags/##p' | sort -V | tail -n 1)"
  else
    remote_ok=0
  fi
  if [ "$remote_ok" -eq 1 ] && [ "$remote_tag" != "$local_tag" ]; then
    echo "FAIL: origin's latest statements tag is '${remote_tag:-none}' but this clone's is '${local_tag:-none}'; fetch tags (git fetch --tags) or push the tag"
    return 1
  fi
  if [ -z "$local_tag" ]; then
    if [ "$remote_ok" -eq 0 ] && [ -n "${CI:-}" ]; then
      echo "FAIL: CI couldn't ask origin for statements tags, so it can't tell 'not frozen yet' from 'tags missing'"
      return 1
    fi
    echo "skipped: no statements-v* tag yet; once one exists, a missing tag fails. It will cover:"
    printf '  %s\n' "${covered[@]}"
    if [ "$remote_ok" -eq 0 ]; then echo "  (origin unreachable: checked local tags only)"; fi
    return 0
  fi
  if git -C "$root" diff --exit-code "$local_tag" -- "${covered[@]}"; then
    echo "ok ($local_tag): ${covered[*]}"
  else
    echo "FAIL: files the statements depend on differ from $local_tag"
    return 1
  fi
}

step "Statements unchanged since the latest statements-v* tag"
mapfile -t covered < <(statement_files)
statements_check || fail=1

step "Links in the Markdown, outside archive/ (scripts/check-links.py)"
"${PYTHON:-python3}" "$root/scripts/check-links.py" "$root" || fail=1

echo
if [ "$fail" -ne 0 ]; then echo "check.sh: FAILED"; else echo "check.sh: passed"; fi
exit "$fail"
