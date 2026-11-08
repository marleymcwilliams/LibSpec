# Statement review protocol

A named reviewer follows this protocol to check that the openai/math release's challenges state their paper's claim ([ROADMAP.md](ROADMAP.md), Phase 8). Each review gives a verdict, and the verdicts are what can make the pilot's `statement_fidelity` axis known ([EXECUTABLE_GATE.md](EXECUTABLE_GATE.md), §3).

**Why it's needed.** Comparator checks a proof against its challenge's statement, but not that the statement says what the paper claims. The release's `lean/formalization.yaml` records its review as `unchecked`. So today `statement_fidelity` is unknown for every manuscript, and no manuscript can be accepted.

**How it differs from [STATEMENTS_REVIEW.md](STATEMENTS_REVIEW.md).** That file supports Marley's review of LibSpec's own frozen statements, before each `statements-v*` tag: each statement beside its source in the corpus, with the mutant that shows it can fail and the witness where it holds. Its result is a tag, and nothing in it is a verdict on someone else's work. This protocol is for the release's challenges, which LibSpec doesn't own. A reviewer compares them with their paper's claim, and the verdict becomes evidence in the pilot's report. In both, whether a statement says what its source means rests on a person's reading. Lean checks STATEMENTS_REVIEW's mutants and witnesses, not that.

## Named reviewers

Only a review by someone on this list counts. Marley adds each reviewer, by GitHub login, with their consent.

| GitHub login | Added |
|---|---|
| `marleymcwilliams` | 2026-11-08 |

Reviews are published under the reviewer's GitHub identity: each is a GitHub issue the reviewer files (step 3), and the report names them. So taking part needs their consent, given before they're added here.

## What a review covers

One review covers **a manuscript's claim together with every challenge linked to it** in `pilot/data/catalogue.json` (the manuscript's `challenges`). The reviewer records which part of the claim each challenge states, and gives one verdict on the set.

**Why the set, not one challenge.** A paper's claim is often split across several challenges, or a challenge states a companion result beside the claim. Counted from `catalogue.json` at release commit `7ef5c0c`:
- **344** manuscripts (folders under `preprints/` that a docs page links) are linked to at least one challenge, and **185** of them to more than one.
- **92** families contain a manuscript linked to more than one challenge.
- **29** families have exactly one manuscript, and it is linked to more than one challenge. Counting instead the families where exactly one manuscript is linked to any challenge, and it to more than one, gives **36**.

Family 343 is an example: "Symplectic Ball Packings in Higher Dimensions" is linked to `BallPacking` and `BallPackingNecessity`. Judged one at a time, each would look like it states less than the paper, though together they may state all of it.

So a challenge that states only part of the claim, or a companion result, is never on its own "weaker or different". The verdict is on what the set states. A challenge linked to more than one manuscript, as `LocalSmoothing` is in family 079, is read in each manuscript's review, against that manuscript's claim.

## What to read

1. **The manuscript's top-line claim,** under `preprints/` at the pinned commit. The challenges have to state this claim, not only lemmas on the way to it, so it's the reference the rest is compared with.
2. **Every challenge linked to the manuscript,** `lean/ComparatorChallenges/<name>.lean` at the same commit. They're the statements Comparator checks a proof against, and so the statements whose meaning a review can vouch for.
3. **Every definition those challenges use that isn't Mathlib's,** wherever the release defines it. A challenge's own definitions can hide what it claims: a theorem that reads like the paper's can say something else through a definition it names. So the reviewer reads them, not just the theorems.

## What to check

- **Quantifiers:** what is bound, over which type, and in which order. Swapping a `∀` and an `∃`, or binding a constant before a variable it should depend on, changes the claim while leaving it looking the same.
- **Hypotheses:** each one a challenge assumes, against the paper's. An extra hypothesis can make the statement weaker than the claim, and one that can't hold makes it vacuous.
- **Edge cases:** zero, empty, degenerate and boundary inputs, and the paper's own exclusions. A statement can agree with the paper everywhere but at an edge the paper rules out or relies on.
  - **Lean's conventions,** where the paper's notation is undefined or ambiguous. Lean gives every expression a value, so the challenge means what these conventions make it mean, and the reviewer checks that this matches the paper:
    - `x / 0 = 0`, in ℕ, ℤ, ℚ and ℝ alike.
    - Subtraction on ℕ stops at 0: `3 - 5 = 0`.
    - Division on ℕ rounds down: `7 / 2 = 3`.
    - Where a coercion between ℕ, ℤ, ℚ and ℝ sits: `((a - b : ℕ) : ℤ)` subtracts in ℕ and then casts, while `(a : ℤ) - (b : ℤ)` casts first, and the two differ when `b > a`. Likewise `((a / b : ℕ) : ℝ)` rounds down before the cast.
- **Definitions that would make the statement trivial:** a definition that is always true, always false, empty or constant, so the theorem holds for a reason that has nothing to do with the paper. That's the way a challenge's own definitions hide what it claims.
- **What the set covers:** which part of the claim each challenge states, whether any part is stated by no challenge, and which challenges state companion results instead.

## What to record

- **The reviewer's GitHub login.** It must be on the list of named reviewers above.
- **The date.** The release keeps changing, so a review is dated, as every other result in the pilot is.
- **The manuscript and the commit:** the manuscript's folder under `preprints/`, and the release's commit the reviewer read, `7ef5c0c` for v1.1. A docs page doesn't say which of its challenges covers which of its papers, so the folder says which paper's claim the verdict is about. Families 342 and 376 link an earlier version of a listed manuscript, and the review is against the listed one. A verdict holds for the statements at that commit only.
- **Each challenge linked to the manuscript, with the part of the claim it states,** or "a companion result" if it states something beside the claim.
- **The non-Mathlib definitions read,** by name. That shows the third reading step was done, and lets a second reviewer see what the first one covered.
- **How long the review took.** Step 4 measures the cost of a review from it.
- **The verdict,** one of the three below, **with a sentence saying why.** The sentence goes into the report, so a reader can see what the reviewer saw without redoing the review.

## The three verdicts

Each verdict is on the set of challenges linked to the manuscript, taken together.

- **They state the claim.** Together, the challenges say what the paper's top-line claim says, no less; anything more they state is a companion result. This is the only verdict that can make `statement_fidelity` known to be 0, so it carries the most weight, and its sentence says what the reviewer checked.
- **They state a weaker or a different claim.** Together, the challenges prove something, but not the paper's claim: a part of the claim that no challenge states, or a challenge whose part differs from the paper's. A proof of them is no evidence for the paper's claim, so this verdict, uncontested, counts as evidence that fails. Its sentence names the difference: the missing part, or the quantifier, hypothesis, edge case or definition.
- **The reviewer can't tell.** The reviewer couldn't settle it, for example because the paper's claim is unclear or the definitions are too deep to follow. Its sentence says what stopped them, so a later review can start there. It confirms nothing, so it can't make the statement count as faithful.

What each verdict does to the raw record and the report is step 2's work: today `Raw.fidelityBy` holds only a reviewer's name, so a review can only show that a statement is faithful.

## When reviewers disagree

When two named reviewers give different verdicts on the same manuscript at the same commit, both reviews stay recorded, and `statement_fidelity` stays unknown, with both reviewers' sentences in the report, until they agree. Only an uncontested "weaker or different" counts as evidence that fails.

## A lighter first pass

A lighter first pass for deep results waits for step 4's times.

## Risks that bear on the protocol

From the roadmap's Phase 8 risks:
- **Deep results take long to review.** Each review records how long it took, and step 4 measures it before a lighter pass is considered.
- **A verdict is a human judgement.** Two reviewers can disagree, and the rule above keeps the axis unknown until they agree.
- **A challenge's own definitions can hide what it claims.** That's why the protocol makes the reviewer read them, and record which ones they read.
- **Names in public issues.** A review is filed under the reviewer's GitHub identity, which is public, so taking part needs their consent.
- **No manuscript is accepted after this phase alone.** `independent_review` and `novelty` stay unknown until a source supplies them (Phase 9). A faithful statement is necessary for acceptance, not enough.
