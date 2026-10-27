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

*Not yet proved.*

## `expiry_tightens`

Proved by Marley (#34).

## `bridge`

*Not yet proved.*

## `mfGate_signed`

*Not yet proved.*

## `lease_sound`

*Not yet proved.*

## `lease_complete`

*Not yet proved.*

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
