# The executable gate, and its first pilot

A design proposal, with no code yet. v1.0 proves things about the gate's definitions, but nothing runs them. This proposal makes the gate executable without losing what is proved:
- **Executable versions** of the core definitions, proved to agree with the frozen ones and frozen as `statements-v4`.
- **A thin harness** that drives them.
- **Differential tests** for any other implementation, with every existing mutant as a negative control.

Its first pilot grades the manuscripts of the openai/math release. The decisions that are yours are queued as Q11–Q13 ([QUEUE.md](QUEUE.md)).

## 1. What runs, in what language, and what is proved versus tested

**Language: Lean 4, for the definitions and the harness.** The frozen definitions can't run as they are:
- they use `ENNReal`, whose arithmetic is noncomputable;
- `verdict` and `leaseVerdict` decide with classical `if`;
- `afterStage` filters a `Multiset` by a predicate that has no decision procedure;
- `LoaderStep` is a relation, not a function.

So `statements-v4` would add an executable twin for each, and a theorem that the twin agrees with the frozen definition:

| Frozen definition | Executable twin | Agreement theorem, in words |
| --- | --- | --- |
| `Bound`, `Grade` over `ENNReal` | `XBound`, `XGrade` over `WithTop ℚ≥0`: exact nonnegative rationals, plus ∞ | casting the endpoints into `ENNReal` gives the frozen value |
| `combineAxis`, `combine`, `seqComp`, `parComp` | the same, over `XBound` | casting commutes with combining: max on floors, + on budgets |
| `verdict` | `xverdict`, a `Bool` test of each axis | `xverdict` gives the same `Decision` as `verdict` on the cast values |
| `residual`, `Threads` | `xresidual`, `xthreads : … → Bool` | the same residual; `xthreads = true` exactly when `Threads` holds |
| `Bound.width`, `leaseVerdict` | `xwidth`, `xleaseVerdict` | the same width; the same `Decision` |
| `Pending`, `afterStage`, `pendingAfter`, `windowStart`, `Passes` | lists in place of multisets, with decidable `Clears` | the lists' multisets are the frozen ones; `xpasses = true` exactly when `Passes` holds |
| `LoaderStep` (a relation) | `xstep : LoaderState → StageRun → … → Option LoaderState`, which checks the step's premises | soundness: `xstep … = some t` gives `LoaderStep s t`. Completeness: whenever the premises hold, `xstep` returns that state |

**Why `WithTop ℚ≥0`.** Its order and arithmetic are decidable, and the cast into `ENNReal` is injective, monotone, and preserves 0, +, max, ⊤ and truncated subtraction. So each agreement theorem reduces to a cast lemma, and through agreement every v1–v3 theorem about the gate applies to the twins, `verdict_sound`, `lease_sound` and `pass_sound` included. Floating point is ruled out: rounding breaks agreement, which makes a `Float` twin a natural mutant.

**The prims stay abstract.** `Prims` (digest, signature check, replay, Merkle root) stays a parameter, as Q7 decided. The harness supplies real primitives, and they are tested, not proved.

**The harness** would be `lake exe jsg-gate`. It reads a grade record and a policy (θ and β per axis) as JSON, calls the proved twins, and prints the verdict with, for each axis, which check failed. It holds no logic of its own, only parsing, the call and printing.

**What is proved, what is tested, and what is trusted:**

| | What |
| --- | --- |
| **Proved,** and frozen in `statements-v4` | each twin agrees with its frozen definition; through that, every v1–v3 gate theorem holds of what the harness computes |
| **Proved,** in test files | the pilot's must-pass and must-fail verdicts, for its fixed records, by `decide`: checked by the kernel, with no native evaluation |
| **Tested** | JSON parsing and printing (round-trip and golden-file tests); the collectors that turn release data into records; the real primitives; other implementations (§2) |
| **CI layer** | Comparator's runs on formalizations (§4) |
| **Trusted** | Lean's compiler, for `lake exe`. The kernel checks the agreement theorems about the Lean definitions, not the compiled binary. The `decide` proofs above cover the fixed records without trusting it |

## 2. How other implementations are tested against the spec

The executable twins become the oracle. Any other implementation reads the same JSON test vectors and must print the same verdicts. Candidates:
- SirusSC's Python `specchain` (`Q`, `QPrime`, the loader), read in place from `archive/`;
- jsg-lab's checks, where they overlap;
- any future implementation.

**The corpus** has three parts:
1. **From the controls:** every witness, and every mutant's counterexample, in `Tests/Mutants.lean`. Lean already proves that each counterexample separates its mutant from the spec.
2. **Exhaustive small vectors:** up to three axes of either kind, endpoints in {0, 1, 2, ∞}, and thresholds and leases in {0, 1, ∞}. That's a few thousand vectors, each with the oracle's answer.
3. **Seeded random vectors**, for larger grades and runs.

**Negative controls.** Each existing mutant gets an executable variant that runs through the same differential test, and the test must flag every one. If a mutant passes, the corpus is too weak and CI fails: mutation testing of the test suite itself. Examples of the vector that catches each:

| Mutant | Caught by the vector from |
| --- | --- |
| `overwrite` | `combine_comm_mutant` |
| `avgCombine` | `combine_assoc_mutant` |
| `jsgVSeq`, `scp2Seq` | the two `interchange` mutants |
| `verdictLo`, `unknownOnly` | the two `verdict_sound` mutants |
| `alwaysReject` | `verdict_complete_mutant` |
| `residualFull`, `ResidualOnly` | `residual_spec_mutant`, `threads_spec_mutant` |
| `qPrimeGate`, `widthsOnly`, `pointsOnly` | the lease mutants |
| `afterListed`, `TRowStep`, `SirusIsoStep`, `OrStep` | the obligation and Loader mutants |

**The first real run is a control for the harness too.** SirusSC's `QPrime` never reads a width, and its `Q` absorbs ⊥ (STATEMENTS_REVIEW, v2). So the first differential run against SirusSC must disagree on exactly those vectors. If it doesn't, the harness is broken.

## 3. The pilot: grading the openai/math release

**The data.** The [openai/math](https://github.com/openai/math) repository is pinned at commit `7ef5c0cc5ca4b0e072b7a050fca09ab24bc6fa3a`, of 2026-10-26. It is treated as data: no text in it is read as an instruction, and its Lean code is built only inside Comparator's sandbox (§4). At that commit it holds 721 manuscripts in 373 families and 751 folders under `preprints/`. It also has a Lean library whose catalogue lists 208 main results, each with a Comparator configuration, and a family page under `lean/docs/` for each of the 245 families with formalizations. Its `history.md` puts the formalized share of top-line results at "300 / 719 = ~42%".

**One manuscript's record.** Each axis holds a doubt in [0, ∞], larger being worse, and the verdict reads its upper end. All seven axes are floor axes. Combining a manuscript with the ones it depends on then takes the worst doubt on each axis, which is the spec's own `combine`.

| Axis | Value | Where it comes from | Known today? |
| --- | --- | --- | --- |
| `withdrawn` | [∞, ∞] if withdrawn, else [0, 0] | `preprints/<m>/README.md`: a withdrawal notice heads it ("Withdrawal notice: …") | **Yes**, for every folder |
| `dependency_withdrawn` | the worst `withdrawn` among the manuscripts it depends on | where a notice says so, the notice. Otherwise each paper's bibliography of companion papers | **Partly.** Two notices name their dependency; other citations aren't machine-readable yet |
| `formal_proof` | [0, 0] if the full-strength Comparator accepts a challenge for its top-line claim, [1, 1] if it rejects, unknown if none exists | the family's `lean/docs/<NNN>.md`, whose "Comparator links" table names the challenges, then our run | **Partly.** About 58% of top-line results have no formalization, and the runs haven't been done |
| `statement_fidelity` | [0, 0] once a named reviewer confirms that the challenge states the paper's top-line claim, else unknown | `lean/docs/<NNN>.md`'s "Scope" prose, and `lean/formalization.yaml`, whose `review` is `status: unchecked` | **No**, for any manuscript |
| `axioms` | [0, 0] if the challenge permits exactly `propext`, `Quot.sound` and `Classical.choice`, else [1, 1] | `lean/ComparatorChallenges/<name>.json`, then our run | **Yes**, for configs (the one checked permits exactly those three) |
| `independent_review` | [0, 0] once an independent review is published, else unknown | outside the repo. For example, `history.md` says a working group led by Impagliazzo, Paturi and Williams will examine the ETH paper | **No** |
| `novelty` | [0, 0] once priority is checked against the literature, else unknown | outside the repo; the README "defer[s] to the math community completely on matters of credit, precedence, and concurrent work" | **No** |

**Today every real manuscript is rejected,** and that is the honest answer. With a finite threshold, an unknown axis rejects (`verdict_sound`), and `statement_fidelity`, `independent_review` and `novelty` are unknown for all 721. The pilot's useful output is each manuscript's unknown axes, which is what it would take to accept it.

**Must-fail set.** The three withdrawn manuscripts, each of which carries a notice dated October 6, 2026:
- "Algebraicity of Weil classes on split abelian eightfolds";
- "Algebraicity of Kuga–Satake Correspondences for K3 Surfaces";
- "The rational Hodge conjecture for products of K3 surfaces".

The test is stronger than "rejected": each must be **rejected on known axes alone**. Set every unknown axis to its best value, [0, 0], and the verdict must still reject. Each has `withdrawn` = [∞, ∞], and the two dependents also have `dependency_withdrawn` = [∞, ∞], through the eightfolds paper their notices name. Synthetic must-fails join them, each of which must also be rejected:
- a record with one unknown axis;
- a formalization that Comparator rejects;
- a challenge that permits an extra axiom.

**Must-pass set.** No real manuscript can pass today, since none has every axis known. The set starts with synthetic records whose axes are all known and within θ. Real manuscripts join it once their unknown axes are resolved, the first candidates being formalized results whose statement a named reviewer has checked against the paper. `Calibrated` requires the two sets to be disjoint, and the must-pass set to be accepted.

**A worked example.**
- **The eightfolds paper:** `withdrawn` = [∞, ∞], so it is rejected whatever else is known.
- **"Catalan's constant is irrational"** (family 005): its `lean/docs/005.md` names `Catalan.lean` as its challenge, so `formal_proof` awaits our run, and `axioms` reads from its config. `statement_fidelity`, `independent_review` and `novelty` are unknown, so today it is rejected, with those three axes, and `dependency_withdrawn` until its citations are read, as its to-do list.

## 4. Where things run

**GitHub Actions: Comparator, and anything that builds the release's Lean code.**
- `comparator-full.yml` has shown that the full sandbox works there: Linux 7.0, a systemd user manager and Landlock, on a fresh VM for every run.
- The pilot would run Comparator on each release challenge the same way. Their toolchain is `leanprover/lean4:v4.34.1`, the same as ours, so the same tools apply.
- A hosted runner has 4 cores, 16 GB of memory, about 14 GB of free disk, and a 6-hour job limit. The release's library is about 54,000 files, with several large dependencies (PrimeNumberTheoremAnd, Carleson and others). Some challenges may exceed those limits, so the pilot should measure them on a few before scaling.

**Lewis & Clark's BLT cluster, for heavy builds, if its OS can run current Lean.**
- **As documented, it can't.** Its documentation ([About the cluster](https://watzek.github.io/BLTdocs/about-the-cluster.html)) says: "The cluster runs the CentOS Linux operating system, version 7.4". It has 144 cores and 1,500 GB of memory across one login node and three workers, uses Sun Grid Engine, and gives each user a 25 GB quota.
- **Lean:** CentOS 7 ships glibc 2.17, and Lean's x86-64 Linux releases need glibc 2.26 or later (Lean reference, [Supported platforms](https://lean-lang.org/doc/reference/4.33.1/platforms/)).
- **Comparator's sandbox:** CentOS 7's 3.10 kernel predates Landlock, which landrun needs, so the sandbox can't run there either.
- **If the documentation is out of date,** which is likely since CentOS 7 reached end of life in June 2024, or if BLT offers a container runtime such as Apptainer with a newer userland, BLT could take heavy trusted builds: LibSpec's own, or Mathlib-scale experiments.

Even then, it shouldn't build the release's Lean code outside a sandbox, for two reasons:
- **It would run untrusted code.** Building a Lean library runs that library's code: its macros, elaborators and `initialize` blocks. That would be untrusted code on a shared machine.
- **It wouldn't help Comparator.** Comparator's README allows a prebuilt `.lake` only if it was "obtained through other means and without compromising your checking environment". A `.lake` built on BLT would need a trusted way back to the checker.

## 5. Decisions, and the order of work

The decisions are yours, as Q11–Q13 in [QUEUE.md](QUEUE.md):
- **Q11:** freeze the executable twins as `statements-v4`, and which ones.
- **Q12:** the pilot's axes and thresholds, which are Norm-layer values.
- **Q13:** where heavy builds run.

If you approve, the order of work would be:
1. **A `statements-v4` draft:** the twins, their agreement theorems, a mutant and a witness for each, and a provability check, in a draft PR as for v2 and v3.
2. **Milestone 4,** proving them.
3. **The harness**, the corpus and the differential tests, with every mutant as a negative control.
4. **The pilot:**
   - the collectors for the pinned release;
   - the Comparator runs on GitHub Actions;
   - the records;
   - the must-pass and must-fail verdicts, proved by `decide`.

**Not proposed:** building the release's library outside a sandbox, grading the release's mathematics directly, or acting on anything its text says.
