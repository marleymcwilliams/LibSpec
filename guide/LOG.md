# Decision log

Decisions Claude Code made without asking, because they are reversible and don't change what a statement means (CLAUDE.md, "When to ask the human"). Newest first. Each entry says what was decided, why, and how to undo it.

## 2026-10-27

### Milestone 2 merged and its gate recorded (#49)
- **Merges:** with `statements-v2` tagged and #33 merged, the stack went in in order, #34–#48. Each PR after the first was retargeted to `main` before the branch under it was deleted, so none was closed, and the fifteen branches were deleted after the last merge. #34 lands Marley's `expiry_tightens` word for word. It also touches `Solution.lean`, which isn't on CLAUDE.md's list, so I merged it with the rest.
- **Proof order:** Marley's `expiry_tightens` first, since its PR creates the proof file, then mine, easiest first. The seven v2 proofs come from the scratch provability check; the six v1 proofs are new.
- **The concrete Loader is a test file (#48):** a proof file may restate only frozen theorems, because Comparator checks every theorem in `Proofs/`, and `Lemmas/` shouldn't depend on proofs. So `concrete`, its `Loader.safe` and `Loader.terminates` corollaries, and the instance that makes what is pending well-founded when the obligations are, all live in `Tests/ConcreteLoader.lean`.
- **Gate:** `guide/MILESTONE_2.md` records how each gate item is met against `main`'s CI run on #48's merge, and carries Marley's closing note verbatim. MASTER_GUIDE's six Milestone 2 rows use Marley's approved wording, "Lean milestone 2" is ticked, and ROADMAP's Milestone 2 note is marked done.
- **Branches:** `statements/v2-proposal` deleted, at Marley's request. The `statements-v2` tag keeps its commit, f05831f.

### `statements-v2` revised after Marley's review (#33, draft)
- **Queue:** Marley answered Q5, Q6 and Q7 yes, as recommended.
- **Leases:** `lease_breach` is widened into `lease_sound`: an axis over its threshold, or wider than its lease, rejects the grade. A gate that checks only widths satisfied both lease theorems, yet accepted [5, 5] under θ = 1; it is now `lease_sound`'s second mutant. `lease_complete` assumes `(g i).hi ≤ θ i` in place of `lo + β ≤ θ`. That's a stronger theorem, and `pointsOnly` still fails it.
- **Tickets:**
  - **The problem:** the first draft's `LoaderStep` needed every stage to discharge a pending obligation. A JSG V window starts with Σ empty, so no window could take its first step.
  - **The fix:** each stage that T-Boot pins (`Boot.stages`) has a ticket, pending from the start (`windowStart`, `bootState`). A stage clears its own ticket when it runs (`DischargeMatrix.Clears`), and tickets rank above every obligation (`Pending.rank`).
  - **What changes:** `LoaderStep`'s `hticket` replaces `hdis` and `hsmall`. `Passes` takes the window's stages, and `pass_sound` and `pass_complete` cover everything pending, tickets included.
  - **Mutants:** JSG V's "or" now stands in for the ticket. I_Σ is read on the obligations alone, since JSG V's Σ has no tickets.
- **New controls:** `loader_runs_window` runs EF and then PR through `LoaderStep` from `bootState`, and the window passes. `empty_run_fails` shows that, from the same state, a run with no stages doesn't pass.
- **Provability check:** all seven theorems were proved in an uncommitted scratch file. Each proof is against its frozen statement, through `type_of%`, and uses only propext, Classical.choice and Quot.sound. With the two Loader theorems, the concrete Loader builds as a `Loader`, and what it has pending is well-founded whenever the obligations are.
- **Left open:** stage order (IDEAS.md). It needs no decision now, because an ordered Loader can come later as a step relation contained in `LoaderStep`, and both theorems carry over.
- **Docs:** CHANGELOG, ROADMAP, MASTER_GUIDE's sketch (regenerated and checked line by line), STATEMENTS_REVIEW (checked against the sources) and IDEAS are updated to match.

## 2026-10-26

### `statements-v2` proposed (#33, draft)
- **Scope:** Marley's brief, with one-time permission to edit `Defs.lean` and `Statements.lean` on a draft branch. Seven theorems and their definitions, appended as sections 8–11 of both files under a note that nothing above changed. Section numbers match across the two files, so `Defs.lean` skips 7, which has no definitions. The diff against `statements-v1` removes no line from any covered file.
- **Drafting choices, all open to review until the tag:**
  - Leases are interval width (`Bound.width`), checked by a separate `leaseVerdict` so `verdict` stays as frozen.
  - Obligations follow JSG V's displayed stage transition. The issuer rule for Stage scope is folded into a single authority per obligation.
  - The concrete Loader keeps what T-Boot pins in its state, so no step may change it. Its primitives are parameters (QUEUE.md, Q7). It has one stage rule: SCp3's T-Row premises, plus I6, I8 and JSG V's progress condition corrected from "or" to "and".
  - The overspent residual is settled by `Threads`, leaving `residual` as frozen (QUEUE.md, Q5).
- **Mutants:** each comes from a defect in `archive/`: SirusSC's `QPrime` and `Q`, JSG V's matrix, I_Σ and progress lemma, SCp3's T-Row and its s ⇒ s check rules, and SirusSC's axis-leak check. `threads_spec`'s comes from v1's `residual` used without `hx`. All of them, and a witness per theorem, are in `Tests/Mutants.lean`. They use only propext, Classical.choice and Quot.sound. The theorems themselves aren't proved: that's Milestone 2.
- **Docs:**
  - **MASTER_GUIDE:** its Lean sketch gains sections 8–11, generated from the two files and checked line by line. Three layer-map rows are updated, and the paragraph on deferred pieces now names what v2 adds.
  - **ROADMAP:** Milestone 3's statements, and the compiler's, now get "a statements version of their own" rather than a number. The Milestone 2 row and note name v2's theorems.
  - **IDEAS:** the overspent-residual item moves to Q5, and four new items record what drafting turned up.
  - **STATEMENTS_REVIEW:** a v2 section, its quoted code checked against the sources.
- **To undo:** close the draft PR. Nothing is tagged or merged.

### Merged branches deleted
- **Decision:** Marley's brief. Every remote branch already merged into `main` was deleted, 24 in all, after checking that none was the head or base of an open PR. Only `main` remains. A deleted branch can be pushed back from its merge commit's second parent.

### Milestone 1 merged and its gate recorded (#32)
- **Merges:** once #23 was in, the seven proof PRs (#25–#31) were merged in order, as Marley's brief allowed. #25 was retargeted to `main` by hand, since #23's branch wasn't deleted; GitHub retargeted the rest.
- **Gate:** `guide/MILESTONE_1.md` records how each gate item is met against `main`'s CI run on #31's merge, and carries Marley's closing note verbatim. MASTER_GUIDE's layer map and roadmap use Marley's wording.
- **Also:** the layer map's sentence on Lean status now covers "Proved", and ROADMAP's Milestone 1 note on the two SCp2 mutants is marked done (#24).

### `statements-v1` tagged, and the freeze confirmed (#22)
- **The tag:** Marley tagged `statements-v1` (annotated) at bc76c3c, the merge of #20. Ruleset 25916221, "freeze statements tags", protects `refs/tags/statements-v*`: active, updates and deletions restricted, creation allowed, no bypass actors.
- **The freeze test (#21):** a one-line comment added to `Statements.lean` on a throwaway branch failed CI at the statements check (run 40413606695). The diff named `lean/JSG/Statements.lean`, then "FAIL: files the statements depend on differ from statements-v1"; the build itself passed. The PR was closed unmerged and its branch deleted.
- **A race on `main`:** CI at bc76c3c (run 40411254587) checked out the merge before the tag was pushed, then found the tag on origin but not in its clone, so the statements check failed as designed. A rerun passed with "ok (statements-v1)". Tagging after `main`'s CI finishes avoids it.

### `verdict_unknown` replaced by `verdict_sound` (#20)
- **Decision:** Marley's, recorded as Q4 in QUEUE.md. This PR applies it with its controls and renames, and puts the statements-v1 entry in the existing `guide/CHANGELOG.md` rather than a second changelog.

### The axiom audit sweeps proofs, lemmas and tests (#23)
- **Decision:** `#audit_sweep` audits every theorem in every module on disk under `JSG/Proofs/`, `JSG/Lemmas/` and `JSG/Tests/`, except the Comparator fixtures, which contain `sorry` by design. A new root, `lean/JSG/Tests.lean`, imports every test file, and `JSG.Solution` already imports every proof file. So no one edits `AxiomAudit.lean` for a new proof, lemma or test.
- **Loud by design:** it fails if a module on disk isn't imported through those roots (naming the root to import it from), if a module declares no theorem, if it finds no proof or test module, or if a name in the by-name list wasn't swept. A proof file missing from `Solution.lean` would also escape Comparator, so this guards that too.
- **Coverage:** the by-name list (`smoke`, `combine_comm`) stays, and the sweep must cover it. This makes a check stronger, so it's Claude Code's call (CLAUDE.md).
- **Undo:** restore #18's `AxiomAudit.lean` and delete `lean/JSG/Tests.lean`.

## 2026-10-20

### The axiom audit covers the controls (#18)
- **Decision:** `AxiomAudit.lean` now imports `JSG.Tests.Mutants` and `JSG.Tests.Calibration` and audits every theorem they declare: 42 today, plus 20 equation and `sizeOf` lemmas that Lean generates for their definitions. Before this it audited only `smoke` and the proofs. The forbidden-token scan catches a literal `sorry` in the tests, but not an axiom that a tactic brings in, such as `bv_decide`'s `Lean.ofReduceBool`. The change makes a check stronger, so it's Claude Code's call (CLAUDE.md).
- **How:** a small `#audit_module` command prints `#print axioms` for each theorem in a module, so a control added later is audited without anyone listing it. It fails if the module isn't imported or declares no theorem, so a renamed module can't pass with nothing checked.
- **Undo:** delete the two `#audit_module` lines, the command and the two imports.

### Three old repos archived; Solanum's `.gitattributes` left out (#16)
- **Decision:** `archive/Reach`, `archive/SirusSC` and `archive/Solanum` hold the files the brief listed, byte for byte, except `Solanum/jsg/.gitattributes`. Inside this repo its rules would apply to the copy: `*.pdf`, `*.png`, `*.svg`, `artifacts/**` and `papers/**/figures/**` go to Git LFS, and `* text=auto eol=lf` rewrites CRLF files to LF. Committed raw instead, those files show as modified in every clone.
- **Also left out, on your review of #16:** SirusSC's `.pytest_cache/` (6 files) and Solanum's three biblatex control files (`*-blx.bib`). Both are generated, like the LaTeX intermediates the brief excluded.
- **Undo:** add the file back with `git add -f`; git then applies its rules to the copy.

### Six docstrings say no more than their theorems (#19)
- **Decision:** Marley's wording for `Loader.safe` as given, and two small rewrites:
  - `residual_spec` also needs θ finite (`hθ`). With θ = x = ⊤, stage one fits, the residual is 0, and y = 1 fails the residual check but passes the total check. So the docstring opens "When θ is finite and stage one fits within it".
  - `charge_chatter`: "which is 0 only when A = 0 or v = 0" spells out what "never 0 unless A or v is" left implied, and `[v, -v]` is in code font, as Lean writes it.
- **The three that were missing:** `combine_comm`, `combine_assoc` and `fold_check_vacuous` use Marley's wording from review. The fold's is reordered so that "nonnegative" qualifies only the cap: the theorem holds for any weight and any readings, which is what makes the check vacuous.
- **Also:** the guide's sketch matches, and every theorem in `Statements.lean` now has a docstring. No statement changed, and no tag exists, so no CHANGELOG line.
- **Undo:** restore the three old docstrings and delete the three new ones.

### The Lean toolchain is cached, and its download retried (#19)
- **Decision:** CI restores `~/.elan` from the GitHub cache, keyed on `lean/lean-toolchain`. On a miss it installs elan and the toolchain itself, in up to five attempts 30, 60, 90 and 120 s apart. lean-action then finds the toolchain installed and doesn't fetch it.
- **Why:** lean-action fetches the toolchain from releases.lean-lang.org once, with no retry. A single TLS error turned #14 and #17 red (the first attempts of runs 39391980839 and 39491370612), so red didn't mean the code was wrong.
- **Still unretried:** lean-action reinstalls elan itself from GitHub on every run, which hasn't failed so far.
- **Undo:** delete the two steps before lean-action.

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

### Triage of the archived repos (#17)
- **Decision:** the brief's four fixes are applied where the sources bear them out, each quoted in the PR. One didn't verify as stated: SirusSC's Loader runs ten checks numbered I1–I10, but only I1 is SCp3's. The Milestone 2 note says so.
- **Glossary:** SCp1's ∧ joins the Combine row (Def 2.2) and the Sequential composition row (Prop 7.4); SCp2's "∧ ≡ ⋆" is recorded as a misreading, no longer as an alias. The Unknown row now says SCp1 and SCp2 put ⊥ below every value, which the new defect row explains: "the information order" was SCp2's intent (§4.1, ⊥ "concretizes to the full concrete carrier"), not its order.
- **`Statements.lean`, comment only, at your request:** `verdict_unknown`'s Mutant comment cites the new defect, and the guide's sketch matches. No statement changed; no tag exists, so no CHANGELOG line.
- **Where the Milestone 2 notes live:** ROADMAP's milestone section, where the concrete-Loader reminder now heads a two-item list.
- **Undo:** revert the PR's commit.

### `expiry_tightens`: the note, not a set-based test (#14)
- **Decision:** the named mutant ("revert to the most recent policy") can't be stated on sets, so `STATEMENTS_REVIEW.md` explains why the list copy tests the same claim. The note also names a set-level candidate mutant (`sSup` for `sInf`) in case you want one. No new test was added.

### Compiled on CI, not locally (#14)
- **Decision:** this machine had 2.3 GB free, with a Lean worker from 2026-10-15 holding 13.3 GB, so no local Mathlib load was added. The branch was compiled with a manually started CI run before the PR was opened.

### `combine_comm` lands in `Proofs/Milestone1.lean`, and the axiom audit lists it (#15)
- **Decision:** the proof file is `lean/JSG/Proofs/Milestone1.lean`, one file per milestone as ROADMAP's layout says. It holds Marley's proof from `lean/Scratch.lean` (lines 35–41) verbatim, under the statements' `variable` line. `AxiomAudit.lean` now imports `JSG.Solution` and `JSG.Tests.Smoke` instead of `JSG`, and prints `combine_comm`'s axioms.
- **Why the import changes:** a proof restates its theorem under the frozen name, so it can't be imported alongside `JSG.Statements`, which `JSG` brings in. The audit asks for every closed theorem to be listed. Comparator already checks the proof's axioms; this adds `check.sh`'s own audit, so the check is stronger.
- **Undo:** restore `import JSG` in `AxiomAudit.lean` and drop the `combine_comm` line.

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
