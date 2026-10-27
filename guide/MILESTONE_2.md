# Milestone 2 note

Milestone 2 proves the second block of `Statements.lean`: the Loader, the frontier charge,
the policy lattice and the must-fail gate from `statements-v1`, and the leases, typed
obligations, concrete Loader and residual threading that `statements-v2` added. The proofs
are in `lean/JSG/Proofs/Milestone2.lean`. Each one gets a five-line, plain-English
explanation here, added by the PR that proves it. The closing note, in your words, goes at
the end once the gate is met: what is now proved, and what it does not show.

## `Loader.safe`

Proved in #39.

1. `Relation.ReflTransGen L.step s t` says t is reached from s in zero or more steps.
2. Induction on that path gives two cases: no steps at all, or a shorter path followed by one more step.
3. With no steps, t is s, and `hs` is the goal.
4. Otherwise the induction hypothesis says the state before the last step satisfies `Inv`, and the Loader's own field `inv_step` carries it across that step.
5. So the invariant holds along any run. For a concrete Loader the work is in its `inv_step`, which is what `LoaderStep.inv_step` proves.

## `Loader.terminates`

Proved in #41.

1. "No infinite run" means the step relation, read backwards, is well-founded: there's no endless chain of steps.
2. Mathlib proves the Dershowitz–Manna order on finite multisets is well-founded whenever the order on their elements is (`Multiset.wellFounded_isDershowitzMannaLT`).
3. `InvImage.wf` pulls that back along `L.pending`, so comparing states by what each has pending is well-founded too.
4. The Loader's field `progress` says every step lowers what is pending in that order, so each step is one of those comparisons (`Subrelation.wf`).
5. So no Loader runs forever when its obligations' order is well-founded. For the concrete Loader, `progress` is `LoaderStep.progress`.

## `charge_append`

Proved in #35.

1. `charge A jumps` is A times the sum of the jumps' sizes, each read in [0, ∞].
2. Unfolding it, the left side is A times the sum of the sizes over `j₁ ++ j₂`.
3. `List.map_append` takes the sizes of each part separately, and `List.sum_append` splits the sum into the sum over `j₁` plus the sum over `j₂`.
4. `mul_add` distributes A over that sum, which is exactly the right side.
5. So however the jumps are split into segments, the total charge is the same: regrouping can't hide a jump.

## `charge_chatter`

Proved in #36.

1. `charge A [v, -v]` is A times the sum of the two jumps' sizes, ‖v‖ and ‖−v‖.
2. `simp only` unfolds `charge` and works out the map and the sum over the two-element list.
3. `nnnorm_neg` says a jump and its reverse have the same size: ‖−v‖ = ‖v‖.
4. That leaves A · (‖v‖ + ‖v‖), and `ring` rearranges it to 2 · A · ‖v‖.
5. So crossing a frontier and coming straight back costs twice one crossing, never nothing. SCp2's max-fold, which charges it once, fails this.

## `expiry_tightens`

Proved by Marley (#34).

## `bridge`

Proved in #42.

1. An input is accepted under a dial when every axis's upper bound is within the threshold the dial gives: `(gradeOf x i).hi ≤ (dial i)⁻¹`.
2. Take an input accepted under the stricter dial₂. Unfolding both verdicts, `split_ifs` turns that acceptance into the condition for dial₂.
3. `h` says dial₁ ≤ dial₂ on every axis, and inverting flips the order, so (dial₂ i)⁻¹ ≤ (dial₁ i)⁻¹ (`ENNReal.inv_le_inv`).
4. Chaining the two, every upper bound is within dial₁'s threshold too, so the input is accepted under dial₁, and the other branch can't happen.
5. So a stricter dial never admits more inputs. A dial stored un-inverted gets this backwards, as the `id` mutant shows.

## `mfGate_signed`

Proved in #44.

1. Induction on t, starting from s (`Nat.le_induction`). When t = s, `hs` and `ht` contradict each other, so there's nothing to show.
2. For the step from t to t + 1, ask whether the class was still in `MF t`.
3. If it was, it left at step t. The gate's rule at t is either "nothing removed", which this contradicts, or "the removal is signed", which is what we need.
4. If it wasn't, it had already left, and the induction hypothesis gives a step u before t, so before t + 1 too.
5. So under the gate, a failure class can't leave the must-fail set unsigned, however many steps pass. A gate that accepts every change lets GOLDEN_RULE_BREACH go.

## `lease_sound`

Proved in #38.

1. As in `lease_complete`, `leaseVerdict` accepts exactly when every axis is within its threshold and its lease, and `split_ifs` splits on that condition.
2. If the condition held, it would hold at our axis `i`: `(g i).hi ≤ θ i` and `(g i).width ≤ β i`.
3. `hout` says one of those fails at `i`: either θ i < hi, or β i < width.
4. Either way that contradicts the condition (`not_le`), so only the rejecting branch is left, and its value is `.reject`.
5. So one axis over its threshold, or wider than its lease, rejects the whole grade. A gate that checks only one of the two, like `qPrimeGate` or `widthsOnly`, fails this.

## `lease_complete`

Proved in #37.

1. `leaseVerdict θ β g` accepts exactly when every axis is within both its threshold and its lease: `(g i).hi ≤ θ i ∧ (g i).width ≤ β i` for every `i`.
2. Unfolding it leaves an if-then-else, and `split_ifs` splits on that condition.
3. In the accepting branch the goal holds at once (`rfl`).
4. In the other branch the condition is assumed false, but `hin i` and `hlease i` give both halves at every axis, so that branch can't happen.
5. So a reading within its threshold and its lease is accepted, even an interval wider than a point. That closes, for the lease gate, the gap Milestone 1's note named.

## `pass_sound`

Proved in #47.

1. In a passing run nothing is left at the end, and an item leaves what is pending only when a stage clears it (`afterStage` is a filter).
2. So take an item pending before stage r, or emitted by it. If r clears it, we're done.
3. Otherwise it's still pending after r, and since the run ends with nothing pending, a later stage must clear it.
4. An induction on the rest of the run finds that stage: at each stage the item is either cleared, or it survives into what the next stage sees.
5. So in a passing window, every ticket was cleared by its own stage, and every obligation by its authority with a witness of its type. JSG V's displayed transition, which clears by witness alone, fails this.

## `pass_complete`

Proved in #40.

1. `Passes` asks two things: the window's grade is within its thresholds and leases, and nothing is pending after the run.
2. The first is `hgrade`, as given.
3. For the second, the run is `pre` followed by `r`, so what is pending at the end is one more `afterStage`, applied to what `pre` left plus what `r` emits.
4. `afterStage` keeps only the items `r` doesn't clear, and `hlast` says `r` clears every one of them, so nothing is kept (`Multiset.filter_eq_nil`).
5. So a window passes when its last stage clears what's left. With `pass_sound`, that is exactly what passing means, and a transition that never clears anything fails this.

## `LoaderStep.inv_step`

Proved in #43.

1. A Loader step has one rule, `stage`, so `cases` exposes its premises: the adapter's pricing, the declared axes, the round-off, the budget and the ticket.
2. The step never changes the boot record, so L1–L5 and L7, which read only that record, carry over unchanged.
3. L8 and L9 are re-established by the premises `hround` and `hbudget`. L10 holds because the step records the new bundle's root itself (`rfl`).
4. L6 needs one more look: an axis written before was already declared, and an axis this stage writes is one its adapter declared (`hiso`).
5. So every step keeps all ten checks. SCp3's T-Row, which skips I6 and I8, fails this, and so does SirusSC's axis-leak check.

## `LoaderStep.progress`

Proved in #46.

1. In the Dershowitz–Manna order, one multiset is below another when it removes something and every item it adds ranks below something removed.
2. After the step, what is pending is what was pending plus what the stage emits, minus everything the stage clears (`afterStage`).
3. Split it that way: the items kept, the emitted items that stay, and the cleared items, which are what's removed.
4. The cleared items include the stage's own ticket, which `hticket` says was pending, so something is removed.
5. Every emitted item is an obligation, and every obligation ranks below every ticket (`WithTop.coe_lt_top`), so each ranks below the ticket the stage cleared.

## `threads_spec`

Proved in #45.

1. Induction on the stages, generalizing the budget, since each stage hands the next what it left.
2. With no stages, threading holds trivially and the total is 0, which fits any θ.
3. For a first stage x and the rest, threading says x ≤ θ and that the rest thread through θ − x. By induction that's "the rest's total ≤ θ − x", since θ − x is finite, being at most θ.
4. Then x ≤ θ and "total ≤ θ − x" together say x + total ≤ θ (`add_tsub_cancel_of_le`). The converse follows from `ENNReal.le_sub_iff_add_le_left`, as in `residual_spec`.
5. So for a finite θ, threading is exactly "the total fits", for any number of stages. An overspent stage fails its own check instead of leaving a 0 that the rest pass.

## The concrete Loader

*Not yet built.*

## Closing note

*To come, in your words, when the gate is met.*
