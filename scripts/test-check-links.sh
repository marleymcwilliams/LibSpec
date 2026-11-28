#!/usr/bin/env bash
# Shows that scripts/check-links.py has teeth, on a throwaway repository of its own: each case
# writes one file of links, which must pass, or fail for the reason given. Its links name a
# made-up repository, example/test, and it never touches the real one.
#
# usage: bash scripts/test-check-links.sh
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
t="$(mktemp -d)"
trap 'rm -rf "$t"' EXIT
git_t() { git -C "$t" -c user.name=test -c user.email=test@example.invalid -c core.autocrlf=false "$@"; }
u="https://github.com/example/test"
fail=0
run() { "${PYTHON:-python3}" "$here/check-links.py" "$t" --repo example/test --pin "v-test=$a" "$@" 2>&1; }
put() { rm -f "$t"/case.*; printf '%s\n' "$2" > "$t/$1"; }
passes() {
  local out
  if ! out="$(run "${@:3}")"; then
    echo "FAIL: $1: the check failed:"
    printf '%s\n' "$out" | sed 's/^/  /'
    fail=1
  elif grep -qxF -- "$2 permanent links and 1 pinned tags checked, 0 broken" <<< "$out"; then
    echo "ok: $1"
  else
    echo "FAIL: $1: the check passed, but didn't find $2 permanent links:"
    printf '%s\n' "$out" | sed 's/^/  /'
    fail=1
  fi
}
fails() {
  local out
  if out="$(run "${@:3}")"; then
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

# Commit a, tagged v-test, then commit b on the branch, and a commit on a side branch. The tags
# and the archive/ folder below are this throwaway repository's own: LibSpec's are untouched.
git_t init -q
printf '# Title\n\n## κ = ψ\n\n## Title\n' > "$t/doc.md"
printf '# A b\n' > "$t/a b.md"
printf 'print(1)\n' > "$t/code.py"
mkdir "$t/dir"
printf 'x\n' > "$t/dir/f.txt"
git_t add -A
git_t commit -q -m a
a="$(git_t rev-parse HEAD)"
git_t tag -a v-test -m v-test
git_t tag other
printf '\n## Later\n' >> "$t/doc.md"
printf 'print(2)\n' > "$t/new.py"
git_t add -A
git_t commit -q -m b
b="$(git_t rev-parse HEAD)"
branch="$(git_t rev-parse --abbrev-ref HEAD)"
git_t checkout -q -b side
printf 'x\n' > "$t/side.txt"
git_t add -A
git_t commit -q -m side
s="$(git_t rev-parse HEAD)"
git_t checkout -q "$branch"
mkdir "$t/archive"
printf '%s\n' "$u/blob/$branch/nothing-here" > "$t/archive/x.md"

put case.md "[a]($u/blob/$a/code.py)"
passes "a link to a file at a full commit id passes" 1
put case.md "[a]($u/blob/$a/doc.md#title) [b]($u/blob/$a/doc.md#title-1)"
passes "links to a heading, and to the second heading of that name, pass" 2
put case.md "[a]($u/blob/$a/doc.md#κ--ψ) [b]($u/blob/$a/doc.md#%CE%BA--%CF%88)"
passes "a link to a heading in Greek passes, as written and percent-encoded" 2
put case.md "[a]($u/blob/$a/a%20b.md#a-b)"
passes "a link to a file with a space in its name passes" 1
put case.md "[a]($u/tree/v-test/dir) [b]($u/tree/v-test)"
passes "links to a directory and to the root, at a pinned tag, pass" 2
put case.py "# See $u/blob/$a/code.py."
passes "a link in a file that isn't Markdown passes, and a full stop after it isn't part of it" 1
put case.md "[a](doc.md#title)"
passes "a relative link to a heading passes" 0
put case.md "x"
passes "a broken link inside archive/ isn't checked" 0

put case.md "[a]($u/blob/$branch/code.py)"
fails "a link at a branch fails" "is a branch, or a tag not in PINS"
put case.md "[a]($u/blob/other/code.py)"
fails "a link at a tag that isn't pinned fails" "is a branch, or a tag not in PINS"
put case.md "[a]($u/blob/${a:0:7}/code.py)"
fails "a link at a short commit id fails" "a short commit id"
put case.md "x"
fails "a pinned tag that names another commit fails" "tag v-test names $a, but PINS pins it to $b" --pin "v-test=$b"
fails "a pinned tag that is missing fails" "tag gone is missing" --pin "gone=$a"
put case.md "[a]($u/blob/$s/code.py)"
fails "a link at a commit outside HEAD's history fails" "isn't in HEAD's history"
put case.md "[a]($u/blob/0123456789abcdef0123456789abcdef01234567/code.py)"
fails "a link at a commit the clone doesn't have fails" "isn't a commit in this clone"
put case.md "[a]($u/blob/$a/new.py)"
fails "a link to a file that exists only at a later commit fails" "no such path at $a"
put case.md "[a]($u/blob/$a/dir)"
fails "a file link to a directory fails" "not a file"
put case.md "[a]($u/tree/$a/code.py)"
fails "a directory link to a file fails" "not a directory"
put case.md "[a]($u/blob/$a/doc.md#later)"
fails "a link to a heading that exists only at a later commit fails" "no heading #later"
put case.md "[a]($u/blob/$a/doc.md#κ--χ)"
fails "a link to a missing heading in Greek fails" "no heading #κ--χ"
put case.md "[a]($u/blob/$a/code.py#L1)"
fails "an anchor on a file that isn't Markdown fails" "only on a Markdown file"
put case.md "[a]($u/blob/$a/doc.md?plain=1)"
fails "a link with a query fails" "a query"
put case.py "# See $u/blob/$a/nothing-here.py"
fails "a broken link in a file that isn't Markdown fails" "case.py:1:"
put case.md "[a](https://github.com/Example/TEST/blob/$a/nothing-here.py)"
fails "a link is checked whatever the case of the repository's name" "no such path"
put case.md "[a](archive/x.md)"
fails "a relative link into archive/ fails" "inside archive/"
put case.md "[a](nothing-here.md)"
fails "a relative link to a missing file fails" "no such file"
put case.md "[a](doc.md#nothing-here)"
fails "a relative link to a missing heading fails" "no heading #nothing-here"
exit "$fail"
