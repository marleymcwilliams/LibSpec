# The executable gate, and its first pilot

A design proposal, with no code yet. v1.0 proves things about the gate's definitions, but nothing runs them. This proposal makes the gate executable without losing what is proved:
- **Executable versions** of the core definitions, proved to agree with the frozen ones and frozen as `statements-v4`.
- **A thin harness** that drives them.
- **Differential tests** for any other implementation, with every existing mutant as a negative control.

Its first pilot grades the manuscripts of the openai/math release. Your answers to Q11–Q15 are recorded in [QUEUE.md](QUEUE.md), and this version follows them. None is open.

## 1. What runs, in what language, and what is proved versus tested

**Language: Lean 4, for the definitions and the harness.** The frozen definitions can't run as they are:
- they use `ENNReal`, whose arithmetic is noncomputable;
- `verdict` and `leaseVerdict` decide with classical `if`;
- `afterStage` filters a `Multiset` by a predicate that has no decision procedure;
- `LoaderStep` is a relation, not a function.

So `statements-v4` adds an executable twin for each definition in the first five rows below, and a theorem that the twin agrees with its frozen definition. Those are the twins the pilot and the first SirusSC differential test need (Q11). The obligation and Loader twins, in the last two rows, wait for a later version, when there's an implementation to test them against.

| Frozen definition | Executable twin | Agreement theorem, in words | In |
| --- | --- | --- | --- |
| `Bound`, `Bound.known`, `Bound.unknown`, `Grade`, over `ENNReal` | `XBound`, `XBound.known`, `XBound.unknown`, `XGrade`, over `WithTop ℚ≥0`: exact nonnegative rationals, plus ∞ | casting the ends into `ENNReal` (`xcast`) gives the frozen value | v4 |
| `combineAxis`, `combine`, `seqComp`, `parComp` | `xcombineAxis`, `xcombine`. Core v2 makes `seqComp` and `parComp` both `combine`, so `xcombine` is their twin too | casting commutes with combining: max on floors, + on budgets | v4 |
| `verdict` | `xverdict`, which checks each of finitely many axes | `xverdict` gives the same `Decision` as `verdict` on the cast values | v4 |
| `residual`, `Threads` | `xresidual`, `xthreads : … → Bool` | the same residual; `xthreads = true` exactly when `Threads` holds | v4 |
| `Bound.width`, `leaseVerdict` | `XBound.width`, `xleaseVerdict` | the same width; the same `Decision` | v4 |
| `Pending`, `afterStage`, `pendingAfter`, `windowStart`, `Passes` | lists in place of multisets, with decidable `Clears` | the lists' multisets are the frozen ones; `xpasses = true` exactly when `Passes` holds | later |
| `LoaderStep` (a relation) | `xstep : LoaderState → StageRun → … → Option LoaderState`, which checks the step's premises | soundness: `xstep … = some t` gives `LoaderStep s t`. Completeness: whenever the premises hold, `xstep` returns that state | later |

**Why `WithTop ℚ≥0`.** Its order and arithmetic are decidable, and the cast into `ENNReal` is injective, monotone, and preserves 0, +, max, ⊤ and truncated subtraction. So each agreement theorem reduces to a cast lemma, and through agreement every v1–v3 theorem about the twinned definitions applies to the twins, `verdict_sound`, `lease_sound` and `threads_spec` included. `pass_sound` joins them with the obligation twins. Floating point is ruled out: rounding breaks agreement, which makes a `Float` twin a natural mutant.

**The prims stay abstract.** `Prims` (digest, signature check, replay, Merkle root) stays a parameter, as Q7 decided. The harness supplies real primitives, and they are tested, not proved.

**The harness** is `lean/Gate.lean`, run as `lake env lean --run Gate.lean`, the way `ComparatorTargets.lean` runs. An executable target, for `lake exe`, would need a `lean_exe` entry in `lean/lakefile.toml`. The statements check covers that file, so the entry would need a new statements version. The harness reads raw records, dependency edges and a policy (θ and β per axis) as JSON, calls the pilot's module (§3), and prints its report. It holds no logic of its own, only parsing, the call and printing.

**What is proved, what is tested, and what is trusted:**

| | What |
| --- | --- |
| **Proved,** and frozen in `statements-v4` | each twin agrees with its frozen definition; through that, every v1–v3 theorem about the twinned definitions holds of what the harness computes |
| **Proved,** in the pilot's module | masking never adds doubt, and combining with a dependency never lowers a manuscript's doubt. So no dependency can rescue a manuscript that its own record rejects (§3) |
| **Proved,** in test files | the pilot's must-pass and must-fail verdicts, for its fixed records, by `decide`: checked by the kernel, with no native evaluation. A scratch check with seven floor axes found that plain `decide` handles comparisons and max in `WithTop ℚ≥0`, which is all the pilot needs at θ = 0. It stops at subtraction and addition, because Lean marks rational arithmetic irreducible and `decide` respects that. `decide +kernel` hands the whole evaluation to the kernel, which decides widths, residuals and budgets too, with only the three axioms. It is kernel evaluation, not native |
| **Tested** | JSON parsing and printing (round-trip and golden-file tests); the collectors, which supply only raw records and dependency edges (§3); the real primitives; other implementations (§2) |
| **CI layer** | Comparator's runs on formalizations (§4) |
| **Trusted** | Lean's code generator and interpreter, which run the harness. The kernel checks the theorems about the Lean definitions, not what the interpreter does. The `decide` proofs above cover the fixed records without trusting it |

## 2. How other implementations are tested against the spec

**Built** (#72, #74–#78). The harness, the corpus and the negative controls are in `lean/JSG/Harness/` and `lean/JSG/Tests/Differential.lean`, and `scripts/differential.sh` runs the differential tests in CI ([REPRODUCE.md](../REPRODUCE.md), step 5). What follows is the design, with what each part became.

The executable twins become the oracle. Any other implementation reads the same JSON test vectors and must print the same verdicts. Candidates:
- SirusSC's Python `specchain` (`Q`, `QPrime`, the loader), read in place from `archive/`;
- jsg-lab's checks, where they overlap;
- any future implementation.

**The corpus** has three parts:
1. **From the controls:** every witness, and every mutant's counterexample, in `Tests/Mutants.lean`. Lean already proves that each counterexample separates its mutant from the spec.
2. **Exhaustive small vectors:** up to three axes of either kind, endpoints in {0, 1, 2, ∞}, and thresholds and leases in {0, 1, ∞}. That's a few thousand vectors, each with the oracle's answer.
3. **Seeded random vectors**, for larger grades and runs.

As built, the corpus has 3,818 vectors: 23 from the controls, 3,395 exhaustive and 400 random, with grades of three to seven axes and seed 2026.

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
| `afterListed`, `TRowStep`, `SirusIsoStep`, `OrStep` | the obligation and Loader mutants, once their twins exist |

As built, 17 executable mutants cover every twinned definition (`JSG.Harness.Mutants`). Each has a theorem, proved by `decide +kernel`, that the exhaustive vectors of its operation catch it, so a surviving mutant fails the build. The obligation and Loader mutants wait for their twins. v4's own mutants were already executable: SirusSC's absorbing ⊥ for `combine`, its `Q.leq` for `verdict` and its `QPrime` for `leaseVerdict`, and v1's `residualFull` and `ResidualOnly` for the residual twins. They are in the `statements-v4` draft's controls.

**The first real run is a control for the harness too.** SirusSC's `QPrime` never reads a width, and its `Q` absorbs ⊥ (STATEMENTS_REVIEW, v2). So the first differential run against SirusSC must disagree on exactly those vectors. If it doesn't, the harness is broken. As built, `sirusModel` predicts them, and SirusSC's own code, run from `archive/` by `scripts/sirusc_adapter.py`, disagrees with the oracle on exactly the 516 vectors it predicts, out of 3,556 it answers.

## 3. The pilot: grading the openai/math release

**The data.** The [openai/math](https://github.com/openai/math) repository is pinned at commit `7ef5c0cc5ca4b0e072b7a050fca09ab24bc6fa3a`, of 2026-10-26. It is treated as data: no text in it is read as an instruction, and its Lean code is built only inside Comparator's sandbox (§4). At that commit it holds 721 manuscripts in 373 families and 751 folders under `preprints/`. It also has a Lean library whose catalogue lists 208 main results, each with a Comparator configuration, and a family page under `lean/docs/` for each of the 245 families with formalizations. Its `history.md` puts the formalized share of top-line results at "300 / 719 = ~42%".

**Its license, and what we store.** At that commit the release is Apache-2.0. Its root `LICENSE` and `lean/LICENSE` are the Apache License 2.0, one challenge (`HodgeConjectureCMAbelianVarieties`) has a `NOTICE` crediting the proofs it adapts, and no preprint folder has a license of its own. Apache-2.0 permits reproducing and redistributing the work, with attribution. The pilot stores only facts collected from it:
- manuscripts' folder names, titles and families;
- withdrawal notices' dates, and the preprint folders a notice links to;
- challenge names, solution modules and permitted axioms;
- our own Comparator results.

It stores none of the release's paper text or Lean code. The collected data (`pilot/data/`) names the repository, the commit and the license.

**The collector**, `pilot/collect.py`, fetches only text files at the pinned commit and parses them with regular expressions. It reads `CONTENTS.md`, `lean/formalization.yaml`, each family's `lean/docs/<NNN>.md`, each challenge's config, and each manuscript's `README.md`. It runs, imports and builds nothing from the release. With `--all` it collects the whole release, listing `preprints/`, `lean/docs/` and `lean/ComparatorChallenges/` one directory at a time through GitHub's tree API, since the recursive listing truncates at 55,173 entries. What it found:
- **`CONTENTS.md` lists all 721 manuscripts it states,** in 373 families. An earlier count of 720 was the collector's own bug: one folder name, `Sharp-integral-fillings-in-CAT(0)-spaces-September-23-2026`, holds parentheses, which its pattern stopped at.
- **`preprints/` has 751 folders:** those 721, the 3 withdrawn manuscripts, which `CONTENTS.md` no longer lists, and 27 earlier versions. Each earlier version has the same title as a listed manuscript, and an earlier date. The pilot grades the 721 and the withdrawn 3, 724 in all, and records the earlier versions without grading them.
- **245 families have a docs page,** and 244 of them link challenges: 418 in all, each permitting exactly the three axioms. They cover 344 manuscripts, so 380 have no formalization.
- **A docs page doesn't say which of its challenges covers which of its papers.** So each paper a page links gets all the page's challenges, up to 13, and `formal_proof` is known only when all of them pass.
- **Two docs pages link an earlier version** of a listed manuscript, in families 342 and 376. Their challenges count for the listed version, and its record names the folder the page links. That's safe because a formalization is complete only once a named reviewer has checked the challenges' statements against the listed paper.

**One manuscript's record.** Each axis holds a doubt in [0, ∞], larger being worse, and the verdict reads its upper end. All seven axes are floor axes. Combining a manuscript with what carries over from the ones it depends on (below) then takes the worst doubt on each axis, which is the spec's own `combine`.

| Axis | Value | Where it comes from | Known today? |
| --- | --- | --- | --- |
| `withdrawn` | [∞, ∞] if withdrawn, else [0, 0] | `preprints/<m>/README.md`: a withdrawal notice heads it ("Withdrawal notice: …") | **Yes**, for every folder |
| `dependency_withdrawn` | not collected: the closure computes it (below). It is [0, 0] if the manuscript's formalization is complete. Otherwise it is unknown until its dependencies are read, and then [∞, ∞] if it rests on a withdrawn manuscript at any distance, else [0, 0] | the dependency edges: from a notice where it names one, and otherwise from each paper's bibliography of companion papers | **Partly.** Two notices name their dependency; other citations aren't machine-readable yet |
| `formal_proof` | [0, 0] if the full-strength Comparator accepts a challenge for its top-line claim, [1, 1] if it rejects, unknown if none exists | the family's `lean/docs/<NNN>.md`, whose "Comparator links" table names the challenges, then our run | **Partly.** About 58% of top-line results have no formalization, and the runs haven't been done |
| `statement_fidelity` | [0, 0] once a named reviewer confirms that the challenge states the paper's top-line claim, else unknown | `lean/docs/<NNN>.md`'s "Scope" prose, and `lean/formalization.yaml`, whose `review` is `status: unchecked` | **No**, for any manuscript |
| `axioms` | [0, 0] if the challenge permits exactly `propext`, `Quot.sound` and `Classical.choice`, else [1, 1] | `lean/ComparatorChallenges/<name>.json`, then our run | **Yes**, for configs (the one checked permits exactly those three) |
| `independent_review` | [0, 0] once an independent review is published, else unknown | outside the repo. For example, `history.md` says a working group led by Impagliazzo, Paturi and Williams will examine the ETH paper | **No** |
| `novelty` | [0, 0] once priority is checked against the literature, else unknown | outside the repo; the README "defer[s] to the math community completely on matters of credit, precedence, and concurrent work" | **No** |

**Today no real manuscript is accepted,** and that is the honest answer. With a finite threshold, an unknown axis makes the verdict `reject` (`verdict_sound`), and `statement_fidelity`, `independent_review` and `novelty` are unknown for all 721. The pilot's useful output is each manuscript's report, which lists what it would take to accept it.

**What carries over from a dependency** (Q14). A manuscript's final grade is its own record combined, by `combine`, with what carries over from the final grade of each manuscript it depends on, so a doubt travels any distance. On a floor axis, combining with [0, 0] changes nothing, so an axis that doesn't carry contributes [0, 0]. Companion papers can cite each other, so the dependencies form a graph, not a tree. The final grades are then its least fixed point, which iterating reaches in finitely many steps, since every value is one of the records' own.

Call a manuscript's formalization **complete** when its own `formal_proof`, `axioms` and `statement_fidelity` are all known to be 0, so its statement has been checked. Comparator has then checked a proof, using only the three axioms, of a statement that a named reviewer confirmed is the paper's claim. Whether a manuscript is complete is read from its own record, before anything carries.

| Axis | Does a dependency's doubt carry over? | Why |
| --- | --- | --- |
| `withdrawn` | No: it feeds `dependency_withdrawn` instead | A notice withdraws its own manuscript, not the ones that cite it. The withdrawal still counts against them, on the next axis |
| `dependency_withdrawn` | Yes, unless the manuscript's formalization is complete: a dependency's `withdrawn` and its own `dependency_withdrawn` both carry, at any distance | A withdrawn result undermines whatever rests on it, however far away: the two K3 papers were withdrawn because of the eightfolds paper. Your reason for the exception: a complete formalization, its statement checked, re-establishes the result in Lean independently, so a withdrawn dependency can't undermine it |
| `formal_proof` | Yes, unless the manuscript's formalization is complete | Your reason: a complete formalization lets Comparator check the whole argument, the dependency's part included. Until then, a result that uses a dependency's theorem is only as well checked as that theorem |
| `axioms` | The same | Comparator's axiom check of a complete formalization covers every lemma it imports, so the dependency's own configuration adds nothing. Otherwise an extra axiom behind a dependency's result is a doubt about what is built on it |
| `statement_fidelity` | The same | A dependency's formal proof supports the result its paper states only if its challenge states that result. A complete formalization uses the dependency's Lean theorem as stated, so it doesn't need that |
| `independent_review` | The same | A referee takes the results a paper cites as given, so a review of the manuscript doesn't cover its dependencies' arguments. A complete formalization does |
| `novelty` | No | Your reason: a new result can rest on old ones. A priority question about a dependency is about the dependency |

**What this changes under θ = 0.** No carried doubt can change a verdict. Nothing carries into a manuscript whose formalization is complete. When it isn't complete, one of its own formal axes is already above 0. So carry-over decides what a report lists, and would decide verdicts only if a threshold were raised above 0.

**What a report says** (Q12). A report never says "rejected", because the verdict is about the evidence, not the mathematics. When the verdict is `reject`, the report reads "not accepted: evidence incomplete on" and lists each axis above its threshold, with one of:
- **unknown:** no evidence yet, or none read yet;
- **the evidence that fails:** for example, "its authors withdrew it on October 6, 2026";
- **through a dependency:** the doubt carried over, and the report names the manuscript it came from.

An accepted manuscript's report reads "accepted: every axis is known to be within its threshold". The spec's `Decision.reject` keeps its frozen name; only the harness's words change.

**Where the pilot's logic lives: in Lean, in the pilot's own module.** Everything the verdict or the report depends on is a Lean definition in `lean/JSG/Pilot/`, over the twins:
- **From raw facts to doubts:** each axis's value in the first table, as a function of the raw facts in its "where it comes from" column. Those facts are a notice and its date, Comparator's result, the axioms a challenge permits, and whether a named reviewer's check, a review or a priority check exists.
- **The carry-over rule:** what a dependency passes on. It reads the dependency's `withdrawn` into the `dependency_withdrawn` it passes on. Then it masks every axis that doesn't carry, given whether the dependent's formalization is complete. A masked axis is [0, 0].
- **The dependency closure:** each manuscript's own doubts, combined by `xcombine` with what each of its dependencies' closures passes on. Its `dependency_withdrawn` starts as unknown until its dependencies have been read, and as [0, 0] once they have, or if its formalization is complete. Iterated from the raw records, the closure settles within as many rounds as there are manuscripts. That bound is for the module to prove: a walk round a cycle passes on no more than the same walk without the cycle.
- **The report:** which axes are above their thresholds, and why.

So the collectors supply only raw records and dependency edges, and the harness only parses, calls the module and prints. Nothing the verdict depends on lives in Python, or in any other collector code.

**Proved in the module,** with only the three axioms:
- **Masking never adds doubt:** each axis of a masked grade lies within the same axis unmasked, at both ends.
- **Combining with a dependency never lowers a manuscript's doubt,** at either end, on a floor or a budget. So every round of the closure keeps each manuscript's own record.
- **A consequence:** more doubt never turns a rejection into an acceptance, so no dependency can rescue a manuscript that its own record rejects.

A scratch check proved all three for the `statements-v4` twins in about 40 lines, with one round of the closure as a fold over a manuscript's dependency edges.

**Where it builds.** The `JSG.*` glob in `lean/lakefile.toml` already builds `lean/JSG/Pilot/`, so that file, which the statements check covers, doesn't change. The axiom audit and the forbidden-token scan cover only `Proofs/`, `Lemmas/` and `Tests/` today. So they must be extended to `Pilot/` when it lands: a stronger check, in files you merge.

**Must-fail set.** The three withdrawn manuscripts, each of which carries a notice dated October 6, 2026:
- "Algebraicity of Weil classes on split abelian eightfolds";
- "Algebraicity of Kuga–Satake Correspondences for K3 Surfaces";
- "The rational Hodge conjecture for products of K3 surfaces".

The test is stronger than "not accepted": each must be **not accepted on known axes alone**. Set every unknown axis to its best value, [0, 0], and the verdict must still be `reject`. Each has `withdrawn` = [∞, ∞]. That axis is its own, not carried, so it rejects whatever the test assumes. As the records stand, the two dependents also get `dependency_withdrawn` = [∞, ∞], through the eightfolds paper their notices name. In the test their formalizations count as complete, so that axis drops out, and `withdrawn` alone must reject them. Synthetic must-fails join them, none of which may be accepted:
- a record with one unknown axis;
- a formalization that Comparator rejects;
- a challenge that permits an extra axiom;
- a manuscript that isn't withdrawn itself and whose formalization isn't complete, resting two steps away on one that is. Its own formal axes already reject it, so the test is that its report lists `dependency_withdrawn` through that chain, which shows the axis carries at any distance.

**Must-pass set.** No real manuscript can pass today, since none has every axis known. The set starts with synthetic records:
- a record whose axes are all known and within θ;
- a complete formalization, with every axis of its own at 0, that rests on a manuscript nobody has reviewed and on one that is withdrawn. It tests that nothing carries past a complete formalization, `dependency_withdrawn` included (Q14).

Real manuscripts join it once their unknown axes are resolved, the first candidates being formalized results whose statement a named reviewer has checked against the paper. `Calibrated` requires the two sets to be disjoint, and the must-pass set to be accepted.

**A worked example.**
- **The eightfolds paper:** `withdrawn` = [∞, ∞], so it is not accepted, whatever else is known. Its report begins "not accepted: evidence incomplete on `withdrawn` (its authors withdrew it on October 6, 2026)".
- **"Catalan's constant is irrational"** (family 005): its `lean/docs/005.md` names `Catalan.lean` as its challenge, so `formal_proof` awaits our run, and `axioms` reads from its config. `statement_fidelity`, `independent_review` and `novelty` are unknown. So today its report reads "not accepted: evidence incomplete on `formal_proof` (unknown: our run is pending), `statement_fidelity`, `independent_review` and `novelty` (unknown), and `dependency_withdrawn` (unknown: its citations aren't read yet)". That is its to-do list.

## 4. Where things run

**GitHub Actions: Comparator, and anything that builds the release's Lean code.**
- `comparator-full.yml` has shown that the full sandbox works there: Linux 7.0, a systemd user manager and Landlock, on a fresh VM for every run.
- The pilot would run Comparator on each release challenge the same way. Their toolchain is `leanprover/lean4:v4.34.1`, the same as ours, so the same tools apply.
- A hosted runner has 4 cores, 16 GB of memory and a 6-hour job limit. It had 86 GB of free disk, and 104 GB once the pilot's workflow removed preinstalled toolchains. The release's library is 163,096 Lean modules, with several large dependencies (PrimeNumberTheoremAnd, Carleson and others). Some challenges may exceed those limits, so the pilot should measure them on a few before scaling.

**Measured on four challenges** ([run 40916190535](https://github.com/marleymcwilliams/LibSpec/actions/runs/40916190535), #83). Comparator accepted all four, with both nanoda and Lean's kernel, but the run isn't trusted (below), so these are measurements:

| Stage | Time | Disk used |
| --- | --- | --- |
| The release's `lean/`, by sparse checkout | 70 s | 2.4 GB |
| `lake update`, with Mathlib's cache | 3 min | 9.0 GB, 8.4 GB of it packages |
| `Catalan` (005) | 85 min: 43 building, 41 in the kernels | 3.2 GB, 999 modules built |
| `DeligneDrinfeld` (008) | 9 min | 0.2 GB, 22 modules |
| `BogomolovPopInjectivity` (009) | 3 min | 0.05 GB, 6 modules |
| `JointDickman` (012) | 48 min: 43 building, 3 in the kernels | 7.7 GB, 1,837 modules |
| **All of it** | **2 h 29 min** | **22.7 GB** |

What that means for scaling:
- **Each challenge builds its part of the release from source.** Mathlib's cache covers only Mathlib, and the release has none of its own. The modules built averaged about 3.9 GB per thousand, and 1.4 to 2.6 seconds each on 4 cores.
- **The whole release is far bigger:** 418 challenges, and 163,096 Lean modules, of which the challenges need 113,748 (the import graph, below). At the measured 3.9 MB of build output a module, that's about 444 GB in all, and 29 GB for the family with the most modules, 013. So a full run must be split into jobs, and a family's shard fits one runner's disk.
- **The kernels can be as slow as the build.** nanoda took 41 minutes on `Catalan`, and 1 to 3 on the others.
- **The 100-minute cap per challenge is too tight.** `Catalan` alone took 85 minutes.
- **Trust:** fetching the dependencies runs the release's lakefile, which applies 24 patches outside Comparator's sandbox, on the same VM as the checker. So no result counts as evidence until the fetch and the check run in separate jobs, the check on a fresh VM that never runs the release's code outside the sandbox. That's proposed in #83, for your decision.

**The import graph** (`pilot/imports.py`, #86). It reads the header of each of the release's 163,096 Lean modules, 1.8 GB of source, as text, and finds what each challenge builds: the release's own modules that its challenge file and its solution import, transitively. Results are in `pilot/data/shards.json`.
- **It matches the measurements exactly.** Catalan's closure is the 988 modules of the release that its build compiled in #83's run, JointDickman's the 1,792 of its build, DeligneDrinfeld's 21 and BogomolovPopInjectivity's 5.
- **The challenges need 113,748 of the 163,096 modules,** 1.4 GB of source. Families barely share modules: shards by family build 117,544 in all, about 3% more.
- **Time, as a range.** The two measured builds give different rates: by source size, 159 s/MB for Catalan and 314 s/MB for JointDickman; by module count, 1.44 s and 2.61 s a module. So the 244 family shards would take 47 to 128 hours of building, before the kernels and each shard's setup.
- **Most shards are small.** 181 of the 244 families take under half an hour by every estimate.
- **Five families may take more than 5 hours,** the cap on one challenge, by one estimate or the other: 189, 266, 090, 159, 013. The estimates differ most where modules are large, as in the first three, so these should be measured before the rest.

| Family | Challenges | Modules | Source | By size | By count |
| --- | --- | --- | --- | --- | --- |
| 189 | 1 | 444 | 223 MB | 9.8–19 h | 0.2–0.3 h |
| 266 | 2 | 3,389 | 205 MB | 9.1–18 h | 1.4–2.5 h |
| 090 | 4 | 795 | 150 MB | 6.6–13 h | 0.3–0.6 h |
| 159 | 1 | 4,775 | 58 MB | 2.6–5.1 h | 1.9–3.5 h |
| 102 | 5 | 1,805 | 34 MB | 1.5–3.0 h | 0.7–1.3 h |
| 013 | 2 | 7,520 | 31 MB | 1.4–2.7 h | 3.0–5.5 h |

The estimate leaves out the dependencies' own modules, PrimeNumberTheoremAnd and the others, since their sources come only from `lake update`. It also leaves out the kernels, which took 41 minutes on Catalan and 1 to 3 minutes elsewhere.

**The shard plan** (`pilot/plan_shards.py`, `pilot/data/shard-plan.json`, #91). Each shard is one trusted job. Each estimate is the larger end of the import graph's two ranges.

| Phase | Shards |
| --- | --- |
| 1. Measure | `f189` and `f159`, one job each |
| 2. ETH and local smoothing | `f378` and `f079`, one job each |
| 3. The rest | 29 jobs: 2 large challenges in jobs of their own, and 27 shared jobs of up to 3.5 estimated hours each |

- **Large families.** Any family whose estimate is over 5.0 hours and that has several challenges is split, a challenge per unit: 266, 090 and 013. A unit over 3.5 hours gets a job of its own, and smaller ones share jobs.
- **The control shard,** `control`, is `BogomolovPopInjectivity` alone, about a minute of building. The workflow runs it on its own pull requests, and the negative controls run it too.
- **Every challenge is in exactly one shard,** apart from the control. The script checks this.

| Shard | Families | Challenges | Estimate |
| --- | --- | --- | --- |
| `f189` | 189 | `CycleCliqueRamsey` | 19.4 h |
| `f159` | 159 | `ErdosReciprocal` | 5.1 h |
| `f378` | 378 | `SubexponentialSAT` | 2.4 h |
| `f079` | 079 | `LocalSmoothing` | 1.6 h |
| `c-MUBSix` | 266 | `MUBSix` | 17.89 h |
| `c-PlanarPacking` | 090 | `PlanarPacking` | 12.35 h |

**The trusted shards** (`.github/workflows/pilot-shards.yml`, #92). Two jobs:
- **`fetch`, untrusted.** It fetches the release's `lean/` at the pin and runs `lake update`, so the release's lakefile clones the 42 packages at their manifest commits and applies its 23 patches. It packs the tree that leaves, sources only, as one artifact. It runs off main, with `cache-mode: read`, `contents: read` and no credentials in its checkout.
- **`shard`, trusted,** one per shard, each on a fresh runner:
  1. **It fetches the release itself,** at the pin, and checks that it names LibSpec's toolchain, so elan installs nothing the release chose.
  2. **It fetches Mathlib's cache** with LibSpec's own lakefile. LibSpec pins the release's Mathlib commit.
  3. **It rebuilds the release's dependencies with git alone** (`scripts/pilot_deps.py`). The nine packages LibSpec shares come from LibSpec's checkout, and the other 33 are cloned at their commits. Each of the 23 patches is applied to its package, as the lakefile does: `patches/<name>-lean4341.patch` to `.lake/packages/<name>`.
  4. **It compares the untrusted artifact with that rebuild,** byte for byte, and refuses on any difference (`scripts/pilot_tree.py verify`). It reads the artifact as a stream and extracts nothing.
  5. **It freezes the build outputs that came through LibSpec's tooling.** These are the nine packages' `.lake/build` directories, Mathlib's among them, and they're set immutable as root. Comparator lets a build write all of `.lake`, and its README accepts a downloaded Mathlib only if it isn't modified. Before the freeze, `lake build Mathlib` in LibSpec's own `lean/` writes the hash files the cache lacks, which Lake would otherwise write while replaying a module. The freeze is cleared at the end of the job.
  6. **It proves the wrapper's limits and the sandbox are in force,** before the first challenge, and stops otherwise. Comparator always passes `--best-effort` to landrun, and go-landlock's best-effort mode "will succeed without error even when Landlock is not available at all".
     - **The sandbox** (`scripts/sandbox-check.sh`): landrun, run inside the wrapper with the flags Comparator gives a build, must let a write inside `.lake` through. It must refuse a write outside it, in `lean/` or `$HOME`, and a write into the frozen outputs.
     - **The memory limit:** a unit with a 256 MB limit must be able to allocate 64 MB, and must be killed when it tries 512 MB. Each challenge's unit gets 13 GB, below the runner's 16 GB, so that only the challenge is killed.
     - **The same sandbox check** now runs in `scripts/comparator-full.sh` too, whose full sandbox rests on it.
     - **The exports resolve the trusted copies.** Lean resolves a module through the first search-path entry that holds its top-level directory, and lean4export appends the toolchain's library after `LEAN_PATH`. A build can write all of `.lake`, so it could plant a substitute `Mathlib/` or `Init/` in any writable entry ahead of the trusted ones. It could also rename the directories above a frozen one and put a substitute in its place. So:
       - **each frozen output is bind-mounted read-only** at a path outside `.lake` (`scripts/pilot-trusted-lib.sh`), which a rename inside `.lake` can't move;
       - **the exports' `LEAN_PATH` starts with the trusted copies:** the toolchain's `lib/lean`, then those mounts. Only then come the release's outputs and the other packages';
       - **Lean's own resolution checks it,** using `initSearchPath (← findSysroot)` and `findOLean`, as lean4export resolves (`scripts/pilot_resolve.lean`). Every root of the trusted packages must resolve into its mount, and Lean's core into the toolchain. It runs before the first challenge, and after each one before its result is printed.
  7. **It runs Comparator on each challenge** (`scripts/pilot-shard.sh`), with nanoda, inside Comparator's landrun sandbox inside the systemd-run wrapper. `LEAN_PATH` comes from the directories, so `lake env` never runs the release's lakefile outside the sandbox. The config comes from the release's, keeping only the modules, theorems, definitions and permitted axioms, so a command such as an external kernel can't come in through it.
- **What the trusted job takes from the untrusted one:** only the artifact, which it checks and never builds from. There are no job outputs, and no expression holds anything of the untrusted job.
- **The evidence is the trusted job's log,** which only that job writes:
  - **Results are its unmarked `result:` lines,** in the step "Comparator on the shard" of a job named "Shard … (trusted)" (`pilot/shard_results.py`). The untrusted job could upload an artifact under a trusted job's name, so artifacts aren't read.
  - **Nothing of the release's is printed unmarked.** Every line of Comparator's output is prefixed with `comparator|`, with carriage returns turned to spaces. Names from the release's config and tar are printed with repr. So no line the release controls can pass for a result line or a GitHub workflow command.
  - **The logs are kept beyond GitHub's 90 days.** That's GitHub's most for a public repository. `pilot/shard_results.py --logs` saves each trusted log, with its SHA-256 recorded in `pilot/data/comparator-results.json`, so the logs can be attached to the v1.1 release and checked against it.
- **Each challenge's result** is one of these. Comparator's exit status is recorded by the shell around it, outside the sandbox:
  - **accepted:** Comparator exited 0, after its success line.
  - **rejected:** Comparator exited 1 on one of its own rejections: a mismatched statement or constant, a disallowed axiom, or a refusal by Lean's kernel. nanoda reports a refusal by panicking, and an internal error the same way, so a failure of nanoda alone doesn't count as one.
  - **kernelsDisagree:** nanoda failed while Lean's kernel accepted, and it wasn't killed by SIGKILL. It stays unknown, is flagged as a warning on the run, and every case goes to Marley.
  - **buildError:** anything else that stopped it. That covers a failed build or export, a crash, and a kill by a signal or by the memory limit, nanoda's included: exit 137 is 128 plus SIGKILL, as Lean's `wait` reports a signal. Its detail says which.
  - **tooLarge:** it timed out as the first challenge in its job, whatever its cap, or later with the full 5-hour cap. It's too large to check yet.
  - **cutOff:** it timed out after other challenges, with less than the full cap, because its shared job was running out of time.
  - **notStarted:** its job ran out before it began.

  A cut-off or unstarted challenge gets one rerun in a job of its own, `solo-<challenge>`. Only a rejection is evidence that fails, and build errors and timeouts stay unknown.
- **`selftest`, a third job,** runs `scripts/test-pilot-shard.sh` before any shard. It drives `scripts/pilot-shard.sh` through the real wrapper, landrun, caps and memory limit, with a fake comparator acting out each outcome. It checks:
  - every result above;
  - that forged result lines and workflow commands appear only marked;
  - that the sandbox check fails when landrun sandboxes nothing, and when a directory listed as frozen can be written;
  - the two attacks on resolution. From inside landrun it plants `Mathlib/` and `Init/` in the release's build directory, and renames the frozen Mathlib package to put a substitute in its place. The old `LEAN_PATH` would then resolve the planted copies, and the exports' `LEAN_PATH` still resolves Mathlib and Init to the trusted ones.

**Shown to bite.** #92's own run, [41015650912](https://github.com/marleymcwilliams/LibSpec/actions/runs/41015650912), is the positive control: the two trees matched, all 194,331 entries, and Comparator accepted the control shard in 224 s. Then four throwaway pull requests each added one step to the untrusted job:

| Control | Run | What happened |
| --- | --- | --- |
| #93: a challenge file tampered with | [41017253244](https://github.com/marleymcwilliams/LibSpec/actions/runs/41017253244) | Refused at verification: "differs from the pin: lean/ComparatorChallenges/BogomolovPopInjectivity.lean" |
| #94: a dependency changed outside its patch | [41018764359](https://github.com/marleymcwilliams/LibSpec/actions/runs/41018764359) | Refused: "differs from the pin: lean/.lake/packages/PrimeNumberTheoremAnd/PrimeNumberTheoremAnd.lean" |
| #95: the restored toolchain tampered with, its `lake` altering a solution file after `lake update` | [41017268730](https://github.com/marleymcwilliams/LibSpec/actions/runs/41017268730) | Refused: "differs from the pin: lean/OAI/Algebra/BogomolovPop/Canonical.lean" |
| #96: a cache save, under the trusted job's tools key and under a fresh key | [41017271496](https://github.com/marleymcwilliams/LibSpec/actions/runs/41017271496) | Refused by the cache service: "Unable to reserve cache" for both. The cache API has no entry for either key in #96's scope, and the trusted job then accepted the control shard |

In the three refusals, the trusted job stopped before any build. Both jobs' logs show "Cache mode: read". GitHub's documentation says the effective mode is also in `ACTIONS_CACHE_MODE`, but a `run` step saw it unset. #94's first run, [41017266866](https://github.com/marleymcwilliams/LibSpec/actions/runs/41017266866), failed in its own tampering step, which found no file to change. Its rerun is the one above.

**What an acceptance shows.** The statement Comparator exported for the challenge is proved by both kernels, with the permitted axioms. Whether that statement says what the paper claims is Phase 8's question, and its reviewers check that statement and the release's definitions it uses.

**What this still trusts.** Comparator's README assumes that the lakefile and the import closure of each challenge are "controlled by you or trustworthy" (its assumption 1). It also assumes nothing adversarial was built before the challenge (its assumption 2). Here none of that is LibSpec's. Each of the following runs during Comparator's builds, inside the sandbox, where it can read everything and write all of `.lake` except the frozen outputs. That's also where the challenge's compiled statement lands before Comparator exports it:
- **The release's lakefile.** The trusted job uses it byte for byte as at the pin, and at the pin all 362 lines of it have been read. Besides declaring 30 packages, each pinned to a commit, and its libraries, it has:
  - a library facet that lists ComparatorChallenges' modules;
  - code that checks each patched package's commit and origin, and clones and patches any that are missing;
  - a hook that applies the release's patches after `lake update`.

  Nothing else in it does IO. A new pin would need it read again.
- **The dependencies' lakefiles,** which Lake elaborates for each of the 42 packages. They haven't been read.
- **Every module in each challenge's import closure:** the challenge file, its helpers, and every module of a dependency it imports. Mathlib's and its dependencies' outputs come frozen from LibSpec's tooling, and the exports reach them, and Lean's core, only through read-only paths. Lake's own view inside `.lake` during the builds can still be subverted, but the exports read Mathlib and core from the trusted copies.
- **The solutions built earlier in the same job** (assumption 2). A shared job's earlier solutions could write into the build outputs a later challenge imports, outside the frozen ones. A challenge alone in its job, such as a solo rerun, has no such earlier solutions.

Reading the release's lakefile, freezing what came through LibSpec's tooling, and proving the sandbox is on all narrow this. None of them closes it.

**Lewis & Clark's BLT cluster, for heavy builds, if its OS can run current Lean.**
- **As documented, it can't.** Its documentation ([About the cluster](https://watzek.github.io/BLTdocs/about-the-cluster.html)) says: "The cluster runs the CentOS Linux operating system, version 7.4". It has 144 cores and 1,500 GB of memory across one login node and three workers, uses Sun Grid Engine, and gives each user a 25 GB quota.
- **Lean:** CentOS 7 ships glibc 2.17, and Lean's x86-64 Linux releases need glibc 2.26 or later (Lean reference, [Supported platforms](https://lean-lang.org/doc/reference/4.33.1/platforms/)).
- **Comparator's sandbox:** CentOS 7's 3.10 kernel predates Landlock, which landrun needs, so the sandbox can't run there either.
- **If the documentation is out of date,** which is likely since CentOS 7 reached end of life in June 2024, or if BLT offers a container runtime such as Apptainer with a newer userland, BLT could take heavy trusted builds: LibSpec's own, or Mathlib-scale experiments.

Even then, it shouldn't build the release's Lean code outside a sandbox, for two reasons:
- **It would run untrusted code.** Building a Lean library runs that library's code: its macros, elaborators and `initialize` blocks. That would be untrusted code on a shared machine.
- **It wouldn't help Comparator.** Comparator's README allows a prebuilt `.lake` only if it was "obtained through other means and without compromising your checking environment". A `.lake` built on BLT would need a trusted way back to the checker.

## 5. Decisions, and the order of work

Your answers, recorded in [QUEUE.md](QUEUE.md):
- **Q11:** `statements-v4` freezes the twins in §1's first five rows. The obligation and Loader twins wait.
- **Q12:** θ = 0 on every axis, with no leases, and the must-pass and must-fail sets of §3. Reports say "not accepted: evidence incomplete on …".
- **Q13:** GitHub Actions for now. You'll look into BLT's current OS and containers.
- **Q14:** the carry-over of §3, with `dependency_withdrawn` also stopping at a complete formalization.
- **Q15:** the twins' form as drafted: `WithTop ℚ≥0`, finitely many axes, and one twin for `combine`, `seqComp` and `parComp`.

You also asked that the carry-over rule and the closure be Lean, in the pilot's own module, with their basic properties proved (§3).

The order of work:
1. **A `statements-v4` draft:** the twins, their agreement theorems, a mutant and a witness for each, and a provability check, in a draft PR as for v2 and v3: #62, to be tagged as `statements-v4`.
2. **Milestone 4,** proving them.
3. **The harness**, `Gate.lean`, the corpus and the differential tests, with every mutant as a negative control. Done: #72 and #74–#78.
4. **The pilot:**
   - its module in Lean (§3): the doubts from raw facts, the carry-over rule, the closure and the report, with their properties proved, and the axiom audit and token scan extended to it;
   - the collectors for the pinned release, which supply only raw records and dependency edges;
   - the Comparator runs on GitHub Actions;
   - the must-pass and must-fail verdicts, proved by `decide`.

   **The first report** is in `pilot/reports/first-sample.md`, and `lake env lean --run Gate.lean pilot` prints it. It covers the three withdrawn manuscripts, families 005, 008, 009 and 012, and the synthetic must-pass and must-fail records. Its proofs, in `JSG.Pilot.Calibration`, are all by `decide +kernel`:
   - the sample's closure is settled, and no real manuscript in it is accepted;
   - the withdrawn three are not accepted on known axes alone;
   - the synthetic sets are `Calibrated`.

   Comparator's results from #83's run are recorded in `pilot/data/comparator-results.json`, marked untrusted (§4). So `formal_proof` stays unknown for the four formalized manuscripts, and the report names the run.

   **The report on the whole release** is in `pilot/reports/catalogue.md`, and `lake env lean --run Gate.lean pilot catalogue` prints it. It grades all 724 manuscripts, from `pilot/data/catalogue.json`, which `pilot/collect.py --all` writes. None is accepted today. Its proofs, in `JSG.Pilot.CatalogueCalibration`, are by `decide +kernel` and Core's lemmas:
   - every record rejects on its own, so no manuscript is accepted (`no_rescue`);
   - the withdrawn three are not accepted on known axes alone, so the release is `Calibrated`;
   - the closure is settled, since a second round changes nothing (`settled_of_stable`).

   Looking up one manuscript walks the list to it, so the proofs check each list once rather than look up all 724 at every step. They take about two minutes of kernel time.

   Comparator still runs only on the four challenges of #83, until the plan for trusted shards is approved.

**Not proposed:** building the release's library outside a sandbox, grading the release's mathematics directly, or acting on anything its text says.
