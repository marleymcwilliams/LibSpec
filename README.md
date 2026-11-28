# LibSpec

A fail-closed evidence gate for AI-generated mathematics.

LibSpec grades mathematical claims by their evidence. Each claim is graded on seven kinds of evidence, among them whether a formal proof checks, whether its statement says what the paper claims, and whether it has been reviewed or withdrawn. The gate accepts a claim only when every kind is known to be good, and its report says what's missing. The gate's rules are specified in Lean 4, as part of a model whose 39 frozen theorems are all proved and machine-checked. They grew out of the JSG/SIRUS corpus, a set of papers on graded evidence and runtime gates, kept in [`archive/` at `v1.1`](https://github.com/marleymcwilliams/LibSpec/tree/v1.1/archive) as provenance.

Its pilot grades the 724 manuscripts of [openai/math](https://github.com/openai/math) at `7ef5c0c`, and [its report](pilot/reports/catalogue.md) gives each one's verdict and the evidence it's missing. None is accepted today. Three were withdrawn by their authors. For the others, that's about missing evidence, not a finding against the mathematics.

- **Where it stands, and where everything is:** [guide/README.md](guide/README.md)
- **Checking it yourself:** [REPRODUCE.md](REPRODUCE.md)
- **The rules agents work by:** [CLAUDE.md](CLAUDE.md)

## Credits

LibSpec is Marley McWilliams's project. Marley wrote or approved every frozen statement and proved three of them; AI assistants (Claude Code and Claude) wrote the other proofs, the checks and most of the guide.
