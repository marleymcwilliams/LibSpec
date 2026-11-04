#!/usr/bin/env bash
# Shows that scripts/archive-check.sh has teeth, on a throwaway repository of its own: it must
# pass on the frozen tree, and fail on a committed change, an uncommitted change, a new file and
# a missing directory. It never touches the real archive/.
#
# usage: bash scripts/test-archive-check.sh
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
t="$(mktemp -d)"
trap 'rm -rf "$t"' EXIT
git_t() { git -C "$t" -c user.name=test -c user.email=test@example.invalid -c core.autocrlf=false "$@"; }
fail=0
passes() {
  if bash "$here/archive-check.sh" "$t" frozen "$expected" > /dev/null 2>&1; then
    echo "ok: $1"
  else
    echo "FAIL: $1: the check failed"
    fail=1
  fi
}
fails() {
  if bash "$here/archive-check.sh" "$t" "${2:-frozen}" "$expected" > /dev/null 2>&1; then
    echo "FAIL: $1: the check passed"
    fail=1
  else
    echo "ok: $1"
  fi
}

git_t init -q
mkdir "$t/frozen"
echo original > "$t/frozen/a.txt"
git_t add frozen
git_t commit -q -m frozen
expected="$(git_t rev-parse HEAD:frozen)"
passes "the frozen tree passes"

echo changed >> "$t/frozen/a.txt"
fails "an uncommitted change fails"
git_t checkout -q -- frozen
passes "undoing it passes again"

echo new > "$t/frozen/b.txt"
fails "a new file fails"
git_t add frozen
git_t commit -q -m added
fails "a committed change fails"

fails "a missing directory fails" nothing-here
exit "$fail"
