import JSG.Solution
import JSG.Tests.Smoke

/-!
Axiom audit, run by `scripts/check.sh`.
List every closed theorem here; the script fails if any of them depends on an
axiom other than `propext`, `Classical.choice` or `Quot.sound` (including `sorryAx`).
Statements still proved by `sorry` stay off this list until their milestone.
It imports the proofs (`JSG.Solution`) rather than `JSG`: each proof restates its
theorem under the frozen name, so the proofs and `JSG.Statements` can't be imported
together.
-/

#print axioms JSG.Tests.smoke
#print axioms JSG.combine_comm
