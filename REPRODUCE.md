# Reproducing LibSpec

This takes a fresh machine through building everything, running the checks, and reading off what is proved and what isn't. Each step says what you should see.

**Which version.** It describes `main`: 34 frozen theorems, all proved. v1.0, the tag `v1.0`, had the first 26. `statements-v4` added eight more, which Milestone 4 proved ([the executable gate](guide/EXECUTABLE_GATE.md)). Where v1.0 differs, the step says so.

## What you need

- **git**, and network access to GitHub. The statements check asks GitHub for the latest `statements-v*` tag.
- **elan**, the Lean toolchain manager ([installation](https://lean-lang.org/install/)). It installs the pinned Lean, v4.34.1 from `lean/lean-toolchain`, the first time you run `lake`.
- **bash.** On Windows, use Git Bash, which comes with Git for Windows.
- **About 10 GB of free disk**, since Mathlib and its prebuilt cache take about 7.5 GB, and **at least 8 GB of RAM**. These figures were measured on the 16 GB Windows machine this was built on:
  - **A command-line build** of one module that imports Mathlib took about 2.5–3.5 GB at its peak, measured as the drop in available memory while it ran.
  - **An editor tab** costs more. Each VS Code Lean worker with such a file open held about 8 GB.
  - **Each project's Lean server** took about 2 GB more, even with no file loaded.

  So close other Lean tabs before you build.
- **For Comparator only:** Linux, with Go, Python 3 and, for the full-strength run, Rust and a systemd user manager. On Windows, use WSL or the GitHub Actions workflow below.

## 1. Clone

```bash
git clone https://github.com/marleymcwilliams/LibSpec.git
cd LibSpec
```

A clone brings the `statements-v*` tags with it, which the statements check needs. To check v1.0 exactly, run `git checkout v1.0` next. To check `main`, skip that.

## 2. Build

```bash
cd lean
lake exe cache get
lake build
cd ..
```

`lake exe cache get` downloads Mathlib's prebuilt files, so you don't compile Mathlib, which would take hours. `lake build` then builds every module: the definitions and statements, the proofs, the helper lemmas and the tests. It should end with "Build completed successfully".

The only warnings are "declaration uses `sorry`", in `JSG/Statements.lean` and in the Comparator fixtures under `JSG/Tests/Comparator/`. Both hold statements without proofs, by design: the proofs are in `JSG/Proofs/`.

## 3. Run the checks

From the repository root:

```bash
bash scripts/check.sh
```

It runs four steps and ends with `check.sh: passed`:

| Step | What it checks | What you should see |
| --- | --- | --- |
| Build | `lake build` again, which is quick once step 2 has run | no errors |
| Forbidden tokens | no `sorry`, `admit`, `axiom` or native evaluation in `Proofs/`, `Lemmas/`, `Tests/` or `Harness/`, or in `lean/Gate.lean` | `ok` |
| Axiom audit | `#print axioms` on every theorem in `Proofs/`, `Lemmas/`, `Tests/` and `Harness/` (`lean/AxiomAudit.lean`) | each theorem lists only `propext`, `Classical.choice` and `Quot.sound`, then `ok` |
| Statements unchanged | `Defs.lean`, `Statements.lean`, their imports, the toolchain, the Mathlib pin and the lakefile, against the latest `statements-v*` tag | `ok (statements-v4): …`, or `ok (statements-v3): …` at v1.0 |

To replay every module through Lean's kernel as well, as CI does:

```bash
cd lean
LEAN_NUM_THREADS=1 lake env leanchecker JSG
```

`LEAN_NUM_THREADS=1` keeps its memory down; without it, it can use over 15 GB.

## 4. Comparator: does each proof prove exactly its frozen statement?

The checks above show that the proofs compile and use only the three axioms. Comparator shows something stronger: each theorem in `JSG/Proofs/` proves exactly the statement frozen in `JSG.Statements`, with no hidden change of definitions. It needs Linux.

**The everyday run**, which CI does on every pull request:

```bash
bash scripts/build-comparator-tools.sh ~/comparator-tools
PATH="$HOME/comparator-tools/bin:$PATH" bash scripts/comparator.sh
```

It runs a self-test, in which a correct fixture must pass and a mutant must be rejected. Then it checks every proof, and lists the frozen theorems not yet proved. You should see "Your solution is okay!", and "none" under "Frozen theorems not yet proved", on `main` and at v1.0 alike.

**The full-strength run** is the gold-standard check that the Lean reference's ["Validating Proofs"](https://lean-lang.org/doc/reference/latest/ValidatingProofs/) chapter describes. It adds three things to the everyday run:
- **A second kernel:** nanoda checks the solution as well as Lean's own kernel.
- **The full sandbox:** Comparator's landrun sandbox runs inside the `systemd-run` wrapper from [Comparator's README](https://github.com/leanprover/comparator), which blocks AF_UNIX sockets. That guards against a landrun escape that Linux 7.1 fixes.
- **A clean start:** a fresh checkout, where nothing but the trusted statements is built outside the sandbox. The script checks that the wrapper is in force before Comparator runs.

There are two ways to run it:
- **On GitHub:** Actions, "Comparator (full strength)", "Run workflow" (`.github/workflows/comparator-full.yml`). To check v1.0, pick the tag `v1.0` under "Use workflow from". Its run summary lists the result.
- **On Linux or WSL**, on a fresh clone:

  ```bash
  cd lean && lake exe cache get && cd ..
  bash scripts/build-comparator-tools.sh ~/comparator-full-tools --with-nanoda
  sudo loginctl enable-linger "$USER"          # starts a systemd user manager, if none runs
  PATH="$HOME/comparator-full-tools/bin:$PATH" bash scripts/comparator-full.sh
  ```

  On `main` it ends with `comparator-full.sh: passed (34 theorems, Lean kernel and nanoda, full sandbox)`, and at v1.0 with the same line for 26 theorems. Don't run step 2 first: Comparator's guarantee assumes the proofs were never built outside its sandbox, and the script stops if they were.

  `lake exe cache get` itself is allowed: it downloads Mathlib, not the proofs. On WSL, enable systemd first (`systemd=true` under `[boot]` in `/etc/wsl.conf`, then `wsl --shutdown`). landrun also needs a kernel with Landlock; if WSL's kernel lacks it, the self-test fails before anything is checked.

The script differs from the README's command in two ways, both for running unattended. It uses `--pipe --wait` in place of `--pty`, since CI has no terminal; the sandbox is the same. And it adds `NoNewPrivileges=yes`, so nothing inside the sandbox can gain privileges.

## 5. Read off what is proved and what isn't

- **[The layer map](guide/MASTER_GUIDE.md#layer-map):** every component, with its status, its limits, and a pointer to its Lean theorem or to the reason it's out of scope.
- **The milestone notes:** [Milestone 1](guide/MILESTONE_1.md), [Milestone 2](guide/MILESTONE_2.md), [Milestone 3](guide/MILESTONE_3.md) and [Milestone 4](guide/MILESTONE_4.md). Each has a plain-English explanation of every proof, the gate record, and a closing note on what is proved and what it doesn't show.
- **[The changelog](guide/CHANGELOG.md):** each statements version, and whether it tightened or weakened the statements. Its `statements-v4` entry lists what v4 adds.

## Full-strength runs

The latest run checked all 34 frozen theorems, on `main` at `6a8a77c`, after Milestone 4. Every run before it checked v1.0's 26. The first run on `main` was started by hand at `d568ed1`, after #56, #57 and #58 were merged. The four before it came from #56, which added the workflow, before it was merged. Each of those checked `main`'s proofs, since #56 changes no Lean file. Each later run started by hand on `main` gets a row here too. The three earliest ran before the step had `shell: bash`, when a failing script could still have shown green. Their logs show they passed: each ends with the script's own pass line, which it prints only if every step succeeded.

| Date | Run | Commit | Result |
| --- | --- | --- | --- |
| 2026-10-29 | [40840546350](https://github.com/marleymcwilliams/LibSpec/actions/runs/40840546350) | `main` at `6a8a77c`, after Milestone 4, started with `gh workflow run` | **Passed** with all 34 frozen theorems. Both probes passed, the self-test passed, the mutant was rejected for its statement, and the Lean kernel and nanoda each accept the solution. Linux 7.0.0-1017-azure, systemd 255, Lean 4.34.1, 5 min |
| 2026-10-28 | [40781130345](https://github.com/marleymcwilliams/LibSpec/actions/runs/40781130345) | `main` at `d568ed1`, started by hand | **Passed**, the first run on `main`. Both probes passed, the self-test passed, the mutant was rejected for its statement, and the Lean kernel and nanoda each accept all 26 frozen theorems. Linux 7.0.0-1017-azure, systemd 255, Lean 4.34.1, 6 min |
| 2026-10-28 | [40761806692](https://github.com/marleymcwilliams/LibSpec/actions/runs/40761806692) | #56's head `104874b`, on `main` at `2e6cbf7` | **Passed**, the first run whose step has `shell: bash`, so a failing script turns it red: the same checks as the row below, 5 min |
| 2026-10-28 | [40757821081](https://github.com/marleymcwilliams/LibSpec/actions/runs/40757821081) | #56's head `8e25f5b`, on `main` at `2e6cbf7` | **Passed.** Both probes passed: AF_UNIX opens outside the wrapper and is refused inside, and `sudo` gains nothing inside. The self-test passed, the mutant was rejected for its statement, and the Lean kernel and nanoda each accept all 26 frozen theorems. Linux 7.0.0-1017-azure, systemd 255, 4.5 min |
| 2026-10-28 | [40757022820](https://github.com/marleymcwilliams/LibSpec/actions/runs/40757022820) | #56's head `e4a1a00`, on `main` at `2e6cbf7` | Passed, before the AF_UNIX probe had its positive control |
| 2026-10-28 | [40755807109](https://github.com/marleymcwilliams/LibSpec/actions/runs/40755807109) | #56's head `432039e`, on `main` at `2e6cbf7` | Passed, before the wrapper probe existed |

Tools: Comparator v4.34.0 (`d03acab`), lean4export v4.34.0, landrun `811cfff`, nanoda_lib 0.4.30 (`d0a02cc`); Lean 4.34.1, Mathlib v4.34.1.
