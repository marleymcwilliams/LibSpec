#!/usr/bin/env bash
# The pilot's Comparator runs (guide/EXECUTABLE_GATE.md §3 and §4): a handful of the
# openai/math release's challenges, pinned at 7ef5c0c, at full strength (nanoda and the
# Lean kernel, inside Comparator's landrun sandbox inside the systemd-run wrapper). It
# measures time and disk at each stage, to size a larger run.
#
# Untrusted code: `lake update` and `lake exe cache get` load the release's lakefile, which
# applies its dependency patches with git, and both run outside Comparator's sandbox. Run
# this only on a disposable machine with no secrets, such as a GitHub-hosted runner with a
# read-only token, and treat its results as measurements: code that ran before Comparator
# could have tampered with the run. The challenge and solution builds happen inside the
# sandbox.
#
# usage: bash scripts/pilot-comparator.sh OUT.json CHALLENGE...
# Needs Linux with a systemd user manager, git, python3, and comparator, lean4export,
# landrun and nanoda_bin on PATH (scripts/build-comparator-tools.sh <dest> --with-nanoda).
set -euo pipefail

COMMIT=7ef5c0cc5ca4b0e072b7a050fca09ab24bc6fa3a
out="$1"
shift
challenges=("$@")
work="${PILOT_WORK:-$(mktemp -d)}"
release="$work/openai-math"
lean_dir="$release/lean"
measures="$work/measures.tsv"
: > "$measures"

step() { printf '\n== %s\n' "$1"; }
free_mb() { df -BM --output=avail / | tail -n 1 | tr -dc '0-9'; }
measure() {
  printf '%s\t%s\t%s\n' "$1" "$(date +%s)" "$(free_mb)" >> "$measures"
  echo "measure: $1: $(free_mb) MB free"
}

step "Environment"
[ "$(uname -s)" = Linux ] || { echo "FAIL: needs Linux (landrun uses Landlock)"; exit 1; }
for tool in comparator lean4export landrun nanoda_bin systemd-run lake git python3; do
  command -v "$tool" > /dev/null || { echo "FAIL: $tool not on PATH"; exit 1; }
done
systemctl --user show-environment > /dev/null 2>&1 ||
  { echo "FAIL: no systemd user manager (try: sudo loginctl enable-linger \"\$USER\")"; exit 1; }
echo "kernel: $(uname -r)"
echo "challenges: ${challenges[*]}"
measure start

# in_wrapper <command>...: a command inside the systemd-run wrapper, in the release's lean/.
# MAX_SECONDS caps how long it may run.
in_wrapper() {
  systemd-run --user --quiet --collect --wait --pipe \
    --property=RestrictAddressFamilies=~AF_UNIX \
    --property=NoNewPrivileges=yes \
    --property=RuntimeMaxSec="${MAX_SECONDS:-infinity}" \
    -E PATH="$PATH" -E HOME="$HOME" --working-directory "$lean_dir" \
    -- "$@"
}

step "The wrapper is in force"
mkdir -p "$lean_dir"
unix_socket='import socket; socket.socket(socket.AF_UNIX)'
python3 -c "$unix_socket" || { echo "FAIL: AF_UNIX sockets don't open even outside the wrapper"; exit 1; }
if in_wrapper python3 -c "$unix_socket" 2> /dev/null; then
  echo "FAIL: an AF_UNIX socket opened inside the wrapper"
  exit 1
fi
echo "ok: AF_UNIX sockets open outside the wrapper and are refused inside it"
if in_wrapper sudo -n true 2> /dev/null; then
  echo "FAIL: sudo gained privileges inside the wrapper"
  exit 1
fi
echo "ok: sudo gains no privileges inside the wrapper"

step "The release's lean/, at $COMMIT"
rm -rf "$release"
git init -q "$release"
git -C "$release" remote add origin https://github.com/openai/math.git
git -C "$release" sparse-checkout set --cone lean
git -C "$release" fetch -q --depth 1 --filter=blob:none origin "$COMMIT"
git -C "$release" checkout -q FETCH_HEAD
[ "$(git -C "$release" rev-parse HEAD)" = "$COMMIT" ] || { echo "FAIL: not at $COMMIT"; exit 1; }
echo "toolchain: $(cat "$lean_dir/lean-toolchain")"
du -sh "$release" | sed 's/^/size: /'
measure fetched

step "Its dependencies (untrusted: the release's lakefile runs here)"
(cd "$lean_dir" && lake update)
measure dependencies
(cd "$lean_dir" && lake exe cache get)
du -sh "$lean_dir/.lake/packages" | sed 's/^/packages: /'
measure cache

mkdir -p "$work/configs"
results="$work/results.tsv"
: > "$results"
for c in "${challenges[@]}"; do
  step "Challenge $c"
  config="$work/configs/$c.json"
  python3 - "$lean_dir/ComparatorChallenges/$c.json" "$config" <<'PY'
import json, sys
src, dst = sys.argv[1:]
cfg = json.load(open(src, encoding="utf-8"))
print("theorems:", ", ".join(cfg["theorem_names"]))
print("permitted axioms:", ", ".join(cfg["permitted_axioms"]))
cfg["enable_nanoda"] = True  # full strength, whatever the release's config says
json.dump(cfg, open(dst, "w", encoding="utf-8"), indent=2)
PY
  t0=$(date +%s)
  # Accepted only on Comparator's own success line; a rejection, a build error and a timeout
  # all count as failed here, and the log says which.
  status=failed
  if MAX_SECONDS=6000 in_wrapper bash -c 'lake env comparator "$1"' comparator "$config" 2>&1 |
      tee "$work/$c.log"; then
    grep -q "Your solution is okay!" "$work/$c.log" && status=accepted
  fi
  t1=$(date +%s)
  printf '%s\t%s\t%s\t%s\n' "$c" "$status" "$((t1 - t0))" "$(free_mb)" >> "$results"
  echo "result: $c: $status in $((t1 - t0)) s, $(free_mb) MB free"
  measure "$c"
done

step "Results"
python3 - "$results" "$measures" "$out" "$COMMIT" <<'PY'
import json, sys
results, measures, out, commit = sys.argv[1:]
rows = [l.rstrip("\n").split("\t") for l in open(results) if l.strip()]
stages = [l.rstrip("\n").split("\t") for l in open(measures) if l.strip()]
t0 = int(stages[0][1])
doc = {
    "commit": commit,
    "results": {c: s for c, s, _, _ in rows},
    "challenges": [{"name": c, "result": s, "seconds": int(sec), "freeMBAfter": int(free)}
                   for c, s, sec, free in rows],
    "stages": [{"stage": n, "elapsedSeconds": int(t) - t0, "freeMB": int(f)}
               for n, t, f in stages],
}
json.dump(doc, open(out, "w", encoding="utf-8"), indent=2)
print(json.dumps(doc, indent=2))
PY
echo
echo "pilot-comparator.sh: done (${#challenges[@]} challenges)"
