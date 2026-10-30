# The guide, and a map of the repository

LibSpec states a governance-and-evidence calculus in Lean, proves it, and runs it as an executable gate on real claims. This page maps every file outside `archive/` and says what to read first. The repository's own [README](../README.md) says what is proved, and [REPRODUCE.md](../REPRODUCE.md) says how to check it.

## Reading order

**For a person new to the project:**
1. [README](../README.md): what LibSpec is, and what is proved and what isn't.
2. [ROADMAP.md](ROADMAP.md): the phases, each with its gate, and where the work stands.
3. [GLOSSARY.md](GLOSSARY.md): the canonical terms, and the four core objects they name.
4. [LAYER_MAP.md](LAYER_MAP.md): every component of the corpus, what justifies it, and its status.
5. [EXECUTABLE_GATE.md](EXECUTABLE_GATE.md): the twins, the harness and the openai/math pilot.
6. The milestone notes, [MILESTONE_1.md](MILESTONE_1.md) to [MILESTONE_4.md](MILESTONE_4.md), for what each proof shows and doesn't.
7. [`pilot/reports/catalogue.md`](../pilot/reports/catalogue.md), for the gate's verdict on a real release.

Then, as needed: [DEFECTS.md](DEFECTS.md) for what the corpus gets wrong, [SOURCES.md](SOURCES.md) for where each part came from, and [STATEMENTS_REVIEW.md](STATEMENTS_REVIEW.md) for why each statement says what it says.

**For an agent starting a session:**
1. [CLAUDE.md](../CLAUDE.md): the rules, which win over everything else.
2. This page, then [CONVENTIONS.md](CONVENTIONS.md): how things are named.
3. [QUEUE.md](QUEUE.md): the open questions, and the answers already given.
4. [LOG.md](LOG.md), from the top: the latest decisions.
5. [ROADMAP.md](ROADMAP.md): the current phase and its gate.
6. Only then, the files the session's target needs. Before touching a statement or a check, read [LAYER_MAP.md](LAYER_MAP.md) and CLAUDE.md's list of what the human merges.

## The guide

| File | What it holds |
| --- | --- |
| [README.md](README.md) | This map |
| [MASTER_GUIDE.md](MASTER_GUIDE.md) | The canon's purpose and reading rules, and an index to the four files below |
| [GLOSSARY.md](GLOSSARY.md) | The canonical terms, each with one home, and the core objects (v2) they name |
| [LAYER_MAP.md](LAYER_MAP.md) | Every component: its layer, status, pointer and source; and what each statements version adds |
| [DEFECTS.md](DEFECTS.md) | The corpus's known defects, and their fixes |
| [SOURCES.md](SOURCES.md) | The corpus's lineage, and what each source is canonical for |
| [ROADMAP.md](ROADMAP.md) | The phases and their gates, the master guide's checklist, and how a session runs |
| [CONVENTIONS.md](CONVENTIONS.md) | How files, branches, pull requests, theorems and tags are named |
| [EXECUTABLE_GATE.md](EXECUTABLE_GATE.md) | The executable gate: the twins, the harness, the pilot, where things run, and its decisions |
| [STATEMENTS_REVIEW.md](STATEMENTS_REVIEW.md) | Each statement beside its source, with its mutant and witness |
| [MILESTONE_1.md](MILESTONE_1.md)–[MILESTONE_4.md](MILESTONE_4.md) | Each milestone's proofs, its gate record and its closing note |
| [CHANGELOG.md](CHANGELOG.md) | What each statements version changed, and whether it tightens or weakens |
| [QUEUE.md](QUEUE.md) | Questions waiting for the human, at most three open, and the answers given |
| [LOG.md](LOG.md) | Every reversible decision, by date, newest first |
| [IDEAS.md](IDEAS.md) | The parking lot: ideas kept out of the current work |
| [decisions/](decisions/) | The human's decision brief and records: [DECISION_BRIEF.md](decisions/DECISION_BRIEF.md), [RAILS.md](decisions/RAILS.md) |

Some of it is the human's alone. The milestone notes' closing notes are in the human's words and stay as written, `decisions/` changes only in pull requests the human merges, and LOG entries are added, never rewritten. [CLAUDE.md](../CLAUDE.md) lists everything else the human merges.

## The Lean library, `lean/`

| File | What it holds |
| --- | --- |
| `lakefile.toml`, `lean-toolchain`, `lake-manifest.json` | The build: Lean and Mathlib v4.34.1. The statements check covers all three |
| `JSG/Defs.lean` | **Frozen.** The definitions the statements use |
| `JSG/Statements.lean` | **Frozen.** The theorem statements, each `sorry`, with its mutant named in a comment |
| `JSG/Proofs/Milestone1.lean`–`Milestone4.lean` | The proofs, one file per milestone, each restating its frozen theorems |
| `JSG/Lemmas/KLFisher.lean`, `JSG/Lemmas/Twins.lean` | Helper lemmas for Milestones 3 and 4 |
| `JSG/Solution.lean` | Imports every proof file: Comparator's solution |
| `JSG/Tests/Mutants.lean` | Each theorem's mutant, proved to violate it, and its witness |
| `JSG/Tests/Calibration.lean` | The must-pass and must-fail sets, and `verdict_calibrated` |
| `JSG/Tests/ConcreteLoader.lean` | The concrete Loader, built as a `Loader` |
| `JSG/Tests/Smoke.lean`, `JSG/Tests/Differential.lean` | Phase 0's smoke test, and the harness's differential tests |
| `JSG/Tests/Comparator/` | Comparator's self-test: a challenge, its solution, and a mutant it must reject |
| `JSG/Tests.lean`, `JSG.lean` | Roots: every test file, and the whole library |
| `JSG/Harness/` and `JSG/Harness.lean` | The executable gate's harness: the report, JSON, the corpus, the mutants, and `run` |
| `JSG/Harness/examples/` | Example inputs and their expected reports |
| `JSG/Pilot/` and `JSG/Pilot.lean` | The pilot: raw records to grades (`Core`), the generated data (`Sample`, `Catalogue`), their proofs (`Calibration`, `CatalogueCalibration`) and the report's words (`Words`) |
| `Gate.lean` | The harness's command line: `lake env lean --run Gate.lean …` |
| `AxiomAudit.lean` | The axiom audit, over every proof, lemma, test, harness and pilot module |
| `ComparatorTargets.lean` | Lists the theorems a Comparator config must name |

## Everything else

| Path | What it holds |
| --- | --- |
| [README.md](../README.md), [REPRODUCE.md](../REPRODUCE.md) | What is proved, and how to check it yourself |
| [CLAUDE.md](../CLAUDE.md) | The working rules for Claude Code |
| `.gitattributes`, `.gitignore` | LF line endings everywhere, the archive kept byte for byte; build output ignored |
| `.github/workflows/ci.yml` | CI: the build with leanchecker, `scripts/check.sh`, the differential tests and Comparator |
| `.github/workflows/comparator-full.yml` | The full-strength Comparator run, by hand: nanoda and the full sandbox |
| `.github/workflows/pilot-comparator.yml` | Comparator on a few of the release's challenges, as measurements only |
| `.github/workflows/pilot-shards.yml` | Phase 7's trusted Comparator runs, by shard: an untrusted job that runs the release's lakefile, and trusted jobs that rebuild its tree from the pin and check against it |
| `scripts/check.sh` | The build, the forbidden-token scan, the axiom audit and the statements check |
| `scripts/comparator.sh`, `scripts/comparator-full.sh`, `scripts/build-comparator-tools.sh` | Comparator, everyday and full-strength, and the tools it needs |
| `scripts/differential.sh`, `scripts/sirusc_adapter.py` | The differential tests, and the adapter that runs SirusSC's code from `archive/` |
| `scripts/pilot-comparator.sh` | The pilot's measurement runs |
| `scripts/pilot-release.sh`, `scripts/pilot-fetch.sh` | The release at the pin, and its `lake update`, in the untrusted job |
| `scripts/pilot_deps.py`, `scripts/pilot_tree.py` | The trusted job's rebuild of the release's dependencies, and the comparison with the untrusted tree |
| `scripts/pilot-shard.sh`, `scripts/pilot_shard.py` | The trusted job's Comparator runs on a shard, and their results |
| `scripts/sandbox-check.sh` | Proves Comparator's landrun sandbox is in force, and the frozen build outputs unwritable |
| `scripts/test-pilot-shard.sh` | The self-test of the shard runs: every outcome, with a fake comparator |
| `pilot/collect.py`, `pilot/to_lean.py`, `pilot/imports.py`, `pilot/plan_shards.py`, `pilot/shard_results.py` | The pilot's collector, its Lean generator, the import-graph reader, the shard plan, and the collector of the trusted results |
| `pilot/data/` | Collected facts: `sample.json`, `catalogue.json`, `comparator-results.json`, `shards.json`, `shard-plan.json` |
| `pilot/reports/` | The generated reports: `first-sample.md`, `catalogue.md` |
| `archive/` | **Read-only.** The original corpus, committed once. [SOURCES.md](SOURCES.md) says what each part is |
