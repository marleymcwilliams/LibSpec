import JSG.Defs

/-!
Milestone 2 proofs: obligations and leases, the Loader, the frontier charge, the policy
lattice and the must-fail gate. Each theorem restates its frozen statement in
`JSG.Statements` under the same name, and CI's Comparator run checks that it proves
exactly that statement.
-/

namespace JSG

variable {ι : Type} (kind : ι → Kind)
variable {E : Type} [NormedAddCommGroup E]
variable {P : Type} [CompleteLattice P]   -- larger = stricter
variable {St O W : Type}
variable {Bytes D : Type}

theorem expiry_tightens (B : P) {a a' : Set P} (h : a' ⊆ a) :
    effective B a ≤ effective B a' := by
  unfold effective
  gcongr

end JSG
