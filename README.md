# LibSpec

Exploration of liberal governance principles within a lean verification paradigm.

LibSpec takes the JSG/SIRUS governance corpus, a set of papers and specs on graded evidence, runtime gates and policy, and asks which of its claims can be stated precisely and proved in Lean 4. The claims that can be are frozen as Lean statements, proved, and checked by machine. Everything else is labelled with the reason it isn't a Lean claim: it belongs to CI, it's a per-instance certificate, it's open mathematics, or it's a declared norm.

## Status

**As of v1.0** (the tag `v1.0`, at `0c36127`), **all 26 frozen theorems are proved.**
- **Comparator** checks each proof against its frozen statement, and allows only `propext`, `Classical.choice` and `Quot.sound`.
- **Controls:** each theorem has a mutant, a plausible wrong version proved to fail it, and a witness, an instance proved to satisfy it.
- **Frozen versions:** the statements were frozen in three versions, `statements-v1` to `statements-v3`, each before its proofs were written. No statement was changed to make a proof go through.

**Since v1.0,** `statements-v4` adds eight frozen theorems. They are executable twins of the core's graded values, combine, verdict, residual threading, widths and leases, each with a theorem that it agrees with its frozen definition ([the executable gate](guide/EXECUTABLE_GATE.md), [the changelog](guide/CHANGELOG.md)). So `main` holds 34 frozen theorems, of which 26 are proved. Until Milestone 4 proves the other eight:
- Comparator's everyday run lists them as not yet proved, and still passes;
- the full-strength run fails, since it requires every frozen theorem to be proved;
- the twins run and their controls pass, but nothing yet proves that they agree with the frozen definitions.

To check v1.0 itself, check out its tag ([REPRODUCE.md](REPRODUCE.md)).

## What is proved, and what isn't

- **[The layer map](guide/MASTER_GUIDE.md#layer-map)** lists every component of the corpus. Each row has its status, its limits, and a pointer to its Lean theorem or to the reason it's out of scope.
- **The three milestone notes:** [Milestone 1](guide/MILESTONE_1.md) is the algebraic core, [Milestone 2](guide/MILESTONE_2.md) the obligations, Loader, charge and policy lattice, and [Milestone 3](guide/MILESTONE_3.md) the analysis layer. Each explains every proof in plain English, and ends with a closing note on what is now proved and what it doesn't show.
- **[The changelog](guide/CHANGELOG.md)** records each statements version and whether it tightened or weakened the statements. So far every one has only added.
- **[The statements review](guide/STATEMENTS_REVIEW.md)** puts each theorem beside the mutant that refutes it, and says where each mutant comes from.

CI shows that the proofs conform to the statements. Whether the statements say the right thing is a human judgment, and the milestone notes record it.

## Checking it yourself

[REPRODUCE.md](REPRODUCE.md) takes a fresh machine through building everything and running `scripts/check.sh`, which does the build, a forbidden-token scan, an axiom audit, and a check that the statements match their frozen tag. It also covers Comparator, both CI's everyday run and the full-strength run, and records the latest full-strength result.

## Layout

| Path | What it holds |
| --- | --- |
| `lean/JSG/Defs.lean`, `lean/JSG/Statements.lean` | The frozen definitions and statements. CI fails if either differs from the latest `statements-v*` tag |
| `lean/JSG/Proofs/` | One proof file per milestone. Each restates its frozen theorems under the same names, and `Solution.lean` imports them all |
| `lean/JSG/Lemmas/` | Helper lemmas, used by the proofs |
| `lean/JSG/Tests/` | Mutants, witnesses and calibration controls, the concrete Loader, and the Comparator self-test fixtures |
| `lean/AxiomAudit.lean`, `lean/ComparatorTargets.lean` | The axiom audit, and the list of theorems Comparator checks |
| `scripts/` | `check.sh`, Comparator's everyday and full-strength runs, and the Comparator tools build |
| `guide/` | The master guide with its layer map, the roadmap, the milestone notes, the decision queue and log |
| `archive/` | The source corpus, read-only |

## Credits

LibSpec is Marley McWilliams's project. Marley wrote or approved every frozen statement and proved three of them; AI assistants (Claude Code and Claude) wrote the other proofs, the checks and most of the guide.
