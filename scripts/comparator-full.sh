#!/usr/bin/env bash
# Comparator at full strength, the gold-standard check in the Lean reference's "Validating
# Proofs": every frozen theorem in JSG.Statements must be proved in JSG.Solution, with only
# propext, Quot.sound and Classical.choice, and accepted by both the Lean kernel and the
# nanoda kernel (enable_nanoda). Each Comparator run goes inside the systemd-run wrapper
# from Comparator's README, which blocks AF_UNIX sockets to guard against a landrun escape
# that Linux 7.1 fixes, around Comparator's own landrun sandbox.
#
# Differences from the README's command, both about running unattended:
# - --pipe --wait in place of --pty: CI has no terminal. The sandbox properties are the same.
# - NoNewPrivileges=yes: a sandboxed process can't gain privileges, sudo included.
#
# Run it on a fresh checkout. Comparator's guarantees assume the solution was never built
# outside its sandbox, so this script builds only the challenge (JSG.Statements, which is
# trusted) before Comparator runs; `lake exe cache get` for Mathlib is allowed. Needs Linux
# with a systemd user manager, and comparator, lean4export, landrun and nanoda_bin on PATH
# (scripts/build-comparator-tools.sh <dest> --with-nanoda).
set -euo pipefail
echo "THROWAWAY: failing on purpose, to test the job reports it"; exit 1

root="$(cd "$(dirname "$0")/.." && pwd)"
lean_dir="$root/lean"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

step() { printf '\n== %s\n' "$1"; }

step "Environment"
[ "$(uname -s)" = Linux ] || { echo "FAIL: needs Linux (landrun uses Landlock)"; exit 1; }
for tool in comparator lean4export landrun nanoda_bin systemd-run lake; do
  command -v "$tool" > /dev/null || { echo "FAIL: $tool not on PATH"; exit 1; }
done
systemctl --user show-environment > /dev/null 2>&1 ||
  { echo "FAIL: no systemd user manager (try: sudo loginctl enable-linger \"\$USER\")"; exit 1; }
echo "kernel: $(uname -r)"
echo "systemd: $(systemd-run --version | head -n 1)"
echo "lean: $(cd "$lean_dir" && lake env lean --version)"
echo "commit: $(git -C "$root" rev-parse HEAD)"
if [ -d "$lean_dir/.lake/build/lib/lean/JSG/Proofs" ]; then
  echo "FAIL: the proofs are already built; run this on a fresh checkout"
  exit 1
fi

# targets <root module> <module prefix>: theorems declared in modules under the prefix.
targets() { (cd "$lean_dir" && lake env lean --run ComparatorTargets.lean "$1" "$2"); }

# write_config <file> <challenge> <solution> <theorem>...
write_config() {
  python3 - "$@" <<'PY'
import json, sys
path, challenge, solution, *names = sys.argv[1:]
with open(path, "w") as f:
    json.dump({"challenge_module": challenge, "solution_module": solution,
               "theorem_names": names, "definition_names": [],
               "permitted_axioms": ["propext", "Quot.sound", "Classical.choice"],
               "enable_nanoda": True}, f, indent=2)
PY
}

# in_wrapper <command>...: a command inside the systemd-run wrapper.
in_wrapper() {
  systemd-run --user --quiet --collect --wait --pipe \
    --property=RestrictAddressFamilies=~AF_UNIX \
    --property=NoNewPrivileges=yes \
    -E PATH="$PATH" -E HOME="$HOME" --working-directory "$lean_dir" \
    -- "$@"
}

# wrapped <config>: Comparator inside the wrapper.
wrapped() { in_wrapper bash -c 'lake env comparator "$1"' comparator "$1"; }

step "The wrapper is in force"
in_wrapper true || { echo "FAIL: systemd-run couldn't start a service"; exit 1; }
unix_socket='import socket; socket.socket(socket.AF_UNIX)'
python3 -c "$unix_socket" || { echo "FAIL: the probe can't open an AF_UNIX socket even outside the wrapper"; exit 1; }
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

step "The challenge's theorems (JSG.Statements, built outside the sandbox: it is trusted)"
(cd "$lean_dir" && lake build JSG.Statements)
mapfile -t frozen < <(targets JSG.Statements JSG.Statements)
echo "${#frozen[@]} frozen theorems"
[ "${#frozen[@]}" -gt 0 ] || { echo "FAIL: no frozen theorems found"; exit 1; }

step "Self-test: the correct solution must pass, with nanoda, inside the wrapper"
(cd "$lean_dir" && lake build JSG.Tests.Comparator.Challenge)
mapfile -t self < <(targets JSG.Tests.Comparator.Challenge JSG.Tests.Comparator.Challenge)
write_config "$work/self.json" JSG.Tests.Comparator.Challenge JSG.Tests.Comparator.Solution "${self[@]}"
wrapped "$work/self.json"

step "Self-test: the mutant must be rejected for its statement"
write_config "$work/mutant.json" JSG.Tests.Comparator.Challenge JSG.Tests.Comparator.Mutant "${self[@]}"
if out="$(wrapped "$work/mutant.json" 2>&1)"; then
  printf '%s\n' "$out"
  echo "FAIL: Comparator accepted the mutant"
  exit 1
fi
if ! printf '%s\n' "$out" | grep -q 'theorem statement do not match'; then
  printf '%s\n' "$out"
  echo "FAIL: the mutant was rejected, but not for its statement"
  exit 1
fi
echo "ok: rejected because its statement differs from the challenge"

step "Every frozen theorem, proved in JSG.Solution, checked by both kernels"
write_config "$work/jsg.json" JSG.Statements JSG.Solution "${frozen[@]}"
wrapped "$work/jsg.json"

echo
echo "comparator-full.sh: passed (${#frozen[@]} theorems, Lean kernel and nanoda, full sandbox)"
