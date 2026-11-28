# Where LibSpec stands, and where things live

This is the page an agent reads after [CLAUDE.md](../CLAUDE.md), and each fact on it has this page as its one home unless its line links elsewhere.

## What is proved

- **The statements:** 39 frozen theorems in `lean/JSG/Statements.lean`, frozen in `statements-v1` to `statements-v6`, each version before its proofs.
- **All 39 are proved.** No statement was changed to make a proof go through.
- **Comparator** checks each proof against its frozen statement, allowing only `propext`, `Classical.choice` and `Quot.sound`: in CI on every build, and at full strength, with nanoda and the full sandbox, by hand ([the latest](../REPRODUCE.md#full-strength-runs)).
- **Controls:** each theorem has a mutant, a plausible wrong version proved to fail it, and a witness, an instance proved to satisfy it.
- **Twins:** the harness runs `statements-v4`'s twins, and differential tests check another implementation against them ([REPRODUCE.md, step 5](../REPRODUCE.md#5-the-harness-and-the-differential-tests)).
- **Conformance is not correctness:** CI and Lean show that the proofs conform to the statements, never that a statement, threshold, model or value is right, which stays a signed human decision.

| File | What it holds |
| --- | --- |
| [LAYER_MAP.md](LAYER_MAP.md) | Each component's layer, status, limits, checks and pointer; what each statements version adds; where the sources are |
| [STATEMENTS_REVIEW.md](STATEMENTS_REVIEW.md) | Each frozen theorem beside its source, with its mutant, that mutant's origin, and its witness |
| [CHANGELOG.md](CHANGELOG.md) | Whether each statements version tightens or weakens; so far each has only added |

**The milestones,** from Marley's closing notes, each of which also lists "That the statements say what I mean": the rule above.

1. **Algebraic core.** Proved: order, grouping and interchange don't change a grade; the verdict is sound, and complete for point evidence; residual checking on one budget axis; `no_flip` for noninterfering graders; JSG IV's capped fold check can never fail, a proved defect. Not shown: anything about a running system; that any real grader is noninterfering; calibration beyond the test sets. [Note](https://github.com/marleymcwilliams/LibSpec/blob/3b481d5e951bb30300195598e9dada5a753ab61c/guide/MILESTONE_1.md#closing-note)
2. **Obligations, Loader, charge, policy.** Proved: Loaders keep their invariant and terminate, the concrete one keeping L1–L10; charge adds up, chattering costs double; expiry only tightens; passes and leases are sound and complete. Not shown: that the cryptography holds; that stages run in JSG V's order; what a stopped run means; completeness for every passing window; the must-fail gate on real histories. [Note](https://github.com/marleymcwilliams/LibSpec/blob/3b481d5e951bb30300195598e9dada5a753ab61c/guide/MILESTONE_2.md#closing-note)
3. **Analysis layer.** Proved: CVaR tail to level, with C₀ = 1; the corrected dwell bound; the local KL–Fisher bound in whitened coordinates; the DRO envelope identity for the dual value. Not shown: the rest of PDE Lemma 9.1; that crossings can't pile up in finite time; KL–Fisher in raw coordinates, where it fails; strong duality; estimates from data. [Note](https://github.com/marleymcwilliams/LibSpec/blob/3b481d5e951bb30300195598e9dada5a753ab61c/guide/MILESTONE_3.md#closing-note)
4. **Executable twins.** Proved: each twin, computing exactly in `WithTop ℚ≥0`, agrees with its frozen definition, so the earlier theorems hold of the twins too. Not shown: infinitely many axes; the obligation and Loader twins (Q11); that the code which runs the twins is correct, since the compiler is trusted, not proved. [Note](https://github.com/marleymcwilliams/LibSpec/blob/3b481d5e951bb30300195598e9dada5a753ab61c/guide/MILESTONE_4.md#closing-note)
5. **The core's gap statements.** Proved: given enclosure, and composition no worse than `combine` assumes, an accept bounds the truth by θ; more evidence can't hurt; a rejection is definite exactly when every narrowing rejects. Not shown: enclosure itself, or that true values compose so; more than two stages; that the pilot's report makes this split. [Note](https://github.com/marleymcwilliams/LibSpec/blob/3b481d5e951bb30300195598e9dada5a753ab61c/guide/MILESTONE_5.md#closing-note)

`statements-v6`'s `narrows_unknown` was proved in #134, outside any milestone ([STATEMENTS_REVIEW.md §39](STATEMENTS_REVIEW.md#39-narrows_unknown-restated-copy)).

## The pilot

- **The release:** [openai/math](https://github.com/openai/math) at `7ef5c0c`, 724 manuscripts.
- **The verdicts,** with the evidence each is missing: [`pilot/reports/catalogue.md`](../pilot/reports/catalogue.md).
- **Comparator's results,** from trusted shard runs on GitHub Actions: [`pilot/data/comparator-results.json`](../pilot/data/comparator-results.json). What those runs still trust: [EXECUTABLE_GATE.md §4](EXECUTABLE_GATE.md#4-where-things-run).
- **None is accepted.** Three were withdrawn by their authors. For the others, that's about missing evidence, not a finding against the mathematics: no named reviewer has checked any statement against its paper, and independent review and novelty are unknown for all of them.
- **An acceptance by Comparator** means both kernels accept the proof of the statement Comparator exported, not that the statement says what the paper claims.
- **`main` holds v1.1's results.** The reruns since v1.1 wait for the results PR, in [Next](#next).
- **To check or rerun it:** [REPRODUCE.md, step 6](../REPRODUCE.md#6-the-pilot-the-gate-on-a-real-release).

## Reviews

- **The protocol** is [REVIEW_PROTOCOL.md](REVIEW_PROTOCOL.md). Its named reviewers are Marley alone.
- **openai/math's manuscripts** can be reviewed now, with Marley as the reviewer. Phase 8's open steps ([its text](https://github.com/marleymcwilliams/LibSpec/blob/3b481d5e951bb30300195598e9dada5a753ab61c/guide/ROADMAP.md#phase-8-statement-review)):
  2. `Raw` gains the verdict and its sentence, so a mismatch counts as evidence that fails; today `Raw.fidelityBy` holds only a name.
  3. Each review is a GitHub issue form, which a collector reads into `pilot/data/`, counting only a named reviewer who made the issue's last edit.
  4. Review seven manuscripts, timing each: `CHALLENGES` in `pilot/reading_list.py`, with [their reading lists](../pilot/reports/reading-lists.md).
  5. Calibrate with a synthetic challenge subtly weaker than its paper's claim, whose review must not count as faithful.
- **LibSpec's own statements** have no eligible reviewer. Nobody reviews their own statements, and that rules out Marley. So their `statement_fidelity` stays unknown, and the self-grading report is blocked.
- **Re-planning Phase 8** belongs to the roadmap step, in [Next](#next).

## Next

1. **The trim, PRs 4 and 5:** the archive's removal; the long references, with a word budget.
2. **The results PR** for the Comparator reruns since v1.1, then the v1.2 release.
3. **The UI,** in its own repository, reading LibSpec's data at a pinned tag.
4. **The roadmap step,** which Marley plans:
   - re-plan Phase 8 ([its text](https://github.com/marleymcwilliams/LibSpec/blob/3b481d5e951bb30300195598e9dada5a753ab61c/guide/ROADMAP.md#phase-8-statement-review));
   - a monthly scheduled full-strength Comparator run, because the sandbox leans on the runner's Linux kernel, which GitHub changes without notice;
   - the Navier–Stokes regularity spine, which the master guide's checklist planned as a research notebook outside the guide's dependency graph ([the checklist](https://github.com/marleymcwilliams/LibSpec/blob/3b481d5e951bb30300195598e9dada5a753ab61c/guide/ROADMAP.md#the-master-guides-checklist));
   - the ACT→JSG compiler's adequacy theorem ([Phase 6's option](https://github.com/marleymcwilliams/LibSpec/blob/3b481d5e951bb30300195598e9dada5a753ab61c/guide/ROADMAP.md#phase-6-guide-v1-then-choose));
   - Phase 9's sources ([its text](https://github.com/marleymcwilliams/LibSpec/blob/3b481d5e951bb30300195598e9dada5a753ab61c/guide/ROADMAP.md#phase-9-more-sources)).

**Deferred, no date:**
- Phase 10's obligation and Loader twins, deferred on 2026-11-13 because they have no consumer ([its text](https://github.com/marleymcwilliams/LibSpec/blob/3b481d5e951bb30300195598e9dada5a753ab61c/guide/ROADMAP.md#phase-10-the-obligation-and-loader-twins)).
- The master guide's three other open items ([the checklist](https://github.com/marleymcwilliams/LibSpec/blob/3b481d5e951bb30300195598e9dada5a753ab61c/guide/ROADMAP.md#the-master-guides-checklist)): freeze the glossary with one rename pass; make CI fail on a `b3:…` placeholder, an unsigned must-fail removal or a theorem without a mutant; recover the SIRUS\_game runtime note and remove MDmaster's SIRUS-algorithm sections.

## A milestone's gate

CLAUDE.md's "Definition of done" holds for each theorem. A milestone also needs:
- Comparator listing none of its theorems as not yet proved;
- every must-pass control accepted;
- its layer-map rows set to Proved, the guide's text naming each Lean theorem;
- a short note in Marley's words: what is now proved, and what it does not show.

Where Marley's closing note for a milestone goes will be decided when the next milestone is planned.

While one is open, a red build on `main` is fixed before any new work, and a theorem that resists three sessions is marked Open in the layer map, with one line on why.

## Where things live

| Path | What it holds |
| --- | --- |
| [README.md](../README.md) | The front door |
| [REPRODUCE.md](../REPRODUCE.md) | Building and checking everything; the full-strength runs |
| `.claude/settings.json` | Deny rules and commit identity |
| `.github/` | `CODEOWNERS`, the paths only Marley merges; the PR template; workflows: `ci.yml`, `comparator-full.yml`, `pilot-shards.yml` (trusted), `pilot-comparator.yml` (measurements) |
| `lean/JSG/Defs.lean`, `lean/JSG/Statements.lean` | **Frozen.** CI fails if either differs from the latest `statements-v*` tag |
| `lean/lakefile.toml`, `lean-toolchain`, `lake-manifest.json` | Lean and Mathlib v4.34.1, under the statements check; the default target globs `JSG.*`, pilot included |
| `lean/JSG/Proofs/` | One file per milestone, restating its frozen theorems; `lean/JSG/Solution.lean` imports them all |
| `lean/JSG/Lemmas/` | Helper lemmas |
| `lean/JSG/Tests/` | Mutants and witnesses (`Mutants.lean`), must-pass and must-fail sets (`Calibration.lean`), differential tests, Comparator's self-test; `lean/JSG/Tests.lean` imports them all |
| `lean/JSG/Harness/`, `lean/Gate.lean` | The harness: report, JSON, corpus, executable mutants; `Gate.lean` runs it and prints the pilot's reports |
| `lean/JSG/Pilot/` | Records to grades (`Core`), generated data, their proofs, the report's words (`Words`) |
| `lean/AxiomAudit.lean`, `lean/ComparatorTargets.lean` | The axiom audit; the theorems Comparator must check |
| `pilot/` | Collectors, generators, data and reports: [Generated files](#generated-files) |
| `scripts/` | `check.sh` (build, token scan, axiom audit, statements, CODEOWNERS, archive, pilot-Python and link checks); Comparator, differential and pilot-shard runs; `blt-build.sbatch`, a sample BLT job |
| [GLOSSARY.md](GLOSSARY.md) | Canonical terms, each defined once, and the core objects |
| [DEFECTS.md](DEFECTS.md) | The corpus's known defects, and their fixes |
| [CONVENTIONS.md](CONVENTIONS.md) | Naming, and how the project is described outward |
| [EXECUTABLE_GATE.md](EXECUTABLE_GATE.md) | Twins, differential tests, the pilot, where things run (runners and BLT, §4), decisions |
| [QUEUE.md](QUEUE.md) | Questions for Marley, at most three open |
| [LOG.md](LOG.md) | Reversible decisions, newest first, added and never rewritten |
| [IDEAS.md](IDEAS.md) | The parking lot |
| [decisions/RAILS.md](decisions/RAILS.md) | Marley's signed decision on the normative rails |
| `archive/` | **Read-only.** The source corpus: [LAYER_MAP.md](LAYER_MAP.md#where-the-sources-are) |

## Generated files

Regenerate these; never edit them by hand. Don't open the big ones (`catalogue.json`, `comparator-results.json`, `shards.json`, `Catalogue.lean`) to learn something: read their generator or the report instead. Run commands in bash, from the repository root.

| File | Command |
| --- | --- |
| `pilot/data/catalogue.json` | `python3 pilot/collect.py --all --cache pilot-cache --comparator pilot/data/comparator-results.json > pilot/data/catalogue.json` |
| `pilot/data/sample.json` | `python3 pilot/collect.py 005 008 009 012 --folder F > pilot/data/sample.json`, a `--folder` per withdrawn manuscript |
| `pilot/data/comparator-results.json` | `python3 pilot/shard_results.py --logs pilot-logs EVERY_RUN_ID... > pilot/data/comparator-results.json` |
| `pilot/data/comparator-measurements.json` | None: #83's untrusted run, recorded once |
| `pilot/data/shards.json` | `python3 pilot/imports.py LEAN_DIR pilot/data/catalogue.json > pilot/data/shards.json` |
| `pilot/data/shard-plan.json` | `python3 pilot/plan_shards.py pilot/data/shards.json > pilot/data/shard-plan.json` |
| `pilot/data/reading-lists.json` | `python3 pilot/reading_list.py LEAN_DIR pilot/data/catalogue.json lean/lake-manifest.json > pilot/data/reading-lists.json` |
| `lean/JSG/Pilot/Catalogue.lean` | `python3 pilot/to_lean.py pilot/data/catalogue.json --comparator pilot/data/comparator-results.json --name Catalogue > lean/JSG/Pilot/Catalogue.lean` |
| `lean/JSG/Pilot/Sample.lean` | `python3 pilot/to_lean.py pilot/data/sample.json --comparator pilot/data/comparator-measurements.json > lean/JSG/Pilot/Sample.lean` |
| `pilot/reports/catalogue.md` | `cd lean && lake env lean --run Gate.lean pilot catalogue > ../pilot/reports/catalogue.md` |
| `pilot/reports/first-sample.md` | `cd lean && lake env lean --run Gate.lean pilot > ../pilot/reports/first-sample.md` |
| `pilot/reports/reading-lists.md` | `python3 pilot/reading_list.py --report pilot/data/reading-lists.json > pilot/reports/reading-lists.md` |

`LEAN_DIR` is the release's `lean/` at the pin, checked out as files only (`pilot/imports.py`). CI's `scripts/pilot-reports.sh` checks the two `Gate.lean` reports.

## Paths that live only at a tag or commit

- **The rule:** a path cited in a frozen file resolves at the statements tag that added the citing section (`statements-v1` for sections 1 to 7; the file's "added for" notes name the rest), not at `v1.1`.
- **Today's case:** section 16's header in `lean/JSG/Statements.lean` and `lean/JSG/Defs.lean` names `guide/ROADMAP.md`, which `main` no longer holds. Read it with `git show statements-v5:guide/ROADMAP.md`, at its "Milestone 5" section ([on GitHub](https://github.com/marleymcwilliams/LibSpec/blob/statements-v5/guide/ROADMAP.md#milestone-5-the-cores-gap-statements)).
- **Any file trim PR 1 deleted** reads with `git show 3b481d5e951bb30300195598e9dada5a753ab61c:<path>`.
- **Permanent links** follow the rules in [`scripts/check-links.py`](../scripts/check-links.py).
