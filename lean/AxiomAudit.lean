import JSG

/-!
Axiom audit, run by `scripts/check.sh`.
List every closed theorem here; the script fails if any of them depends on an
axiom other than `propext`, `Classical.choice` or `Quot.sound` (including `sorryAx`).
Statements still proved by `sorry` stay off this list until their milestone.
-/

#print axioms JSG.Tests.smoke
