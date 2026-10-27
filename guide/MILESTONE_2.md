# Milestone 2 note

Milestone 2 proves the second block of `Statements.lean`: the Loader, the frontier charge,
the policy lattice and the must-fail gate from `statements-v1`, and the leases, typed
obligations, concrete Loader and residual threading that `statements-v2` added. The proofs
are in `lean/JSG/Proofs/Milestone2.lean`. Each one gets a five-line, plain-English
explanation here, added by the PR that proves it. The closing note, in your words, goes at
the end once the gate is met: what is now proved, and what it does not show.

## `Loader.safe`

*Not yet proved.*

## `Loader.terminates`

*Not yet proved.*

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

*Not yet proved.*

## `mfGate_signed`

*Not yet proved.*

## `lease_sound`

*Not yet proved.*

## `lease_complete`

Proved in #37.

1. `leaseVerdict θ β g` accepts exactly when every axis is within both its threshold and its lease: `(g i).hi ≤ θ i ∧ (g i).width ≤ β i` for every `i`.
2. Unfolding it leaves an if-then-else, and `split_ifs` splits on that condition.
3. In the accepting branch the goal holds at once (`rfl`).
4. In the other branch the condition is assumed false, but `hin i` and `hlease i` give both halves at every axis, so that branch can't happen.
5. So a reading within its threshold and its lease is accepted, even an interval wider than a point. That closes, for the lease gate, the gap Milestone 1's note named.

## `pass_sound`

*Not yet proved.*

## `pass_complete`

*Not yet proved.*

## `LoaderStep.inv_step`

*Not yet proved.*

## `LoaderStep.progress`

*Not yet proved.*

## `threads_spec`

*Not yet proved.*

## The concrete Loader

*Not yet built.*

## Closing note

*To come, in your words, when the gate is met.*
