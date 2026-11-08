# Statement review protocol

**Draft, for Marley's approval** ([ROADMAP.md](ROADMAP.md), Phase 8, step 1). It isn't in force until Marley approves it, and two of Marley's decisions are left open at the end. Text marked **Suggestion** isn't settled: it goes beyond what step 1 lists, and stays a suggestion until Marley takes it or drops it.

A named reviewer follows this protocol to check that a challenge in the openai/math release states its paper's claim. Each review gives a verdict, and the verdicts are what can make the pilot's `statement_fidelity` axis known ([EXECUTABLE_GATE.md](EXECUTABLE_GATE.md), §3).

**Why it's needed.** Comparator checks a proof against its challenge's statement, but not that the statement says what the paper claims. The release's `lean/formalization.yaml` records its review as `unchecked`. So today `statement_fidelity` is unknown for every manuscript, and no manuscript can be accepted.

**How it differs from [STATEMENTS_REVIEW.md](STATEMENTS_REVIEW.md).** That file supports Marley's review of LibSpec's own frozen statements, before each `statements-v*` tag: each statement beside its source in the corpus, with the mutant that shows it can fail and the witness where it holds. Its result is a tag, and nothing in it is a verdict on someone else's work. This protocol is for the release's challenges, which LibSpec doesn't own. A reviewer compares each one with its paper's claim, and the verdict becomes evidence in the pilot's report. Neither protocol is a check Lean runs: both rest on a person's reading.

## What to read

1. **The paper's top-line claim,** in the manuscript under `preprints/` at the pinned commit. The challenge has to state this claim, not a lemma on the way to it, so it's the reference the rest is compared with.
2. **The challenge file,** `lean/ComparatorChallenges/<name>.lean` at the same commit. It's the statement Comparator checks a proof against, and so the one statement whose meaning a review can vouch for.
3. **Every definition the challenge uses that isn't Mathlib's,** wherever the release defines it. A challenge's own definitions can hide what it claims: a theorem that reads like the paper's can say something else through a definition it names. So the reviewer reads them, not just the theorem.

## What to check

- **Quantifiers:** what is bound, over which type, and in which order. Swapping a `∀` and an `∃`, or binding a constant before a variable it should depend on, changes the claim while leaving it looking the same.
- **Hypotheses:** each one the challenge assumes, against the paper's. An extra hypothesis can make the statement weaker than the claim, and one that can't hold makes it vacuous.
- **Edge cases:** zero, empty, degenerate and boundary inputs, and the paper's own exclusions. A statement can agree with the paper everywhere but at an edge the paper rules out or relies on.
- **Definitions that would make the statement trivial:** a definition that is always true, always false, empty or constant, so the theorem holds for a reason that has nothing to do with the paper. That's the way a challenge's own definitions hide what it claims.

## What to record

- **The reviewer's name.** `statement_fidelity` becomes known only once a named reviewer confirms the statement, so an unnamed review can't count.
- **The date.** The release keeps changing, so a review is dated, as every other result in the pilot is.
- **The challenge and the commit:** the challenge's name and the release's commit the reviewer read, `7ef5c0c` for v1.1. A verdict holds for the statement at that commit only.
- **The verdict,** one of the three below, **with a sentence saying why.** The sentence goes into the report, so a reader can see what the reviewer saw without redoing the review.

## The three verdicts

- **It states the claim.** The challenge says what the paper's top-line claim says, no more and no less. This is the only verdict that makes `statement_fidelity` known to be 0, so it carries the most weight, and its sentence says what the reviewer checked.
- **It states a weaker or a different claim.** The challenge proves something, but not the paper's claim. A proof of it is no evidence for the paper's claim, so this verdict must count as evidence that fails. Its sentence names the difference: the quantifier, hypothesis, edge case or definition.
- **The reviewer can't tell.** The reviewer couldn't settle it, for example because the paper's claim is unclear or the definitions are too deep to follow. Its sentence says what stopped them, so a later review can start there. It confirms nothing, so it can't make the statement count as faithful.

What each verdict does to the raw record and the report is step 2's work: today `Raw.fidelityBy` holds only a reviewer's name, so a review can only show that a statement is faithful.

## Risks that bear on the protocol

From the roadmap's Phase 8 risks:
- **Deep results take long to review.** The pilot in step 4 measures how long, and the protocol may need a lighter first pass.
- **A verdict is a human judgement.** Two reviewers can disagree, and that needs a rule: open question 1.
- **A challenge's own definitions can hide what it claims.** That's why the protocol makes the reviewer read them, not just the theorem.
- **Names in public issues.** A review filed as a GitHub issue carries the reviewer's GitHub identity, which is public, so taking part needs their consent: open question 2.
- **No manuscript is accepted after this phase alone.** `independent_review` and `novelty` stay unknown until a source supplies them (Phase 9). A faithful statement is necessary for acceptance, not enough.

## Suggestions, not settled

- **Suggestion: record how long the review took.** Step 4 has to record it for six challenges, and the time is what tells whether the protocol needs a lighter first pass.
- **Suggestion: record which manuscript the claim was read from.** A docs page doesn't say which of its challenges covers which of its papers, so each paper a page links gets all its challenges. Naming the manuscript's folder says which paper's claim the verdict is about. Families 342 and 376 link an earlier version of a listed manuscript, and the review is against the listed one.
- **Suggestion: list the definitions read.** Naming each non-Mathlib definition the reviewer read shows the third reading step was done, and lets a second reviewer see what the first one covered.
- **Suggestion: a lighter first pass,** if step 4 shows deep results take too long: a first pass that checks only the theorem's shape and its definitions for triviality, and gives only "weaker or different" or "can't tell". Only a full review could give "states the claim".

## Open questions: Marley's to decide

These stay Marley's ([ROADMAP.md](ROADMAP.md), Phase 8, "Decisions that stay yours"). This draft doesn't decide them.

### 1. Who counts as a named reviewer, and how a disagreement between reviewers is settled

**Who counts.** The options:
- **Marley alone.** Simple, and every review has one standard, but every review costs Marley's time, and the reviewer is never independent of the project.
- **Anyone Marley names,** on a list kept in the guide. Marley controls who can make `statement_fidelity` known, and the list shows who could. Each name needs Marley's judgement of the person's competence for the field.
- **Anyone who files a review under the protocol,** with Marley accepting or declining each one. It's open to more reviewers, but a stranger's verdict then counts only through Marley's acceptance, which makes the acceptance the real check.

**Settling a disagreement.** The options:
- **The more cautious verdict stands:** any "weaker or different" or "can't tell" keeps the statement from counting as faithful. It never accepts a statement someone doubts, but one wrong objection blocks a faithful statement until it's withdrawn.
- **Marley decides,** and the reason is recorded beside both reviews. One person resolves each case, and that person isn't independent of the project.
- **A third reviewer breaks the tie.** Each case costs another review, and a 2–1 split still counts as faithful over a recorded objection.
- **Both reviews stay recorded, and the axis stays unknown until they agree.** It's the most honest about the doubt, and it can leave a statement unknown for good.

### 2. Whether reviewers' names are published

The options:
- **Published, with the reviewer's GitHub identity.** A review filed as a GitHub issue shows who filed it, with its timestamps and edit history, which is the record step 3's issue forms were chosen for, so a changed review shows. Taking part then needs each reviewer's consent to being named in public.
- **Published under a name the reviewer chooses,** not necessarily their GitHub identity: a reviewer who doesn't want their account shown would need someone else to file the issue for them. The report stays checkable by name, but the issue's author is no longer the reviewer, so the history proves less about who reviewed.
- **Not published:** the report says "a named reviewer", and Marley keeps the names. It suits reviewers who won't be named, but no reader can check who vouched for a statement, and it doesn't fit public issues filed by the reviewers themselves.
