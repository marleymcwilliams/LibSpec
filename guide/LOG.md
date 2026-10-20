# Decision log

Decisions Claude Code made without asking, because they are reversible and don't change what a statement means (CLAUDE.md, "When to ask the human"). Newest first. Each entry says what was decided, why, and how to undo it.

## 2026-10-20

### Three old repos archived; Solanum's `.gitattributes` left out (#16)
- **Decision:** `archive/Reach`, `archive/SirusSC` and `archive/Solanum` hold the files the brief listed, byte for byte, except `Solanum/jsg/.gitattributes`. Inside this repo its rules would apply to the copy: `*.pdf`, `*.png`, `*.svg`, `artifacts/**` and `papers/**/figures/**` go to Git LFS, and `* text=auto eol=lf` rewrites CRLF files to LF. Committed raw instead, those files show as modified in every clone.
- **Also:** SirusSC's `.pytest_cache/` isn't on the brief's exclude list, so it's in, force-added past its own `.gitignore`. The biblatex helpers `*-blx.bib` aren't on the LaTeX list, so they're in too.
- **Undo:** add the file back with `git add -f`; git then applies its rules to the copy.

### `mfGate_monotone` dropped; the general form replaces it (#14)
- **Decision:** Q3 left this call to Claude Code. `mfGate_monotone` is dropped rather than kept as a corollary.
- **Why:** `mfGate_signed` implies it. Keeping both would freeze two statements that carry the same claim, and the corollary would need its own mutant, witness and proof.
- **What stays:** its two controls are kept as tests of the real gate, renamed `mfGate_rejects_draft_history` and `mfGate_accepts_kept_history`. No test was deleted.
- **Undo:** add `mfGate_monotone` back as a theorem in `Statements.lean`; that's a statements change.

### Controls for the restated theorems (#14)
- **Decision:** `BridgeHolds` and `SignedRemovals` in `Mutants.lean` state each claim with the map or gate as a parameter, so a mutant plugs into the same claim. The mutants are `id` for the dial map, and a gate that accepts every change, run on the drafts' history.
- **What changed:** the new `bridge_mutant` is, Prop for Prop, the old reversed-hypothesis copy, so nothing is lost. The old bridge witness tested a statement that no longer exists; its replacement uses the real `threshold`. `mfGate_signed`'s witness is the drafts' history with its removal signed.
- **Undo:** revert the two sections of `Mutants.lean`.

### `mfGate_signed` assigned to Milestone 2 (#14)
- **Decision:** ROADMAP's Milestone 2 row and MASTER_GUIDE's milestone list now include the must-fail gate. `mfGate_monotone` had been in neither, as #3 reported.
- **Why Milestone 2:** it sits with the policy-lattice theorems, and its proof is an induction on steps.
- **Undo:** move it to another milestone.

### The concrete-Loader reminder (#14)
- **Decision:** besides the note in `STATEMENTS_REVIEW.md`, ROADMAP's milestone section says that Milestone 2's note must record that a concrete Loader (L1–L10) is still owed.
- **Why:** that note is written when the milestone closes, so the reminder sits next to it.
- **Undo:** delete the sentence.

### `expiry_tightens`: the note, not a set-based test (#14)
- **Decision:** the named mutant ("revert to the most recent policy") can't be stated on sets, so `STATEMENTS_REVIEW.md` explains why the list copy tests the same claim. The note also names a set-level candidate mutant (`sSup` for `sInf`) in case you want one. No new test was added.

### Compiled on CI, not locally (#14)
- **Decision:** this machine had 2.3 GB free, with a Lean worker from 2026-10-15 holding 13.3 GB, so no local Mathlib load was added. The branch was compiled with a manually started CI run before the PR was opened.

## 2026-10-15

### Statements review report (#13)
- **Decision:** `guide/STATEMENTS_REVIEW.md` shows, for each of the 16 theorems, the Prop its mutant refutes next to the statement, and says what differs. A script confirmed that all 74 quoted code lines match the sources apart from the omitted proofs.
- **Why a file:** the side-by-side is review material for `statements-v1`, and Q2 and Q3 refer to it.
- **Undo:** delete the file once the tag exists.

### Witnesses prove their hypotheses (#11)
- **Decision:** each witness now proves one conjunction for a single concrete instance: every hypothesis of its theorem, in the statement's order, then the conclusion. A few named fixtures (`θone`, `dWitness`) keep the hypotheses readable. `Loader.safe`'s general countdown lemma is kept as `loader_safe_countdown`, and a concrete instance (state 3 down to 1) is the witness.
- **Undo:** go back to conclusion-only witnesses. That weakens a check, so it would go to the queue.

### The statements check asks origin for tags (#12)
- **Decision:** `check.sh` compares this clone's latest `statements-v*` tag with origin's and fails if they differ. In CI, being unable to reach origin fails too; locally, it skips with a note. Before any tag exists, it skips.
- **Why:** this is how "tags missing" differs from "not frozen yet" without a marker file.
- **Outside the repo:** a GitHub tag ruleset on `statements-v*` that blocks deleting or moving tags would close the last gap. That's a settings change for you.
- **Undo:** revert #12. That weakens a check, so it would go to the queue.

### The Q2 and Q3 proposals were checked before queueing (#13)
- **Decision:** a scratch file, not committed, type-checked both restatements against the real `Defs` and proved that each one's mutant fails it: the un-inverted dial for the restated bridge, and a gate that accepts every change for `mfGate_signed`. No Milestone 1 theorem was proved.

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
