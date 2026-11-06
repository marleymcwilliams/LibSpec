#!/usr/bin/env bash
# Shows that scripts/codeowners_check.py has teeth, on CODEOWNERS files of its own in a throwaway
# directory. Rules naming each path, or a directory above it, from the root must pass, and so must
# a later rule that gives a path back to Marley. The check must fail when a path has no rule, when
# a later rule hands it to someone else or to no one, when the rule that decides it is a glob,
# isn't anchored at the root, names only the root, or only shares a prefix with the path, when
# only the machine account owns it, and when the file is missing. It never reads the real
# .github/CODEOWNERS.
#
# usage: bash scripts/test-codeowners-check.sh
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
t="$(mktemp -d)"
trap 'rm -rf "$t"' EXIT
fail=0
paths=(lean/JSG/Statements.lean lean/JSG/Defs.lean lean/lean-toolchain .github/CODEOWNERS)
check() { "${PYTHON:-python3}" "$here/codeowners_check.py" "$t/$1" "${paths[@]}" 2>&1; }
passes() {
  if check "$1" > /dev/null; then
    echo "ok: $2"
  else
    echo "FAIL: $2: the check failed"
    fail=1
  fi
}
# A failure counts only with the check's own FAIL line, so a crash doesn't pass for one.
fails() {
  local out
  if out="$(check "$1")"; then
    echo "FAIL: $2: the check passed"
    fail=1
  elif grep -q '^FAIL: ' <<< "$out"; then
    echo "ok: $2 ($(grep -m 1 '^FAIL: ' <<< "$out" | sed 's/^FAIL: //'))"
  else
    echo "FAIL: $2: the check stopped without saying why:"
    printf '%s\n' "$out" | head -n 5
    fail=1
  fi
}
rules() { local name="$1"; shift; printf '%s\n' "$@" > "$t/$name"; }

rules good '# A comment, then a blank line.' '' \
  '/lean/ @marleymcwilliams' \
  '/lean/JSG/Statements.lean @marleymcwilliams' \
  '/lean/JSG/Defs.lean @MarleyMcWilliams' \
  '/.github/ @someone-else @marleymcwilliams'
passes good "exact paths and directories above them pass, the owner in any case"

rules back '/lean/ @someone-else' '/.github/ @someone-else' \
  '/lean/ @marleymcwilliams' '/.github/CODEOWNERS @marleymcwilliams'
passes back "a later rule that gives the paths back to Marley passes"

rules missing '/lean/JSG/ @marleymcwilliams' '/.github/ @marleymcwilliams'
fails missing "a path with no rule fails"

cp "$t/good" "$t/handed"
echo '/lean/JSG/ @someone-else' >> "$t/handed"
fails handed "a later rule that hands a path to someone else fails"

cp "$t/good" "$t/unowned"
echo '/lean/lean-toolchain' >> "$t/unowned"
fails unowned "a later rule with no owners fails"

cp "$t/good" "$t/glob"
echo '*.lean @marleymcwilliams' >> "$t/glob"
fails glob "a later glob decides, and fails even when it names Marley"

rules unanchored '/lean/ @marleymcwilliams' '.github/ @marleymcwilliams'
fails unanchored "a rule not anchored at the root fails"

rules root '/ @marleymcwilliams'
fails root "a rule naming only the root fails"

rules prefix '/lean/ @marleymcwilliams' '/.github/CODEOWNER @marleymcwilliams'
fails prefix "a rule that only shares a prefix with the path fails"

rules machine '/lean/ @MarleyMCo' '/.github/ @MarleyMCo'
fails machine "the machine account alone fails"

fails nothing-here "a missing file fails"
exit "$fail"
