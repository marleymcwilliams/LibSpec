#!/usr/bin/env bash
# Shows that scripts/archive-check.sh has teeth, on a throwaway repository of its own: it must
# pass on the frozen tree with no archive/, and fail, for the reason given, on a committed
# change, an uncommitted change, a new file and a missing directory, and on an archive/ that is
# committed, staged, or untracked and not ignored. The frozen/ and archive/ folders below are
# that repository's own: LibSpec's are untouched.
#
# usage: bash scripts/test-archive-check.sh
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
t="$(mktemp -d)"
trap 'rm -rf "$t"' EXIT
git_t() { git -C "$t" -c user.name=test -c user.email=test@example.invalid -c core.autocrlf=false "$@"; }
fail=0
passes() {
  local out
  if out="$(bash "$here/archive-check.sh" "$t" frozen "$expected" 2>&1)"; then
    echo "ok: $1"
  else
    echo "FAIL: $1: the check failed:"
    printf '%s\n' "$out" | sed 's/^/  /'
    fail=1
  fi
}
fails() {
  local out
  if out="$(bash "$here/archive-check.sh" "$t" "${3:-frozen}" "$expected" 2>&1)"; then
    echo "FAIL: $1: the check passed"
    fail=1
  elif grep -qF -- "$2" <<< "$out"; then
    echo "ok: $1"
  else
    echo "FAIL: $1: the check failed, but not with \"$2\":"
    printf '%s\n' "$out" | sed 's/^/  /'
    fail=1
  fi
}

git_t init -q
mkdir "$t/frozen"
echo original > "$t/frozen/a.txt"
git_t add frozen
git_t commit -q -m frozen
expected="$(git_t rev-parse HEAD:frozen)"
passes "the frozen tree, with no archive/, passes"

mkdir "$t/archive"
echo x > "$t/archive/x.txt"
fails "an untracked file in archive/ fails" "archive/ belongs only at the v1.1 tag"
mkdir -p "$t/.git/info"
echo archive/ >> "$t/.git/info/exclude"
passes "an ignored file in archive/ passes: it isn't in the repository"
git_t add -f archive
fails "a file staged in archive/ fails" "archive/ belongs only at the v1.1 tag"
git_t commit -q -m archive
fails "a committed archive/ fails" "archive/ belongs only at the v1.1 tag"
git_t rm -q -r --cached archive
fails "an archive/ staged for deletion, but still in HEAD, fails" "archive/ belongs only at the v1.1 tag"
git_t commit -q -m "no archive"
passes "committing its deletion passes again"

echo changed >> "$t/frozen/a.txt"
fails "an uncommitted change fails" "frozen/ has uncommitted changes"
git_t checkout -q -- frozen
passes "undoing it passes again"

echo new > "$t/frozen/b.txt"
fails "a new file fails" "frozen/ has uncommitted changes"
git_t add frozen
git_t commit -q -m added
fails "a committed change fails" "frozen/ at HEAD is tree"

fails "a missing directory fails" "nothing-here/ at HEAD is tree none" nothing-here
exit "$fail"
