import JSG.Harness.Mutants

/-!
The differential tests' negative controls (guide/EXECUTABLE_GATE.md §2). Each executable
mutant in `JSG.Harness.Mutants` disagrees with the oracle on at least one of the corpus's
exhaustive vectors for its operation. Those vectors weren't chosen with the mutants in mind;
the corpus's first part, from the controls, catches every mutant by construction.

The kernel checks each theorem by evaluating the vectors in order until one disagrees,
with `decide +kernel`, which isn't native evaluation. If a mutant ever agreed with the
oracle on all of them, its theorem would fail, and so would the build: the corpus would be
too weak to catch it.
-/

namespace JSG.Tests.Differential

open JSG.Harness

theorem overwrite_caught : exCombine.any (disagrees overwrite) = true := by decide +kernel

theorem avgCombine_caught : exCombine.any (disagrees avgCombine) = true := by decide +kernel

theorem jsgVSeq_caught : exCombine.any (disagrees jsgVSeq) = true := by decide +kernel

theorem scp2Seq_caught : exCombine.any (disagrees scp2Seq) = true := by decide +kernel

theorem absorbCombine_caught : exCombine.any (disagrees absorbCombine) = true := by decide +kernel

theorem verdictLo_caught : exVerdict.any (disagrees verdictLo) = true := by decide +kernel

theorem unknownOnly_caught : exVerdict.any (disagrees unknownOnly) = true := by decide +kernel

theorem alwaysReject_caught : exVerdict.any (disagrees alwaysReject) = true := by decide +kernel

theorem leqSkipsUnknown_caught : exVerdict.any (disagrees leqSkipsUnknown) = true := by
  decide +kernel

theorem residualFull_caught : exResidual.any (disagrees residualFull) = true := by decide +kernel

theorem residualOnly_caught : exThreads.any (disagrees residualOnly) = true := by decide +kernel

theorem qPrimeGate_caught : exLease.any (disagrees qPrimeGate) = true := by decide +kernel

theorem widthsOnly_caught : exLease.any (disagrees widthsOnly) = true := by decide +kernel

theorem pointsOnly_caught : exLease.any (disagrees pointsOnly) = true := by decide +kernel

theorem floatWidth_caught : exWidth.any (disagrees floatWidth) = true := by decide +kernel

theorem upperOnly_caught : exKnown.any (disagrees upperOnly) = true := by decide +kernel

theorem bottomUnknown_caught : exKnown.any (disagrees bottomUnknown) = true := by decide +kernel

/-- SirusSC's model disagrees with the oracle too, so the first differential run against
    SirusSC has disagreements to find. -/
theorem sirusModel_caught :
    (exCombine ++ exVerdict ++ exLease).any (disagrees sirusModel) = true := by
  decide +kernel

end JSG.Tests.Differential
