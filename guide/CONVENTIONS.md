# Conventions

How files, branches, pull requests and theorems are named in LibSpec. These are the habits LibSpec's pull requests settled into, written down so that new work follows them. The rules for who may change what are in [CLAUDE.md](../CLAUDE.md), and they win over anything here.

## Files

| What | Form | Examples |
| --- | --- | --- |
| Guide documents | `UPPER_SNAKE.md`, in `guide/` | `ROADMAP.md`, `LAYER_MAP.md`, `EXECUTABLE_GATE.md` |
| Milestone notes | `MILESTONE_<N>.md`, one per milestone | `MILESTONE_4.md` |
| Decision briefs and records | `guide/decisions/`, which you own | `RAILS.md`, `DECISION_BRIEF.md` |
| Lean modules | `UpperCamel.lean`, one directory per layer, and a root file of the same name that imports every module in it | `JSG/Pilot/Core.lean`, imported by `JSG/Pilot.lean` |
| Proof files | `JSG/Proofs/Milestone<N>.lean`, restating each frozen theorem under its exact name | `Milestone3.lean` |
| Helper lemmas | `JSG/Lemmas/<Topic>.lean`, never in a proof file | `KLFisher.lean`, `Twins.lean` |
| Tests | `JSG/Tests/<Topic>.lean`; a change to an existing one is a pull request you merge, and adding a new one isn't | `Mutants.lean`, `Differential.lean` |
| Generated Lean | a first line naming the generator and its input, and "Don't edit it by hand" | `JSG/Pilot/Catalogue.lean` |
| Shell scripts | `kebab-case.sh`, in `scripts/` | `comparator-full.sh` |
| Python | `snake_case.py`: in `scripts/` for checks, in `pilot/` for the pilot | `sirusc_adapter.py`, `to_lean.py` |
| Workflows | `kebab-case.yml`, in `.github/workflows/` | `pilot-comparator.yml` |
| Collected data | `pilot/data/<name>.json`, with camelCase keys, naming its source, commit and license | `catalogue.json`, `shards.json` |
| Reports | `pilot/reports/<name>.md`, generated, never edited by hand | `catalogue.md` |

`archive/` is read-only: nothing in it is renamed, moved or edited.

## Branches

`<area>/<topic>`, in kebab-case, one branch per pull request. `main` is never pushed to.

| Area | For | Example |
| --- | --- | --- |
| `proof/` | one frozen theorem's proof | `proof/kl-fisher-local` |
| `statements/` | a statements version's draft | `statements/v4-proposal` |
| `lean/`, `test/` | other Lean work: definitions under your review, and tests | `test/concrete-loader` |
| `check/`, `ci/` | the checks, and the workflows that run them | `check/audit-pilot`, `ci/comparator-full` |
| `harness/`, `pilot/` | the executable gate's harness and pilot | `pilot/catalogue` |
| `guide/`, `docs/` | the guide, and other documentation | `guide/milestone-4-gate` |
| `archive/` | adding to the archive, never changing it | `archive/old-repos` |
| `throwaway/` | a branch that shows a check bites, closed unmerged and deleted | `throwaway/audit-pilot-bites` |

## Pull requests

- **Title:** `<area>: <what it does>`, in plain words, with its place in a series when it has one: `proof: xverdict_agrees (Milestone 4, 3 of 8)`, `harness: the corpus, the oracle, and the diff command (3 of 5)`, `pilot: … (step 5)`. A statements draft is titled `statements-v<N> (proposal): …`. A throwaway is titled `THROWAWAY: <the question it answers>? (don't merge)`.
- **Body:** `## What`, then any section the change needs (a report, findings, measurements), then `## Merging`, which says whose merge it is and why, by CLAUDE.md's list. It ends with the attribution line.
- **Stacks:** a series of pull requests can stack, each on the one before. When one merges, the next is retargeted to `main` before the merged branch is deleted, since deleting a base first closes the pull request on it.
- **Commits:** `<area>: <summary>`, then a body saying what changed and why, ending with the co-author line.

## Lean names

| What | Form | Examples |
| --- | --- | --- |
| Theorems | `snake_case`, saying what holds | `combine_comm`, `verdict_sound`, `no_rescue` |
| Definitions | `lowerCamelCase` | `xcombine`, `ownGrade`, `catalogueReport` |
| Structures, inductives and their namespaces | `UpperCamelCase` | `Release`, `XBound`, `Axis` |
| Executable twins | `x` and the frozen definition's name | `xverdict`, twin of `verdict` |
| Agreement theorems | `<twin>_agrees` | `xverdict_agrees` |
| A theorem's mutant and witness | `<theorem>_mutant` and `<theorem>_witness`, in `Tests/Mutants.lean` | `verdict_complete_mutant` |
| A mutant from a real defect | `<theorem>_<source>_mutant` | `interchange_scp2_mutant` |
| Frozen names | never renamed, in `Defs.lean`, `Statements.lean` or a proof file that restates them | |

Only `JSG.lean`, the library's root, imports `JSG.Statements`. Proof files import `JSG.Defs` and restate each frozen theorem, and Comparator checks each restatement against its frozen one. Pilot and harness modules import `JSG.Defs` and each other.

## Tags

`statements-v<N>` marks a frozen statements version, and `v<X>.<Y>` a release. You create every tag. A ruleset blocks moving or deleting either kind.

## The guide's records

- **[LOG.md](LOG.md):** a `## <date>` heading per day, newest first, and under it a `### <what was decided> (#<PR>)` entry per change, in bullets.
- **[QUEUE.md](QUEUE.md):** `### Q<N>. <the question>?`, with a recommended answer, what breaks if it's wrong, and whether it can be undone. At most three are open, and an answered entry moves under `## Answered`, with your answer.
- **[IDEAS.md](IDEAS.md):** a `## Found while <doing what>` section per piece of work, with one bold lead-in per idea.
- **[CHANGELOG.md](CHANGELOG.md):** a section per statements version, saying for each change whether it tightens or weakens.
