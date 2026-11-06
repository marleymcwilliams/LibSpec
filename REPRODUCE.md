# Reproducing LibSpec

This takes a fresh machine through building everything, running the checks, and reading off what is proved and what isn't. Each step says what you should see.

**Which version.** It describes `main`: 34 frozen theorems, all proved. v1.0, the tag `v1.0`, had the first 26. `statements-v4` added eight more, which Milestone 4 proved ([the executable gate](guide/EXECUTABLE_GATE.md)). v1.1, the tag `v1.1` at `6f2ffae`, has all 34 proved and adds the pilot. Where v1.0 differs, the step says so. The pilot in step 6 is what v1.1 adds.

## What you need

- **git**, and network access to GitHub. The statements check asks GitHub for the latest `statements-v*` tag.
- **elan**, the Lean toolchain manager ([installation](https://lean-lang.org/install/)). It installs the pinned Lean, v4.34.1 from `lean/lean-toolchain`, the first time you run `lake`.
- **bash.** On Windows, use Git Bash, which comes with Git for Windows.
- **About 10 GB of free disk**, since Mathlib and its prebuilt cache take about 7.5 GB, and **at least 8 GB of RAM**. These figures were measured on the 16 GB Windows machine this was built on:
  - **A command-line build** of one module that imports Mathlib took about 2.5–3.5 GB at its peak, measured as the drop in available memory while it ran.
  - **An editor tab** costs more. Each VS Code Lean worker with such a file open held about 8 GB.
  - **Each project's Lean server** took about 2 GB more, even with no file loaded.

  So close other Lean tabs before you build.
- **For the differential tests:** Python 3.
- **For Comparator only:** Linux, with Go, Python 3 and, for the full-strength run, Rust and a systemd user manager. On Windows, use WSL or the GitHub Actions workflow below.
- **For the pilot's logs and reruns:** the [GitHub CLI](https://cli.github.com/), `gh`, logged in, and Python 3.

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

It runs seven steps and ends with `check.sh: passed`:

| Step | What it checks | What you should see |
| --- | --- | --- |
| Build | `lake build` again, which is quick once step 2 has run | no errors |
| Forbidden tokens | no `sorry`, `admit`, `axiom` or native evaluation in `Proofs/`, `Lemmas/`, `Tests/`, `Harness/` or `Pilot/`, or in `lean/Gate.lean` | `ok` |
| Axiom audit | `#print axioms` on every theorem in `Proofs/`, `Lemmas/`, `Tests/`, `Harness/` and `Pilot/` (`lean/AxiomAudit.lean`) | each theorem lists only `propext`, `Classical.choice` and `Quot.sound`, then `ok` |
| Statements unchanged | `Defs.lean`, `Statements.lean`, their imports, the toolchain, the Mathlib pin and the lakefile, against the latest `statements-v*` tag | `ok (statements-v4): …`, or `ok (statements-v3): …` at v1.0 |
| CODEOWNERS | `.github/CODEOWNERS` gives `@marleymcwilliams` every file the statements check covers, and itself, by the path or a directory above it (`scripts/codeowners_check.py`), and that check fails on CODEOWNERS files of its own when it should (`scripts/test-codeowners-check.sh`). v1.0 and v1.1 don't have this step | `ok: @marleymcwilliams owns all 6: …`, then an `ok` for each case |
| `archive/` unchanged | `archive/` is the tree it's frozen at, committed and in the working tree (`scripts/archive-check.sh`), and that check fails on a throwaway repository when it should (`scripts/test-archive-check.sh`). v1.0 doesn't have this step | `ok: archive/ is tree c2f6dac…, with nothing uncommitted`, then an `ok` for each case |
| Links | every relative link in the Markdown outside `archive/`, and the heading its anchor names (`scripts/check-links.py`). v1.0 doesn't have this step. On Windows, run it with `PYTHON=python` | `… links checked, 0 broken` |

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

## 5. The harness and the differential tests

The executable gate's harness runs the proved twins ([EXECUTABLE_GATE.md](guide/EXECUTABLE_GATE.md)). After step 2, from `lean/`:

```bash
lake env lean --run Gate.lean report JSG/Harness/examples/withdrawn.json
```

That prints the verdict and the report: "not accepted: evidence incomplete on withdrawn (above its threshold), novelty (unknown)". Each run takes about 15 s, most of it loading Mathlib. `lake env lean --run Gate.lean` with no command lists the others.

The differential tests run from the repository root:

```bash
bash scripts/differential.sh              # on Windows: PYTHON=python bash scripts/differential.sh
```

It ends with `differential.sh: passed`:

| Step | What it checks | What you should see |
| --- | --- | --- |
| Golden examples | the `report` command on each input in `lean/JSG/Harness/examples/` | `ok` for each |
| Corpus | `Gate.lean corpus` writes every test vector, with the oracle's answer | `3818 vectors` |
| The corpus against its own answers | every vector and answer round-trips through the JSON, and matches the twins | `"disagreementCount":0` |
| SirusSC | its code, run in place from `archive/` by `scripts/sirusc_adapter.py`, disagrees with the oracle exactly where its known defects predict | `"asExpected":true`, with 516 disagreements |

The negative controls are theorems in `lean/JSG/Tests/Differential.lean`, so step 2's `lake build` has already checked that the corpus catches each of the 17 executable mutants.

## 6. The pilot: the gate on a real release

The pilot runs the executable gate on [openai/math](https://github.com/openai/math), pinned at `7ef5c0c`. [Its report](pilot/reports/catalogue.md) gives every manuscript's verdict and the evidence it's missing, and sections 3 and 4 of [the executable gate](guide/EXECUTABLE_GATE.md) explain how it works.

**Don't run the release's lakefile, `lake update` or `lake build` on your own machine,** since they run the release's code. The first three checks below read it only as data, and the rerun happens on GitHub Actions.

**Check the report against its Lean data.** After step 2, from the repository root:

```bash
bash scripts/pilot-reports.sh "$(mktemp -d)"
```

You should see `ok: pilot/reports/first-sample.md is what Gate.lean prints`, and the same for `catalogue.md`. Step 2's `lake build` has already proved every verdict by the kernel, in `JSG.Pilot.CatalogueCalibration`. CI runs this script on Linux; it hasn't been tried on Windows.

**Check the Lean data against the recorded facts.** CI doesn't do this one. These commands read the release only as data, at the pin, and should leave `git diff` empty. If they don't, `git restore` both files before going on:

```bash
python3 pilot/collect.py --all --cache pilot-cache --comparator pilot/data/comparator-results.json > pilot/data/catalogue.json
python3 pilot/to_lean.py pilot/data/catalogue.json --comparator pilot/data/comparator-results.json --name Catalogue > lean/JSG/Pilot/Catalogue.lean
git diff --stat
```

**Check the kept logs.** Each Comparator result comes from a trusted job's own log. GitHub keeps logs for 90 days at most, so they're kept as assets of the v1.1 release, with their SHA-256s in `pilot/data/comparator-results.json`. To download them and check each against its recorded SHA-256:

```bash
gh release download v1.1 --repo marleymcwilliams/LibSpec --pattern '*.log' --dir pilot-logs
python3 - <<'EOF'
import hashlib, json
runs = json.load(open("pilot/data/comparator-results.json", encoding="utf-8"))["runs"]
logs = [l for r in runs for l in r["logs"]]
bad = [l["file"] for l in logs
       if hashlib.sha256(open("pilot-logs/" + l["file"], "rb").read()).hexdigest() != l["sha256"]]
print(f"{len(logs)} logs, {len(bad)} differ", bad)
EOF
```

It should print the number of logs and `0 differ []`. Each challenge's result is an unmarked line in those logs. Later runs add how its unit ended, and the latest also what ran inside it. Everything of the release's is marked `comparator|`. To read them:

```bash
grep -hE '^[^ ]+ (unit|sample|result): ' pilot-logs/*.log
```

**Rerun Comparator.** This builds the release's code, so it runs only on GitHub Actions, in `.github/workflows/pilot-shards.yml`: an untrusted job runs the release's lakefile, and a trusted job on a fresh runner checks that job's output against the pin, byte for byte, and then runs Comparator inside the full sandbox. To run it you need write access to this repository, or a fork with Actions on. It has only been run here, not in a fork.

1. **Optionally, run "Comparator (full strength)" once on `main`,** as in "4. Comparator" above. It saves the tools to the cache, which the jobs restore. Without it, each job builds them itself.
2. **Push a branch other than `main`,** since the workflow's jobs skip `main`, and start the control:

   ```bash
   git push origin HEAD:refs/heads/pilot/runs
   gh workflow run pilot-shards.yml --ref pilot/runs -f shards='["control"]'
   ```

   It takes about 15 minutes. The log of the job "Shard control (trusted)" should show `result: BogomolovPopInjectivity: accepted in … s (cap 18000 s), … MB free; Comparator's success line, and exit 0`.
3. **Run what you want to check.** `shards` takes names from `pilot/data/shard-plan.json`, or `solo-<Challenge>` for one challenge in a job of its own. Adding `-f lean_threads=2` sets `LEAN_NUM_THREADS`, so a build runs fewer Lean processes at once. That can keep it under the memory limit, at some cost in time. On `SnakyCertificate`, the largest Lean process's anonymous memory barely changed, though the run without it was killed early, so don't count on it for a module that's too big on its own:

   ```bash
   gh workflow run pilot-shards.yml --ref pilot/runs -f shards='["solo-SnakyCertificate"]' -f lean_threads=2
   ```

4. **Collect the results into a file of their own.** In a fork, first change `REPO` at the top of `pilot/shard_results.py`. It reads each trusted job's raw log, saves it under `pilot-logs/`, and writes a results file holding only the runs you name. Compare each challenge's `status` and `attempts` under `challenges` with those in `pilot/data/comparator-results.json`:

   ```bash
   python3 pilot/shard_results.py --logs pilot-logs RUN_ID... > my-results.json
   ```

5. **To put a rerun into the report,** the results file must cover every challenge, or the ones it leaves out count as not run. So, unless your own runs cover them all, name every run in the committed file's `runs`, oldest first, then yours: a later result replaces an earlier unknown one, never an acceptance or a rejection. The collector reads one repository, and GitHub keeps logs for 90 days at most, so naming them works only here, within that time. Then regenerate, still reading the release only as data, and rebuild as in "2. Build" above. The last command fails while `pilot/reports/` is out of date, and leaves the new reports in the directory you give it, to copy there:

   ```bash
   python3 pilot/shard_results.py --logs pilot-logs EVERY_RUN_ID... > pilot/data/comparator-results.json
   python3 pilot/collect.py --all --cache pilot-cache --comparator pilot/data/comparator-results.json > pilot/data/catalogue.json
   python3 pilot/to_lean.py pilot/data/catalogue.json --comparator pilot/data/comparator-results.json --name Catalogue > lean/JSG/Pilot/Catalogue.lean
   # rebuild, then:
   bash scripts/pilot-reports.sh pilot-new-reports
   ```

**What can differ in a rerun.** Each challenge gets a 13 GB memory limit and a 5-hour cap, on a runner with 4 cores and 16 GB, and GitHub keeps updating the runner's image. So a run can stop on memory or time where another didn't. Those results stay unknown: they never count as failures, though an unknown still keeps a manuscript from being accepted. Only an acceptance or a rejection is evidence, and `pilot/data/comparator-results.json` lists every attempt, with its run, its job and the LibSpec commit that says which build of the tools gave it.

**What an acceptance shows.** Both kernels accept the proof of the statement Comparator exported, with only the permitted axioms. Whether that statement says what the paper claims is a separate question, and no named reviewer has checked one yet. [The executable gate](guide/EXECUTABLE_GATE.md#4-where-things-run) lists what these runs still trust, chiefly the release's lakefiles and each challenge's import closure, which run inside the sandbox.

## 7. Read off what is proved and what isn't

- **[The layer map](guide/LAYER_MAP.md):** every component, with its status, its limits, and a pointer to its Lean theorem or to the reason it's out of scope.
- **[The pilot's report](pilot/reports/catalogue.md):** every manuscript's verdict, and the evidence it's missing.
- **The milestone notes:** [Milestone 1](guide/MILESTONE_1.md), [Milestone 2](guide/MILESTONE_2.md), [Milestone 3](guide/MILESTONE_3.md) and [Milestone 4](guide/MILESTONE_4.md). Each has a plain-English explanation of every proof, the gate record, and a closing note on what is proved and what it doesn't show.
- **[The changelog](guide/CHANGELOG.md):** each statements version, and whether it tightened or weakened the statements. Its `statements-v4` entry lists what v4 adds.

## Full-strength runs

The latest run checked all 34 frozen theorems, on `main` at `6f2ffae`, with the tools as they're built now. The runs back to `6a8a77c`, after Milestone 4, checked all 34 too, and every run before that checked v1.0's 26. The first run on `main` was started by hand at `d568ed1`, after #56, #57 and #58 were merged. The four before it came from #56, which added the workflow, before it was merged. Each of those checked `main`'s proofs, since #56 changes no Lean file. Each later run started by hand on `main` gets a row here too. The three earliest ran before the step had `shell: bash`, when a failing script could still have shown green. Their logs show they passed: each ends with the script's own pass line, which it prints only if every step succeeded.

| Date | Run | Commit | Result |
| --- | --- | --- | --- |
| 2026-11-06 | [42138237336](https://github.com/marleymcwilliams/LibSpec/actions/runs/42138237336) | `main` at `6f2ffae`, the commit v1.1 tags, after #110, started with `gh workflow run` | **Passed** with all 34 frozen theorems, using the same build of the tools as the pilot's rerun of 11 challenges with two Lean processes at once ([42065367459](https://github.com/marleymcwilliams/LibSpec/actions/runs/42065367459)). Both probes passed, the sandbox check showed landrun in force, the self-test passed, the mutant was rejected for its statement, and the Lean kernel and nanoda each accept the solution. Linux 7.0.0-1017-azure, systemd 255, Lean 4.34.1, 4.5 min |
| 2026-11-05 | [41973625293](https://github.com/marleymcwilliams/LibSpec/actions/runs/41973625293) | `main` at `cbe89aa`, after #104, started with `gh workflow run` | **Passed** with all 34 frozen theorems, the first run on `main` with both patched tools. Both probes passed, the self-test passed, the mutant was rejected for its statement, and the Lean kernel and nanoda each accept the solution. Linux 7.0.0-1017-azure, systemd 255, Lean 4.34.1, 6 min |
| 2026-11-04 | [41890870505](https://github.com/marleymcwilliams/LibSpec/actions/runs/41890870505) | `main` at `8badfa7`, after #101, started with `gh workflow run` | **Passed** with all 34 frozen theorems, the first run on `main` with the patched nanoda: the same checks as the row above, 5 min |
| 2026-10-29 | [40840546350](https://github.com/marleymcwilliams/LibSpec/actions/runs/40840546350) | `main` at `6a8a77c`, after Milestone 4, started with `gh workflow run` | **Passed** with all 34 frozen theorems. Both probes passed, the self-test passed, the mutant was rejected for its statement, and the Lean kernel and nanoda each accept the solution. Linux 7.0.0-1017-azure, systemd 255, Lean 4.34.1, 5 min |
| 2026-10-28 | [40781130345](https://github.com/marleymcwilliams/LibSpec/actions/runs/40781130345) | `main` at `d568ed1`, started by hand | **Passed**, the first run on `main`. Both probes passed, the self-test passed, the mutant was rejected for its statement, and the Lean kernel and nanoda each accept all 26 frozen theorems. Linux 7.0.0-1017-azure, systemd 255, Lean 4.34.1, 6 min |
| 2026-10-28 | [40761806692](https://github.com/marleymcwilliams/LibSpec/actions/runs/40761806692) | #56's head `104874b`, on `main` at `2e6cbf7` | **Passed**, the first run whose step has `shell: bash`, so a failing script turns it red: the same checks as the row below, 5 min |
| 2026-10-28 | [40757821081](https://github.com/marleymcwilliams/LibSpec/actions/runs/40757821081) | #56's head `8e25f5b`, on `main` at `2e6cbf7` | **Passed.** Both probes passed: AF_UNIX opens outside the wrapper and is refused inside, and `sudo` gains nothing inside. The self-test passed, the mutant was rejected for its statement, and the Lean kernel and nanoda each accept all 26 frozen theorems. Linux 7.0.0-1017-azure, systemd 255, 4.5 min |
| 2026-10-28 | [40757022820](https://github.com/marleymcwilliams/LibSpec/actions/runs/40757022820) | #56's head `e4a1a00`, on `main` at `2e6cbf7` | Passed, before the AF_UNIX probe had its positive control |
| 2026-10-28 | [40755807109](https://github.com/marleymcwilliams/LibSpec/actions/runs/40755807109) | #56's head `432039e`, on `main` at `2e6cbf7` | Passed, before the wrapper probe existed |

Tools: Comparator v4.34.0 (`d03acab`), lean4export v4.34.0, landrun `811cfff`, nanoda_lib 0.4.30 (`d0a02cc`); Lean 4.34.1, Mathlib v4.34.1. `scripts/build-comparator-tools.sh` changes one line in each of two tools, as [the executable gate](guide/EXECUTABLE_GATE.md#4-where-things-run) records: since `8badfa7`, nanoda's thread stack is 1 GiB, and since `cbe89aa`, Comparator passes `LEAN_NUM_THREADS` to the sandbox around its builds.
