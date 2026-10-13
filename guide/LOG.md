# Decision log

Decisions Claude Code made without asking, because they are reversible and don't change what a statement means (CLAUDE.md, "When to ask the human"). Newest first. Each entry says what was decided, why, and how to undo it.

## 2026-10-13

### Phase 2 stubs written; no compile fixes needed (#10)
- **Decision:** the v2 stubs went into `lean/JSG/Defs.lean` (every inductive, structure and definition) and `lean/JSG/Statements.lean` (every theorem), with the `variable` lines in the stub's order. Both compiled on the first try against Mathlib v4.34.1, so there are no compile fixes to record. `Multiset.IsDershowitzMannaLT` exists, and `IsDershowitzMannaLT M N` means M is the smaller multiset, matching the stub's `progress`.
- **Meaning check:** a scratch script elaborated the original single-file stub in a separate namespace and compared every declaration with the split files. 107 are identical in type and value. 4 differ only in the hidden universe names Lean generates for `noConfusion`, which embed the source module's name. `interchange` is definitionally equal to v2's equation, the Q1 change.
- **Undo:** paste the stub back into one file. Comparator needs the split, so this would mean copying definitions into the solution.

### Mutants for the three theorems that had none (#10)
- **Decision:**
  - `combine_comm`: overwrite, where the later stage's grade replaces the earlier one.
  - `charge_append`: v1's merged-jump charge, a real corpus defect (PDE Lemma 10.1).
  - `fold_check_vacuous`: the uncapped fold, whose nightly check can fail, which shows the cap is what makes the check vacuous.
- **Mutant shapes that differ from their statement:**
  - `expiry_tightens`: "revert to the most recent policy" needs an order, so its mutant works on lists, newest first.
  - The two Loader mutants model a loader that couldn't be built: a skipped check breaks `inv_step`, and a retry breaks `progress`, which `retry_breaks_progress` also shows.
- **Undo:** choose other mutants in `Statements.lean`'s comments and `Mutants.lean`.

### Controls in `JSG/Tests/` (#10)
- **Decision:** `Mutants.lean` holds a proved mutant counterexample and a proved witness instance for all 16 theorems, plus `Noninterfering` and `Calibrated`: 37 theorems. They use at most propext, Classical.choice and Quot.sound. The file imports only `JSG.Defs`, so no control can rest on an unproved theorem. `Calibration.lean` checks the real gate: `verdict` with θ = 1 accepts the must-pass set (known 0, known 1) and rejects the must-fail set (unknown, known 2).
- **Your part:** ROADMAP Phase 2 has you choose the must-pass and must-fail inputs, so these sets are a starting point to change.
- **Undo:** delete the files. That weakens a check, so it would go to the queue.

### The guide's Lean sketch follows the Lean files (#10)
- **Decision:** the sketch now says the Lean files are canonical and is kept in step with them for reading: the two-operator interchange and the three new Mutant lines.
- **Undo:** revert the sketch's lines.

### Lean and Mathlib upgrades under the Comparator design (#6)
- **Every upgrade is a new statements version.** An upgrade changes `lean/lean-toolchain` or `lean/lake-manifest.json`, which the statements check now covers. So it needs its own PR, a new `statements-vN` tag and a CHANGELOG line. The line usually says neither tightens nor weakens, and should say what moved. These files are yours to merge.
- **Mathlib can change what a statement means.** It can rename a lemma or change a definition the statements use. If a statement no longer elaborates, or elaborates to something different, that's a statement change and goes to the queue.
- **Comparator re-checks every proof on the upgrade PR,** against the re-elaborated statements. A proof whose statement drifted fails there.
- **The Comparator tools move with Lean.** lean4export reads our `.olean` files, which load only under the exact Lean version that wrote them. So `scripts/build-comparator-tools.sh` builds comparator and lean4export with our `lean-toolchain`. On an upgrade, set `COMPARATOR_REV` to comparator's tag for the new Lean version; its manifest pins the matching lean4export. If a patch release has no tag, use the nearest one, as now: v4.34.0 sources built with the v4.34.1 toolchain. The CI cache key includes the toolchain, so the tools rebuild by themselves.
- **Undo:** narrow `statement_files` in `scripts/check.sh`. That would make a check weaker, so it would go to the queue first.

### Comparator layout: definitions in a shared `Defs.lean` (#6)
- **Decision:**
  - Definitions the statements use go in `lean/JSG/Defs.lean`, and `Statements.lean` holds only theorem statements.
  - Proof files in `lean/JSG/Proofs/` import `JSG.Defs` and restate frozen theorems under their exact names.
  - `lean/JSG/Solution.lean` imports every proof file.
- **Why:** Comparator needs the solution to declare the same names without importing the challenge. A shared definitions module makes the definitions the same constants on both sides, so `definition_names` stays empty and every definition a statement uses is compared in full. Copying the definitions into the solution would also work, but leaves two copies to keep in step.
- **Effect on you:** in Phase 2, put the v2 stubs' definitions in `Defs.lean`.
- **Undo:** move the definitions back into `Statements.lean`, and give the solution its own copy.

### Comparator targets are generated, not listed by hand (#6)
- **Decision:** `lean/ComparatorTargets.lean` lists every theorem declared under `JSG.Proofs`, and those are the targets. It skips internal names and the theorems Lean generates on demand (equation lemmas, `ext`, `injEq`, induction principles), so a proof file that unfolds a definition doesn't add a target the challenge lacks.
- **Why:** a hand-kept list can leave a proof unchecked.
- **Consequence:** a proof file may contain only frozen theorems. Helper lemmas go in `JSG/Lemmas/`.
- **Undo:** write the config by hand.

### Comparator runs inside the required `build` job (#6)
- **Decision:** the tools are built once and cached (17 s to build; Comparator itself took 14 s), pinned to comparator d03acab (tag v4.34.0, whose manifest pins lean4export 076e8e5, tag v4.34.0) and landrun 811cfff (main).
- **Why:** inside `build`, the ruleset's required check covers Comparator with no settings change.
- **Undo:** move the steps into their own job and add that job to the ruleset.

### Comparator's self-test (#6)
- **Decision:** `lean/JSG/Tests/Comparator/` holds a shared `Defs`, a `Challenge`, a correct `Solution` and a `Mutant`, which proves a weaker statement under the frozen name. CI requires the solution to pass and the mutant to fail, with "theorem statement do not match" in the error. The challenge carries a real proof, because the forbidden-token scan covers `JSG/Tests/`; Comparator compares only statements.
- **Why:** it shows the check has teeth before any real proof exists.
- **Undo:** delete the directory and the two self-test steps. Deleting a test weakens a check, so it would go to the queue.

### Comparator's sandbox (#6)
- **Decision:** Comparator runs under landrun in its default best-effort mode, without the `systemd-run` wrapper its README suggests, since GitHub runners have no user systemd. CI also builds the solution before Comparator does.
- **Why:** both matter only for proof code that attacks the checker, which isn't this repo's threat model. The guarantees used here (statement match, permitted axioms, kernel replay) don't depend on the sandbox.
- **Undo:** add the wrapper on a runner that supports it.

### Rails decision: one added line in the brief (#5)
- **Decision:** added "Decision 2 was decided in RAILS.md." under the brief's existing note, leaving your sentence as it was.
- **Undo:** delete the line.

### Layer-map sources (#4, merged)
- **Decision:** six Source cells now cite the corpus sections they come from. The commit message quotes each supporting line:
  - Receipt integrity: SIRUS spec §0.5; JSG V §6
  - Loader: MDmaster SCp3; JSG V §3
  - Frontier charge: PDE §10; MDmaster SCp2
  - Policy lattice: JSG IV, Governance as Code
  - Calibration: Core v2; Operational Playbook (must-fail coverage)
  - Typed obligations and the unknowns lease: JSG V §3; PDE §2.2, I4b
- **Undo:** revert ee55add.

### Operating model (#7)
- **Decision:** created this log and `guide/QUEUE.md`, added "When to ask the human" to CLAUDE.md, and updated ROADMAP's "One sitting" steps.
- **Why this PR holds the log:** this PR is the one that creates the file, so this session's entries for #4–#6 live here, and no two open PRs edit the log at once.
