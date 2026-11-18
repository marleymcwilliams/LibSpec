# Conventions

How files, branches, pull requests and theorems are named in LibSpec, and how the project is described. These are the habits LibSpec's pull requests settled into, written down so that new work follows them. The rules for who may change what are in [CLAUDE.md](../CLAUDE.md), and they win over anything here.

## Files

| What | Form | Examples |
| --- | --- | --- |
| Guide documents | `UPPER_SNAKE.md`, in `guide/` | `ROADMAP.md`, `LAYER_MAP.md`, `EXECUTABLE_GATE.md` |
| Milestone notes | `MILESTONE_<N>.md`, one per milestone | `MILESTONE_4.md` |
| Decision briefs and records | `guide/decisions/`, which you own | `RAILS.md`, `DECISION_BRIEF.md` |
| Lean modules | `UpperCamel.lean`, one directory per layer, and a root file of the same name that imports every module in it | `JSG/Pilot/Core.lean`, imported by `JSG/Pilot.lean` |
| Proof files | `JSG/Proofs/Milestone<N>.lean`, restating each frozen theorem under its exact name | `Milestone3.lean` |
| Helper lemmas | `JSG/Lemmas/<Topic>.lean`, never in a proof file | `KLFisher.lean`, `Twins.lean` |
| Tests | `JSG/Tests/<Topic>.lean`; any change there, a new file included, is a pull request you merge (`.github/CODEOWNERS`) | `Mutants.lean`, `Differential.lean` |
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
- **Body:** the sections of [`.github/pull_request_template.md`](../.github/pull_request_template.md). `gh pr create --body-file` doesn't apply the template, so write them out, and end with the attribution line.
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

## Describing the project

Marley's rules of 2026-11-13, for outward text: the README, the repository's About line, release notes, a report's opening lines, upstream posts, and anything sent to people. The guide's own records keep the corpus's names where they name a source.

- **It grades the evidence.** Never say it verifies, confirms or debunks anyone's mathematics.
- **Standard terms lead.** JSG and SIRUS appear only as provenance labels, and "governance" not at all.
- **Who did what stays.** The README keeps its statement of who did what, in Credits.

Copy a description from here rather than rewrite it. Each number is as of v1.1, and the note under each description says where its numbers come from, so they change together.

**Plain:**

> You've probably seen headlines about AI solving math problems. I'm building a fact-checker for those claims: it sorts out which ones are actually established and which are still missing something. I ran it on about 700 papers one AI company released. Every formal proof our machines could check held up, though only about half the papers come with one. None of the papers is fully established yet, mainly because nobody has confirmed that the computer checked what each paper actually claims.

Its numbers: 724 manuscripts, 344 of them with at least one formal proof ([catalogue.md](../pilot/reports/catalogue.md)), and 406 proofs accepted, none rejected and 12 unfinished ([comparator-results.json](../pilot/data/comparator-results.json)).

**Technical,** which the README's opening says in fewer words:

> A fail-closed evidence gate for AI-generated mathematics. Each claim is graded on seven kinds of evidence, among them whether a machine-checked proof exists, whether the formal statement matches the paper, whether it has been independently reviewed, and whether it or anything it rests on has been withdrawn. A claim is accepted only when every kind is known to be good, and anything unknown counts against it. The gate's rules are specified in Lean 4, as part of a model whose 34 frozen theorems are all proved. The pilot graded all 724 manuscripts in OpenAI's openai/math release. The 406 formal proofs that fit within our runners' limits passed two independent proof checkers in a sandbox, none failed, and 12 exceeded the limits. No manuscript can be accepted yet, because nothing yet checks that a statement says what its paper claims, and no independent reviews or priority checks exist yet. The next phase builds the first of those checks.

Its sources:

- the seven kinds are the axes in `lean/JSG/Pilot/Core.lean`, where θ is 0 on each, so an unknown rejects;
- the 34 theorems are in `lean/JSG/Statements.lean`;
- the release is openai/math at commit `7ef5c0c`, and its 724 manuscripts are in [catalogue.md](../pilot/reports/catalogue.md);
- the 406, the none and the 12 are in [comparator-results.json](../pilot/data/comparator-results.json);
- the two checkers are Lean's kernel and nanoda, and the sandbox is Comparator's landrun sandbox ([EXECUTABLE_GATE.md](EXECUTABLE_GATE.md) §4);
- the next phase is Phase 8 in [ROADMAP.md](ROADMAP.md).

**For engineers:**

> It's guarded acceptance and guarded rejection from conformity assessment, with the zone between them left undecided. Accept only when the whole uncertainty interval is inside the limit, reject outright only when it's wholly outside, and report anything between as indeterminate.

Its sources: both terms are from JCGM 106:2012, opened on 2026-11-14, which treats rules with two outcomes only. The undecided zone is a lead from ISO 14253-1:2017, which nobody here has read. In LibSpec, a report already tells evidence that fails from evidence that's unknown (`Release.why` in `lean/JSG/Pilot/Core.lean`). Candidate G, planned for `statements-v5` (Milestone 5 in [ROADMAP.md](ROADMAP.md)), would prove that a failure is final.

**Proof points:**

- **Every proof that fit within the limits was checked by two independent kernels, with public, hashed logs.** The 125 job logs are assets of the v1.1 release, and the results file holds each one's SHA-256 ([REPRODUCE.md](../REPRODUCE.md), "Check the kept logs").
- **Two problems found in the tools were reported upstream.** Both on 2026-11-08: a new issue, lean4#16347, and our data added to an existing one, lean4#16290 ([LOG.md](LOG.md)).
- **Every claim's report says what's missing.** Each of the 724 manuscripts gets one of six reports, naming the axes that hold it back ([catalogue.md](../pilot/reports/catalogue.md)).
