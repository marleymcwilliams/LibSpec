# Decision queue

Questions only you can answer: anything that changes a statement's meaning, a Norm-layer value or anything frozen, and anything that would make a check weaker. Each entry gives the question, a recommended answer, what breaks if the answer is wrong, and whether it can be undone. At most three entries are open at once, and work never waits on one. "Not yet" is a valid answer.

## Open

None.

## Answered

### Q4. `verdict_unknown` covers only grades that are exactly unknown

**Answered 2026-10-26: yes.** Replace it with `verdict_sound`, which is strictly stronger.

- **Question:** `verdict_unknown` covered only `g i = Bound.unknown`. So [5, ∞], which is what an unknown becomes after combining, and every finite value over its threshold were outside the frozen statements. A gate that rejects only unknowns satisfied all four verdict theorems. Should it be replaced by a statement that any axis over its threshold rejects the whole grade?
- **Recommended answer:** Yes. State it as:

  ```lean
  theorem verdict_sound (θ : ι → ENNReal) (g : Grade ι) (i : ι)
      (hover : θ i < (g i).hi) : verdict θ g = .reject
  ```

  - It implies `verdict_unknown`: an unknown's upper bound is ⊤, so any finite threshold is below it.
  - It also covers [5, ∞] and every finite value over its threshold, so the unknown-only gate fails it: that gate accepts [2, 2] under θ = 1.
  - Checked in a scratch file, not committed: the statement type-checks against the real `Defs` and is provable from them, and both mutants are proved to fail it.
- **What breaks if wrong:** Little. Everything `verdict_unknown` guaranteed still holds, since `verdict_sound` implies it. If a later design must accept a grade whose upper bound is over its threshold, `verdict_sound` has to be weakened, and after the tag that takes a new statements version, a CHANGELOG line and a signed decision. Keeping `verdict_unknown` instead leaves [5, ∞] and every finite overrun outside the frozen statements.
- **Can it be undone:** Yes, freely until `statements-v1` is tagged. After that, only with a new statements version and a CHANGELOG line.

### Q2. `bridge` can't fail on its named mutant

**Answered 2026-10-20: yes.** Restate `bridge` over the fixed dial-to-threshold map that stores the inverse.

- **Question:** `bridge` takes thresholds directly, so its named mutant, a threshold dial stored un-inverted, has nothing to plug into and can't fail it. Today's `bridge_mutant` refutes a copy with the hypothesis reversed instead. The guide's core object 4 says "the bridge theorem catches the mistake". Should `bridge` be restated over a dial-to-threshold map, or kept, given a mutant it does catch, and the guide's sentence fixed?
- **Recommended answer:** Restate it. Add a fixed map to `Defs.lean` that stores the inverse, `noncomputable def threshold (dial : ι → ENNReal) : ι → ENNReal := fun i => (dial i)⁻¹`, and state the bridge over dials, larger meaning stricter: `dial₁ ≤ dial₂ → {x | verdict (threshold dial₂) (gradeOf x) = .accept} ⊆ {x | verdict (threshold dial₁) (gradeOf x) = .accept}`.
  - The un-inverted dial (`id` in place of `threshold`) then fails it: with dial₁ = 0 and dial₂ = 1, a grade of 1 is accepted under the stricter dial and rejected under the looser one.
  - ENNReal's inverse fits the dial: 0⁻¹ = ⊤, so dial 0 means no limit, and ⊤⁻¹ = 0.
  - This makes the guide's sentence true rather than deleting it. Today's statement becomes a lemma for the proof.
  - Checked in a scratch file, not committed: the restated statement type-checks against the real `Defs`, and the `id` mutant is proved to fail it.

  The alternative is to keep the statement and name a mutant it catches, such as a verdict that compares the wrong way (accepting when hi ≥ θ), then change the guide so it no longer says the bridge checks the dial encoding.
- **What breaks if wrong:** If restating is wrong, for example because real dials aren't stored per axis in ENNReal, `threshold` has to change, and after the freeze that's a statements change. If keeping is wrong, the bridge stays a fact about `verdict` alone, nothing checks the dial encoding, and the guide claims a check that doesn't exist.
- **Can it be undone:** Yes, freely until `statements-v1` is tagged. After that, only with a new statements version and a CHANGELOG line.

### Q3. `mfGate_monotone` covers only histories with no signed removal

**Answered 2026-10-20: yes,** the general form. Whether `mfGate_monotone` stays as a corollary was left to Claude Code; it was dropped (LOG.md).

- **Question:** `mfGate_monotone` assumes `hs : ∀ s, signed s → s = ∅`, so it says nothing once any removal is signed, which is exactly when the gate matters. Should it be replaced by the general form, which follows from `hg` alone: every class that leaves MF leaves in a signed step?
- **Recommended answer:** Yes. State it as:

  ```lean
  theorem mfGate_signed {C : Type} (signed : Set C → Prop) (MF : ℕ → Set C)
      (hg : ∀ t, mfGate signed (MF t) (MF (t + 1))) {s t : ℕ} (hst : s ≤ t) {c : C}
      (hs : c ∈ MF s) (ht : c ∉ MF t) :
      ∃ u, s ≤ u ∧ u < t ∧ c ∈ MF u \ MF (u + 1) ∧ signed (MF u \ MF (u + 1))
  ```

  - This is the layer map's claim, "accepted histories keep every unsigned failure class".
  - `mfGate_monotone` follows as a corollary, so it can stay or go.
  - Either form gets a real mutant from a gate that accepts every change, run on the drafts' history: GOLDEN_RULE_BREACH then leaves in an unsigned step. Today's mutant shows only that the real gate rejects that history, which refutes neither form.
  - Checked in a scratch file, not committed: the statement type-checks, and the loose-gate mutant is proved to fail it.
- **What breaks if wrong:** If the general form is wrong, for instance because a signed removal should also have to expire, the statement records only that the step was signed and would need another change. If you keep today's form, the theorem is silent about every history with a signed removal, and the layer map's claim stays unproved.
- **Can it be undone:** Yes, freely until `statements-v1` is tagged. After that, only with a new statements version and a CHANGELOG line.

### Q1. State interchange over two named operators

**Answered 2026-10-13: yes.** Use the two-operator form in the stubs.

- **Question:** Should the statements define interchange as a Prop over two named operators, `Interchange seq par`, with `seqComp` and `parComp` both defined as `combine`, and state `interchange` as `Interchange seqComp parComp`?
- **Recommended answer:** Yes. With one operator, the law follows from `combine_comm` and `combine_assoc`, so it can't fail for any commutative, associative `combine` and catches nothing. With two named operators, JSG V's rule becomes a mutant that can be stated: max on every axis in sequence, `combine` in parallel. On a budget axis with x = 1, x′ = 0, y = 0, y′ = 1, it grades 2 one way and 1 the other.
- **What breaks if wrong:** If yes is the wrong call, the cost is small: two extra definitions in `Defs.lean` that must stay equal to `combine`, and a longer statement to review. If you answer no, `interchange` stays vacuous, and it can't meet the roadmap's rule that every theorem names a mutant that fails it.
- **Can it be undone:** Yes, freely until `statements-v1` is tagged. After that, only with a new statements version and a CHANGELOG line.
