# SIRUS\_SPEC\_MASTER.md — Table of Contents (normative)
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:TOC_STAGECARD_v1",
  "Admits": [
    {"anchor":"#howto","content_b3":"b3:HOWTO_ANCHOR"},
    {"anchor":"#normative-foundations","content_b3":"b3:NORM_FOUND"},
    {"anchor":"#architecture","content_b3":"b3:ARCH"},
    {"anchor":"#hybrid","content_b3":"b3:HYBRID"},
    {"anchor":"#evidence","content_b3":"b3:EVIDENCE"},
    {"anchor":"#frontier-debit","content_b3":"b3:DELTA_FR"},
    {"anchor":"#gmm","content_b3":"b3:GMM"},
    {"anchor":"#self-similarity","content_b3":"b3:SSG"},
    {"anchor":"#self-spec","content_b3":"b3:SELF_SPEC"},
    {"anchor":"#governance","content_b3":"b3:GOV"},
    {"anchor":"#verification","content_b3":"b3:VERIFY"},
    {"anchor":"#runbooks","content_b3":"b3:RUNBOOKS"},
    {"anchor":"#implementation","content_b3":"b3:IMPL"},
    {"anchor":"#glossary","content_b3":"b3:GLOSS"},
    {"anchor":"#predicate-registry","content_b3":"b3:PRED_REG"},
    {"anchor":"#axis-catalog","content_b3":"b3:AXIS_CAT"},
    {"anchor":"#examples","content_b3":"b3:EXAMPLES"},
    {"anchor":"#templates","content_b3":"b3:TEMPLATES"},
    {"anchor":"#evidence-kg","content_b3":"b3:EVID_KG"},
    {"anchor":"#negatives","content_b3":"b3:NEGATIVES"},
    {"anchor":"#bench-suites","content_b3":"b3:BENCH"},
    {"anchor":"#blt-profile","content_b3":"b3:BLT"},
    {"anchor":"#security","content_b3":"b3:SEC"},
    {"anchor":"#faqs","content_b3":"b3:FAQ"},
    {"anchor":"#conformance","content_b3":"b3:CONF"}
  ],
  "Emits": [
    {"anchor":"#toc-canon","content_b3":"b3:TOC_CANON"},
    {"anchor":"#receipt-canon","content_b3":"b3:RECEIPT_CANON"},
    {"anchor":"#civ-canon","content_b3":"b3:CIV_CANON"}
  ],
  "Guards": [
    {"family":"anchor_exists","ver":"v1","anchor":"#toc-canon","content_b3":"b3:TOC_G_ANCHOR"},
    {"family":"unique_ids","ver":"v1","anchor":"#toc-canon","content_b3":"b3:TOC_G_UNIQUE"},
    {"family":"numbering_monotone","ver":"v1","anchor":"#toc-canon","content_b3":"b3:TOC_G_ORDER"}
  ],
  "FailFast": [
    "toc_anchor_missing",
    "toc_duplicate_anchor",
    "toc_misnumbered",
    "toc_forbidden_prose"
  ],
  "Links": [
    {"anchor":"#receipt-canon","content_b3":"b3:RECEIPT_CANON"},
    {"anchor":"#civ-canon","content_b3":"b3:CIV_CANON"}
  ]
}
```
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules**

1. The Table of Contents (ToC) MUST enumerate only canonical homes; all cross-references are SSOT pointers (no prose restates).
2. Item IDs MUST be unique, stable, and strictly monotone by section number (`0,1,…,12` then `A…L`); violations hard-fail with the enumerated `reason_code`.
3. ToC MUST NOT introduce non-canonical prose or redefine scope; appended descriptions in parentheses MUST be strictly informational and may be removed by CI (`toc_forbidden_prose`).

---
## Mainline

0. [How to Read This Document](#howto)
1. [Normative Foundations](#normative-foundations)
2. [Sirus Architecture Overview](#architecture)
3. [Unified Dynamics: Hybrid Automaton](#hybrid)
4. [Evidence, Guards, and Receipts](#evidence)
5. [Frontier Debit (Δ\_fr)](#frontier-debit)
6. [Generative / Inversion Layer (GMM)](#gmm)
7. [Self-Similarity Modeling (SSG)](#self-similarity)
8. [Self-Specification](#self-spec)
9. [Governance (Identity, Roles, UpdateCert, Budgets)](#governance)
10. [Verification & Benchmarks](#verification)
11. [Runbooks (BLT/HPC, Troubleshooting, Templates)](#runbooks)
12. [Implementation Guide (EnvLock, Seeds, Reproducibility)](#implementation)
## Appendices

A. [Glossary](#glossary)
B. [Predicate Registry (IDs, Schemas)](#predicate-registry)
C. [Axis Catalog](#axis-catalog)
D. [Canonical Examples](#examples)
E. [Templates](#templates)
F. [Evidence Knowledge Graph](#evidence-kg)
G. [Negative Controls (must-fail)](#negatives)
H. [Benchmark Suites](#bench-suites)
I. [BLT Profile](#blt-profile)
J. [Security Posture](#security)
K. [FAQs](#faqs)
L. [Conformance Checklist](#conformance)

---

**Example (valid)**

```jsonc
{
  "schema_id": "ExampleReceipt/v1",
  "schema_b3": "b3:EXAMPLE_RECEIPT_v1",
  "input_digest": "b3:TOC_INPUTS",
  "output_digest": "b3:TOC_CANON",
  "meta": {"note":"toc anchors validated"}
}
```

**Example (must-fail)** — `reason_code: toc_misnumbered`

```jsonc
{
  "case": "section numbers skip from 2 to 4",
  "why": "Triggers toc_misnumbered by violating Rule 2 (monotone numbering)"
}
```
## 00 — Executive Overview & Core Philosophy *(non-normative preface; sits before §0–§12)* {#sec-00}

**What is SIRUS?**
SIRUS is a guard-first, evidence-centric specification for agentic systems that run through a fixed, replayable pipeline—ingesting inputs, discovering structure, evaluating guarded kernels, enforcing budgets, and closing with a content-addressed proof surface—so that every decision is *deterministically* reproducible and *verifiably* bound to immutable evidence (never prose restates).

> **PILLARS (paste-once):** Receipts use **ReceiptEnvelope/v1** with `checker_hash ∈ EnvLock`; all guards evaluate against a content-addressed **CIV** produced *before* any kernel executes. SSOT pointers: `{ "anchor":"#receipt-canon","content_b3":"b3:…" }`, `{ "anchor":"#envlock","content_b3":"b3:…" }`, `{ "anchor":"#civ-canon","content_b3":"b3:…" }`.
### Fixed Pipeline (visual, non-normative)

```
EF ──► DRO ──► PR ──► CBF ──► Ω
│      │       │       │       └─► proof_surface (canonical digest)
│      │       │       └──────────► ledger (append-only)
│      │       └──────────────────► kernels/guards (receipts)
│      └──────────────────────────► definitions/frontiers
└─────────────────────────────────► evidence foundation (attest)
```

The **canonical** description of this pipeline is at:
`{ "anchor":"#pipeline", "content_b3":"b3:…" }` (see §2.1: *EF → DRO → PR → CBF → Ω*).
### Core Philosophy

* **Guard-First.** Every transition is admitted or rejected by explicit guards that operate on canon inputs and policy digests—never on ambient state. See `{ "anchor":"#evidence", "content_b3":"b3:…" }`.
* **Deterministic Replay.** End-to-end runs are reproducible under **EnvLock** (seeds, versions, salts) with resume-safe heads and stable hashes; replay mismatches fail fast. See `{ "anchor":"#implementation", "content_b3":"b3:…" }`.
* **Policy-as-Code.** Thresholds, adapters, and invariants are declared as versioned artifacts (schemas + digests) and validated via receipts, not prose. See `{ "anchor":"#predicate-registry", "content_b3":"b3:…" }`.
* **Immutable Evidence.** State (Transport Pack) is strictly separated from the Evidence Bundle; Ω emits a **proof_surface** digest for audit. See `{ "anchor":"#commit-path", "content_b3":"b3:…" }` and `{ "anchor":"#state-and-evidence", "content_b3":"b3:…" }`.
* **SSOT Discipline.** Concepts appear only at their canonical homes; this preface links by anchor + `content_b3` and adds no new normative definitions.

**SSOT pointers used in this section (no restates):**

```jsonc
[
  { "anchor":"#pipeline", "content_b3":"b3:…" },
  { "anchor":"#receipt-canon", "content_b3":"b3:…" },
  { "anchor":"#civ-canon", "content_b3":"b3:…" },
  { "anchor":"#envlock", "content_b3":"b3:…" },
  { "anchor":"#evidence", "content_b3":"b3:…" },
  { "anchor":"#predicate-registry", "content_b3":"b3:…" },
  { "anchor":"#commit-path", "content_b3":"b3:…" },
  { "anchor":"#state-and-evidence", "content_b3":"b3:…" },
  { "anchor":"#implementation", "content_b3":"b3:…" }
]
```

---

<!-- §0 — Preamble & SSOT discipline -->
# 0. SIRUS\_SPEC\_MASTER — Preamble / Outline
## 0.0 <a id="howto"></a>How to Read this Spec (Learn → Do → Verify)
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Spec source tree", "Appendix registries", "CI gate configuration"],
  "Emits": ["Authoring discipline rules", "Paste-once PILLARS macro usage", "SSOT pointer placement"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"}
  ],
  "FailFast": ["duplicate_definition_outside_home", "pillars_missing_on_first_mention"],
  "Links": [
    {"anchor":"#ssot-dedup-impl","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules**

1. **Normative mainline only (MUST).** Conformance rules live in numbered sections; examples are delegated to Appendix D via SSOT pointers.
2. **SSOT discipline (MUST).** Each core concept has one canonical home/anchor; all other sections **link** using SSOT pointers (no prose restates).
3. **PILLARS paste-once (MUST).** On the first mention of *Receipts* or *CIV* inside any subsection, paste the one-liner macro exactly once; duplications **MUST** fail with `pillars_missing_on_first_mention`.

**Example (valid)**

```jsonc
{
  "schema_id": "ExampleReceipt/v1",
  "schema_b3": "b3:…",
  "input_digest": "b3:howto_inputs",
  "output_digest": "b3:howto_outputs",
  "meta": {"note":"authoring discipline acknowledged"}
}
```

**Example (must-fail)** — `reason_code: duplicate_definition_outside_home`

```jsonc
{
  "case": "Subsection restates ReceiptEnvelope details instead of SSOT pointer",
  "why": "Violates Rule 2 (SSOT); definition not in canonical home"
}
```

---
## 0.1 SSOT Map (canonical homes & stable anchors)
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Concept→Anchor mapping proposal"],
  "Emits": ["Canonical anchor table", "Editing rule for references"],
  "Guards": [
    {"anchor":"#ssot-dedup-impl","content_b3":"b3:…"}
  ],
  "FailFast": ["anchor_renamed", "redefine_outside_home"],
  "Links": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"},
    {"anchor":"#gmm-replay","content_b3":"b3:…"},
    {"anchor":"#proposal-spec","content_b3":"b3:…"},
    {"anchor":"#ssg-spec","content_b3":"b3:…"},
    {"anchor":"#ssg-bind","content_b3":"b3:…"},
    {"anchor":"#q-prime","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules**

1. **Reference-only (MUST).** Later sections reference mapped concepts **only** via SSOT pointers listed here.
2. **Stability (MUST NOT).** Renaming any anchor without registry update is forbidden (`anchor_renamed`).
3. **Single-source (MUST).** Redefining a mapped concept outside its home **MUST** fail (`redefine_outside_home`).

**Example (valid)**

```jsonc
{ "anchor":"#civ-canon","content_b3":"b3:…" }
```

**Example (must-fail)** — `reason_code: redefine_outside_home`

```jsonc
{
  "case": "Inline prose redefining CIV fields in §7",
  "why": "Mapped to #civ-canon; must link, not restate"
}
```

---
## 0.2 The Three Pillars (SSOT, paste-once macro)
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Macro definition request"],
  "Emits": ["PILLARS one-liner macro", "Placement rule"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": ["pillars_pasted_multiple_times", "pillars_missing_on_first_mention"],
  "Links": [{"anchor":"#ssot-dedup-impl","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```
PILLARS := ( EnvLock ⇄ Receipts ⇄ CIV )
where
  EnvLock pins authorized checker_hash values and runtime fingerprints,
  Receipts are all ReceiptEnvelope/v1,
  CIV is the content-addressed Canonical Input View produced before any kernel runs.
```

**Reusable one-liner macro (paste-once):**
**PILLARS:** Receipts use **ReceiptEnvelope/v1**; each carries `checker_hash` that **MUST** be present in **EnvLock**; all guards operate over a content-addressed **CIV** produced before any kernel runs.

**Example (must-fail)** — `reason_code: pillars_pasted_multiple_times`

```jsonc
{
  "case": "PILLARS macro repeated twice in the same subsection",
  "why": "Violates paste-once rule"
}
```

---
## 0.3 SSOT Dedup — Placement & Implementation {#ssot-dedup-impl}
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Section drafts with overlapping definitions"],
  "Emits": ["Placement rules", "Editor markers", "Receipt pinning first-mention line"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["duplicate_canonical_prose", "first_mention_pinning_missing", "anchor_renamed"],
  "Links": [
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules**

1. **Placement (MUST).** Mainline (§§4–7): paste one-liners immediately after the opening paragraph. Appendices: never inside canonical homes; use one-liner links back.
2. **Duplicates (MUST NOT).** Keep only the first one-liner in a subsection; remove repeats (`duplicate_canonical_prose`).
3. **Receipt pinning (MUST).** On the first mention of “receipt”, include exactly once:
   *“Receipts use **ReceiptEnvelope/v1** (Appendix B) and **must** have `checker_hash` pinned in **EnvLock**; Ω fails the bundle if any receipt is unpinned or not advanced via UpdateCert.”*
   Omission ⇒ `first_mention_pinning_missing`.

**Example (editor markers; lint-only)**

```md
<!-- ssot-pointer:receipt-canon -->
<!-- ssot-pointer:civ-canon -->
<!-- ssot-pointer:unknowns-guard -->
<!-- ssot-pointer:envlock -->
<!-- ssot-pointer:delta-fr-invariants -->
<!-- ssot-pointer:commit-path -->
<!-- ssot-pointer:gmm-replay -->
<!-- ssot-pointer:proposal-spec -->
<!-- ssot-pointer:ssg-spec -->
<!-- ssot-pointer:ssg-bind -->
```

---
## 0.4 CI Gates for Editorial Rigor (preamble-level)
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Spec tree", "CI config"],
  "Emits": ["Gates for SSOT integrity", "Receipt pinning check", "JSON canonicalization", "Must-fail coverage", "Gate 0 promotion"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": ["ssot_restated_outside_home", "first_mention_line_missing", "json_noncanonical", "negative_suite_missing"],
  "Links": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules**

1. **SSOT integrity (MUST).** Restates outside canonical homes fail with `ssot_restated_outside_home`.
2. **First-mention line (MUST).** Missing receipt-pinning line fails with `first_mention_line_missing`.
3. **Canonicalization (MUST).** All JSON examples MUST be JCS/RFC8785 canonical; else `json_noncanonical`.
4. **Negatives (MUST).** ≥1 must-fail per predicate family; else `negative_suite_missing`.
5. **Gate 0 (MUST).** Final QA checklist in §10 blocks new `specid` and Ω acceptance until all above pass.

---
## 0.5 Canonical Anchors (SSOT)
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Anchor definitions"],
  "Emits": ["Receipt canon", "CIV canon", "Unknowns Guard summary", "Commit Path pointer"],
  "Guards": [{"anchor":"#ssot-dedup-impl","content_b3":"b3:…"}],
  "FailFast": ["variant_receipt_envelope", "adapter_rejects_civ_fields"],
  "Links": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->
### 0.5.1 <a id="receipt-canon"></a>Receipt Canon

**Rules**

1. All receipts use **ReceiptEnvelope/v1**; `checker_hash` MUST be pinned in **EnvLock**.
2. Variant envelopes are forbidden (`variant_receipt_envelope`).
3. PASS/FAIL outcomes are Merkle leaves under the evidence bundle.

**Example (valid)**

```jsonc
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "ENV_ATTEST_OK",
  "checker_hash": "b3:…",
  "envlock_digest": "b3:…",
  "verdict": "PASS"
}
```
### 0.5.2 <a id="civ-canon"></a>CIV Canon

**Rules**

1. Adapters MUST accept `CIVContract/v1` field set **verbatim**; rejections fail as `adapter_rejects_civ_fields`.
2. Conformance verified via `ADAPTER_AXIS_OK` and monotonicity negatives (see Appendix G via SSOT pointer).
### 0.5.3 <a id="unknowns-guard"></a>Unknowns Guard (Summary)

**Rules**

1. Priced-axis unknowns MUST halt via `C_UNK_PRICED` (schema in Appendix B).
2. `unk_budget.jsonl` artifact is maintained as per Appendix B (SSOT pointer above).
### 0.5.4 <a id="commit-path"></a>Commit Path

**Rules**

1. Bundle manifest and canonical Merkle recipe are normative.
2. CI MUST recompute and compare roots (see §0.6).

---
## 0.6 Merkle Recipe (fixture-backed, link-only elsewhere)
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Manifest bytes", "Artifact list"],
  "Emits": ["Merkle root b3:…", "Ω failure codes"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": ["merkle_recompute_mismatch", "root_encoding_invalid"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules**

1. Leaf: `BLAKE3(0x00 || leaf_bytes)`; Node: `BLAKE3(0x01 || left || right)`; odd nodes duplicate the lone child.
2. Digest/encoding: BLAKE3-256, `b3:<lower-hex>`; otherwise `root_encoding_invalid`.
3. CI MUST recompute the fixture manifest root; mismatches **hard-fail** with `merkle_recompute_mismatch`.

**Ω failure codes (enumerated)**

* `MERKLE_MISMATCH`
* `TAIL_EXT_FAIL`

**Example (valid)**

```jsonc
{
  "schema_id": "BundleManifest/v1",
  "schema_b3": "b3:…",
  "merkle_root": "b3:abcd…"
}
```

---
## 0.7 Approximation Hard Gate (rounding receipts)
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Kernel advertising approximation mode"],
  "Emits": ["ROUNDING_RECEIPT digest bound into TRANSITION_OK meta"],
  "Guards": [{"anchor":"#delta-fr-invariants","content_b3":"b3:…"}],
  "FailFast": ["rounding_missing"],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules**

1. If a kernel advertises approximation mode, any `TRANSITION_OK` **without** `meta.rounding_receipt_digest` MUST be **REJECTED** with `rounding_missing`.

**Example (must-fail)** — `reason_code: rounding_missing`

```jsonc
{
  "case": "Approx kernel emits TRANSITION_OK without rounding_receipt_digest",
  "why": "Violates Rule 1"
}
```

---
## 0.8 Provenance & Sources
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Prior spec fragments", "Anchor table"],
  "Emits": ["Consolidated SSOT map", "PILLARS macro", "Merkle fixture mandate", "Approx gate rule", "Gate 0 promotion"],
  "Guards": [{"anchor":"#ssot-dedup-impl","content_b3":"b3:…"}],
  "FailFast": ["non_ssot_prose_reintroduced"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules**

1. Consolidate via SSOT pointers only; reintroducing prose that restates canon fails with `non_ssot_prose_reintroduced`.

---
## 0.9 Stage Card Template (authoring discipline)
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Subsection draft"],
  "Emits": ["Canonical StageCard structure"],
  "Guards": [],
  "FailFast": ["stagecard_missing_key", "prose_before_stagecard"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules**

1. Every **normative** subsection uses **exactly five keys** in this order: `Admits, Emits, Guards, FailFast, Links`.
2. No free prose appears **before** the StageCard; violation ⇒ `prose_before_stagecard`.
3. Missing any key ⇒ `stagecard_missing_key`.

---
## 0.10 Transport Pack ⇄ Evidence Bundle Boundary (canonical)
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Transport Pack rows", "Evidence artifacts"],
  "Emits": ["Boundary filenames", "Resume rule", "Unknowns sidecar name"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": ["replay_mismatch", "unknowns_sidecar_misnamed"],
  "Links": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```
          ┌──────────────────────────┐
          │  Transport Pack (state)  │
          │  transport_pack.jsonl    │
          │  rows: {ids, frontiers,  │
          │         axes_delta, rng, │
          │         seeds, buckets}  │
          └─────────────┬────────────┘
                        │ (Ω collects)
                        ▼
┌────────────────────────────────────────────────────────────┐
│        Evidence Bundle (audit, append-only)                │
│  manifest: Omega-manifest-v1.json  → merkle_root (b3:…)    │
│  receipts/: *.jsonl (ReceiptEnvelope/v1 leaves)            │
│  tails/: I11|I12|I13 witnesses                             │
└────────────────────────────────────────────────────────────┘
```

**Rules**

1. **Resume (MUST).** Resumption requires matching TP head **and** bundle head digests; mismatch ⇒ `replay_mismatch`.
2. **Unknowns sidecar (MUST).** Priced-unknowns ledger filename is **`Omega-unk_budget-v1.jsonl`**; any other name ⇒ `unknowns_sidecar_misnamed`.

---
## 0.11 Acceptance Algebra Guardrail (Q vs. Q′)
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Q and Q′ definitions"],
  "Emits": ["Homomorphism rule π(Q′)=Q", "Must-fail: confidence inflation"],
  "Guards": [{"anchor":"#q-prime","content_b3":"b3:…"}],
  "FailFast": ["qprime_flip_attempt"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules**

1. `Q ∈ {ACCEPT, REJECT}` is the **only** decision space; any third value is non-conformant (see §1.2).
2. `Q′` binds `Q` to evidence and uncertainty; **metadata cannot upgrade** a `REJECT`. Any attempted upgrade MUST fail with `qprime_flip_attempt`.
3. Appendix G MUST include a “confidence inflation” negative.

**Example (must-fail)** — `reason_code: qprime_flip_attempt`

```jsonc
{
  "case": "Q′ claims REJECT with 0.999 confidence implies ACCEPT",
  "why": "π(Q′)=Q; metadata cannot flip"
}
```

---
## 0.12 Governance as Guards — must-fail hooks
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Governance policy vocabulary"],
  "Emits": ["Two required negatives"],
  "Guards": [],
  "FailFast": ["policy_bypass_in_pipeline"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules**

1. **Required negatives (MUST).**

   * Valid functional guard but **wrong signer role** → `GOV_GUARD_FAIL`.
   * Valid signature but **stale UpdateCert** → `POLICY_VERSION_STALE`.
2. Any bypass of governance checks MUST fail with `policy_bypass_in_pipeline`.

---
## 0.13 EnvLock Portability Stance (echo requirement)
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["EnvLock body & signature", "Ω finalization inputs"],
  "Emits": ["Surface echo of portability_stance", "CI cross-replay requirement (Strong stance)"],
  "Guards": [{"anchor":"#envlock","content_b3":"b3:…"}],
  "FailFast": ["omega_surface_missing_stance", "cross_replay_failed_for_strong"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules**

1. Ω MUST echo the run’s **portability\_stance** from EnvLock into both the final surface and the `OMEGA` receipt; omission ⇒ `omega_surface_missing_stance`.
2. Stance **Strong** implies CI cross-replay on the allowed platform set; any failure ⇒ `cross_replay_failed_for_strong`.

---

**Minimal must-fail(s) introduced in §0**

* *MerkleMismatchFixture*: manifest/root disagree ⇒ `MERKLE_MISMATCH`.
* *ApproxRoundingMissing*: approx kernel without rounding receipt ⇒ `rounding_missing`.
* *ReplayHeadMismatch*: resume with mismatched TP/bundle heads ⇒ `replay_mismatch`.

**New schemas defined in §0:** *None.*

**New reason codes requested in §0:**
`duplicate_definition_outside_home`, `pillars_missing_on_first_mention`, `pillars_pasted_multiple_times`, `anchor_renamed`, `redefine_outside_home`, `ssot_restated_outside_home`, `first_mention_line_missing`, `json_noncanonical`, `negative_suite_missing`, `variant_receipt_envelope`, `adapter_rejects_civ_fields`, `merkle_recompute_mismatch`, `root_encoding_invalid`, `unknowns_sidecar_misnamed`, `policy_bypass_in_pipeline`, `omega_surface_missing_stance`, `cross_replay_failed_for_strong`.

**Required cross-ref updates (outside scope)**

* Register/confirm anchors for all entries listed in §0.1’s SSOT map (no prose restates).
* Ensure Appendix B contains `ReceiptEnvelope/v1`, `CIVContract/v1`, Unknowns Guard receipts, and enumerates all `reason_code`s cited above.
* Wire §10 Gate 0 checklist to enforce §0.4 gates (SSOT pointer only).

---
# 1. Normative Foundations

> SSOT pointers: `{ "anchor":"#receipt-canon","content_b3":"b3:…" }`, `{ "anchor":"#envlock","content_b3":"b3:…" }`, `{ "anchor":"#civ-canon","content_b3":"b3:…" }`.

---
### 1.0 Guard Primitives (Required)
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["GuardSpec/v1 draft", "axis_catalog", "policy caps (saltation_max)", "runtime EnvLock"],
  "Emits": ["Hysteresis discipline", "Saltation discipline", "dwell.tau_min_s requirement", "Frontier-crossing receipt fields"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"}
  ],
  "FailFast": [
    "missing_hysteresis",
    "missing_saltation",
    "dwell_breach",
    "saltation_cap_breach"
  ],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Definitions (normative).**

* **Hysteresis** — tuple `H=(θ_on, θ_off, dir)` with `θ_on ≥ θ_off`, `dir ∈ {"increasing","decreasing"}` controlling enable/disable of a mode switch for a scalar (or scalarized) observable.
* **Dwell** — loader-enforced minimum interval `τ_min` between consecutive crossings on the same edge to preclude Zeno oscillations.
* **Saltation** — total reset map `R: x^- ↦ x^+` applied atomically on guard satisfaction with sensitivity bound `K_obs = ∂x^+/∂x^-` (or a certified bound).

**Rules.**

1. **Spec presence (MUST).** Every `GuardSpec/v1` **MUST** declare:

   * `hysteresis.{on,off,dir}` with units,
   * `dwell.tau_min_s`,
   * `saltation.reset_hash` (content-address of canonical bytes) and `saltation.sensitivity_cap` (≤ policy `saltation_max` for affected axes).
     Missing any of these **MUST** hard-fail with `reason_code ∈ {missing_hysteresis, missing_saltation}`.
2. **Crossing semantics (MUST).** A transition `m→m′` **enters** only on crossing `θ_on` in the enabling `dir`; **exits** only on crossing `θ_off` in the opposite sense; crossings within `Δt < τ_min` **MUST** be rejected with `reason_code: dwell_breach`.
3. **Saltation bound (MUST).** For each affected axis, the checker **MUST** verify `‖K_obs − I‖ ≤ saltation_max[axis]`. Breach ⇒ `reason_code: saltation_cap_breach`.
4. **Purity & scope (MUST).** `R` **MUST** be total over the guard domain and side-effect-free outside model state.
5. **Receipt pinning (MUST).** Crossing receipts **MUST** pin `reset_hash`, report `{hysteresis_ok, dwell_ok, saltation_ok}`, and carry `(checker_hash, envlock_digest)` per ReceiptEnvelope/v1.

**Example (valid) — Frontier crossing receipt**

```jsonc
// ReceiptEnvelope/v1 (FrontierCrossing)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "FRONTIER_CROSSING_OK",
  "inputs_digest": "b3:{x_pre,x_post,edge:e_GA}",
  "checker_hash": "b3:hybrid_cross_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": {
    "edge_id": "e_GA",
    "hysteresis_ok": true,
    "dwell_ok": true,
    "saltation_ok": true,
    "reset_hash": "b3:R_GA…",
    "K_obs_bound": 0.032
  },
  "witness_digest": "b3:saltation_witness…"
}
```

**Example (must-fail)** — `reason_code: dwell_breach`

```jsonc
{
  "case": "Two e_GA crossings 12ms apart with tau_min_s=0.050",
  "why": "Violates Rule 2 dwell interval"
}
```

---
### 1.1 Author-Facing Interfaces (Canonized)
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Author definitions for guards", "Reset implementation bytes"],
  "Emits": ["GuardSpec/v1 canonical key-set", "ReceiptEnvelope/v1 minimal crossing meta"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": ["unknown_guard_field", "receipt_missing_schema", "noncanonical_numbers"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Guard declaration (canonical JSON).**

```jsonc
// GuardSpec/v1 (canon/v1)
{
  "schema_id": "GuardSpec/v1",
  "schema_b3": "b3:…",
  "hysteresis": { "on": 0.12, "off": 0.08, "dir": "increasing", "units": "fraction" },
  "dwell":      { "tau_min_s": 0.050 },
  "saltation":  { "reset_hash": "b3:R_GA…", "sensitivity_cap": 0.05 }
}
```

**Crossing receipt (required fields when present).**

```jsonc
// ReceiptEnvelope/v1 (meta subset) (canon/v1)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "FRONTIER_CROSSING_OK",
  "checker_hash": "b3:…",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": {
    "edge_id": "e_GA",
    "hysteresis_ok": true,
    "saltation_ok": true,
    "dwell_ok": true,
    "reset_hash": "b3:R_GA…",
    "K_obs_bound": 0.032
  }
}
```

**Rules.**

1. **Canonicalization (MUST).** Numbers are fixed-decimal per Appendix B; keys sorted (RFC8785/JCS). Non-canonical numbers ⇒ `reason_code: noncanonical_numbers`.
2. **Schema presence (MUST).** `schema_id` and `schema_b3` **MUST** be present and match the registered schema bytes; else `reason_code: receipt_missing_schema`.
3. **Field set (MUST).** `GuardSpec/v1` **forbids** `additionalProperties`. Unknown keys ⇒ `reason_code: unknown_guard_field`.

---
## 1.2 Acceptance Algebra `Q`  {#acceptance-algebra}
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Boolean decisions from guards/kernels"],
  "Emits": ["Q carrier, order, connectives, monotonicity law"],
  "Guards": [{"anchor":"#q-prime","content_b3":"b3:…"}],
  "FailFast": ["q_unknown_third_value"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Definition.** `Q = {ACCEPT, REJECT}`, order `REJECT < ACCEPT`.
Connectives: `∧, ∨, ¬` behave as classical Boolean over this order.
**Monotonicity:** For any monotone `f` over evidence, `e₁ ⪯ e₂ ⇒ f(e₁) ≤ f(e₂)`.

**Rules.**

1. **Uniqueness (MUST).** Every normative decision returns exactly one `Q` value.
2. **No third value (MUST NOT).** “Unknown” is **not** a `Q` value; attempts to emit a third value **MUST** fail with `reason_code: q_unknown_third_value`.
3. **Receipt coupling (MUST).** Any `ACCEPT` **MUST** be justified by a guard and yield a receipt (SSOT pointer: `{ "anchor":"#receipt-canon","content_b3":"b3:…" }`).

---
## 1.3 Unknowns & Guard-First Discipline  {#unknowns-guard-first}
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Observations", "CIV slice", "GuardSpec/v1"],
  "Emits": ["REJECT or PASS+receipt", "Unknowns Guard routing"],
  "Guards": [{"anchor":"#unknowns-guard","content_b3":"b3:…"}],
  "FailFast": ["missing_observation", "unit_mismatch", "out_of_domain"],
  "Links": [
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**

1. **Guard-first (MUST).** Any operation requiring evidence **MUST** route through a guard with declared inputs, hysteresis, saltation, and dwell.
2. **Fail-closed (MUST).** Missing/ambiguous/unit-invalid/out-of-domain observations **MUST** yield `REJECT` with `reason_code ∈ {missing_observation, unit_mismatch, out_of_domain}`.
3. **Determinism (MUST).** With identical observations and guard definition (including `τ_min`), evaluation **MUST** replay bit-for-bit under EnvLock (SSOT `{ "anchor":"#envlock","content_b3":"b3:…" }`).

*(Priced-axis unknowns and the `C_UNK_PRICED` stub are defined via SSOT `{ "anchor":"#unknowns-guard","content_b3":"b3:…" }`.)*

---
## 1.4 Uncertainty Lift `Q′` (Result Contract)  {#uncertainty-lift}
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Q value", "ReceiptEnvelope reference", "metrics"],
  "Emits": ["QPrime/v1 object", "π homomorphism law"],
  "Guards": [{"anchor":"#q-prime","content_b3":"b3:…"}],
  "FailFast": ["qprime_flip_attempt"],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Definition.** `Q′ := ( q ∈ Q, receipt_ref, metrics )` where:

* `receipt_ref` — content-address (hash/anchor) of **ReceiptEnvelope/v1**.
* `metrics` — optional numerics (bounds, p-values, CIs, margins, budget deltas).

**Rules.**

1. **Homomorphism (MUST).** Projection `π(Q′) = q`; composition over `Q′` **MUST** commute with `π`. Metadata **CANNOT** upgrade `REJECT → ACCEPT`; attempts **MUST** fail with `reason_code: qprime_flip_attempt`.
2. **Receipt binding (MUST).** Any `ACCEPT` in `Q` **MUST** have a corresponding `Q′` with a valid `receipt_ref`.
3. **Aggregation (MUST).** When composing results, `receipt_ref`s are aggregated as a multiset (content-addressed de-duplication).

**Example (must-fail)** — `reason_code: qprime_flip_attempt`

```jsonc
// QPrime/v1 (negative control)
{
  "schema_id": "QPrime/v1",
  "schema_b3": "b3:…",
  "q": "REJECT",
  "receipt_ref": "b3:…",
  "metrics": { "confidence": 0.999, "margin": 0.000 }
}
```

---
## 1.5 Minimal Interfaces (Author Uses)  {#foundations-interfaces}
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Author intent to declare guards and consume decisions"],
  "Emits": ["GuardSpec/v1 key set", "ReceiptEnvelope/v1 fields for crossings", "QPrime/v1 contract"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#q-prime","content_b3":"b3:…"}
  ],
  "FailFast": ["ad_hoc_boolean"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**

1. **Guard declaration (MUST).** Register via SSOT `{ "anchor":"#predicate-registry","content_b3":"b3:…" }` → `GuardSpec/v1` with **hysteresis**, **saltation**, and **`dwell.tau_min_s`**.
2. **Receipt (MUST).** Use **ReceiptEnvelope/v1**; crossing receipts expose `{hysteresis_ok, saltation_ok, dwell_ok}` in `meta`.
3. **Decision result (MUST).** Emit **QPrime/v1** only. Ad-hoc booleans or bespoke “maybe” flags **MUST NOT** be introduced (`reason_code: ad_hoc_boolean`).

---
## 1.6 Verification (What to Test)  {#foundations-verification}
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Recorded observations", "GuardSpec/v1", "Receipts", "Q′ composites"],
  "Emits": ["Determinism checks", "Fail-closed checks", "Projection checks", "Dwell & saltation negatives"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#q-prime","content_b3":"b3:…"}
  ],
  "FailFast": ["receipt_ref_mismatch", "projection_violation"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**

1. **Determinism (MUST).** Replaying identical `GuardSpec` + observations yields identical `Q` **and** identical `receipt_ref` (else `reason_code: receipt_ref_mismatch`).
2. **Fail-closed (MUST).** Missing/malformed observations force `REJECT` (rule hooks from §1.3).
3. **Projection law (MUST).** For composed results, `π(f(Q′₁,…,Q′ₙ)) = f(π(Q′₁), …, π(Q′ₙ))`; violations hard-fail (`reason_code: projection_violation`).
4. **Dwell evidence (MUST).** Crossing receipts set `dwell_ok=true` when `Δt ≥ τ_min`; otherwise `dwell_breach`.
5. **Saltation cap (MUST).** Any breach of `saltation_max` deterministically rejects (`saltation_cap_breach`).

---
## 1.7 Author To-Dos (Concise)  {#foundations-author-todos}
```jsonc
// StageCard/v1 (key order is normative)
{
  "schema_id": "StageCard/v1",
  "schema_b3": "b3:…",
  "Admits": ["Author checklist intentions"],
  "Emits": ["Minimal actionable to-dos for guards, receipts, Q′, negatives"],
  "Guards": [{"anchor":"#predicate-registry","content_b3":"b3:…"}],
  "FailFast": ["todo_missing_negatives"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples MUST validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Checklist (normative).**

1. Declare all guards with explicit **hysteresis**, **saltation**, and **`dwell.tau_min_s`** (or state `"none"` with justification artifact per Appendix B); omission fails with `missing_hysteresis`/`missing_saltation`.
2. Ensure every `ACCEPT` path emits a **receipt** and link it by content hash in `Q′`.
3. Use only `Q` / `Q′` types; remove ad-hoc booleans (`ad_hoc_boolean` if found).
4. Add the **must-fail** for Q′ confidence inflation (cannot flip `REJECT` → `ACCEPT`).

---
### Minimal must-fail(s) introduced in §1

* *HysteresisMissing*: guard declared without `hysteresis` ⇒ `missing_hysteresis`.
* *SaltationMissing*: guard declared without `saltation.reset_hash` or `sensitivity_cap` ⇒ `missing_saltation`.
* *DwellBreach*: two crossings on same edge with `Δt < τ_min` ⇒ `dwell_breach`.
* *SaltationCapBreach*: `‖K_obs − I‖ > saltation_max` on any affected axis ⇒ `saltation_cap_breach`.
* *QPrimeFlipAttempt*: metadata tries to upgrade `REJECT → `**`ACCEPT`** ⇒ `qprime_flip_attempt`.
* *QThirdValue*: attempt to emit “UNKNOWN” as a `Q` value ⇒ `q_unknown_third_value`.
* *ReceiptSchemaMissing*: receipt lacks `schema_id`/`schema_b3` ⇒ `receipt_missing_schema`.
* *ReceiptRefMismatch*: replay yields different `receipt_ref` under identical inputs ⇒ `receipt_ref_mismatch`.
* *ProjectionViolation*: composition fails `π` homomorphism ⇒ `projection_violation`.
* *AdHocBoolean*: bespoke flag outside `Q`/`Q′` detected ⇒ `ad_hoc_boolean`.

**New schemas defined:** *None in §1* (all schemas referenced via SSOT to Appendix B).

**New reason codes requested:**
`missing_hysteresis` — GuardSpec lacks required hysteresis fields.
`missing_saltation` — GuardSpec lacks required saltation fields.
`dwell_breach` — Crossing occurred before `tau_min_s`.
`saltation_cap_breach` — Observed saltation sensitivity exceeds policy cap.
`receipt_missing_schema` — Receipt missing `schema_id` or `schema_b3`.
`qprime_flip_attempt` — Attempted upgrade of `REJECT` via metadata.
`q_unknown_third_value` — Emitted a third decision value outside `Q`.
`receipt_ref_mismatch` — Non-deterministic receipt under replay.
`projection_violation` — Composition violated π homomorphism.
`ad_hoc_boolean` — Non-conformant boolean/maybe flag detected.

**Required cross-ref updates (outside scope):**

* Ensure Appendix **B** registers `GuardSpec/v1`, `ReceiptEnvelope/v1`, and `QPrime/v1` schemas with frozen `schema_b3` and `additionalProperties: false`.
* Link priced-axis unknowns and `C_UNK_PRICED` to §4.2.2 via SSOT pointer.
* Confirm policy anchor publishing `saltation_max` per axis in §5 and its SSOT anchor referenced here.

---
# 2. Sirus Architecture Overview (What Runs Where)  {#architecture}

> **What you’ll learn:** how the pipeline is wired end-to-end, what each stage admits/checks/produces, and where state vs. evidence live.
> **What you’ll do:** trace a minimal EF→Ω run, inspect Transport Pack vs. Evidence Bundle, and map adapters to axes.
> **How to verify:** replay the run under EnvLock and confirm each stage’s receipts plus the final `proof_surface`.&#x20;

---
## 2.0 The Three Pillars (pinned here, referenced everywhere)
```jsonc
// StageCard/v1
{
  "Admits": ["EnvLock", "ReceiptEnvelope/v1", "CIVContract/v1"],
  "Emits": ["PILLARS one-liner", "Placement rule (paste-once per subsection)"],
  "Guards": [
    {"anchor":"#envlock","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"}
  ],
  "FailFast": ["pillars_missing_on_first_mention", "pillars_pasted_multiple_times"],
  "Links": [{"anchor":"#ssot-dedup-impl","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```
PILLARS := ( EnvLock ⇄ Receipts ⇄ CIV )
where
  EnvLock pins authorized checker_hash values and runtime fingerprints,
  Receipts are all ReceiptEnvelope/v1,
  CIV is the content-addressed Canonical Input View produced before any kernel runs.
```

**Reusable one-liner (paste-once per subsection after the first receipt/CIV mention):**
**PILLARS:** Receipts use **ReceiptEnvelope/v1**; each carries `checker_hash` that **MUST** be present in **EnvLock**; all guards operate over a content-addressed **CIV** produced before any kernel runs.

---
## 2.1 Fixed Pipeline — EF → DRO → PR → CBF → Ω  {#pipeline}
```jsonc
// StageCard/v1
{
  "Admits": ["EnvLock", "axis_catalog", "policy_digests", "CIVContract/v1", "Transport Pack head", "Evidence Bundle head"],
  "Emits": ["Per-stage receipts", "Transport Pack rows", "Bundle manifest entries", "proof_surface digest"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"}
  ],
  "FailFast": [
    "envlock_missing",
    "civ_invalid",
    "axis_leak",
    "kernel_id_mismatch",
    "rounding_missing",
    "budget_cap_breach",
    "merkle_mismatch",
    "tail_ext_fail"
  ],
  "Links": [
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#ledger-discipline","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Stages (concise, DRY):**

* **EF — Evidence Foundation (ingest & attest)**
  *Admits:* EnvLock, axis catalog, policy digests, raw corpus pointers.
  *Emits (state):* `ef_manifest.json`, initial `transport_pack.jsonl` rows.
  *Emits (evidence):* `ENV_ATTEST_OK`, `CANON_INPUT_VIEW`.
  *FailFast:* `envlock_missing`, `civ_invalid`.
  *SSOT:* `{ "anchor":"#civ-canon","content_b3":"b3:…" }`, `{ "anchor":"#receipt-canon","content_b3":"b3:…" }`.

* **DRO — Definitions / Relations / Objects (frontier discovery)**
  *Admits:* EF transport pack.
  *Emits (state):* `definitions.jsonl`, `frontiers.jsonl`, updated TP rows.
  *Emits (evidence):* `ADAPTER_AXIS_OK`, `ADAPTER_MONO_OK`.
  *FailFast:* `axis_leak`, `adapter_mono_fail`.
  *SSOT:* `{ "anchor":"#adapter-contracts","content_b3":"b3:…" }`, `{ "anchor":"#unknowns-guard","content_b3":"b3:…" }`.

* **PR — Proof Reader (guarded evaluation / kernels)**
  *Admits:* DRO outputs, policy thresholds/salts.
  *Emits (evidence):* `KERNEL_ID_OK`, `TRANSITION_OK`, optional `ROUNDING_RECEIPT`.
  *FailFast:* `kernel_id_mismatch`, `rounding_missing`.
  *SSOT:* `{ "anchor":"#delta-fr-invariants","content_b3":"b3:…" }`.

* **CBF — Cost / Barrier / Frontier (pricing & ledger)**
  *Admits:* PR deltas, budget vector `B`, group caps.
  *Emits (state):* `cbf_ledger.json` (append-only).
  *Emits (evidence):* `CBF_BUDGET_CHECK(OK|FAIL)`, `CBF_LEDGER_POST`.
  *FailFast:* `budget_cap_breach`, `ledger_atomicity_fail`, `duplicate_txid`.
  *SSOT:* `{ "anchor":"#ledger-discipline","content_b3":"b3:…" }`.

* **Ω — Omega (close & fingerprint)**
  *Admits:* complete TP + Evidence Bundle; pinned axis/catalog/budgets.
  *Emits (state):* `surface_v1.json` (canonical preimage), `proof_surface` digest.
  *Emits (evidence):* `OMEGA` (+ TailReceipt summaries).
  *FailFast:* `merkle_mismatch`, `tail_ext_fail`, `missing_receipt`.
  *SSOT:* `{ "anchor":"#commit-path","content_b3":"b3:…" }`.

**Example receipts (canonical):**

```jsonc
// ReceiptEnvelope/v1 (EF attestation)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "ENV_ATTEST_OK",
  "inputs_digest": "b3:envlock|axis_catalog|policy_digests",
  "checker_hash": "b3:ef_attest_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": {"civ_digest": "b3:…"}
}
```

```jsonc
// ReceiptEnvelope/v1 (PR transition; approx kernel)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "TRANSITION_OK",
  "inputs_digest": "b3:frontier_id|x_pre|x_post",
  "checker_hash": "b3:pr_kernel_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": { "rounding_receipt_digest": "b3:…" }
  // If approx=true and this field is absent → reason_code: rounding_missing
}
```

---
## 2.2 Transport Pack & Evidence Bundle  {#state-and-evidence}
```jsonc
// StageCard/v1
{
  "Admits": ["transport_pack.jsonl head", "Evidence artifacts"],
  "Emits": ["Boundary filenames", "Resume rule", "Bundle manifest entry", "Unknowns sidecar name"],
  "Guards": [
    {"anchor":"#commit-path","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"}
  ],
  "FailFast": ["replay_mismatch", "merkle_mismatch", "unknowns_sidecar_misnamed"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Boundary (canonical ASCII diagram; filenames frozen):**

```
          ┌──────────────────────────┐
          │  Transport Pack (state)  │
          │  transport_pack.jsonl    │
          │  rows: {ids, frontiers,  │
          │         axes_delta, rng, │
          │         seeds, buckets}  │
          └─────────────┬────────────┘
                        │ (Ω collects)
                        ▼
┌────────────────────────────────────────────────────────────┐
│        Evidence Bundle (audit, append-only)                │
│  manifest: Omega-manifest-v1.json  → merkle_root (b3:…)    │
│  receipts/: *.jsonl (ReceiptEnvelope/v1 leaves)            │
│  tails/: I11|I12|I13 witnesses                             │
└────────────────────────────────────────────────────────────┘
```

**Resume rule (normative).** Resumption **MUST** present matching TP head **and** bundle head digests; a mismatch **MUST** reject with `reason_code: replay_mismatch`.

**Canonical shapes:**

```jsonc
// BundleManifest/v1 (canon/v1)
{
  "schema_id": "BundleManifest/v1",
  "schema_b3": "b3:…",
  "merkle_root": "b3:…",
  "artifacts": [
    { "name": "attestation_receipt", "digest": "b3:…" },
    { "name": "receipts/0001.jsonl", "digest": "b3:…" },
    { "name": "tails/I11/…", "digest": "b3:…" }
  ]
}
```

```jsonc
// TransportPackRow/v1 (canon/v1)
{
  "schema_id": "TransportPackRow/v1",
  "schema_b3": "b3:…",
  "row_id": 87,
  "clock_bucket_utc_min": "2025-09-23T12:34:00Z",
  "frontier_id": "fr:…",
  "axes_delta": { "Qfr": 0.007, "Qstale": 0.000 },
  "rng_domain": "PR.kernel.hsic",
  "seed": "b3:derived-seed…"
}
```

**Unknowns sidecar (name is normative):** priced-unknowns ledger **MUST** be `Omega-unk_budget-v1.jsonl` (schema via SSOT `{ "anchor":"#unknowns-guard","content_b3":"b3:…" }`).

**CI hooks (normative):** Merkle recomputation from manifest bytes is mandatory; mismatch ⇒ `merkle_mismatch`. Missing artifact entries **MUST** fail CI.

---
## 2.3 Axis Catalog & Budgets  {#axis-and-budgets}
```jsonc
// StageCard/v1
{
  "Admits": ["AxisCatalog/v1", "BudgetVector/v1"],
  "Emits": ["axis_catalog_digest (pinned in proof_surface)", "CBF group-cap checks"],
  "Guards": [
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"}
  ],
  "FailFast": ["axis_missing", "order_undefined", "budget_vector_incomplete"],
  "Links": [{"anchor":"#ledger-discipline","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// AxisCatalogEntry/v1 (canon/v1)
{
  "schema_id": "AxisCatalogEntry/v1",
  "schema_b3": "b3:…",
  "axis": "Qfr",
  "class": "S",
  "units": "dimensionless",
  "order": "≤",
  "unknown_absorbing": true,
  "policy": {
    "cap": 0.20,
    "group": "frontier_g1",
    "hysteresis": { "green": 0.05, "amber": 0.10, "red": 0.15 },
    "salt": "b3:…",
    "saltation_max": 0.05
  }
}
```

```jsonc
// BudgetVector/v1 (canon/v1)
{
  "schema_id": "BudgetVector/v1",
  "schema_b3": "b3:…",
  "budget": { "Qfr": 0.15, "Qstale": 0.02, "Qrisk": 3.0 },
  "axis_catalog_digest": "b3:…",
  "policy_digests": ["b3:…","b3:…"]
}
```

**Rules.**

1. Catalog **MUST** enumerate all axes referenced by adapters/guards; missing axis ⇒ `reason_code: axis_missing`.
2. Each axis **MUST** declare a monotone order (`≤`, `≥`, named partial order, or lattice ref); else `order_undefined`.
3. Ω **MUST** check `q ≤ B` axis-wise at close; group budgets enforced by CBF per ledger discipline (SSOT `{ "anchor":"#ledger-discipline","content_b3":"b3:…" }`).
4. Any axis with `unknown_absorbing: true` **MUST** integrate with the Unknowns Guard (SSOT pointer above).

---
## 2.4 Adapter Contracts (Modules ↔ Q)  {#adapter-contracts}
```jsonc
// StageCard/v1
{
  "Admits": ["AdapterDecl/v1", "CIVContract/v1"],
  "Emits": ["ADAPTER_AXIS_OK", "ADAPTER_MONO_OK"],
  "Guards": [
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"}
  ],
  "FailFast": ["c_axis_leak", "adapter_mono_fail", "envlock_drift"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Interface (normative).** An adapter is a pure function with a declared **axis whitelist** and `checker_hash`. It **MUST** be a monotone homomorphism into `Q` and enforce **axis isolation** with respect to `writes_axes`.

```jsonc
// AdapterDecl/v1 (canon/v1)
{
  "schema_id": "AdapterDecl/v1",
  "schema_b3": "b3:…",
  "adapter": "dro.frontier_id",
  "version": "1.2.0",
  "checker_hash": "b3:…",
  "writes_axes": ["Qfr","Qstale"],
  "reads_axes": [],
  "stability": "deterministic_under_envlock",
  "tests": ["appendix:E/adapter/frontier_id/mono.json", "appendix:E/adapter/frontier_id/isolation.json"]
}
```

```jsonc
// ReceiptEnvelope/v1 (Adapter conformance)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "ADAPTER_AXIS_OK",
  "inputs_digest": "b3:AdapterDecl/v1:…",
  "checker_hash": "b3:axis_linter",
  "envlock_digest": "b3:…",
  "verdict": "PASS"
}
```

**Mandatory negatives (must-fail fixtures).**

* **Axis leak:** simulate undeclared write → expect `verdict=FAIL`, `reason_code: c_axis_leak`.
* **Non-monotone:** craft counterexample wrt declared order → `reason_code: adapter_mono_fail`.
* **Non-determinism under EnvLock:** vary seed/env despite EnvLock pins → `reason_code: envlock_drift`.

---
## 2.5 Runtime Order, Seeds, and Restart Semantics  {#runtime-semantics}
```jsonc
// StageCard/v1
{
  "Admits": ["run args --from/--to", "master_seed", "EnvLock", "code_commit", "axis_catalog"],
  "Emits": ["Deterministic seed derivations", "Replay policy", "SEED_DERIVATION_OK receipt"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": ["replay_mismatch", "seed_domain_unauthorized"],
  "Links": [{"anchor":"#gmm-replay","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Order (normative).** Stages run strictly **EF→DRO→PR→CBF→Ω**. No back-edges; no self-loops.

**Restart.**
`--from STAGE` starts at the **guard-entry** of `STAGE` (re-checks guards).
`--to STAGE` stops **after** `STAGE` receipts append.
Mismatch of TP head or bundle manifest ⇒ `reason_code: replay_mismatch`.

**Deterministic seeding (HKDF + domains).**

* Primitive: RFC5869 with BLAKE3-256.
* `IKM`: master seed at run start.
* `Salt`: `BLAKE3(EnvLock) || BLAKE3(code_commit) || BLAKE3(axis_catalog)`.
* `Info`: `sirus/hkdf/<domain>/v1`.
* Deriving outside the allow-list **MUST** hard-fail (`seed_domain_unauthorized`).

```jsonc
// ReceiptEnvelope/v1 (seed derivation)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "SEED_DERIVATION_OK",
  "inputs_digest": "b3:EnvLock|code_commit|axis_catalog",
  "checker_hash": "b3:hkdf_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": { "rng_domain": "PR.kernel.hsic" },
  "witness_digest": "b3:master_seed"
}
```

---
## 2.6 Quick Maps  {#quick-maps}
```jsonc
// StageCard/v1
{
  "Admits": ["Module list", "Axis catalog"],
  "Emits": ["Module↔Axis responsibility table", "Canonical artifact filename pattern"],
  "Guards": [],
  "FailFast": ["map_inconsistent_with_axis_catalog"],
  "Links": [
    {"anchor":"#axis-and-budgets","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Module ↔ Axis responsibilities (auditor quick view).**

| Module            | Responsible Axis       | Description                               |
| ----------------- | ---------------------- | ----------------------------------------- |
| `GMM.Actor`       | `action_selection`     | Selects actions from scored inputs.       |
| `GMM.Scorer`      | `threat_score`         | Scores input vectors per model.           |
| `SSG.Binder`      | `pattern_hash_binding` | Binds runtime to authorized SSG pattern.  |
| `CIV.Validator`   | `civ_validation`       | Validates CIV integrity and conformance.  |
| `PR.Kernel`       | `hsic_computation`     | HSIC computations for PR module.          |
| `Omega.Finalizer` | `bundle_attestation`   | Emits the final Ω receipt for the bundle. |

**Canonical artifact filenames.** Pattern: `<runID>-<module>-<artifact_type>-v1.<ext>`

* `20241001T1800Z-GMM-receipts-v1.jsonl` — GMM receipts
* `20241001T1800Z-CIV-validated_inputs-v1.csv` — validated CIV inputs
* `20241001T1800Z-SSG-active_pattern-v1.json` — SSG pattern in use
* `20241001T1800Z-Omega-manifest-v1.json` — bundle manifest (with `merkle_root`)
* `20241001T1800Z-Omega-unk_budget-v1.jsonl` — priced-unknowns ledger

---
### Minimal must-fail(s) introduced in §2

* *ReplayHeadMismatch* — resume with mismatched TP or bundle heads ⇒ `replay_mismatch`.
* *AdapterAxisLeak* — undeclared write by adapter ⇒ `c_axis_leak`.
* *AdapterNonMonotone* — adapter violates declared order ⇒ `adapter_mono_fail`.
* *EnvLockDrift* — nondeterminism under fixed EnvLock ⇒ `envlock_drift`.
* *SeedDomainUnauthorized* — attempt to HKDF a seed for an unregistered domain ⇒ `seed_domain_unauthorized`.

**New schemas defined in §2 (canon/v1 URIs):**

* `$id: BundleManifest/v1`
* `$id: TransportPackRow/v1`
* `$id: AxisCatalogEntry/v1`
* `$id: BudgetVector/v1`
* `$id: AdapterDecl/v1`

**New reason codes requested in §2:**

* `pillars_missing_on_first_mention` — first receipt/CIV mention lacks the Pillars one-liner.
* `pillars_pasted_multiple_times` — Pillars one-liner duplicated in a subsection.
* `envlock_missing` — EF started without a valid EnvLock.
* `civ_invalid` — CIV failed contract/canonicalization.
* `axis_leak` / `c_axis_leak` — adapter wrote to an undeclared axis.
* `adapter_mono_fail` — adapter monotonicity check failed.
* `kernel_id_mismatch` — PR checker and kernel identity/ABI disagree.
* `rounding_missing` — approx kernel transition without rounding receipt digest.
* `budget_cap_breach` — CBF detected axis/group cap violation.
* `ledger_atomicity_fail` — non-atomic ledger commit.
* `duplicate_txid` — duplicate transaction identifier in ledger.
* `merkle_mismatch` — bundle manifest/root mismatch at Ω.
* `tail_ext_fail` — TailReceipt extensionality check failed.
* `replay_mismatch` — TP/bundle heads don’t match at resume.
* `envlock_drift` — nondeterministic adapter/guard under EnvLock.
* `seed_domain_unauthorized` — seed derived for a domain not in allow-list.
* `order_undefined` — axis order missing/invalid.
* `axis_missing` — adapter/guard referenced an axis not in catalog.
* `budget_vector_incomplete` — required axis budget not present.

---
## 2.8 EnvLock: Code & Environment Attestation {#envlock}

> **Why this exists:** to make every guard/kernel receipt verifiable under *exactly* the code and runtime that produced it.
> **What it binds:** a signed allowlist of `checker_hash` values, kernel image digests, and runtime fingerprints.
> **When it’s checked:** before any guard runs, before any kernel runs, and again at Ω (finalization).

---
### 2.8.0 The Three Pillars (pinned here, referenced everywhere)
```jsonc
// StageCard/v1
{
  "Admits": ["EnvLock", "ReceiptEnvelope/v1", "CIVContract/v1"],
  "Emits": ["PILLARS one-liner", "placement rule (paste-once)"],
  "Guards": [
    {"anchor":"#envlock","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"}
  ],
  "FailFast": ["pillars_missing_on_first_mention", "pillars_pasted_multiple_times"],
  "Links": [{"anchor":"#ssot-dedup-impl","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```
PILLARS := ( EnvLock ⇄ Receipts ⇄ CIV )
where
  EnvLock pins authorized checker_hash values and runtime fingerprints,
  Receipts are all ReceiptEnvelope/v1,
  CIV is the content-addressed Canonical Input View produced before any kernel runs.
```

**Reusable one-liner (paste once after the first receipt/CIV mention in any subsection):**
**PILLARS:** Receipts use **ReceiptEnvelope/v1**; each carries `checker_hash` that **MUST** be present in **EnvLock**; all guards operate over a content-addressed **CIV** produced before any kernel runs.

---
### 2.8.1 EnvLock Object (canon/v1)
```jsonc
// StageCard/v1
{
  "Admits": ["EnvLock/v1 JSON body", "EnvLockSig/v1 detached signature"],
  "Emits": ["envlock_digest", "runtime pin-set", "allowlist for checker_hash and kernel ABI"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ],
  "FailFast": [
    "envlock_missing",
    "envlock_expired",
    "envlock_scope_mismatch",
    "envlock_sig_invalid",
    "allowlist_empty"
  ],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Definition (canonical bytes).** `canon_bytes := RFC8785/JCS(JSON)`; `envlock_digest := b3:HEX(BLAKE3-256(0xEE || canon_bytes))`. The signature is detached and covers `envlock_digest` only.

```jsonc
// EnvLock/v1 (canon/v1; additionalProperties: false)
{
  "schema_id": "EnvLock/v1",
  "schema_b3": "b3:…",
  "lock_id": "urn:envlock:production",
  "issued_at": "2025-09-01T00:00:00Z",
  "expires_at": "2026-09-01T00:00:00Z",
  "runtime": {
    "os_fingerprint": "sha256:…",
    "container_image": "docker@sha256:…",
    "toolchain_lock": "sha256:…",
    "env": { "LC_ALL": "C.UTF-8" }
  },
  "allowlist": {
    "checker_hashes": ["b3:…","b3:…"],
    "kernel_interfaces": [
      { "name": "price_kernel", "abi_hash": "b3:…" },
      { "name": "routing_kernel", "abi_hash": "b3:…" }
    ]
  },
  "policy": {
    "unknowns": "halt_priced_axes",
    "approximation": { "allowed": true, "require_rounding_receipt": true }
  },
  "prev_envlock_digest": "b3:…",
  "meta": { "owner": "ops@sirus", "note": "Prod baseline 2025-09" }
}
```

```jsonc
// EnvLockSig/v1 (canon/v1; additionalProperties: false)
{
  "schema_id": "EnvLockSig/v1",
  "schema_b3": "b3:…",
  "envlock_digest": "b3:…",
  "alg": "Ed25519",
  "pubkey": "base64:…",
  "signature": "base64:…"
}
```

**Rules (normative).**
Rule 1 (**MUST**): A run presents exactly one active `EnvLock/v1` plus a validating `EnvLockSig/v1`; absence ⇒ `envlock_missing`.
Rule 2 (**MUST**): If `expires_at < now()`, reject with `envlock_expired`.
Rule 3 (**MUST**): `lock_id` must match the intended environment scope; mismatch ⇒ `envlock_scope_mismatch`.
Rule 4 (**MUST**): `allowlist.checker_hashes` is non-empty and deduplicated; empty ⇒ `allowlist_empty`.
Rule 5 (**MUST**): Signature verifies under configured trust root; failure ⇒ `envlock_sig_invalid`.
Rule 6 (**MUST**): If `prev_envlock_digest` is present, evolution is authorized only via `UpdateCert/v1` (see §2.8.3 via SSOT pointer below).

**Example (must-fail):** expired lock
Minimal: `expires_at="2024-12-31T23:59:59Z"`, run at `2025-01-01`.
Expected: reject with `reason_code: envlock_expired`.

---
### 2.8.2 Computing `checker_hash` (uniform)
```jsonc
// StageCard/v1
{
  "Admits": ["checker artifact bytes", "toolchain_lock"],
  "Emits": ["checker_hash"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["checker_hash_mismatch", "toolchain_unpinned"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Definition.** `checker_hash := b3:HEX(BLAKE3-256(0xCF || checker_canon_bytes))`, where `checker_canon_bytes` are canonicalized bytes of the fully resolved checker/kernel artifact (sources or image) under the pinned `toolchain_lock`.

**Rules.**
Rule 1 (**MUST**): Build steps are reproducible; `runtime.toolchain_lock` pins compilers, linkers, and flags. Missing/soft-pinned toolchain ⇒ `toolchain_unpinned`.
Rule 2 (**MUST**): The Loader recomputes `checker_hash` at receipt ingestion and **MUST** reject envelopes whose `checker_hash` ≠ locally computed ⇒ `checker_hash_mismatch`.

**Example (must-fail):** mutated checker bytes post-sign
Expected: receipt `verdict=FAIL`, `reason_code: checker_hash_mismatch`.

---
### 2.8.3 UpdateCert (controlled evolution)
```jsonc
// StageCard/v1
{
  "Admits": ["EnvLock/v1 (from,to)", "UpdateCert/v1"],
  "Emits": ["Authorized transition of active envlock_digest"],
  "Guards": [],
  "FailFast": ["updatecert_invalid_sig", "envlock_chain_fork", "update_applied_multiple"],
  "Links": [{"anchor":"#governance","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// UpdateCert/v1 (canon/v1; additionalProperties: false)
{
  "schema_id": "UpdateCert/v1",
  "schema_b3": "b3:…",
  "from_envlock": "b3:…",
  "to_envlock":   "b3:…",
  "issued_at": "2025-09-15T12:00:00Z",
  "reason": "rotate_guard_set_add_rounding_v0_3_2",
  "approvers": [
    { "role": "SecEng", "sig": "base64:…", "alg": "Ed25519", "pubkey": "base64:…" },
    { "role": "Ops",    "sig": "base64:…", "alg": "Ed25519", "pubkey": "base64:…" }
  ],
  "meta": { "change_ticket": "CHG-4821" }
}
```

**Rules.**
Rule 1 (**MUST**): Transition allowed only if `from_envlock` equals the currently active lock and all approver signatures verify; else `updatecert_invalid_sig`.
Rule 2 (**MUST**): Exactly one `UpdateCert` may be applied per run initialization; multiple applications ⇒ `update_applied_multiple`.
Rule 3 (**MUST**): The `prev_envlock_digest` chain is linear (no forks). Detection of divergent successors for the same `from_envlock` ⇒ `envlock_chain_fork`.
Rule 4 (**MUST**): Ω embeds the run-start `envlock_digest` in the final surface and `OMEGA` receipt (SSOT `{ "anchor":"#commit-path","content_b3":"b3:…" }`).

**Example (must-fail):** two competing `UpdateCert` objects with the same `from_envlock`
Expected: reject with `reason_code: envlock_chain_fork`.

---
### 2.8.4 Loader & CI Semantics (enforcement points)
```jsonc
// StageCard/v1
{
  "Admits": ["EnvLock/v1", "EnvLockSig/v1", "ReceiptEnvelope/v1"],
  "Emits": ["run-scoped envlock_digest", "hard-gate outcomes"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"}
  ],
  "FailFast": [
    "envlock_missing",
    "envlock_expired",
    "envlock_scope_mismatch",
    "checker_hash_not_allowlisted",
    "kernel_abi_unapproved",
    "rounding_missing"
  ],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**At run start (pre-guard, pre-kernel).**
(1) Parse `EnvLock/v1`; verify `EnvLockSig/v1`. (2) Enforce expiry and `lock_id` scope. (3) Record `envlock_digest` for all downstream receipts. (4) Preload `allowlist.checker_hashes` into a constant-time set.

**On each receipt ingestion.**
Rule A (**MUST**): `checker_hash ∈ allowlist.checker_hashes`; else `checker_hash_not_allowlisted`.
Rule B (**MUST**): If the receipt declares a kernel call, kernel `abi_hash` **MUST** match an entry in `allowlist.kernel_interfaces`; else `kernel_abi_unapproved`.
Rule C (**MUST**): If approximation is both allowed by policy and advertised by the kernel, any `TRANSITION_OK` must carry `meta.rounding_receipt_digest`; else `rounding_missing` (SSOT `{ "anchor":"#delta-fr-invariants","content_b3":"b3:…" }`).
Rule D (**MUST**): If the Unknowns Guard emits `C_UNK_PRICED`, the row does not proceed to any kernel (SSOT `{ "anchor":"#unknowns-guard","content_b3":"b3:…" }`).

**CI Gate (pre-publish / pre-deploy).**
Rule E (**MUST**): Canonicalization round-trip stable; deduped non-empty allowlist; reproducible `runtime.*` artifacts resolvable; signature verified; linear `prev_envlock_digest` chain unless `lock_id` changes. Violations hard-fail with the enumerated reason codes above.

---
### 2.8.5 Binding to Receipts & CIV
```jsonc
// StageCard/v1
{
  "Admits": ["ReceiptEnvelope/v1", "CIVContract/v1"],
  "Emits": ["envlock_digest echoed in receipts", "view_digest provenance"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"}
  ],
  "FailFast": ["receipt_envlock_mismatch"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**
Rule 1 (**MUST**): Each `ReceiptEnvelope/v1` includes `(checker_hash, envlock_digest)`; the Loader **rejects** any envelope with `envlock_digest ≠` the run-start value ⇒ `receipt_envlock_mismatch`.
Rule 2 (**MUST**): CIV is produced under an allowlisted guard `checker_hash`; its `view_digest` becomes input to subsequent receipts (SSOT pointers above). Consumers that operate on a CIV slice **MUST** echo `view_digest`.

**Example (valid).**

```jsonc
// ReceiptEnvelope/v1 (CIV emission)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "CANON_INPUT_VIEW",
  "inputs_digest": "b3:row:01af…",
  "checker_hash": "b3:1a93…",
  "envlock_digest": "b3:7c0a…",
  "verdict": "PASS",
  "meta": { "view_digest": "b3:vd:552e…" }
}
```

---
### 2.8.6 Minimal Example Shapes (copyable)
```jsonc
// StageCard/v1
{
  "Admits": ["EnvLock/v1", "EnvLockSig/v1"],
  "Emits": ["Example canonical shapes (short)"],
  "Guards": [],
  "FailFast": [],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// EnvLockSig (detached)
{
  "schema_id": "EnvLockSig/v1",
  "schema_b3": "b3:…",
  "envlock_digest": "b3:7c0a…",
  "alg": "Ed25519",
  "pubkey": "base64:t4b3…",
  "signature": "base64:Q3V2…"
}
```

> Longer authoring walk-throughs and full fixtures are in Appendix D via SSOT pointers.

---
### 2.8.7 Security & Lifecycle
```jsonc
// StageCard/v1
{
  "Admits": ["Key material", "EnvLock chain", "runtime fingerprints"],
  "Emits": ["Key rotation policy", "Scope separation", "Hotfix TTL", "Fail-closed reproducibility rule"],
  "Guards": [],
  "FailFast": ["cross_env_replay", "repro_missing_artifact"],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**
Rule 1 (**SHOULD**): Rotate signing keys via `UpdateCert/v1`; publish new `EnvLockSig/v1`; retain prior public keys for historical verification.
Rule 2 (**MUST**): Use distinct `lock_id` values per environment (dev/staging/prod); cross-environment replay attempts **MUST** be rejected ⇒ `cross_env_replay`.
Rule 3 (**SHOULD**): For hotfixes, set short `expires_at` (days) and refresh once stabilized.
Rule 4 (**MUST**): If the Loader cannot reproduce `checker_hash` for any configured guard/kernel due to missing image/artifact, fail closed ⇒ `repro_missing_artifact`.

---
### Minimal must-fail(s) introduced in §2.8

* *EnvLockExpired*: `expires_at < now()` ⇒ `envlock_expired`.
* *CheckerHashMismatch*: receipt `checker_hash` ≠ locally computed ⇒ `checker_hash_mismatch`.
* *UpdateChainFork*: competing `UpdateCert` successors for same `from_envlock` ⇒ `envlock_chain_fork`.
* *KernelAbiUnapproved*: kernel `abi_hash` not in allowlist ⇒ `kernel_abi_unapproved`.
* *ReceiptEnvlockMismatch*: receipt carries different `envlock_digest` than run-start ⇒ `receipt_envlock_mismatch`.

**New schemas defined in §2.8 (canon/v1 URIs):**

* `$id: EnvLock/v1`
* `$id: EnvLockSig/v1`
* `$id: UpdateCert/v1`

**New reason codes requested in §2.8:**

* `envlock_scope_mismatch` — `lock_id` does not match intended environment.
* `envlock_sig_invalid` — detached signature invalid or unknown key.
* `allowlist_empty` — `allowlist.checker_hashes` is empty.
* `toolchain_unpinned` — missing/soft-pinned toolchain lock.
* `checker_hash_mismatch` — recomputed `checker_hash` differs from envelope.
* `update_applied_multiple` — multiple UpdateCert applications in one init.
* `envlock_chain_fork` — non-linear EnvLock chain detected.
* `checker_hash_not_allowlisted` — receipt’s checker not in allowlist.
* `kernel_abi_unapproved` — kernel ABI not authorized by EnvLock.
* `receipt_envlock_mismatch` — envelope’s `envlock_digest` ≠ run-start.
* `cross_env_replay` — attempt to replay a bundle across environments.
* `repro_missing_artifact` — reproducibility check cannot fetch required artifact.

**Required cross-ref updates (outside scope):**

* Register `EnvLock/v1`, `EnvLockSig/v1`, `UpdateCert/v1` in Appendix **B** with frozen `schema_b3` and `additionalProperties:false`.
* Ensure Ω (`#commit-path`) echoes `envlock_digest` and enforces receipt binding rules.
* Link Unknowns Guard and approximation gate to §4 via SSOT pointers where referenced above.
* Add CI checks for `receipt_envlock_mismatch`, `envlock_chain_fork`, and `toolchain_unpinned`.

---
# 3. Unified Dynamics: Hybrid Automaton  {#hybrid}

> **PILLARS (paste-once macro):** Receipts use **ReceiptEnvelope/v1**; each carries `checker_hash` that **MUST** be present in **EnvLock**; all guards operate over a content-addressed **CIV** produced before any kernel runs. <!-- ssot-pointer:receipt-canon --><!-- ssot-pointer:envlock --><!-- ssot-pointer:civ-canon -->

---
## 3.1 Formal Object: The Sirus Hybrid Automaton  {#hybrid-formal}
```jsonc
// StageCard/v1
{
  "Admits": ["HybridDecl/v1 draft", "EnvLock", "CIVContract/v1"],
  "Emits": ["HybridDecl/v1 (canonical JSON)", "FRONTIER_CROSSING_OK", "TRANSITION_OK"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#q-prime","content_b3":"b3:…"}
  ],
  "FailFast": ["ha_missing_field", "mode_invariant_violation", "flow_kernel_unpinned", "edge_guard_unpinned"],
  "Links": [{"anchor":"#delta-fr-invariants","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Normative goal.** Every run is a trace of a **priced** and **guarded** hybrid automaton. Guards decide `Q∈{ACCEPT,REJECT}`; pricing posts Δ\_fr without altering `Q` (SSOT `{ "anchor":"#q-prime","content_b3":"b3:…" }`).

**Canonical declaration.**

```jsonc
// HybridDecl/v1 (canon/v1; additionalProperties: false)
{
  "schema_id": "HybridDecl/v1",
  "schema_b3": "b3:…",
  "modes": ["AMBER","GREEN"],
  "state_type": "R^2",
  "invariants": {
    "AMBER": "||x||<=1.20",
    "GREEN": "||x||<=1.00"
  },
  "flows": {
    "AMBER": { "checker_hash": "b3:flow_amber", "abi": "ode:v1" },
    "GREEN": { "checker_hash": "b3:flow_green", "abi": "ode:v1" }
  },
  "edges": [
    {
      "edge_id": "e_GA",
      "src": "GREEN",
      "dst": "AMBER",
      "guard": { "checker_hash": "b3:guard_GA" },
      "reset_hash": "b3:R_GA",
      "policy_id": "Π_e_GA:v1"
    },
    {
      "edge_id": "e_AG",
      "src": "AMBER",
      "dst": "GREEN",
      "guard": { "checker_hash": "b3:guard_AG" },
      "reset_hash": "id",
      "policy_id": "Π_e_AG:v1"
    }
  ],
  "budgets_ref": { "anchor":"#axis-and-budgets", "content_b3":"b3:…" },
  "rank": { "signature": "ρ=v1", "tau_min_s": 0.050 }
}
```

**Rules.**

1. **Completeness (MUST).** `modes, invariants, flows, edges` are required; omission ⇒ `reason_code: ha_missing_field`.
2. **Pinning (MUST).** All `checker_hash` values **MUST** appear in **EnvLock**; otherwise `flow_kernel_unpinned` / `edge_guard_unpinned`.
3. **Invariants (MUST).** `Inv(m)` holds for all flow steps in `m`; violation ⇒ `mode_invariant_violation`.
4. **Bounded context.** Consumers operating on CIV slices **MUST** echo the `view_digest` they used within receipts’ `inputs_digest`.

**Frontier crossing (receipt).**

```jsonc
// ReceiptEnvelope/v1
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "FRONTIER_CROSSING_OK",
  "inputs_digest": "b3:{view_digest,x_pre,x_post,edge:e_GA}",
  "checker_hash": "b3:hybrid_cross_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": {
    "edge_id": "e_GA",
    "hysteresis_ok": true,
    "dwell_ok": true,
    "saltation_ok": true,
    "reset_hash": "b3:R_GA",
    "K_obs_bound": 0.032
  },
  "witness_digest": "b3:saltation_witness"
}
```

---
## 3.2 Discrete Layer: Game/Graph View  {#hybrid-discrete}
```jsonc
// StageCard/v1
{
  "Admits": ["HybridDecl/v1", "AxisCatalogEntry/v1", "BudgetVector/v1"],
  "Emits": ["Planner state-graph", "NODE_EQUIV_OK receipts", "Q-postings plan"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"}
  ],
  "FailFast": ["planner_axis_violation", "node_equiv_missing_proof"],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**

1. **State graph (MUST).** Nodes are `(m, x-bin)`; edges are legal mode switches or discretized flow steps.
2. **Objective (MUST).** Minimize **Q-cost** along paths under budgets `B`; treat **M-axes** as `max`, **S-axes** as additive (SSOT `{ "anchor":"#axis-and-budgets","content_b3":"b3:…" }`).
3. **Merges (MUST).** Any node merge requires `NODE_EQUIV_OK`; missing proof ⇒ `node_equiv_missing_proof`.

**Equivalence receipt (example).**

```jsonc
// ReceiptEnvelope/v1
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "NODE_EQUIV_OK",
  "inputs_digest": "b3:{nodeA,nodeB,partition_cert}",
  "checker_hash": "b3:equiv_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "witness_digest": "b3:partition_certificate"
}
```

---
## 3.3 Continuous Layer: Flows, Clamps, Tubes  {#hybrid-continuous}
```jsonc
// StageCard/v1
{
  "Admits": ["HybridDecl/v1", "GuardSpec/v1", "TubeSpec/v1"],
  "Emits": ["CLAMP_DWELL_OK", "TUBE_INV_OK"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"}
  ],
  "FailFast": ["dwell_breach", "saltation_cap_breach", "tube_invariant_fail"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**

1. **Flows (MUST).** Mode-specific `ẋ=f_m(x,u,t)` run under EnvLock with deterministic solvers and canonical step sizes.
2. **Clamp FSM (MUST).** Enforce hysteresis and `τ_min`; the loader emits `CLAMP_DWELL_OK` per window.
3. **Tubes (MUST).** Safe sets `T_m` with ISS/CBF checks (I12 family); violations ⇒ `tube_invariant_fail`.

**Clamp receipt (example).**

```jsonc
// ReceiptEnvelope/v1
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "CLAMP_DWELL_OK",
  "inputs_digest": "b3:{window_bucket}",
  "checker_hash": "b3:clamp_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": {
    "tau_min_s": 0.050,
    "hysteresis": { "on": 0.12, "off": 0.08, "dir": "increasing" },
    "saltation_bound": 0.05
  }
}
```

**Tube receipt (example).**

```jsonc
// ReceiptEnvelope/v1
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "TUBE_INV_OK",
  "inputs_digest": "b3:{x_segment_digest}",
  "checker_hash": "b3:iss_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "witness_digest": "b3:lyapunov_witness"
}
```

---
## 3.4 Governance as Guards (Policy → Predicates)  {#hybrid-governance}
```jsonc
// StageCard/v1
{
  "Admits": ["HybridDecl/v1 edges", "Policy bundle"],
  "Emits": ["GOV_GUARD_OK", "RejectionCerts"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["role_mismatch", "policy_version_stale"],
  "Links": [{"anchor":"#governance","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Principle (MUST).** Governance is enforced as an edge guard `G_e(x) ∧ Π_e(meta)`; it **precedes** pricing and state mutation.

**Receipt (example).**

```jsonc
// ReceiptEnvelope/v1
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "GOV_GUARD_OK",
  "inputs_digest": "b3:{edge_id:e_GA,signature_bundle}",
  "checker_hash": "b3:governance_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "witness_digest": "b3:signature_bundle"
}
```

**Must-fail fixtures (Appendix G via SSOT).**
Wrong signer role ⇒ `role_mismatch`. Stale UpdateCert ⇒ `policy_version_stale`.

---
## 3.5 Priced Frontiers & Δ\_fr Posting  {#hybrid-pricing}
```jsonc
// StageCard/v1
{
  "Admits": ["HybridDecl/v1 edges", "CBF ledger", "BudgetVector/v1"],
  "Emits": ["TRANSITION_OK", "EdgeKernelMap/v1"],
  "Guards": [
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"}
  ],
  "FailFast": ["rounding_missing", "ledger_atomicity_fail", "duplicate_txid"]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Guard-first (MUST).** Only **after** a guard `PASS` may CBF compute and post the canonical debit `Δ_fr(e,x^-,x^+)`. Approximations **MUST** be upper bounds and include `ROUNDING_RECEIPT` (SSOT `{ "anchor":"#commit-path","content_b3":"b3:…" }`).

**Transition receipt (example).**

```jsonc
// ReceiptEnvelope/v1
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "TRANSITION_OK",
  "inputs_digest": "b3:{x_before,guard_view}",
  "checker_hash": "b3:pricing_kernel_id",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": {
    "edge_id": "e_GA",
    "q_posting": { "Qfr": 0.008, "Qwork": 31 },
    "rounding_receipt_digest": "b3:relax_round"
  },
  "witness_digest": "b3:x_after"
}
```
### Edge→Pricing Kernel Map (generated artifact)  {#edge-kernel-map}

```jsonc
// EdgeKernelMap/v1 (canon/v1; additionalProperties: false)
{
  "schema_id": "EdgeKernelMap/v1",
  "schema_b3": "b3:…",
  "edges": [
    {
      "edge_id": "e_GA",
      "pricing_kernel": "b3:pricing_kernel_id",
      "axes_touched": ["Qfr","Qwork"],
      "rounding_policy": { "mode": "upper_bound", "gap_bound": 0.001 }
    },
    {
      "edge_id": "e_AG",
      "pricing_kernel": "b3:pricing_kernel_id",
      "axes_touched": ["Qfr"],
      "rounding_policy": { "mode": "exact" }
    }
  ]
}
```

**Norms.**

1. **Atomicity (MUST).** Each `axes_touched` posting appears **exactly once** in the CBF ledger.
2. **Approx gate (MUST).** If `mode!="exact"`, `TRANSITION_OK.meta.rounding_receipt_digest` is required; else `rounding_missing`.
3. **Pinning (MUST).** The `EdgeKernelMap/v1` is emitted with the hybrid declaration and pinned in the bundle manifest.

---
## 3.6 Liveness: Rank, Dwell, and TailContracts  {#hybrid-liveness}
```jsonc
// StageCard/v1
{
  "Admits": ["ρ signature", "dwell.tau_min_s", "TailContracts I11/I12/I13"],
  "Emits": ["RANK_STEP receipts", "TailReceipt bindings"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["rank_nondecreasing_without_dwell", "tail_ext_fail"]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**

1. **Rank (MUST).** `ρ` is lexicographic over: remaining obligations Σ, clamp debt, tube slack, planner residual. Each accepted step reduces `ρ` or consumes dwell budget; otherwise `rank_nondecreasing_without_dwell`.
2. **TailContracts (MUST).** Internal loops emit I11/I12/I13 witnesses; acceptance is **extensional** in tail bytes.

**Rank receipt (example).**

```jsonc
// ReceiptEnvelope/v1
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "RANK_STEP",
  "inputs_digest": "b3:{pre_state}",
  "checker_hash": "b3:rank_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": {
    "rank_before": [5,2,12,8,1],
    "rank_after":  [5,2,12,7,9]
  }
}
```

---
## 3.7 Worked Mini-Example (2 Modes, 2 Edges)  {#hybrid-example}
```jsonc
// StageCard/v1
{
  "Admits": ["HybridDecl/v1", "EdgeKernelMap/v1", "BudgetVector/v1"],
  "Emits": ["Chronological receipt list", "Ω acceptance with q≤B"],
  "Guards": [
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ],
  "FailFast": ["dwell_breach", "role_mismatch"]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Chronology (canonical).**

1. `CANON_INPUT_VIEW` (Unknowns Guard PASS).
2. `GOV_GUARD_OK` for `e_GA`.
3. `FRONTIER_CROSSING_OK` (`hysteresis_ok`, `saltation_ok`, `dwell_ok`).
4. `TRANSITION_OK` (Δ\_fr posting; `rounding_receipt_digest` if approx).
5. `CLAMP_DWELL_OK` (window).
6. **Tripwires:** `GOV_GUARD_FAIL` (`role_mismatch`) and `DWELL_BOUND_FAIL` (`dwell_breach`).
7. `Ω` finalizes (`q_final ≤ B`; `proof_surface` pins all digests).

*(Full artifacts live in Appendix D via SSOT pointer.)*

---
## 3.8 Author To-Dos (before publish)  {#hybrid-todos}
```jsonc
// StageCard/v1
{
  "Admits": ["Author checklist items"],
  "Emits": ["Pinned checker hashes", "EdgeKernelMap/v1", "2-mode fixture"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"}
  ],
  "FailFast": ["rounding_missing", "node_equiv_missing_proof"]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Checklist (normative).**

1. Emit `HybridDecl/v1` + diagram (`docs/img/hybrid_automaton.svg`) with `schema_b3` pinned.
2. Pin `checker_hash` for flows, guards, governance, pricing.
3. Generate and pin **EdgeKernelMap/v1**.
4. Provide the 2-mode mini-example with a passing path plus **two** negatives (`role_mismatch`, `dwell_breach`).
5. Cross-link Δ\_fr axioms and governance vocabulary via SSOT pointers (no prose restatements).
6. Exercise the approximation hard gate (`rounding_missing`) in CI.

---
### Minimal must-fail(s) introduced in §3

* *HAMissingField* — Hybrid declaration missing a required key ⇒ `ha_missing_field`.
* *FlowKernelUnpinned* — flow `checker_hash` not in EnvLock ⇒ `flow_kernel_unpinned`.
* *EdgeGuardUnpinned* — guard `checker_hash` not in EnvLock ⇒ `edge_guard_unpinned`.
* *ModeInvariantViolation* — numerical step violates `Inv(m)` ⇒ `mode_invariant_violation`.
* *NodeEquivMissingProof* — merged nodes lack `NODE_EQUIV_OK` ⇒ `node_equiv_missing_proof`.
* *TubeInvariantFail* — segment exits `T_m` without TailReceipt ⇒ `tube_invariant_fail`.
* *RankNonDecreasingWithoutDwell* — `ρ` fails to decrease and no dwell consumption ⇒ `rank_nondecreasing_without_dwell`.
* *RoundingMissing* — approx kernel transition without rounding receipt ⇒ `rounding_missing`.

**New schemas defined in §3 (canon/v1 URIs):**
`$id: HybridDecl/v1`, `$id: EdgeKernelMap/v1`, `$id: TubeSpec/v1` (field set referenced), *(all with `additionalProperties: false`)*.

**New reason codes requested in §3:**
`ha_missing_field` — HybridDecl missing a required key.
`flow_kernel_unpinned` — flow checker not authorized in EnvLock.
`edge_guard_unpinned` — guard checker not authorized in EnvLock.
`mode_invariant_violation` — state violates mode invariant.
`node_equiv_missing_proof` — node merge lacks proof receipt.
`tube_invariant_fail` — tube/invariant check failed.
`rank_nondecreasing_without_dwell` — rank did not decrease and dwell not consumed.

**Required cross-ref updates (outside scope):**

* Appendix **B**: register schemas for `HybridDecl/v1`, `EdgeKernelMap/v1`, `TubeSpec/v1` with frozen `schema_b3` and `additionalProperties:false`.
* §5 (**Δ\_fr**): ensure axioms and approximation gate anchor match the references here.
* §9 (**Governance**): publish role vocabulary and UpdateCert semantics for `policy_version_stale`.

---
# 4. Evidence, Guards, and Receipts {#evidence}

> **What you’ll learn:** the canonical evidence model, the guard-first path over *Canonical Input Views (CIVs)*, the Unknowns guard contract, kernel/rounding receipts, and the bundle manifest ⇢ Merkle rules.
> **What you’ll do:** produce canonical receipts for a toy transition, build an evidence bundle and Merkle root per the normative construction, and exercise the Unknowns guard with a failing fixture.
> **How to verify:** run the evidence collector on the toy trace in Appendix D and recompute the bundle Merkle root; confirm Ω includes `q_final`, `budget_vector`, a matching `proof_surface`, and echoes the **portability\_stance**.

---
## 4.0 The Three Pillars (SSOT, pinned at top of §4)
```jsonc
// StageCard/v1
{
  "Admits": ["EnvLock", "ReceiptEnvelope/v1", "CIVContract/v1"],
  "Emits": ["PILLARS macro", "Pillars mini-schema"],
  "Guards": [
    {"anchor":"#envlock","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"}
  ],
  "FailFast": ["pillars_missing_on_first_mention", "pillars_pasted_multiple_times"],
  "Links": [{"anchor":"#ssot-dedup-impl","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```
PILLARS := ( EnvLock ⇄ Receipts ⇄ CIV )
where
  EnvLock pins a set of authorized checker_hash values,
  Receipts are all ReceiptEnvelope/v1 with (predicate_id, inputs_digest, checker_hash, envlock_digest, verdict, …),
  CIV is the Canonical Input View that guards produce and downstream adapters consume.
```

**Reusable one-liner macro (paste once per subsection after the first receipt/CIV mention):**
**PILLARS:** Receipts use **ReceiptEnvelope/v1**; each carries `checker_hash` that **MUST** be present in **EnvLock**; all guards operate over a content-addressed **CIV** produced before any kernel runs.

---
## 4.1 Evidence–Environment Binding (normative)
```jsonc
// StageCard/v1
{
  "Admits": ["EnvLock", "ReceiptEnvelope/v1"],
  "Emits": ["Binding tuple (checker_hash, envlock_digest)", "Ω echo of portability_stance"],
  "Guards": [{"anchor":"#envlock","content_b3":"b3:…"}],
  "FailFast": ["envlock_mismatch", "un-pinned_checker", "portability_echo_missing"],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Binding tuple (normative).** Every receipt is meaningful only under the exact code+environment that produced it. The pair `(checker_hash, envlock_digest)` **MUST** appear in each **ReceiptEnvelope/v1**; Ω **REJECTS** any bundle containing a receipt whose `checker_hash ∉ EnvLock.allowlist` (`reason_code: un-pinned_checker`) or whose `envlock_digest` ≠ the active lock at run start (`reason_code: envlock_mismatch`). The **portability\_stance** pinned in EnvLock **MUST** be echoed into `SurfaceV1.json` and the `OMEGA` receipt; absence ⇒ `reason_code: portability_echo_missing`.

> SSOT pointers: `{ "anchor":"#envlock","content_b3":"b3:…" }`, `{ "anchor":"#receipt-canon","content_b3":"b3:…" }`.

**Loader invariants (enforced).**

1. Recompute `checker_hash`; require `checker_hash ∈ EnvLock.allowlist`.
2. Require `envlock_digest` equality to the active EnvLock.
3. Echo `portability_stance` into both the surface and `OMEGA.meta.portability_stance`; if stance = **Strong**, CI **MUST** cross-replay on the allowed platform set (SSOT pointer to CI rules in §10).

**Example (attestation receipt).**

```jsonc
// ReceiptEnvelope/v1 — ENV_ATTEST_OK (PASS)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "ENV_ATTEST_OK",
  "inputs_digest": "b3:envlock|axis_catalog|policy_digests",
  "checker_hash": "b3:ef_attest_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": { "portability_stance": "Strong" }
}
```

---
## 4.2 Guard Sequence & Canonical Input Views (CIV) {#guard-sequence-civ}
```jsonc
// StageCard/v1
{
  "Admits": ["Observations", "GuardSpec/v1", "CIVContract/v1"],
  "Emits": ["CANON_INPUT_VIEW receipt", "CIV bytes + view_digest"],
  "Guards": [
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"}
  ],
  "FailFast": ["civ_minimality_violation", "missing_civ_receipt"],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Guard-first discipline.** Guards validate and canonicalize inputs into minimal, content-addressed CIVs **before any kernel runs**. Minimality and content addressing **MUST** hold (`reason_code: civ_minimality_violation`).

**CIV Contract (adapter boundary, SSOT).** Adapters **MUST** accept the following field set verbatim (canonical home via `{ "anchor":"#civ-canon","content_b3":"b3:…" }`):

```jsonc
// CIVContract/v1 (consumed by adapters)
{
  "schema_id": "CIVContract/v1",
  "schema_b3": "b3:…",
  "created": "2025-09-15T12:00:00Z",
  "schema_tag": "CIV/v1",
  "source": "transport_pack",
  "axis_whitelist": ["Qfr","Qwork"],
  "view_digest": "b3:…"
}
```

**Required receipt.**

```jsonc
// ReceiptEnvelope/v1 — CANON_INPUT_VIEW
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "CANON_INPUT_VIEW",
  "inputs_digest": "b3:civ_bytes",
  "checker_hash": "b3:civ_guard_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": { "view_digest": "b3:…" }
}
```

---
## 4.2.2 Unknowns Guard (normative) {#unknowns}
```jsonc
// StageCard/v1
{
  "Admits": ["CIV slice", "AxisCatalog/v1 (priced flags)"],
  "Emits": ["C_UNK_PRICED receipt (FAIL)", "Omega-unk_budget-v1.jsonl line"],
  "Guards": [{"anchor":"#unknowns-guard","content_b3":"b3:…"}],
  "FailFast": ["unknowns_sidecar_misnamed"],
  "Links": [
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#axis-and-budgets","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules (priced axes).** On encountering `⊥` for **any priced axis**, the Unknowns Guard **MUST**:

1. Emit `C_UNK_PRICED` (`verdict=FAIL`) for the current row,
2. Append exactly one `UnknownPricedAxisEvent/v1` line to `Omega-unk_budget-v1.jsonl` (name is normative; misname ⇒ `reason_code: unknowns_sidecar_misnamed`),
3. **Stop processing the current row** and continue with the next.

Policy determines behavior for **unpriced** axes (SSOT pointer above).

**Receipt stub (envelope only).**

```jsonc
// ReceiptEnvelope/v1 — C_UNK_PRICED (FAIL)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "C_UNK_PRICED",
  "inputs_digest": "b3:frontier_row_digest",
  "checker_hash": "b3:unknowns_guard_checker",
  "envlock_digest": "b3:…",
  "verdict": "FAIL",
  "meta": { "axis": "Qfr", "row_id": "r-182" }
}
```

---
## 4.3 Receipt Canon (uniform envelope) {#receipt-canon}
```jsonc
// StageCard/v1
{
  "Admits": ["ReceiptEnvelope/v1"],
  "Emits": ["Uniform envelope rule", "PASS/FAIL as Merkle leaves"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["variant_envelope_detected", "un-pinned_checker"]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rule (single envelope).** All receipts **MUST** use **ReceiptEnvelope/v1** with keys:
`predicate_id, inputs_digest, checker_hash, envlock_digest, verdict, (optional) witness_digest, (optional) meta`. **No variant envelopes are permitted** (`reason_code: variant_envelope_detected`). All PASS/FAIL receipts are Merkle leaves in the evidence bundle. Loader **REJECTS** any receipt whose `checker_hash` is not pinned (`un-pinned_checker`).

---
## 4.5 Kernel Receipts, Approximations & RoundingReceipt {#kernel-rounding}
```jsonc
// StageCard/v1
{
  "Admits": ["Kernel outputs", "Approximation mode flag"],
  "Emits": ["ROUNDING_RECEIPT (PASS)", "TRANSITION_OK (PASS) with digest binding"],
  "Guards": [{"anchor":"#delta-fr-invariants","content_b3":"b3:…"}],
  "FailFast": ["rounding_missing", "round_upper_bound_false"]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Allowance (sound upper bounds).** Exact `Δ_fr` can be NP-hard; **sound upper-bounding approximations are permitted** **only** with a `ROUNDING_RECEIPT` certifying `upper_bound=true` and a numeric `gap_bound ≥ 0`. When a kernel **advertises approximation**, a `TRANSITION_OK` **MUST** include `meta.rounding_receipt_digest` referencing that receipt; omission ⇒ `reason_code: rounding_missing`. A `ROUNDING_RECEIPT` with `upper_bound=false` is invalid ⇒ `reason_code: round_upper_bound_false`.

**Receipts (field sketches; schemas via SSOT Appendix B).**

```jsonc
// ReceiptEnvelope/v1 — ROUNDING_RECEIPT (PASS)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "ROUNDING_RECEIPT",
  "inputs_digest": "b3:pricing_context_digest",
  "checker_hash": "b3:rounding_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": { "upper_bound": true, "gap_bound": 0.001 }
}
```

```jsonc
// ReceiptEnvelope/v1 — TRANSITION_OK (PASS; approximation advertised)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "TRANSITION_OK",
  "inputs_digest": "b3:{x_before,guard_view}",
  "checker_hash": "b3:pricing_kernel_id",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": {
    "edge_id": "e_GA",
    "q_posting": { "Qfr": 0.008, "Qwork": 31 },
    "rounding_receipt_digest": "b3:relax_round"
  },
  "witness_digest": "b3:x_after"
}
```

> SSOT pointer to **EdgeKernelMap/v1** for edge→kernel/axes/rounding policy: `{ "anchor":"#edge-kernel-map","content_b3":"b3:…" }`.

---
## 4.6 Bundle Manifest & Merkle Root (evidence pack) {#bundle-manifest}
```jsonc
// StageCard/v1
{
  "Admits": ["Manifest bytes", "Evidence artifacts (ordered)"],
  "Emits": ["Deterministic manifest", "Merkle root (b3:…)", "Ω failure codes"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": ["MERKLE_MISMATCH", "BUNDLE_INCOMPLETE", "TAIL_EXT_FAIL"]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Bundle shape.** The Evidence Bundle is an append-only ledger of receipts and canonical artifacts. Its canonical preimage is the **Bundle Manifest**, which lists entries in **exact execution order** and carries a deterministic `merkle_root`. Ω embeds that root in `SurfaceV1.json` and the `OMEGA` receipt.

**Canonical Merkle construction (BLAKE3-256).**
Leaf: `BLAKE3(0x00 || leaf_bytes)` · Node: `BLAKE3(0x01 || left || right)`; odd nodes duplicate the lone child (`right := left`). Root encoding is `b3:<lowercase hex of 32-byte node_hash>`. Deterministic order = **manifest order**.

**Fixture & CI (mandatory).**

* Recompute the fixture manifest root; mismatch ⇒ `MERKLE_MISMATCH`.
* Missing required artifact ⇒ `BUNDLE_INCOMPLETE`.
* Tail extensionality violation ⇒ `TAIL_EXT_FAIL`.
  (SSOT pointer: `{ "anchor":"#commit-path","content_b3":"b3:…" }`.)

**Manifest shape (canon).**

```jsonc
// BundleManifest/v1
{
  "schema_id": "BundleManifest/v1",
  "schema_b3": "b3:…",
  "merkle_root": "b3:…",
  "artifacts": [
    { "name": "receipts/0001.jsonl", "digest": "b3:…" },
    { "name": "Omega-unk_budget-v1.jsonl", "digest": "b3:…" },
    { "name": "tails/I11/…", "digest": "b3:…" }
  ]
}
```

---
## 4.7 Must-fail Library (negative controls) {#must-fail}
```jsonc
// StageCard/v1
{
  "Admits": ["Minimal fixtures exercising guard/loader/Ω failure paths"],
  "Emits": ["Deterministic FAIL receipts & Ω codes"],
  "Guards": [
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"}
  ],
  "FailFast": ["silent_accept_regression"]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Required negatives (CI-enforced).**

1. **Priced unknowns** → `C_UNK_PRICED` (this section).
2. **Approx advertised but missing rounding** → `rounding_missing`.
3. **Governance guard wrong-signer / stale policy** → `GOV_GUARD_FAIL`, `POLICY_VERSION_STALE` (SSOT to §3 / Appendix G).
4. **Dwell violation (loader)** → `DWELL_BOUND_FAIL` (SSOT to §3).
5. **Ω failures** → `MERKLE_MISMATCH`, `BUNDLE_INCOMPLETE`, `TAIL_EXT_FAIL` (this section).

Each fixture is tiny, deterministic, and asserts the stated `reason_code`. CI **MUST** fail on any **silent acceptance** (`reason_code: silent_accept_regression`).

---
## 4.8 Receipt Quick-Reference (cheat sheet)
```jsonc
// StageCard/v1
{
  "Admits": ["Predicate registry view"],
  "Emits": ["Tabular summary of predicate_id → purpose/fields"],
  "Guards": [{"anchor":"#predicate-registry","content_b3":"b3:…"}],
  "FailFast": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

| predicate\_id      |  Stage |  verdict  | purpose                              | primary fields                                                                             |
| ------------------ | :----: | :-------: | ------------------------------------ | ------------------------------------------------------------------------------------------ |
| CANON\_INPUT\_VIEW | EF/DRO | PASS/FAIL | CIV produced                         | `meta.view_digest`                                                                         |
| C\_UNK\_PRICED     |   PR   |    FAIL   | Unknown priced axis                  | `meta.axis`, `meta.row_id`                                                                 |
| TRANSITION\_OK     |   PR   |    PASS   | Kernel success & q\_posting          | `meta.q_posting`, `witness_digest`, `meta.rounding_receipt_digest?`                        |
| ROUNDING\_RECEIPT  |   PR   |    PASS   | Certified conservative approximation | `meta.upper_bound`, `meta.gap_bound`                                                       |
| CLAMP\_DWELL\_OK   |   PR   |    PASS   | Loader-enforced dwell / no-Zeno      | `meta.tau_min_s`, `meta.hysteresis`, `meta.saltation_bound`                                |
| OMEGA              |    Ω   | PASS/FAIL | Final budget & bundle check          | `meta.q_final`, `meta.budget_vector`, `meta.bundle_merkle_root`, `meta.portability_stance` |

*(Full registry and schemas live in Appendix B — link via SSOT pointer above.)*

---
### Editorial/Process note (CI Gate 0)
```jsonc
// StageCard/v1
{
  "Admits": ["Final QA checklist (anchor in §10)"],
  "Emits": ["Gate 0 promotion blocking new specid / Ω acceptance"],
  "Guards": [{"anchor":"#verification","content_b3":"b3:…"}],
  "FailFast": ["ci_stagecard_missing", "ci_ssot_pointer_stale", "ci_receipt_schema_b3", "ci_negatives", "ci_no_free_reason_text"]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

Before assigning a fresh `specid` or allowing Ω to accept a run under this spec, the **Final QA Checklist** (anchor in §10) is promoted to **CI Gate 0**: anchor integrity checks, duplicate-schema scan, JSON example lints, Merkle fixture check, and SSOT one-liner enforcement **MUST pass** or the build is rejected.

---
### Minimal must-fail(s) introduced in §4

* *PricedUnknownsRow* — CIV row contains `⊥` on a priced axis ⇒ `C_UNK_PRICED`.
* *ApproxRoundingMissing* — kernel advertises approximation but `TRANSITION_OK.meta.rounding_receipt_digest` absent ⇒ `rounding_missing`.
* *MerkleMismatchFixture* — manifest/root disagree ⇒ `MERKLE_MISMATCH`.
* *BundleIncompleteFixture* — missing required artifact in manifest ⇒ `BUNDLE_INCOMPLETE`.
* *TailExtensionalityBreach* — tail bytes not extensionally bound ⇒ `TAIL_EXT_FAIL`.
* *PortabilityEchoMissing* — Ω surface or OMEGA receipt missing stance ⇒ `portability_echo_missing`.
* *VariantEnvelopeDetected* — non-ReceiptEnvelope/v1 format encountered ⇒ `variant_envelope_detected`.

**New schemas defined:** *None* (all schemas referenced via SSOT to Appendix B).
**New reason codes requested:**

* `un-pinned_checker` — `checker_hash` not present in EnvLock allowlist.
* `portability_echo_missing` — Ω failed to echo `portability_stance`.
* `civ_minimality_violation` — CIV not minimal/content-addressed as required.
* `round_upper_bound_false` — ROUNDING\_RECEIPT did not assert `upper_bound=true`.
* `silent_accept_regression` — CI detected a must-fail fixture that passed.
* `variant_envelope_detected` — Receipt envelope not `ReceiptEnvelope/v1`.

**Required cross-ref updates (outside scope):**

* Appendix **B**: ensure `$id` and `schema_b3` are frozen for `ReceiptEnvelope/v1`, `CIVContract/v1`, `UnknownPricedAxisEvent/v1`, `BundleManifest/v1`.
* §10 Verification: include Gate 0 checks (`ci_*` enumerants above).
* §3 Governance / Appendix G: maintain negatives `GOV_GUARD_FAIL`, `POLICY_VERSION_STALE`.
* Add SSOT anchor for **EdgeKernelMap/v1** `{ "anchor":"#edge-kernel-map","content_b3":"b3:…" }` and bind from §5.

<!-- :contentReference[oaicite:0]{index=0} -->

---
# 5. Frontier Debit (Δ\_fr) {#frontier-debit}

> **PILLARS:** Receipts use **ReceiptEnvelope/v1**; each carries `checker_hash` that **MUST** be present in **EnvLock**; all guards operate over a content-addressed **CIV** produced before any kernel runs. <!-- ssot-pointer:receipt-canon --><!-- ssot-pointer:envlock --><!-- ssot-pointer:civ-canon -->

---
## 5.1 Objects & Notation {#deltafr-objects}
```jsonc
// StageCard/v1
{
  "Admits": ["Account catalog", "Axis/budget digests", "Ledger tip state (t)", "CIV slice for Δ_fr"],
  "Emits": ["Normalized transaction inputs", "txid", "Block-level identifiers"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"}
  ],
  "FailFast": ["unknown_account", "unit_mismatch", "noncanonical_numbers"],
  "Links": [
    {"anchor":"#axis-and-budgets","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Definitions (canonical).**

* **Account** — named bucket with type/policy (e.g., `budget/teamA`, `escrow/policy`, `fees/system`).
* **Balance** — `Bal_t(A)`: balance of `A` after block height `t`.
* **Entry** — `e = (account, amt)` with fixed precision amount.
* **Transaction** — ordered set `T = {e₁,…,e_k}` + metadata (author, evidence, memo).
* **Block** — committed unit with header linking to previous tip.
* **Ledger** — append-only sequence `L = (B₁,…,B_t)`; tip at height `t`.
* **Bundle** — submission artifact to **CBF**: `{ T, evidence, guard_params }`.

**Content addressing (normative).**
`txid := BLAKE3_256(canon_json(TransactionSpec/v1))` with RFC8785/JCS canonicalization.
`blockid := BLAKE3_256(BlockHeader/v1)`; Merkle over `txid`s uses the single recipe at `{ "anchor":"#commit-path","content_b3":"b3:…" }`.
`receipt_ref := BLAKE3_256(ReceiptEnvelope/v1)`.

**Rules.**

1. All numeric amounts **MUST** be encoded as fixed-scale strings; noncanonical numbers ⇒ `reason_code: noncanonical_numbers`.
2. Unknown account identifiers **MUST** reject (`unknown_account`).
3. Unit/domain mismatches **MUST** reject (`unit_mismatch`).

---
## 5.2 TransactionSpec/v1 and Normalization {#deltafr-txspec}
```jsonc
// StageCard/v1
{
  "Admits": ["Author-submitted TransactionSpec/v1 (bytes)", "EnvLock", "Axis/budget policy digests"],
  "Emits": ["Canonicalized TransactionSpec/v1", "Normalization witness", "txid"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": [
    "txschema_missing_field",
    "txschema_extra_field",
    "fee_missing",
    "rounding_missing",
    "noncanonical_numbers"
  ],
  "Links": [
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Schema (canon/v1; `additionalProperties: false`).**

```jsonc
// $id: TransactionSpec/v1  (canon/v1)
{
  "schema_id": "TransactionSpec/v1",
  "schema_b3": "b3:…",
  "unit": "credits.v1",
  "entries": [ { "account": "…", "amt": "…" } ],
  "rounding_adjustment": { "account": "fees/rounding", "amt": "0.00" },
  "fee": { "account": "fees/system", "amt": "0.00" },
  "memo": "…",
  "evidence": { "anchor": "#receipt-envelope", "ref": "b3:…" },
  "policy_version": "budget/1.3.0",
  "author_id": "did:…",
  "auth_signature": "sig:…"
}
```

**Normalization rules (MUST).**

1. **Presence.** `fee` and `rounding_adjustment` **MUST** exist even if `"0.00"`; absence ⇒ `fee_missing` / `rounding_missing`.
2. **Fixed precision.** All `amt` values **MUST** conform to the domain’s fixed scale; any implicit rounding is **forbidden**.
3. **Canonicalization.** Apply RFC8785/JCS (sorted keys, decimals normalized, numeric strings).
4. **Zero-sum post-normalization.** Treat `fee` and `rounding_adjustment` as entries for conservation (see §5.3).

**Bounded-context rule.** Consumers that operate on a CIV slice **MUST** echo `view_digest` in any submission envelope (SSOT: `{ "anchor":"#civ-canon","content_b3":"b3:…" }`).

---
## 5.3 Δ\_fr Invariants (Normative) {#delta-fr-invariants}
```jsonc
// StageCard/v1
{
  "Admits": ["Canonical TransactionSpec/v1", "Pre-state balances at tip", "Policy/budget digests"],
  "Emits": ["Q ∈ {ACCEPT, REJECT}", "Q′ (with receipt_ref)", "Invariant receipts"],
  "Guards": [
    {"anchor":"#q-prime","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"}
  ],
  "FailFast": [
    "non_conservative",
    "duplicate_txid",
    "atomicity_not_guaranteed",
    "immutable_history",
    "auth_failure",
    "unauthorized_account",
    "policy_violation",
    "budget_exceeded"
  ],
  "Links": [
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**I — Conservation (MUST).** After normalization (entries + fee + rounding), `Σ amt(e) = 0`. Violation ⇒ `non_conservative`.
**II — Uniqueness (MUST).** Each `txid` may commit **at most once**; replays ⇒ `duplicate_txid`.
**III — Atomicity (MUST).** Budget/policy validation and append occur **indivisibly** per transaction; partial application ⇒ `atomicity_not_guaranteed` (detail may include `budget_exceeded`, `policy_violation`).
**IV — Immutability (MUST).** History is append-only; corrections use compensating transactions; mutation attempts ⇒ `immutable_history`.
**Authz (MUST).** `author_id` + `auth_signature` must verify under active policy; failures ⇒ `auth_failure` / `unauthorized_account`.
**Evidence binding (MUST).** On `ACCEPT`, emit `CBF_LEDGER_POST` binding `{txid, blockid, pre/post balance digests, checker_hash, receipt_ref}`; on `REJECT`, emit `CBF_LEDGER_FAIL` with an enumerated `reason_code`.

---
## 5.4 Normative Commit Path (9 steps) {#commit-path}
```jsonc
// StageCard/v1
{
  "Admits": ["TransactionSpec/v1 bytes", "EnvLock", "Budget/policy digests", "Ledger tip header"],
  "Emits": ["txid", "blockid", "CBF_LEDGER_POST|FAIL receipts", "Q′ result"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": [
    "txschema_missing_field",
    "non_conservative",
    "duplicate_txid",
    "policy_violation",
    "budget_exceeded",
    "atomicity_not_guaranteed",
    "merkle_mismatch"
  ],
  "Links": [
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**The only commit sequence (MUST).**

1. Load bytes; canonicalize **TransactionSpec/v1**.
2. Static-validate schema, fixed-precision, required fields.
3. Normalize (inject fee & rounding entries).
4. Compute `txid`.
5. **Budget Guard:** evaluate `{pre_balances, policies, T, guard_params}` under EnvLock.
6. **Atomic Append** iff `Q=ACCEPT`.
7. Compute `blockid` with prev-tip + Merkle of txids (recipe at §0.6 via SSOT).
8. Emit receipt(s): success ⇒ `CBF_LEDGER_POST`; failure ⇒ `CBF_LEDGER_FAIL`.
9. Return `Q′` with `receipt_ref`. Projection law: `π(Q′)=Q` (SSOT `{ "anchor":"#q-prime","content_b3":"b3:…" }`).

**Edge→Pricing linkage (MUST).** If the transaction originates from a priced frontier transition, **CBF** **MUST** verify:
(a) a `TRANSITION_OK` exists whose `edge_id` is mapped in `EdgeKernelMap/v1` (SSOT pointer),
(b) axes posted match `axes_touched`, and
(c) if the kernel advertised approximation, `meta.rounding_receipt_digest` is present (`rounding_missing` otherwise).

---
## 5.5 Budget Guard Semantics {#budget-guard}
```jsonc
// StageCard/v1
{
  "Admits": ["Balances at tip", "Policy/budget digests", "Normalized T", "guard_params"],
  "Emits": ["Q ∈ {ACCEPT, REJECT}", "CBF_BUDGET_CHECK(OK|FAIL)", "CBF_LEDGER_POST|FAIL"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": [
    "budget_exceeded",
    "policy_violation",
    "duplicate_txid",
    "non_conservative",
    "rounding_missing"
  ],
  "Links": [
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules (MUST).**

1. Decision is **binary**: `Q ∈ {ACCEPT, REJECT}`; no provisional state.
2. Guard executes under EnvLock with canonical inputs; irrelevant field orderings must not change `Q` or `receipt_ref`.
3. Rows halted by priced-unknowns (`C_UNK_PRICED`) **MUST NOT** reach pricing/ledger (SSOT `{ "anchor":"#unknowns-guard","content_b3":"b3:…" }`).
4. On `ACCEPT`, emit `CBF_LEDGER_POST` with `{txid, blockid, pre/post balance digests, policy digests, checker_hash, receipt_ref}`.
5. On `REJECT`, emit `CBF_LEDGER_FAIL` with `reason_code ∈ { non_conservative, duplicate_txid, atomicity_not_guaranteed, immutable_history, auth_failure, policy_violation, budget_exceeded, rounding_missing }`.

**Receipt example (canonical).**

```jsonc
// ReceiptEnvelope/v1 — CBF_LEDGER_POST (success)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "CBF_LEDGER_POST",
  "inputs_digest": "b3:{txid|pre_bal_digest|post_bal_digest}",
  "checker_hash": "b3:cbf_guard_v2",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": {
    "txid": "b3:…",
    "blockid": "b3:…",
    "policy_digests": ["b3:…"]
  }
}
```

---
## 5.6 Minimal Interfaces (Author Uses) {#deltafr-interfaces}
```jsonc
// StageCard/v1
{
  "Admits": ["Author intent to post a transaction"],
  "Emits": ["TransactionSpec/v1 bytes", "Evidence reference", "Q′ result"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["txschema_missing_field", "non_conservative", "auth_failure"],
  "Links": [
    {"anchor":"#commit-path","content_b3":"b3:…"},
    {"anchor":"#q-prime","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**TransactionSpec/v1 (example body).**

```jsonc
{
  "schema_id": "TransactionSpec/v1",
  "schema_b3": "b3:…",
  "unit": "credits.v1",
  "entries": [
    { "account": "budget/teamA", "amt": "-12.50" },
    { "account": "vendor/acme",  "amt": "12.50" }
  ],
  "rounding_adjustment": { "account": "fees/rounding", "amt": "0.00" },
  "fee": { "account": "fees/system", "amt": "0.00" },
  "memo": "PO-4312",
  "evidence": { "anchor": "#receipt-envelope", "ref": "b3:…" },
  "policy_version": "budget/1.3.0",
  "author_id": "did:teamA:signer1",
  "auth_signature": "sig:…"
}
```

**Result contract (Q′).** Implementations **MUST** return `Q′` with `receipt_ref` on both PASS/FAIL paths; `π(Q′)=Q` (SSOT `{ "anchor":"#q-prime","content_b3":"b3:…" }`).

---
## 5.7 Tests & CI (Executable Invariants) {#deltafr-tests}
```jsonc
// StageCard/v1
{
  "Admits": ["Fixtures for normalization, MVCC races, replay, edge→pricing, Merkle"],
  "Emits": ["CI gates", "Golden receipts", "Determinism proofs"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": [
    "non_conservative",
    "atomicity_not_guaranteed",
    "duplicate_txid",
    "receipt_ref_mismatch",
    "MERKLE_MISMATCH",
    "rounding_missing"
  ],
  "Links": [
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**CI gates (normative).**

A. **Zero-sum proof** (`ci_tx_schema_strict` + `ci_deltafr_cov`) → enforce fee/rounding presence; Σ entries = 0; fail ⇒ `non_conservative`.
B. **MVCC atomicity race** (`ci_mvcc_race_atomicity`) → parallel spends; exactly one `ACCEPT`; loser ⇒ `atomicity_not_guaranteed/budget_exceeded`.
C. **Replay proof** (`ci_replay_proof`) → fixed EnvLock; re-run must reproduce balances & `receipt_ref` byte-for-byte; mismatch ⇒ `receipt_ref_mismatch`.
D. **Determinism harness** → permute irrelevant input field orders; `receipt_ref` must be identical.
E. **Edge→Pricing fixture** (`ci_edge_kernel_map_consistency`) → verify `TRANSITION_OK` postings; if approx advertised, require `ROUNDING_RECEIPT` digest; else `rounding_missing`.
F. **Block Merkle fixture** (`ci_block_merkle_fixture`) → recompute root; mismatch ⇒ `MERKLE_MISMATCH`.

---
## 5.8 Negative Controls (Must-Fail) {#deltafr-negatives}
```jsonc
// StageCard/v1
{
  "Admits": ["Small counterexamples exercising §5 rules"],
  "Emits": ["Expected FAIL receipts with reason_code"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": [],
  "Links": [{"anchor":"#delta-fr-invariants","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

1. **Latent rounding** — omit `rounding_adjustment` → schema reject (`fee_missing`/`rounding_missing`).
2. **Hidden fees** — apply implicit fee not modeled as entry → `non_conservative`.
3. **Double-spend attempt** — re-post same canonical body → `duplicate_txid`.
4. **Partial commit** — inject failure after budget success but before append → framework must roll back; if not, `atomicity_not_guaranteed`.
5. **History tamper** — mutate prior block bytes → `immutable_history`.
6. **Unpinned checker** — receipt `checker_hash ∉ EnvLock` → Ω-level reject (SSOT `{ "anchor":"#envlock","content_b3":"b3:…" }`).
7. **Approximation without witness** — kernel advertises approximation but `TRANSITION_OK.meta.rounding_receipt_digest` absent → `rounding_missing`.
8. **Block Merkle mismatch** — header root does not match recomputation → `MERKLE_MISMATCH`.
9. **Tail extensionality breach (Ω)** — finalization detects tail-contract violation → `TAIL_EXT_FAIL`.

---
## 5.9 Author To-Dos (Concise) {#deltafr-todos}
```jsonc
// StageCard/v1
{
  "Admits": ["Author checklist intentions"],
  "Emits": ["Strict JSON Schema for TransactionSpec/v1", "Fixtures & CI wiring"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": ["todo_missing_negatives"],
  "Links": [
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Checklist (normative).**

* Publish **TransactionSpec/v1** JSON Schema (canon/v1, `additionalProperties: false`) including mandatory `fee` and `rounding_adjustment`.
* Ship fixtures: `mvcc_race_01`, `replay_golden_01`, `edge_kernel_map_consistency_01`, `block_merkle_fixture_01`.
* Wire `ci_replay_proof` as a **blocking** gate.
* Replace any other commit narratives with a link to **§5.4** (SSOT-only).
* Ensure Unknowns Guard halts priced rows **before** Δ\_fr (SSOT `{ "anchor":"#unknowns-guard","content_b3":"b3:…" }`).

---
### Minimal must-fail(s) introduced in §5

* *ZeroSumViolation* — post-normalization sum ≠ 0 ⇒ `non_conservative`.
* *ReplayDuplicate* — `txid` seen before ⇒ `duplicate_txid`.
* *AtomicityRace* — concurrent spends; loser ⇒ `atomicity_not_guaranteed`.
* *SchemaMissingFee* — missing `fee` or `rounding_adjustment` ⇒ `fee_missing` / `rounding_missing`.
* *ApproxWitnessMissing* — approx kernel without rounding witness ⇒ `rounding_missing`.
* *MerkleHeaderMismatch* — recomputed root differs ⇒ `MERKLE_MISMATCH`.

**New schemas defined:**

* `$id: TransactionSpec/v1` (canon/v1; `additionalProperties: false`).

**New reason codes requested:**

* `txschema_missing_field` — required field absent in TransactionSpec.
* `txschema_extra_field` — extra field present (violates `additionalProperties: false`).
* `fee_missing` — `fee` field absent.
* `noncanonical_numbers` — numbers not encoded as fixed-scale strings.

**Required cross-ref updates (outside scope):**

* Register **TransactionSpec/v1** in Appendix B with frozen `schema_b3`.
* Ensure §0.6 Merkle recipe anchor and §3.5 `EdgeKernelMap/v1` anchors are published with stable `content_b3`.
* Verify Appendix G includes the must-fail fixtures named above.

---
# 6. The Generative / Inversion Layer (GMM) {#gmm}

> **Learn.** GMM turns pinned context into **deterministic proposals and actions**. `Actor` proposes; `Scorer` scores; `Committer` binds outcomes. **All** entropy is HKDF-derived and receipted; **no hidden RNG** is allowed.
> **Do.** Emit `ProposalSpec/v1`; derive seeds per **authorized** domain; enforce **context-binding** (`proposal.context_digest == scorer.context_digest`); attach receipts.
> **Verify.** Replays under the same **EnvLock** and inputs reproduce orderings, scores, selections, and receipts **byte-for-byte**.
> **CI Gate(s).** `ci_gmm_hidden_rng`, `ci_gmm_context_bind`, `ci_seed_derivation_registry`, `ci_gmm_replay_roundtrip`.

> **PILLARS (paste-once):** Receipts use **ReceiptEnvelope/v1**; each carries `checker_hash` that **MUST** be present in **EnvLock**; all guards operate over a content-addressed **CIV** produced before any kernel runs.
> SSOT pointers: `{ "anchor":"#receipt-canon","content_b3":"b3:…" }`, `{ "anchor":"#envlock","content_b3":"b3:…" }`, `{ "anchor":"#civ-canon","content_b3":"b3:…" }`.

---
## 6.1 Canonical objects & roles (SSOT-aligned)
```jsonc
// StageCard/v1
{
  "Admits": ["ProposalSpec/v1", "EnvLock", "CIV view", "Axis catalog"],
  "Emits": ["GMM role contract", "Required pins on ProposalSpec", "Bounded-context echo rules"],
  "Guards": [
    {"anchor":"#proposal-spec","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"}
  ],
  "FailFast": ["proposal_missing_pin", "proposal_civ_bind_fail"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Roles (normative):**
**Actor** — selects actions from scored candidates (may consume authorized HKDF entropy only).
**Scorer** — maps canonical features to scores **deterministically** under EnvLock.
**Committer** — materializes accepted selections into TP rows and evidence; no other side-effects.

**`ProposalSpec/v1` (bounded-context):** the **only** admissible candidate bundle. Consumers **MUST** echo `civ.view_digest` when operating on a CIV slice.

**Required pins on `ProposalSpec` (MUST):**

* `proposal_id = BLAKE3(body_canon)`
* `context_digest` — hash of the **exact** context bytes used by the proposer
* `features_digest` — hash of the canonical feature matrix
* `civ.view_digest` — the bound CIV preimage (guard-first discipline)
* If randomness is used: `rng_domain` and `seed_ref` (content-address of a `SEED_DERIVATION_OK`)

**FailFast:** missing any required pin ⇒ `reason_code: proposal_missing_pin`.
CIV mismatch (`proposal.civ.view_digest` ≠ active CIV `view_digest`) ⇒ `reason_code: proposal_civ_bind_fail`.

---
## 6.2 Deterministic seeding & replay (HKDF + domains) {#gmm-replay}
```jsonc
// StageCard/v1
{
  "Admits": ["master_seed", "EnvLock", "code_commit", "axis_catalog", "seed_domains.json"],
  "Emits": ["SEED_DERIVATION_OK receipts", "Domain allow-list checks", "Replay contract"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": ["seed_domain_unauthorized", "seed_missing", "replay_mismatch"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Primitive (MUST):** RFC5869 HKDF with BLAKE3-256.
`IKM = master_seed`; `Salt = BLAKE3(EnvLock) || BLAKE3(code_commit) || BLAKE3(axis_catalog)`;
`Info = "sirus/hkdf/<rng_domain>/v1"`.

**Registry (MUST):** `seed_domains.json` **allow-lists** domains; **at least** `GMM.actor` and (if used) `GMM.scorer`. Derivation for an absent domain **MUST** fail (`reason_code: seed_domain_unauthorized`). Each observed domain in a run **MUST** have **exactly one** `SEED_DERIVATION_OK`; otherwise `reason_code: seed_missing`.

**Replay contract (MUST):** Identical `(EnvLock, code_commit, axis_catalog, ProposalSpec)` ⇒ identical proposal orderings, tie-breaks, selections, and attached receipts (byte-for-byte). Violation ⇒ `reason_code: replay_mismatch`.

**Seed Derivation Receipt (example, canon/v1).**

```jsonc
// ReceiptEnvelope/v1
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "SEED_DERIVATION_OK",
  "inputs_digest": "b3:EnvLock|code_commit|axis_catalog",
  "checker_hash": "b3:hkdf_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": { "rng_domain": "GMM.actor", "info": "sirus/hkdf/GMM.actor/v1" },
  "witness_digest": "b3:master_seed_public"
}
```

---
## 6.3 Guards — hidden RNG, context binding, pinning
### 6.3.1 Hidden RNG detector
```jsonc
// StageCard/v1
{
  "Admits": ["Actor binary", "Scorer binary", "seccomp/eBPF policy"],
  "Emits": ["C_GMM_HIDDEN_RNG (FAIL) receipts", "Zero TP emissions on fail"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["c_gmm_hidden_rng"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rule (MUST):** Any call to `getrandom()`, `/dev/urandom`, language RNGs, or CSPRNGs **not** routed via authorized HKDF domains **MUST** terminate the stage and emit `C_GMM_HIDDEN_RNG` with `verdict=FAIL` and `reason_code: c_gmm_hidden_rng`. No TP rows may be emitted on this path.

**Required CI:** `ci_gmm_hidden_rng` executes a fixture that attempts unauthorized draws; the build **MUST** fail.

---
### 6.3.2 Context-binding guard
```jsonc
// StageCard/v1
{
  "Admits": ["ProposalSpec header", "Scorer context bytes"],
  "Emits": ["GMM_CONTEXT_BIND_OK (PASS|FAIL)"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": ["gmm_context_mismatch"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rule (MUST):** Before scoring, recompute `scorer.context_digest` from the loaded context and require **constant-time** equality with `proposal.context_digest`. Mismatch ⇒ `verdict=FAIL`, `reason_code: gmm_context_mismatch`.

**Receipt (example, canon/v1).**

```jsonc
// ReceiptEnvelope/v1
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "GMM_CONTEXT_BIND_OK",
  "inputs_digest": "b3:proposal_header|scorer_context",
  "checker_hash": "b3:context_bind_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": {
    "proposal_context_digest": "b3:…",
    "scorer_context_digest": "b3:…"
  }
}
```

---
### 6.3.3 Receipt factory & pinning
```jsonc
// StageCard/v1
{
  "Admits": ["GMM sub-stage outputs"],
  "Emits": ["Factory-built receipts only"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["ad_hoc_receipt_json"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rule (MUST):** All GMM receipts (`SEED_DERIVATION_OK`, `GMM_CONTEXT_BIND_OK`, `GMM_SCORE_OK`, `GMM_ACT_OK`, `GMM_COMMIT_OK`) **MUST** be produced by the Receipt Factory; ad-hoc JSON is rejected (`reason_code: ad_hoc_receipt_json`).

---
## 6.4 Scoring & acting — receipts and invariants
### 6.4.1 Score receipt
```jsonc
// StageCard/v1
{
  "Admits": ["ProposalSpec/v1", "Model/weights digest", "Feature matrix (canonical)"],
  "Emits": ["GMM_SCORE_OK receipt", "scores_digest"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["non_deterministic_scores", "scorer_unpinned"],
  "Links": [{"anchor":"#envlock","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Fields (MUST):** `proposal_id`, `scores_digest` (canon bytes of score vector), optional `calibration_ref`, `witness_digest` (e.g., model/weights digest).
**Determinism (MUST):** Permuting irrelevant feature-key orders **MUST NOT** change `scores_digest`; violation ⇒ `reason_code: non_deterministic_scores`.
**Pinning (MUST):** Scorer code/weights **MUST** be pinned via EnvLock; drift ⇒ `reason_code: gmm_scorer_unpinned`.

---
### 6.4.2 Act receipt
```jsonc
// StageCard/v1
{
  "Admits": ["scores_digest", "Policy caps", "Authorized rng_domain (optional)"],
  "Emits": ["GMM_ACT_OK receipt", "selection_digest"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["seed_domain_unauthorized", "seed_missing"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Fields (MUST):** `selection_digest` (order + tie-breaks), and when randomness is used: `rng_domain`, `seed_ref`, `policy_applied`.
**Rule (MUST):** Any randomness consumed **MUST** reference a prior `SEED_DERIVATION_OK` with the **same** domain. If no randomness is used, `rng_domain`/`seed_ref` **MUST** be absent.

---
### 6.4.3 Commit receipt
```jsonc
// StageCard/v1
{
  "Admits": ["selection_digest", "ProposalSpec/v1"],
  "Emits": ["GMM_COMMIT_OK receipt", "TP rows"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["side_effects_outside_tp"],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Binding (MUST):** Receipt binds `proposal_id`, `selection_digest`, and emitted TP `row_ids`/digests.
**Isolation (MUST):** No hidden side-effects; TP rows are the **only** stateful emission (`reason_code: side_effects_outside_tp` on violation).

---
## 6.5 Transport Pack (TP) rows & determinism
```jsonc
// StageCard/v1
{
  "Admits": ["GMM selections", "Seed refs", "CIV view digest"],
  "Emits": ["TransportPackRow additions (GMM)"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": ["replay_mismatch"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**TP schema additions (canon/v1):**

```jsonc
{
  "schema_id": "TransportPackRow/v1",
  "schema_b3": "b3:…",
  "row_id": 0,
  "stage": "GMM",
  "proposal_id": "b3:…",
  "scores_digest": "b3:…",
  "selection_digest": "b3:…",
  "rng_domain": "GMM.actor",
  "seed_ref": "b3:seed_receipt",
  "context_digest": "b3:…",
  "civ_view_digest": "b3:…"
}
```

**Handshake on resume (MUST):** On `--from GMM` resumption, compare `(TP_head_digest, bundle_manifest_digest)` to recorded pair; mismatch ⇒ `reason_code: replay_mismatch`.
*(Resume semantics via SSOT pointer `{ "anchor":"#runtime-semantics","content_b3":"b3:…" }`.)*

---
## 6.6 Tests & CI (executable guarantees)
```jsonc
// StageCard/v1
{
  "Admits": ["GMM fixtures", "seed_domains.json", "EnvLock", "ProposalSpec"],
  "Emits": ["Blocking CI gates and required fixtures"],
  "Guards": [],
  "FailFast": [
    "c_gmm_hidden_rng",
    "gmm_context_mismatch",
    "seed_domain_unauthorized",
    "seed_missing",
    "replay_mismatch"
  ],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

1. **Hidden RNG detector** — unauthorized syscall causes `C_GMM_HIDDEN_RNG` (FAIL), process termination, **zero** TP emissions. (`ci_gmm_hidden_rng`)
2. **Context binding** — mismatched `context_digest` yields FAIL (`gmm_context_mismatch`); matching digests pass. (`ci_gmm_context_bind`)
3. **Seed registry coverage** — every observed `rng_domain` has **exactly one** `SEED_DERIVATION_OK`; unknown/absent domain ⇒ reject (`seed_domain_unauthorized`/`seed_missing`). Also fail if a domain is not present in `seed_domains.json`. (`ci_seed_derivation_registry`)
4. **Replay round-trip** — scoring/acting re-run under the same EnvLock yield identical `scores_digest`, `selection_digest`, and receipts. (`ci_gmm_replay_roundtrip`)

---
## 6.7 Negative controls (must-fail)
```jsonc
// StageCard/v1
{
  "Admits": ["Contrived runs that violate rules"],
  "Emits": ["FAIL receipts with reason_code enums"],
  "Guards": [],
  "FailFast": [
    "seed_domain_unauthorized",
    "seed_missing",
    "gmm_scorer_unpinned",
    "ad_hoc_receipt_json",
    "proposal_civ_bind_fail"
  ],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

* **Unauthorized RNG domain** → `reason_code: seed_domain_unauthorized`; no `GMM_ACT_OK`.
* **Seed missing** (`rng_domain` present but no `SEED_DERIVATION_OK`) → `reason_code: seed_missing`.
* **Drifted weights/model** (scorer code or weights digest differs from EnvLock) → `reason_code: gmm_scorer_unpinned`.
* **Ad-hoc receipt** (not produced by factory) → Loader rejects bundle at load (`reason_code: ad_hoc_receipt_json`).
* **CIV mismatch** (`proposal.civ.view_digest` ≠ active CIV `view_digest`) → `reason_code: proposal_civ_bind_fail`.

---
## 6.8 Interfaces (author-facing)
```jsonc
// StageCard/v1
{
  "Admits": ["Author calls to GMM"],
  "Emits": ["Canonical interface signatures", "Receipt refs"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": ["seed_domain_unauthorized", "seed_missing"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**APIs (normative):**

* `derive_seed(rng_domain) -> (seed, receipt_ref)` — HKDF(BLAKE3) with run pins; emits `SEED_DERIVATION_OK`.
* `score(proposal) -> (scores_digest, receipt_ref)` — deterministic scoring under EnvLock.
* `act(proposal, scores) -> (selection_digest, receipt_ref)` — selection using only authorized RNG domains.
* `commit(selection) -> (row_ids[], receipt_ref)` — append TP rows; **no** extra state.

---
## 6.9 Author To-Dos (short)
```jsonc
// StageCard/v1
{
  "Admits": ["Implementation backlog items"],
  "Emits": ["Minimal actionable tasks"],
  "Guards": [],
  "FailFast": ["todo_missing_negatives"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

* [ ] Ship the sandbox wrapper that enforces the **hidden RNG** policy (seccomp/eBPF profile + tests).
* [ ] Publish the **domain-separation registry** (`seed_domains.json`) and code-gen enums for `rng_domain`.
* [ ] Add a green-path toy run: `ProposalSpec → SCORE → ACT → COMMIT`, plus one negative control (`c_gmm_hidden_rng`).
* [ ] Ensure Ω aggregates all `SEED_DERIVATION_OK` receipts and fails on gaps; bind each `ProposalSpec` to the **CIV view** via `civ.view_digest`.
* [ ] Register must-fail fixtures for each reason code referenced below.

---
### Minimal must-fail(s) introduced in §6

* *HiddenRngFixture* — unauthorized entropy access ⇒ `c_gmm_hidden_rng`.
* *ContextDigestMismatch* — `proposal.context_digest` ≠ `scorer.context_digest` ⇒ `gmm_context_mismatch`.
* *SeedDomainUnauthorized* — derive seed for an unregistered domain ⇒ `seed_domain_unauthorized`.
* *SeedMissing* — `rng_domain` present but no `SEED_DERIVATION_OK` ⇒ `seed_missing`.
* *ReplayMismatch* — non-identical outputs under identical pins ⇒ `replay_mismatch`.
* *ScorerUnpinned* — scorer weights/code drift from EnvLock ⇒ `gmm_scorer_unpinned`.
* *AdHocReceipt* — receipt not produced by factory ⇒ `ad_hoc_receipt_json`.
* *ProposalCivBindFail* — `proposal.civ.view_digest` mismatch ⇒ `proposal_civ_bind_fail`.
* *NonDeterministicScores* — feature-key permutation changes `scores_digest` ⇒ `non_deterministic_scores`.
* *SideEffectsOutsideTP* — commit path emits state outside TP ⇒ `side_effects_outside_tp`.
* *ProposalMissingPin* — any required `ProposalSpec` pin missing ⇒ `proposal_missing_pin`.

**New schemas defined in §6:** *None* (all via SSOT to Appendix B).
**New reason codes requested in §6:**

* `c_gmm_hidden_rng` — unauthorized RNG usage detected.
* `gmm_context_mismatch` — proposer/scorer context digests differ.
* `ad_hoc_receipt_json` — receipt not produced by the factory.
* `non_deterministic_scores` — score digest changed under irrelevant permutation.
* `gmm_scorer_unpinned` — scorer not pinned by EnvLock.
* `side_effects_outside_tp` — state changes outside TP rows.
* `proposal_missing_pin` — required `ProposalSpec` pin absent.
* `proposal_civ_bind_fail` — bound CIV digest mismatch.

**Required cross-ref updates (outside scope):**

* Ensure Appendix **B** lists schemas and `schema_b3` for `ReceiptEnvelope/v1`, `TransportPackRow/v1`, and `ProposalSpec/v1`.
* Publish `seed_domains.json` format (registry anchor) and add `rng_domain` enum code-gen note in Implementation Guide.
* Confirm §2.5 `{#runtime-semantics}` anchor exposes resume handshake fields `(TP_head_digest, bundle_manifest_digest)`.

<!-- Source: :contentReference[oaicite:0]{index=0} :contentReference[oaicite:1]{index=1} :contentReference[oaicite:2]{index=2} -->

---
# 7. Self-Similarity (SSG) — Patterns & Binds {#ssg}

> **Learn:** SSG contributes *reusable* pattern definitions (**SSGSpec/v1**) and *concrete* instantiations (**SSGBind/v1**) that compose existing guards/kernels strictly by **anchor**.
> **Do:** Author patterns once; bind with parameters to produce runnable plans that call guards and Δ\_fr via anchors.
> **Verify:** Rebinding the same pattern with the same parameters under the same context reproduces receipts **bit-for-bit**.

---
## 7.1 Scope & Roles (link-only, normative) {#ssg-scope}
```jsonc
// StageCard/v1
{
  "Admits": ["SSGSpec/v1", "SSGBind/v1", "anchors to guards/kernels/GMM"],
  "Emits": ["Named reusable patterns", "Concrete binds (runnable plans)"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"}
  ],
  "FailFast": ["ssg_inline_math", "ssg_anchor_missing", "ssg_attempt_new_envelope"],
  "Links": [
    {"anchor":"#ssg-spec","content_b3":"b3:…"},
    {"anchor":"#ssg-bind","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"},
    {"anchor":"#gmm-replay","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**

1. **Composition only (MUST).** SSG **names** and **parameterizes** flows; it **MUST NOT** restate math for guards/kernels, invent envelopes, or alter ledger/commit rules (`reason_code: ssg_inline_math`, `ssg_attempt_new_envelope`). Use SSOT pointers only.
2. **Anchor-only references (MUST).** All guards/kernels/Δ\_fr references are anchor objects; missing/relative links **MUST** reject (`reason_code: ssg_anchor_missing`).
3. **GMM parameters (MAY).** Parameters may be produced by GMM iff `{ "anchor":"#gmm-replay","content_b3":"b3:…" }` determinism and seed-registry constraints are satisfied (link-only here).

---
## 7.2 Artifacts (normative) {#ssg-artifacts}
```jsonc
// StageCard/v1
{
  "Admits": ["Pattern specs", "Bind specs", "EnvLock", "axis_catalog"],
  "Emits": ["content-addressed SSGSpec/v1", "content-addressed SSGBind/v1"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": [
    "ssg_spec_hash_mismatch",
    "ssg_bind_arg_extraneous",
    "ssg_bind_arg_format",
    "ssg_bind_guard_missing",
    "envlock_unpinned_checker"
  ],
  "Links": [
    {"anchor":"#ssg-spec","content_b3":"b3:…"},
    {"anchor":"#ssg-bind","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->
### 7.2.1 Pattern Spec — `SSGSpec/v1` {#ssg-spec-body}

**Definition (canon).** Reusable, versioned pattern with pivots/parameters and **anchor** links to normative guards/kernels. Canonical JSON, RFC8785/JCS ordering, `additionalProperties: false`.

```jsonc
// SSGSpec/v1 (canon/v1)
{
  "schema_id": "SSGSpec/v1",
  "schema_b3": "b3:…",
  "name": "pattern.display.name",
  "version": "1.2.0",
  "hash": "b3:…",  // MUST equal BLAKE3-256(canonical bytes of this object)
  "pivot": { "kind": "account", "id": "acct_1234" },
  "parameters": [
    {"name": "limit", "type": "decimal", "min": "0.00", "max": "1000.00"},
    {"name": "window_days", "type": "int", "min": "1", "max": "90"}
  ],
  "guards":  [ {"ref": {"anchor":"#civ-canon","content_b3":"b3:…"}}, {"ref": {"anchor":"#unknowns-guard","content_b3":"b3:…"}} ],
  "kernels": [ {"ref": {"anchor":"#delta-fr-invariants","content_b3":"b3:…"}}, {"ref": {"anchor":"#commit-path","content_b3":"b3:…"}} ],
  "notes": "informative (optional)"
}
```
### 7.2.2 Bind Spec — `SSGBind/v1` {#ssg-bind-body}

**Definition (canon).** Concrete instantiation with parameters resolved. Canonical JSON; no hidden effects; orchestrates existing predicates only.

```jsonc
// SSGBind/v1 (canon/v1)
{
  "schema_id": "SSGBind/v1",
  "schema_b3": "b3:…",
  "pattern_hash": "b3:…",                 // MUST equal SSGSpec/v1.hash
  "pattern_ref": "pattern.display.name@1.2.0",
  "pivot": { "kind": "account", "id": "acct_1234" },
  "args": { "limit": "250.00", "window_days": "30" },
  "context_digest": "b3:…",               // state snapshot under which the bind is valid
  "proof_surface": "b3:…",                // optional: if GMM/UI knobs involved (link §6 via SSOT)
  "memo": "optional"
}
```

**Rules (normative).**

1. **SSOT & hashing (MUST).** `pattern_hash == BLAKE3-256(canonical_bytes(SSGSpec/v1))` encoded as `b3:<hex>`. Mismatch ⇒ `reason_code: ssg_spec_hash_mismatch`.
2. **Declared args only (MUST).** Any `args` key not declared in the pattern ⇒ `reason_code: ssg_bind_arg_extraneous`. Values **MUST** be canonical per registry; format drift ⇒ `reason_code: ssg_bind_arg_format`.
3. **Ref-only (MUST).** `guards[]`/`kernels[]` are **anchors**. SSGBind **MUST NOT** inline code or schemas.
4. **No hidden receipts (MUST NOT).** SSGBind **MUST NOT** mint new receipt types; only orchestrates existing predicates. Missing required guard receipts at runtime ⇒ `reason_code: ssg_bind_guard_missing`.
5. **Pinning (MUST).** Any SSG-emitted receipt’s `checker_hash` **MUST** be in EnvLock; else Ω fails bundle (`reason_code: envlock_unpinned_checker`).

---
## 7.3 Lifecycle & Governance (normative) {#ssg-governance}
```jsonc
// StageCard/v1
{
  "Admits": ["UpdateCert/v1", "EnvLock (advanced)", "SSGSpec/v1", "SSGBind/v1"],
  "Emits": ["PATTERN_HASH_OK", "PATTERN_BIND_OK"],
  "Guards": [
    {"anchor":"#envlock","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"}
  ],
  "FailFast": ["governance_upgrade_invalid_cert", "policy_version_stale", "envlock_unpinned_checker"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Pre-use requirements when `pattern_hash` changes (MUST).**

1. A valid **UpdateCert/v1** authorizing the new `pattern_hash` exists and validates against the current EnvLock trust root; else `reason_code: governance_upgrade_invalid_cert`.
2. **EnvLock** is **advanced** (linearized) to include/post-date that UpdateCert issuance; otherwise `reason_code: policy_version_stale`.

**Loader-visible receipts (MUST).**

```jsonc
// ReceiptEnvelope/v1 (PATTERN_HASH_OK)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "PATTERN_HASH_OK",
  "inputs_digest": "b3:SSGSpec/v1.hash|pattern_ref",
  "checker_hash": "b3:ssg_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": { "pattern_hash": "b3:…" }
}
```

```jsonc
// ReceiptEnvelope/v1 (PATTERN_BIND_OK)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "PATTERN_BIND_OK",
  "inputs_digest": "b3:SSGSpec/v1.hash|SSGBind/v1|context_digest",
  "checker_hash": "b3:ssg_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": { "pivot_echo": {"kind":"account","id":"acct_1234"} }
}
```

**Pinning (MUST).** Each receipt’s `checker_hash` **MUST** be pinned in the **advanced EnvLock**; unpinned ⇒ Ω bundle fail (`reason_code: envlock_unpinned_checker`).

---
## 7.4 Determinism Contract (rebind = replay) {#ssg-determinism}
```jsonc
// StageCard/v1
{
  "Admits": ["SSGBind/v1", "CIV slice", "EnvLock", "axis_catalog", "edge↔kernel map"],
  "Emits": ["Ordered receipt multiset", "proof_surface (optional)"],
  "Guards": [
    {"anchor":"#commit-path","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": ["ssg_rebind_drift"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Determinism tuple (canon).**

```
D := (
  pattern_hash,
  pivot,
  args (canonicalized),
  context_digest,
  envlock_digest,
  civ.view_digest,
  axis_catalog_digest,
  edge_kernel_map_digest,
  portability_stance
)
```

**Rule (MUST).** For fixed `D`, the Loader **MUST** reproduce the same ordered receipt multiset and the same `proof_surface` bytes **bit-for-bit**. Any variation ⇒ `verdict=FAIL`, `reason_code: ssg_rebind_drift`.

**Bounded-context note.** Consumers operating on a CIV slice **MUST** echo `civ.view_digest` in all SSG receipts that include CIV-dependent inputs.

---
## 7.5 Negative Controls (must-fail) {#ssg-negatives}
```jsonc
// StageCard/v1
{
  "Admits": ["Mutated specs/binds", "Loader fixtures"],
  "Emits": ["Must-fail outcomes with reason codes"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": [],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

1. **Hash drift (must-fail).** SSGSpec bytes change (whitespace/comments included) but a bind still presents the *old* `pattern_hash` ⇒ **REJECT** `reason_code: ssg_hash_drift`.
2. **Undeclared arg (must-fail).** SSGBind contains an arg name not declared in the pattern ⇒ **REJECT** `reason_code: ssg_bind_arg_extraneous`.
3. **Canonicalization mismatch (must-fail).** Same numeric value encoded differently and not equal under registry canonicalization ⇒ **REJECT** `reason_code: ssg_bind_arg_format`.
4. **Bypass guards (must-fail).** Bind references a kernel but omits required guard receipts ⇒ **REJECT** `reason_code: ssg_bind_guard_missing`.
5. **Unpinned checker (must-fail).** Any SSG-related checker not in EnvLock ⇒ Ω **FAIL** `reason_code: envlock_unpinned_checker`.
6. **Approximation without rounding (must-fail).** Kernel advertises approximation mode but `TRANSITION_OK` lacks `meta.rounding_receipt_digest` ⇒ **REJECT** `reason_code: rounding_missing`.
7. **Governance role misuse (must-fail).** Pattern evaluates with valid functional guard but wrong signer role ⇒ **REJECT** `reason_code: gov_guard_fail`.
8. **Stale policy epoch (must-fail).** Valid signature but stale UpdateCert during pattern upgrade ⇒ **REJECT** `reason_code: policy_version_stale`.

---
## 7.6 Verification (what to test) {#ssg-verification}
```jsonc
// StageCard/v1
{
  "Admits": ["Recorded runs", "SSGSpec/v1", "SSGBind/v1", "EnvLock", "CIV slice"],
  "Emits": ["Determinism proof", "Hash integrity check", "Governance path check", "Guard-first/rounding gates", "Receipt pinning check"],
  "Guards": [
    {"anchor":"#commit-path","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"}
  ],
  "FailFast": ["ssg_rebind_drift", "ssg_spec_hash_mismatch", "governance_upgrade_invalid_cert", "rounding_missing", "envlock_unpinned_checker"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Checks (normative).**

* **Rebind determinism.** Fixed `D` tuple ⇒ identical receipts and `proof_surface`; otherwise `ssg_rebind_drift`.
* **Hash integrity.** `SSGBind.pattern_hash == BLAKE3-256(canonical_bytes(SSGSpec/v1))`; mismatch ⇒ `ssg_spec_hash_mismatch`.
* **Governance upgrade path.** New `pattern_hash` without valid **UpdateCert** and **EnvLock** advancement ⇒ `governance_upgrade_invalid_cert` or `policy_version_stale`.
* **Guard-first.** Unknowns/CIV contracts run before kernels; missing `CANON_INPUT_VIEW` or priced-unknown halt ⇒ fail via Unknowns Guard (SSOT pointer).
* **Rounding hard gate.** Any approximation-advertising kernel without a `ROUNDING_RECEIPT` linked from `TRANSITION_OK` ⇒ `rounding_missing`.
* **Receipt pinning.** Any SSG-emitted receipt with `checker_hash ∉ EnvLock` ⇒ `envlock_unpinned_checker`.

**Acceptance (human-level, informative).** Rebinding the same pattern/params reproduces receipts exactly.

---
## 7.7 Author To-Dos (concise) {#ssg-author-todos}
```jsonc
// StageCard/v1
{
  "Admits": ["Authoring intentions for SSG"],
  "Emits": ["Minimal actionable to-dos"],
  "Guards": [
    {"anchor":"#ssg-spec","content_b3":"b3:…"},
    {"anchor":"#ssg-bind","content_b3":"b3:…"}
  ],
  "FailFast": ["ssg_todo_missing_negatives"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Checklist (normative).**

1. Publish patterns only via **SSGSpec/v1**; never inline pattern logic or math.
2. Define pivots/parameters with explicit **types/units/defaults** and value ranges; adhere to registry canonicalization.
3. Reference guards/kernels **by anchor** only; avoid restating shapes/algorithms.
4. If a binding can touch budgets, route postings through Δ\_fr (anchor link) and obey the **rounding hard gate** when in approximation mode.
5. Check in a minimal *green-path skeleton* run that emits exactly: `PATTERN_HASH_OK`, `PATTERN_BIND_OK`, required guard receipts, any `ROUNDING_RECEIPT` (if needed), and `Ω`.
6. Emit a **SpecEmitter** round-trip artifact: re-emit the used SSGSpec bytes and bind them into the run’s `proof_surface` for CI self-verification.

---
### Minimal must-fail(s) introduced in §7

* *SSGHashDrift* ⇒ `ssg_hash_drift`
* *SSGSpecHashMismatch* ⇒ `ssg_spec_hash_mismatch`
* *SSGBindArgExtraneous* ⇒ `ssg_bind_arg_extraneous`
* *SSGBindArgFormat* ⇒ `ssg_bind_arg_format`
* *SSGBindGuardMissing* ⇒ `ssg_bind_guard_missing`
* *SSGRebindDrift* ⇒ `ssg_rebind_drift`
* *GovernanceUpgradeInvalidCert* ⇒ `governance_upgrade_invalid_cert`
* *PolicyVersionStale* ⇒ `policy_version_stale`
* *EnvLockUnpinnedChecker* ⇒ `envlock_unpinned_checker`
* *RoundingMissing* ⇒ `rounding_missing`
* *SSGInlineMath* ⇒ `ssg_inline_math`
* *SSGAnchorMissing* ⇒ `ssg_anchor_missing`
* *SSGAttemptNewEnvelope* ⇒ `ssg_attempt_new_envelope`

**New schemas defined in §7:** *None* (both `SSGSpec/v1` and `SSGBind/v1` are SSOT-linked to Appendix B).

**New reason codes requested in §7 (enums):**

* `ssg_inline_math` — SSG tried to redefine kernel/guard math.
* `ssg_anchor_missing` — Reference to guard/kernel/Δ\_fr not provided as an SSOT anchor.
* `ssg_attempt_new_envelope` — Attempt to mint a non-canonical receipt/envelope via SSG.
* `ssg_spec_hash_mismatch` — `pattern_hash` ≠ hash of canonical SSGSpec bytes.
* `ssg_hash_drift` — Binding old `pattern_hash` to changed SSGSpec bytes.
* `ssg_bind_arg_extraneous` — Arg name not declared in SSGSpec.
* `ssg_bind_arg_format` — Arg value not in canonical form/range.
* `ssg_bind_guard_missing` — Required guard receipts omitted.
* `ssg_rebind_drift` — Rebind under identical `D` did not replay receipts/`proof_surface`.

**Required cross-ref updates (outside scope):**

* Ensure Appendix **B** registers `SSGSpec/v1` and `SSGBind/v1` with frozen `schema_b3`, `additionalProperties:false`, and numeric canonicalization rules.
* Confirm §4 Unknowns Guard and §5 Δ\_fr anchors referenced above remain stable and publish `content_b3` for SSOT integrity.

---
# 8. Self-Specification (SPEC) {#self-spec}

> **PILLARS (paste-once macro):** Receipts use **ReceiptEnvelope/v1**; each carries `checker_hash` that **MUST** be present in **EnvLock**; all guards operate over a content-addressed **CIV** produced before any kernel runs. <!-- ssot-pointer:receipt-canon --><!-- ssot-pointer:envlock --><!-- ssot-pointer:civ-canon -->

---
## 8.1 SPECDoc/v1 (canonical object) {#specdoc}
```jsonc
// StageCard/v1
{
  "Admits": ["Spec source tree", "EnvLock", "CI config"],
  "Emits": ["SPECDoc/v1 canonical bytes", "specid (b3:…)", "hash map of materializations"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": [
    "spec_json_noncanonical",
    "spec_hash_undefined",
    "materialization_digest_mismatch"
  ],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// SPECDoc/v1 (canon/v1) — additionalProperties: false
{
  "schema_id": "SPECDoc/v1",
  "schema_b3": "b3:…",
  "version": "1.0.4",
  "timestamp": "2025-09-24T00:00:00Z",
  "source": "docs/SIRUS_SPEC_MASTER.md",
  "pillars_echo": { "envlock_portability_stance": "Strong|Bounded|Local" },
  "ssot_map_digest": "b3:…",
  "merkle_fixture_root": "b3:…",
  "hashes": {
    "json": "b3:…",
    "latex": "b3:…",
    "pdf": "b3:…",
    "html": "b3:…"
  },
  "receipts": {
    "emit": "b3:…",       // SPEC_EMIT_OK
    "ext": "b3:…",        // SPEC_EXT_OK
    "roundtrip": "b3:…"   // SPEC_ROUNDTRIP_OK
  },
  "notes": "Self-describing spec snapshot with anchors, receipts, and Merkle binding"
}
```

**Rules.**

1. **Canonicalization (MUST).** `SPECDoc/v1` bytes are RFC8785/JCS-canonical; unsorted keys/NaN/Inf ⇒ `reason_code: spec_json_noncanonical`.
2. **Content address (MUST).** `specid := BLAKE3_256(canonical_bytes)`; governance binds only to `specid` (`spec_hash_undefined` if missing).
3. **Materializations (MUST).** LaTeX/PDF/HTML/Markdown (if produced) are derived from canonical JSON; their digests **MUST** match `hashes.*` or fail `materialization_digest_mismatch`.
4. **Portability echo (MUST).** `pillars_echo.envlock_portability_stance` **MUST** mirror EnvLock stance; Ω echoes it on the proof surface.

---
## 8.2 Receipts (uniform, hard-pinned) {#spec-receipts}
```jsonc
// StageCard/v1
{
  "Admits": ["SpecEmitter outputs", "EnvLock"],
  "Emits": ["SPEC_EMIT_OK", "SPEC_EXT_OK", "SPEC_ROUNDTRIP_OK"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": [
    "receipt_unpinned_checker",
    "receipt_missing_schema",
    "roundtrip_hash_drift",
    "merkle_mismatch"
  ],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Receipt shapes (canonical examples).**

```jsonc
// ReceiptEnvelope/v1 (SPEC_EMIT_OK)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "SPEC_EMIT_OK",
  "inputs_digest": "b3:spec_sources|envlock",
  "checker_hash": "b3:spec_emitter_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": { "specid": "b3:…" }
}
```

```jsonc
// ReceiptEnvelope/v1 (SPEC_EXT_OK)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "SPEC_EXT_OK",
  "inputs_digest": "b3:specid|renderer_versions",
  "checker_hash": "b3:spec_ext_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": { "latex":"b3:…", "pdf":"b3:…", "html":"b3:…" }
}
```

```jsonc
// ReceiptEnvelope/v1 (SPEC_ROUNDTRIP_OK)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "SPEC_ROUNDTRIP_OK",
  "inputs_digest": "b3:specid",
  "checker_hash": "b3:spec_roundtrip_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": { "json_hash_pre": "b3:…", "json_hash_post": "b3:…" }
}
```

**Rules.**

1. **Pinning (MUST).** Each receipt’s `checker_hash` **MUST** be present in EnvLock; else `reason_code: receipt_unpinned_checker`.
2. **Schema presence (MUST).** `schema_id` and `schema_b3` **MUST** match the registered schema; else `receipt_missing_schema`.
3. **Roundtrip identity (MUST).** `json_hash_pre == json_hash_post`; inequality ⇒ `roundtrip_hash_drift`.
4. **Merkle coupling (MUST).** All three receipts are leaves of the bundle manifest; Ω recomputation mismatch ⇒ `merkle_mismatch`.

---
## 8.3 SpecEmitter run (required green-path) {#spec-trace}
```jsonc
// StageCard/v1
{
  "Admits": ["Spec sources", "Renderer toolchain", "EnvLock"],
  "Emits": ["SPECDoc/v1", "Evidence Bundle", "Omega-manifest-v1.json (merkle_root)"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": [
    "spec_emit_fail",
    "spec_ext_fail",
    "spec_roundtrip_fail",
    "merkle_mismatch"
  ],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Green-path trace (normative).**

1. Render canonical JSON → compute `specid`. Emit **`SPEC_EMIT_OK`**.
2. Build LaTeX/PDF/HTML from canonical JSON; emit **`SPEC_EXT_OK`** with digests.
3. Parse→serialize→parse canonical JSON; emit **`SPEC_ROUNDTRIP_OK`** (identical hash).
4. Assemble **Omega-manifest-v1.json** and compute `merkle_root` (BLAKE3; leaf `0x00||leaf`, node `0x01||L||R`, odd nodes duplicate).
5. Write frozen filenames:
   `SPECDoc.json|.tex|.pdf|.html`, `receipts/spec_emit.jsonl`, `receipts/spec_ext.jsonl`, `receipts/spec_roundtrip.jsonl`, `Omega-manifest-v1.json`.

**Failure mapping (normative).**

* Emission error ⇒ `spec_emit_fail` (FAIL receipt `SPEC_EMIT_FAIL`).
* Extension build error/digest drift ⇒ `spec_ext_fail` (FAIL receipt `SPEC_EXT_FAIL`).
* Roundtrip drift ⇒ `spec_roundtrip_fail` (FAIL receipt `SPEC_ROUNDTRIP_FAIL`).
* Manifest recompute mismatch at CI/Ω ⇒ `merkle_mismatch`.

---
## 8.4 Normative Governance Link (SPEC as the governed object) {#spec-governance-link}
```jsonc
// StageCard/v1
{
  "Admits": ["specid_old", "SpecEmitter bundle (new)", "Governance proposal draft"],
  "Emits": ["UpdateCert/v1 binding specid_old→specid_new", "Ω-visible governance log entry"],
  "Guards": [{"anchor":"#envlock","content_b3":"b3:…"}],
  "FailFast": [
    "updatecert_missing_specid",
    "updatecert_missing_receipts",
    "updatecert_missing_manifest_root"
  ],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// UpdateCert/v1 (canon/v1) — additionalProperties: false
{
  "schema_id": "UpdateCert/v1",
  "schema_b3": "b3:…",
  "specid_old": "b3:…",
  "specid_new": "b3:…",
  "bundle_manifest_root": "b3:…",
  "receipts": {
    "emit": "b3:…",
    "ext": "b3:…",
    "roundtrip": "b3:…"
  },
  "issued_at": "2025-09-24T00:00:00Z",
  "approvers": [
    {"role":"SecEng","sig":"base64:…","alg":"Ed25519","pubkey":"base64:…"}
  ],
  "meta": {"change_ticket":"CHG-…"}
}
```

**Rules.**

1. **Binding (MUST).** A proposal **MUST** present `specid_new`; missing ⇒ `updatecert_missing_specid`.
2. **Receipts (MUST).** Digests of **SPEC\_EMIT\_OK**, **SPEC\_EXT\_OK**, **SPEC\_ROUNDTRIP\_OK** **MUST** be included; omission ⇒ `updatecert_missing_receipts`.
3. **Manifest root (MUST).** `bundle_manifest_root` **MUST** be present and equal to the SpecEmitter bundle’s root; omission ⇒ `updatecert_missing_manifest_root`.
4. **Authoritative object (MUST).** Governance binds **only** to `specid`; patches/filenames are non-authoritative.

---
## 8.5 Interfaces (author- and CI-facing) {#spec-interfaces}
```jsonc
// StageCard/v1
{
  "Admits": ["Author CLI", "CI job spec", "Adapters requiring SPEC fields"],
  "Emits": ["Interface list + canonical responsibilities"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["interface_contract_violation"],
  "Links": [
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Canonical interface set (normative).**

* **SPECDoc/v1** — canonical spec artifact; content-addressed by `specid`.
* **ReceiptEnvelope/v1** — envelope for `SPEC_EMIT_OK`, `SPEC_EXT_OK`, `SPEC_ROUNDTRIP_OK`.
* **UpdateCert/v1** — governance wrapper that advances SPEC hash.
* **SpecEmitter fixture** — runnable CI job emitting bundle + receipts + manifest.
* **CIVContract/v1** — **single JSON contract** that adapters consume verbatim (referenced via SSOT).
* **Ω surface** — must echo EnvLock portability stance and pin `specid`.

**Rule.** Consumers that operate on a SPEC-derived **CIV slice** **MUST** echo `view_digest` when present (bounded-context exposure).

---
## 8.6 CI Gate 0 (pre-publish hard gate) {#spec-ci-gate0}
```jsonc
// StageCard/v1
{
  "Admits": ["Spec tree", "SpecEmitter bundle", "Manifest bytes", "Lint config"],
  "Emits": ["Gate 0 verdict", "Must-fail coverage report"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ],
  "FailFast": [
    "ssot_anchor_violation",
    "receipt_pinning_line_missing",
    "json_example_noncanonical",
    "negative_control_passed",
    "merkle_mismatch",
    "rounding_missing",
    "portability_stance_mismatch"
  ],
  "Links": [{"anchor":"#unknowns-guard","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Gate 0 checklist (blocking).**

1. **SSOT anchors & pointer lint.** Dupes/omissions fail `ssot_anchor_violation`.
2. **Receipt pinning first-mention line.** Missing once-per-subsection ⇒ `receipt_pinning_line_missing`.
3. **JSON example canonicalization.** Non-canonical fence ⇒ `json_example_noncanonical`.
4. **Negative controls.** Must-fail fixtures for CIV/Unknowns/TRANSITION/ROUNDING/TAIL/Ω families **MUST** fail; any PASS ⇒ `negative_control_passed`.
5. **Merkle recomputation.** CI recompute equals `merkle_fixture_root`; else `merkle_mismatch`.
6. **Approximation hard gate.** Any `TRANSITION_OK` from an approx kernel **MUST** link a `ROUNDING_RECEIPT`; absence ⇒ `rounding_missing`.
7. **Portability echo.** Ω surface must echo EnvLock stance; mismatch ⇒ `portability_stance_mismatch`.

---
## 8.7 Verification (what to test) {#spec-verification}
```jsonc
// StageCard/v1
{
  "Admits": ["SpecEmitter bundles across runs", "Governance logs", "EnvLock set"],
  "Emits": ["Determinism and append-only proofs"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": [
    "spec_reemit_drift",
    "receipt_unpinned_checker",
    "governance_chain_incomplete"
  ],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**

1. **Determinism (MUST).** Re-emitting under identical EnvLock re-creates identical `specid` and materialization digests; mismatch ⇒ `spec_reemit_drift`.
2. **Receipt pinning (MUST).** Each EMIT/EXT/ROUNDTRIP receipt carries `(checker_hash, envlock_digest)` pinned in EnvLock; missing ⇒ `receipt_unpinned_checker`.
3. **Governance replay (MUST).** Replaying UpdateCerts reproduces the exact `specid_old → specid_new` sequence; gaps ⇒ `governance_chain_incomplete`.
4. **Immutability (MUST).** Prior SPEC bundles are preserved, never mutated; Ω must show an append-only hash chain.

---
## 8.8 Author To-Dos (short, enforceable) {#spec-author-todos}
```jsonc
// StageCard/v1
{
  "Admits": ["Author intent to publish a new SPEC"],
  "Emits": ["Minimal actionable checklist"],
  "Guards": [],
  "FailFast": ["todo_missing_negatives"],
  "Links": [
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Checklist (normative).**

1. Regenerate **SPECDoc/v1** via **SpecEmitter** only; never hand-edit canonical JSON.
2. Produce and pin **SPEC\_EMIT\_OK**, **SPEC\_EXT\_OK**, **SPEC\_ROUNDTRIP\_OK**; include their digests and the **bundle manifest root** in **UpdateCert**.
3. Propose only `specid` + receipt/manifest digests; no raw patches.
4. Keep `version`/`timestamp` synchronized; bump `version` only when `specid` changes.
5. Keep `seed_domains.json` in repo; attempts to derive seeds outside allow-list must have a must-fail (see §12 via SSOT).
6. Ship two Appendix D bundles: **all-PASS green path** and **must-fail tripwire** (unknowns-priced, wrong signer role, missing rounding receipt); absence ⇒ `todo_missing_negatives`.

---
### Minimal must-fail(s) introduced in §8

* *SpecJsonNoncanonical* — non-canonical SPECDoc JSON ⇒ `spec_json_noncanonical`.
* *SpecHashUndefined* — missing `specid` binding ⇒ `spec_hash_undefined`.
* *MaterializationDigestMismatch* — derived PDF/HTML/LaTeX digest drift ⇒ `materialization_digest_mismatch`.
* *RoundtripDrift* — parse/serialize mismatch ⇒ `roundtrip_hash_drift`.
* *ReceiptUnpinnedChecker* — receipt `checker_hash` not in EnvLock ⇒ `receipt_unpinned_checker`.
* *UpdateCertMissingFields* — missing specid/receipts/manifest root ⇒ `updatecert_missing_specid|updatecert_missing_receipts|updatecert_missing_manifest_root`.
* *MerkleMismatchFixture* — manifest/root disagree ⇒ `merkle_mismatch`.
* *SpecReemitDrift* — re-emit under same EnvLock changes digests ⇒ `spec_reemit_drift`.
* *GovernanceChainIncomplete* — cannot replay `specid_old→specid_new` sequence ⇒ `governance_chain_incomplete`.
* *TodoMissingNegatives* — required negative controls absent ⇒ `todo_missing_negatives`.
* *PortabilityStanceMismatch* — Ω surface stance != EnvLock ⇒ `portability_stance_mismatch`.

**New schemas defined in §8:**
*`$id: UpdateCert/v1` (canon/v1, `additionalProperties:false`).*

**New reason codes requested in §8:**
`spec_json_noncanonical` — SPECDoc not RFC8785/JCS.
`spec_hash_undefined` — `specid` absent/blank.
`materialization_digest_mismatch` — derived digest mismatch.
`roundtrip_hash_drift` — JSON hash changed after roundtrip.
`updatecert_missing_specid` — UpdateCert lacks `specid_new`.
`updatecert_missing_receipts` — UpdateCert lacks required receipt digests.
`updatecert_missing_manifest_root` — UpdateCert lacks bundle root.
`spec_reemit_drift` — re-emit not bit-identical under EnvLock.
`governance_chain_incomplete` — replay gap in SPEC hash transitions.
`todo_missing_negatives` — required negatives not shipped.
`portability_stance_mismatch` — Ω echo differs from EnvLock stance.

**Required cross-ref updates (outside scope):**

* Register **UpdateCert/v1** in Appendix B (schemas) with frozen `schema_b3` and `additionalProperties:false`.
* Ensure Ω finalization (§2 / Ω stage) pins `specid` and echoes EnvLock portability stance on the proof surface.
* Confirm §4 Receipt canon includes PASS/FAIL variants for `SPEC_EMIT_(OK|FAIL)`, `SPEC_EXT_(OK|FAIL)`, `SPEC_ROUNDTRIP_(OK|FAIL)` and maps them as manifest leaves.

---
# 9. Governance — identity, roles, UpdateCert, budgets {#governance}

> **Learn → Do → Verify (non-normative overview):** Governance decisions are **guards backed by receipts**, not policy prose. Policy is serialized, content-addressed, and pinned; decisions bind to that exact snapshot. Propose **UpdateCert/v1**, collect ballots under pinned quorum rules, and—on `ACCEPT`—advance **SPEC** and (if requested) the **EnvLock checker set** via an explicit **upgrade map**. Replays under the same EnvLock, pinned policies, ballots, and artifacts must re-derive identical tallies, ledger tips, and receipt hashes.&#x20;

---
## 9.1 Canonical objects (policy as data)
```jsonc
// StageCard/v1
{
  "Admits": ["Role lattice (RBAC)", "Quorum policy", "Eligibility policy", "Timing policy"],
  "Emits": ["governance_pins tuple (digests)", "role_lattice_digest"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"}
  ],
  "FailFast": ["policy_noncanonical", "policy_unpinned", "role_lattice_missing"],
  "Links": [
    {"anchor":"#predicate-registry","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Definitions (canonical JSON, sorted keys, fixed decimals).**

* **Role lattice** — RBAC graph; hash → `role_lattice_digest : b3:<hex>`.
* **Quorum policy** — weights, thresholds.
* **Eligibility policy** — voter set definition, revocations.
* **Timing policy** — open/close windows, grace, escrow.

**Rule 1 (MUST).** Governance guard **MUST** declare:

```jsonc
// canon/v1 (excerpt)
{
  "governance_pins": {
    "role_lattice_digest": "b3:…",
    "quorum_policy": "b3:…",
    "eligibility_policy": "b3:…",
    "timing_policy": "b3:…"
  }
}
```

**Rule 2 (MUST).** Policies **MUST** be canonical bytes (RFC8785/JCS); noncanonical encodings ⇒ `reason_code: policy_noncanonical`.

**Rule 3 (MUST).** All four digests **MUST** be present and non-null; absence ⇒ `role_lattice_missing` (for lattice) or `policy_unpinned` (others).

---
## 9.2 Governance as a guard (GOV\_GUARD\_OK)
```jsonc
// StageCard/v1
{
  "Admits": ["Proposer identity", "Ballot bundle", "governance_pins", "attestations"],
  "Emits": ["GOV_GUARD_OK receipt", "role_lattice_digest echo"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": ["role_mismatch", "policy_epoch_stale", "quota_breach", "attestation_invalid"],
  "Links": [{"anchor":"#predicate-registry","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

> **PILLARS:** Receipts use **ReceiptEnvelope/v1** and **must** have `checker_hash` pinned in **EnvLock**; Ω fails if any receipt is unpinned or not advanced via UpdateCert.

**Required receipt fields (delta over prior spec).**

```jsonc
// ReceiptEnvelope/v1 (GOV_GUARD_OK)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "GOV_GUARD_OK",
  "inputs_digest": "b3:{edge,proposer,attachments,governance_pins}",
  "checker_hash": "b3:gov_guard_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "witness_digest": "b3:tally_witness_bundle",
  "meta": {
    "role_lattice_digest": "b3:…",
    "quota_checked": true,
    "epoch": 7
  }
}
```

**Rules (binding + replay).**

1. **Lattice binding (MUST).** Replays **MUST** fail if `meta.role_lattice_digest` ≠ pinned lattice (`reason_code: role_lattice_mismatch`).
2. **Signer resolution (MUST).** All identities **MUST** resolve to roles present in the pinned lattice at decision time; mismatch ⇒ `role_mismatch`.
3. **Epoch discipline (MUST).** Stale policy epoch at evaluation time ⇒ `policy_epoch_stale`.
4. **Quotas/attestations (MUST).** Breach or invalid ⇒ `quota_breach` / `attestation_invalid`.

---
## 9.3 UpdateCert/v1 (SPEC & policy adoption)
```jsonc
// StageCard/v1
{
  "Admits": ["SPECDoc/v1", "SPEC receipts (emit/ext/roundtrip)", "governance_pins", "ballots"],
  "Emits": ["UpdateCert/v1", "UpdateCertReceipt/v1 (success/failure)"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ],
  "FailFast": [
    "spec_roundtrip_missing",
    "gate0_block",
    "rounding_policy_violation",
    "ucid_duplicate"
  ],
  "Links": [
    {"anchor":"#self-spec","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

> **PILLARS:** Receipts use **ReceiptEnvelope/v1**; `checker_hash` **MUST** be pinned in **EnvLock**; evaluation is over CIV preimages.

**Canonical UpdateCert body (proposal bytes; `ucid = BLAKE3(body)`).**

```jsonc
// UpdateCert/v1 (canon/v1)
{
  "schema_id": "UpdateCert/v1",
  "schema_b3": "b3:…",
  "id": "auto|ignored",
  "spec_transition": { "from": "hash:specid_old", "to": "hash:specid_new" },
  "attachments": {
    "SPEC_EMIT_OK": "b3:…",
    "SPEC_EXT_OK": "b3:…",
    "SPEC_ROUNDTRIP_OK": "b3:…"
  },
  "governance_pins": {
    "role_lattice_digest": "b3:…",
    "quorum_policy": "b3:…",
    "eligibility_policy": "b3:…",
    "timing_policy": "b3:…"
  },
  "ballot_config": { "opens_at": "2025-09-15T12:00:00Z", "closes_at": "2025-09-18T12:00:00Z" },
  "memo": "Adopt SPEC vX.Y.Z"
}
```

**Rules.**

1. **Round-trip proof (MUST).** All three attachments **MUST** be present/pinned; omission ⇒ `spec_roundtrip_missing`.
2. **Gate 0 (MUST).** Target `specid_new` **MUST** have passed Final QA Checklist; otherwise `gate0_block`. (SSOT: `{ "anchor":"#verification","content_b3":"b3:…"} `)
3. **Approx stance (MUST).** If SPEC enables kernels advertising approximation, EnvLock policy **MUST** require a rounding receipt; violation ⇒ `rounding_policy_violation`.
4. **Deduplication (MUST).** Reposting identical body **MUST** reject with `ucid_duplicate`.

**Success receipt (example).**

```jsonc
// UpdateCertReceipt/v1 (success)
{
  "schema_id": "UpdateCertReceipt/v1",
  "schema_b3": "b3:…",
  "predicate_id": "SPEC_ADOPTED",
  "inputs_digest": "b3:ucid|tally_digest|pins",
  "checker_hash": "b3:gov_guard_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": {
    "ucid": "b3:…",
    "specid_old": "hash:…",
    "specid_new": "hash:…",
    "role_lattice_digest": "b3:…",
    "policy_hashes": ["b3:…","b3:…"],
    "blockid": "L12345:7",
    "evaluator_hash": "b3:…",
    "tally_digest": "b3:…",
    "epoch": 7
  }
}
```

---
## 9.4 EnvLock advance (Checker Upgrade Map)
```jsonc
// StageCard/v1
{
  "Admits": ["Current EnvLock", "Proposed checker set", "UpdateCert/v1"],
  "Emits": ["envlock_upgrade_map", "EnvLock′"],
  "Guards": [{"anchor":"#envlock","content_b3":"b3:…"}],
  "FailFast": ["envlock_upgrade_denied", "upgrade_map_invalid", "receipt_checker_unpinned"],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

> **PILLARS:** Receipts are **ReceiptEnvelope/v1** and **MUST** have `checker_hash ∈ EnvLock` after upgrade application.

**Canonical map (one-to-one).**

```jsonc
// EnvLockUpgradeMap/v1 (canon/v1)
{
  "schema_id": "EnvLockUpgradeMap/v1",
  "schema_b3": "b3:…",
  "entries": [
    { "old_checker_hash": "b3:…", "new_checker_hash": "b3:…" },
    { "old_checker_hash": "b3:…", "new_checker_hash": "b3:…" }
  ]
}
```

**Rules.**

1. **Explicitness (MUST).** Any EnvLock change in UpdateCert **MUST** include a one-to-one map; omission ⇒ `envlock_upgrade_denied`.
2. **Integrity (MUST).** No duplicates, no cycles; violations ⇒ `upgrade_map_invalid`.
3. **Enforcement (MUST).** Ω **MUST** reject any receipt whose `checker_hash` is not present in the **post-upgrade** EnvLock (`receipt_checker_unpinned`).
4. **Loader semantics (MUST).** Loader applies at most **one** EnvLock hop per run init; Ω echoes portability stance (SSOT `{ "anchor":"#envlock","content_b3":"b3:…" }`).

---
## 9.5 Guard path & receipts (ballot → tally → adopt)
```jsonc
// StageCard/v1
{
  "Admits": ["UpdateCert/v1", "Ballot/v1", "Quorum policy"],
  "Emits": ["Tally witness", "SPEC_ADOPTED receipt", "Δ_fr transaction inputs"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"}
  ],
  "FailFast": ["quorum_not_met", "eligibility_violation", "timing_window_violation"],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

> **PILLARS:** Receipt pinning line applies; all ballots/tallies bind to the pinned policy snapshot.

**Rules.**

1. **Validation order (MUST).** `GOV_GUARD_OK` → collect `Ballot/v1` → tally per pinned quorum → on `ACCEPT`, emit `SPEC_ADOPTED` and stage Δ\_fr inputs.
2. **No effect (MUST).** No code/config change is recognized until SPEC hash is adopted via UpdateCert.
3. **Quorum/eligibility/timing (MUST).** Violations yield `quorum_not_met`, `eligibility_violation`, or `timing_window_violation`.

---
## 9.6 Governance transaction (Δ\_fr binding) {#gov-deltafr}
```jsonc
// StageCard/v1
{
  "Admits": ["SPEC_ADOPTED receipt", "Ledger state"],
  "Emits": ["TransactionSpec/v1 with Σ=0 postings", "Δ_fr append"],
  "Guards": [{"anchor":"#delta-fr-invariants","content_b3":"b3:…"}],
  "FailFast": ["dupe_commit", "non_conservative_postings"],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

> **PILLARS:** Receipts are **ReceiptEnvelope/v1** and are referenced by Q′ in outcomes; they are Merkle leaves.

**Rules.**

1. **Conservation (MUST).** Debit/credit postings sum to zero; else `non_conservative_postings`.
2. **Uniqueness (MUST).** Each adoption recorded once; duplicate ⇒ `dupe_commit`.
3. **Pinning (MUST).** Transaction links the UpdateCert receipt by content address and pins the policy epoch used.

---
## 9.7 Receipts (success & failure)
```jsonc
// StageCard/v1
{
  "Admits": ["UpdateCert lifecycle results"],
  "Emits": ["UpdateCertReceipt/v1 (success|failure)"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["receipt_missing_schema", "variant_envelope"],
  "Links": [{"anchor":"#predicate-registry","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

> **PILLARS:** All governance receipts use **ReceiptEnvelope/v1**; no variant envelopes are permitted.

**Failure receipt (example).**

```jsonc
// UpdateCertReceipt/v1 (failure)
{
  "schema_id": "UpdateCertReceipt/v1",
  "schema_b3": "b3:…",
  "predicate_id": "UPDATECERT_FAIL",
  "inputs_digest": "b3:ucid|pins",
  "checker_hash": "b3:gov_guard_checker",
  "envlock_digest": "b3:…",
  "verdict": "FAIL",
  "meta": {
    "ucid": "b3:…",
    "failing_stage": "GOV_GUARD_OK",
    "reason_code": "rounding_policy_violation"
  }
}
```

**Rules.**

1. **Schema presence (MUST).** `schema_id`/`schema_b3` required; else `receipt_missing_schema`.
2. **Envelope uniformity (MUST NOT).** No variant envelope types; detection ⇒ `variant_envelope`.

---
## 9.8 Replay & audit
```jsonc
// StageCard/v1
{
  "Admits": ["SPECDoc/v1 bundle", "Pinned policies", "Ballots", "EnvLock"],
  "Emits": ["Deterministic ledger tip", "SPEC_ADOPTED digest"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": ["replay_policy_drift", "envlock_drift", "attachment_mismatch"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

> **PILLARS:** Receipts must be pinned and EnvLock-present; replay is over CIV preimages.

**Rules.**

1. **Bit-for-bit (MUST).** Reconstruct SPEC and re-evaluate ballots under the same pinned policies/lattice; any drift ⇒ `replay_policy_drift`.
2. **Attachment parity (MUST).** Missing/mismatched attachments (`SPEC_*_OK`) ⇒ `attachment_mismatch`.
3. **EnvLock determinism (MUST).** Drift ⇒ `envlock_drift`.

---
## 9.9 Interfaces (author uses)
```jsonc
// StageCard/v1
{
  "Admits": ["Author intents"],
  "Emits": ["UpdateCert/v1", "Ballot/v1", "UpdateCertReceipt/v1", "TransactionSpec/v1", "SPECDoc/v1"],
  "Guards": [{"anchor":"#predicate-registry","content_b3":"b3:…"}],
  "FailFast": ["unknown_interface"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

> **PILLARS:** When an interface emits a receipt, it **MUST** use ReceiptEnvelope/v1 and pin `checker_hash` present in EnvLock.

**Rule.** Only the listed interfaces are permitted within this section’s scope; unrecognized interface names ⇒ `unknown_interface`.

---
## 9.10 Verification (what to test)
```jsonc
// StageCard/v1
{
  "Admits": ["Governance fixtures", "EnvLock variants"],
  "Emits": ["CI gates: ci_gov_guard, ci_updatecert_roundtrip, ci_envlock_upgrade_map, ci_deltafr_cov, Gate 0"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": ["gate_missing", "negative_fixture_missing"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

> **PILLARS:** Tests assert receipt pinning and EnvLock presence.

**Rules.**

1. **Role lattice binding (MUST).** Replay with different `role_lattice_digest` **must** fail GOV guard (`role_lattice_mismatch`).
2. **EnvLock upgrade map (MUST).** UpdateCert changing checker set without a map **must** fail (`envlock_upgrade_denied`).
3. **Δ\_fr invariants (MUST).** Adoption transaction satisfies uniqueness, atomicity, append-only, conservation.
4. **Deterministic tally (MUST).** Same ballots/policies ⇒ identical `SPEC_ADOPTED` digest under EnvLock.
5. **Gate 0 enforcement (MUST).** New `specid` blocked unless Final QA Checklist passed.

---
## 9.11 Negative controls (must-fail)
```jsonc
// StageCard/v1
{
  "Admits": ["Minimal fixtures"],
  "Emits": ["Expected FAIL receipts with reason_code"],
  "Guards": [{"anchor":"#negatives","content_b3":"b3:…"}],
  "FailFast": [],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

> **PILLARS:** Each failing path still emits **ReceiptEnvelope/v1** with EnvLock-pinned `checker_hash`.

1. **Role inflation** — runtime lattice ≠ `role_lattice_digest` ⇒ `GOV_GUARD_FAIL`, `reason_code: role_lattice_mismatch`.
2. **Wrong signer role** — valid signature, unauthorized role ⇒ `GOV_GUARD_FAIL`, `reason_code: role_mismatch`.
3. **Stale policy epoch** — signature verifies but snapshot ≠ pinned epoch ⇒ `POLICY_VERSION_STALE`, `reason_code: policy_epoch_stale`.
4. **Wildcard EnvLock advance** — UpdateCert changes checker set but omits map ⇒ `ENVLOCK_UPGRADE_DENIED`, `reason_code: envlock_upgrade_denied`.
5. **Unpinned checker** — governance receipt with `checker_hash ∉ EnvLock` ⇒ Ω reject, `reason_code: receipt_checker_unpinned`.
6. **Duplicate UCID** — repost identical UpdateCert body ⇒ reject, `reason_code: ucid_duplicate`.
7. **Approx policy mismatch** — SPEC advertises approx but EnvLock lacks rounding requirement ⇒ `UPDATECERT_FAIL`, `reason_code: rounding_policy_violation`.

---
## 9.12 Author To-Dos (concise)
```jsonc
// StageCard/v1
{
  "Admits": ["Implementation checklist intentions"],
  "Emits": ["Minimal action list for CI and fixtures"],
  "Guards": [],
  "FailFast": ["todo_missing_negatives"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

> **PILLARS:** Add the receipt pinning line on first mention in each normative subsection you extend.

* [ ] Publish `role_lattice_digest` canonicalization and SSOT pointer target.
* [ ] Implement `ci_envlock_upgrade_map` and wire to UpdateCert parser.
* [ ] Add one green-path governance run + one failing guard to Appendix D; include **wrong role** and **stale policy** fixtures.
* [ ] Replace any narrative governance commit prose with an SSOT pointer to `{ "anchor":"#commit-path","content_b3":"b3:…" }`.

---
### Minimal must-fail(s) introduced in §9

* *RoleLatticeMismatch* — replay under different lattice ⇒ `role_lattice_mismatch`.
* *WrongSignerRole* — unauthorized role signer ⇒ `role_mismatch`.
* *PolicyEpochStale* — snapshot not the pinned epoch ⇒ `policy_epoch_stale`.
* *EnvLockUpgradeDenied* — checker set change without map ⇒ `envlock_upgrade_denied`.
* *ReceiptCheckerUnpinned* — `checker_hash ∉ EnvLock` ⇒ `receipt_checker_unpinned`.
* *DuplicateUCID* — duplicate proposal body ⇒ `ucid_duplicate`.
* *RoundingPolicyViolation* — approx enabled but rounding requirement absent ⇒ `rounding_policy_violation`.
* *PolicyNoncanonical* — JSON not canon/v1 ⇒ `policy_noncanonical`.
* *PolicyUnpinned* — missing policy digest ⇒ `policy_unpinned`.
* *QuorumNotMet / EligibilityViolation / TimingWindowViolation* — as named.

**New schemas defined:** `$id: EnvLockUpgradeMap/v1` (canon/v1, `additionalProperties:false`).
**New reason codes requested:**
`role_lattice_mismatch` — replay/eval lattice ≠ pinned digest.
`policy_noncanonical` — governance policy bytes not canon/v1.
`policy_unpinned` — required policy digest absent.
`upgrade_map_invalid` — duplicate/cycle/one-to-many entries in upgrade map.
`quorum_not_met`, `eligibility_violation`, `timing_window_violation` — ballot/tally window/eligibility failures.
`dupe_commit` — duplicate governance Δ\_fr commit.

**Required cross-ref updates (outside scope):**

* Register `$id` for **UpdateCert/v1**, **UpdateCertReceipt/v1**, and **EnvLockUpgradeMap/v1** in Appendix **B** with frozen `schema_b3`.
* Ensure §0 and §2 EnvLock stance echo rule is linked from §9.4 (SSOT to `#envlock`).
* Add Gate 0 anchor in §10 and SSOT-link it where referenced here.

---
# 10. Verification & Benchmarks {#verification}
## 10.1 Test Matrix (receipt/guard/property) {#verification-matrix}
```jsonc
// StageCard/v1
{
  "Admits": ["Predicate registry", "ReceiptEnvelope/v1 instances", "GuardSpec/v1", "Suite metadata"],
  "Emits": ["TestMatrix/v1 index", "Per-family coverage report", "ReplayPlan/v1 stubs"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"}
  ],
  "FailFast": ["matrix_misfiled", "predicate_family_coverage_gap", "non_envelope_receipt", "unknown_schema_ref"],
  "Links": [
    {"anchor":"#predicate-registry","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**

1. **Group by Receipt.** Suites **MUST** be grouped by `predicate_id` families (e.g., `CANON_INPUT_VIEW`, `C_UNK_PRICED`, `TRANSITION_OK`, `ROUNDING_RECEIPT`, `CBF_BUDGET_CHECK(OK|FAIL)`, `OMEGA`, `UpdateCert`, and registered failure predicates). Any receipt **MUST** use `ReceiptEnvelope/v1`; variants **MUST** hard-fail (`reason_code: non_envelope_receipt`).
2. **Slice by Guard.** Within each family, tests **MUST** cover guard classes: *well-formedness, timing/dwell, eligibility/governance, quorum, budget, uniqueness, immutability*.
3. **Name by Property.** Each case **MUST** declare its target property from {determinism/replay, fail-closed, projection `π(Q′)=Q`, rounding booking, seed replay}. Missing or misfiled property **MUST** hard-fail CI (`reason_code: matrix_misfiled`).
4. **Coverage.** For every predicate family, provide **must-pass**, **must-fail**, and **replay** cases. Lack of any category **MUST** fail with `reason_code: predicate_family_coverage_gap`.
5. **Index.** Maintain a single `tests/README.md` index anchoring suites; links **MUST** be SSOT pointers to canonical anchors for definitions referenced elsewhere.

---
## 10.2 Conformance Gates (CI “Gate 0” and friends) {#verification-ci-gates}
```jsonc
// StageCard/v1
{
  "Admits": ["Spec tree", "CI pipeline config", "Canonical fixtures", "EnvLock stance"],
  "Emits": ["Gate0 verdict", "Editorial SSOT report", "Evidence/replay gate report"],
  "Guards": [
    {"anchor":"#commit-path","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": [
    "gate0_block",
    "ssot_anchor_violation",
    "receipt_first_mention_missing",
    "json_noncanonical",
    "rounding_missing",
    "merkle_mismatch",
    "policy_version_stale"
  ],
  "Links": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#gmm-replay","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**

1. **Gate 0 (pre-publish).** The executable Final QA Checklist **MUST** pass before a fresh `specid` is accepted or Ω admits a run; failure ⇒ `reason_code: gate0_block`.
2. **Editorial SSOT gates.**

   * **SSOT anchor integrity.** Concepts redefined outside canonical homes **MUST** fail (`ssot_anchor_violation`); stray prose **MUST** be replaced by SSOT pointers.
   * **Receipt first-mention pinning.** Enforce exactly once per subsection the pin line: receipts use `ReceiptEnvelope/v1` and carry `checker_hash` present in EnvLock; missing ⇒ `receipt_first_mention_missing`.
   * **JSON canonicalization.** Enforce `jsonc` fences, sorted keys, fixed decimals; NaN/Inf **forbidden** (`json_noncanonical`).
3. **Evidence & Replay gates.**

   * **Merkle recipe fixture.** CI recomputes the root from canonical fixture bytes; mismatch ⇒ `merkle_mismatch`.
   * **Rounding hard gate.** If any kernel advertises approximation, reject `TRANSITION_OK` missing `meta.rounding_receipt_digest` (`rounding_missing`; see SSOT `{ "anchor":"#delta-fr-invariants","content_b3":"b3:…" }`).
   * **EnvLock portability stance.** Ω **MUST** echo stance; `Strong` implies CI cross-replay on the allowed platform set; failures reject the run (SSOT `{ "anchor":"#envlock","content_b3":"b3:…" }`).
   * **UpdateCert freshness.** Governance updates **MUST** be current; stale epoch ⇒ `policy_version_stale`.

---
## 10.3 Must-Fail Library (canonical negatives) {#verification-mustfail}
```jsonc
// StageCard/v1
{
  "Admits": ["Tiny fixtures (≤1KiB each)", "Deterministic setup bytes"],
  "Emits": ["Failure receipts with machine-readable reason_code", "No state changes"],
  "Guards": [
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"}
  ],
  "FailFast": ["mustfail_mutates_state", "reason_text_freeform", "missing_sidecar"],
  "Links": [
    {"anchor":"#ledger-discipline","content_b3":"b3:…"},
    {"anchor":"#q-prime","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Required families & examples (non-exhaustive).**

* **Δ\_fr / Ledger:** non-conservative transaction; duplicate `txid`; atomicity race; history edit; missing `ROUNDING_RECEIPT` when approx advertised ⇒ `rounding_missing`.
* **GMM / Seeds:** missing evidence; nondeterministic actor/seed path; scorer metadata attempting to flip `π(Q′)`.
* **SPEC / SSOT:** hash drift across renderings; missing receipts; SSOT pointer duplication/omission.
* **Governance:** wrong signer role ⇒ `GOV_GUARD_FAIL/ROLE_MISMATCH`; valid signature but stale UpdateCert epoch ⇒ `POLICY_VERSION_STALE`; duplicate `ucid` ⇒ deterministic reject.
* **Unknowns:** priced-axis unknown ⇒ `C_UNK_PRICED` + `UnknownPricedAxisEvent/v1` sidecar; missing sidecar ⇒ `missing_sidecar`.
* **Adapters:** axis leak ⇒ `C_AXIS_LEAK`; non-monotone ⇒ `ADAPTER_MONO_FAIL`; nondeterminism under EnvLock ⇒ `ENVLOCK_DRIFT`.
* **Ω Finalization / Bundle:** manifest/root disagreement ⇒ `MERKLE_MISMATCH`; required artifact missing ⇒ `BUNDLE_INCOMPLETE`; tail extensionality violation ⇒ `TAIL_EXT_FAIL`.

**Rules.**

1. Fixtures **MUST** emit a **FAIL** `ReceiptEnvelope/v1` with `reason_code` only (no free-text) and **MUST NOT** mutate ledger or state (`mustfail_mutates_state` if detected).
2. Where a sidecar is prescribed (e.g., Unknowns), absence **MUST** fail with `reason_code: missing_sidecar`.

---
## 10.4 Replay & Determinism (bit-for-bit) {#verification-replay}
```jsonc
// StageCard/v1
{
  "Admits": ["ReplayPlan/v1", "EnvLock", "Machine image/container digests", "Inputs/seeds/versions"],
  "Emits": ["Byte-equal receipts", "Stable txid/blockid", "Bundle merkle_root"],
  "Guards": [
    {"anchor":"#gmm-replay","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ],
  "FailFast": ["envlock_mismatch", "replay_mismatch", "rounding_missing", "omega_fail_code"],
  "Links": [{"anchor":"#envlock","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**

1. A single command **MUST** materialize a `ReplayPlan/v1` manifest of `(inputs, seeds, versions, machine images)` and **MUST** replay end-to-end asserting byte-equal: all receipts, `txid/blockid`, balances, and the bundle Merkle root. Any digest drift ⇒ `replay_mismatch`.
2. Machine image/container digests are part of the manifest; mismatch ⇒ `envlock_mismatch`.
3. Ω **MUST** embed the Merkle root in `SurfaceV1.json`; recomputation is CI-mandatory; any Ω failure code in §4.6 **MUST** abort (`omega_fail_code` bucket).

**Example (receipt excerpt; canonical):**

```jsonc
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "OMEGA",
  "inputs_digest": "b3:BundleManifest/v1:…",
  "checker_hash": "b3:omega_finalizer",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": { "merkle_root": "b3:…" }
}
```

---
## 10.5 Benchmarks (discipline) {#verification-benchmarks}
```jsonc
// StageCard/v1
{
  "Admits": ["Frozen dataset/state snapshot", "Fixed seeds", "SLO policy (optional)"],
  "Emits": ["Throughput/latency/memory/commit-rate metrics", "Perf receipts (advisory unless pinned)"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": ["benchmark_mutates_state", "perf_gate_without_policy"],
  "Links": [{"anchor":"#bench-suites","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**

1. **Isolation.** Benchmarks **MUST** run on a frozen dataset and fixed seeds, producing no state deltas; mutation ⇒ `benchmark_mutates_state`.
2. **Signals.** Only throughput, latency, memory, and commit rate are measured; no correctness coupling.
3. **Pins.** If a perf SLO matters, it **MUST** be pinned in policy and enforced as a guard with an explicit FAIL path and a matching must-fail negative; otherwise, perf is advisory. Attempting to gate correctness on unpinned perf ⇒ `perf_gate_without_policy`.

---
## 10.6 Canonical Fixtures & Bundles (small, runnable) {#verification-fixtures}
```jsonc
// StageCard/v1
{
  "Admits": ["Appendix-D bundles (≤10 receipts each)", "EdgeKernelMap/v1"],
  "Emits": ["Green-path bundle", "Tripwire bundle", "Exact merkle_root recomputation"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"}
  ],
  "FailFast": ["bundle_incomplete", "merkle_mismatch", "edge_kernel_map_missing"],
  "Links": [{"anchor":"#examples","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**

1. **Ship two bundles (Appendix D).**

   * **Green path:** all-PASS, exercising CIV→governance→frontier crossing→pricing→Ω.
   * **Tripwire path:** triggers priced-unknown halt, wrong signer role, and missing rounding receipt.
2. **Required bytes.**

   * `bundle_min.v1.manifest.json` **MUST** be reused across repos; CI **MUST** recompute its `merkle_root` exactly; mismatch ⇒ `merkle_mismatch`.
   * `EdgeKernelMap/v1` **MUST** be emitted and pinned in the bundle manifest, binding each edge to `{pricing_kernel, axes_touched, rounding_policy}`; missing or stale ⇒ `edge_kernel_map_missing`.
3. **Completeness.** Any required artifact missing ⇒ `bundle_incomplete`.

---
## 10.7 Author To-Dos (keep short) {#verification-author-todos}
```jsonc
// StageCard/v1
{
  "Admits": ["New predicates, guards, kernels"],
  "Emits": ["Must-fail per predicate family", "Replay tests per actor/scorer/kernel", "Rounding gate pairs", "EdgeKernelMap/v1"],
  "Guards": [
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": ["author_todo_missing_negatives", "replay_test_missing", "axes_touched_mismatch"],
  "Links": [{"anchor":"#ledger-discipline","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Checklist (normative).**

1. Add a **must-fail** for **every** new predicate family and guard path with fixed `reason_code`; absence ⇒ `author_todo_missing_negatives`.
2. Add a **replay test** for every new actor/scorer or kernel; assert byte-equal receipts and manifest root; absence ⇒ `replay_test_missing`.
3. Exercise the **rounding hard gate** by pairing each advertised-approx transition with (a) valid `ROUNDING_RECEIPT` and (b) a negative missing-witness case.
4. Generate and pin **EdgeKernelMap/v1**; test that every `axes_touched` posting appears **exactly once** in CBF’s ledger; mismatch ⇒ `axes_touched_mismatch`.
5. Keep benchmarks isolated; never gate correctness on perf unless explicitly pinned by policy.

---
### Minimal must-fail(s) introduced in §10

* *MatrixMisfiled*: a test case’s declared property/family does not match its location ⇒ `matrix_misfiled`.
* *PredicateFamilyCoverageGap*: predicate family lacks must-pass/must-fail/replay coverage ⇒ `predicate_family_coverage_gap`.
* *Gate0Block*: Final QA Checklist not satisfied ⇒ `gate0_block`.
* *MissingSidecar*: priced-unknowns case omits `UnknownPricedAxisEvent/v1` ⇒ `missing_sidecar`.
* *BenchmarkMutatesState*: benchmark writes any state ⇒ `benchmark_mutates_state`.
* *EdgeKernelMapMissing*: bundle missing or stale `EdgeKernelMap/v1` ⇒ `edge_kernel_map_missing`.

**New schemas defined in §10:** *None.*

**New reason codes requested in §10:**
`matrix_misfiled` — Test case placed under wrong family/property.
`predicate_family_coverage_gap` — Missing must-pass/fail/replay cases for a predicate family.
`gate0_block` — Gate 0 (pre-publish) failed.
`missing_sidecar` — Required sidecar artifact absent in a must-fail.
`benchmark_mutates_state` — Benchmark changed state.
`edge_kernel_map_missing` — Required `EdgeKernelMap/v1` missing or stale.

**Required cross-ref updates (outside scope):**

* Appendices **D** and **H**: ensure example bundles and benchmark suites are registered and SSOT-pointed from §10.6 and §10.5.
* Appendix **B**: confirm schemas for `UnknownPricedAxisEvent/v1`, `EdgeKernelMap/v1`, and `BundleManifest/v1` carry current `schema_b3`.
* §4, §5, §12: verify the PILLARS first-mention pin line and EnvLock replay semantics are present once per subsection.

---
# 11. Runbooks (Ops Only) {#runbooks}

> **Scope:** Operations procedures that call into already-defined guards, receipts, and policies.
> **Discipline:** Steps are linear, observable, and either diagnostic (no state change) or mutation (Δ\_fr commit path only via guards).
> **Bounded-context:** Consumers MUST echo `view_digest` when operating on a CIV slice to maintain replay determinism.

---
## 11.1 Custodian — Adopt a SPEC (happy path) {#runbook-adopt-spec}
```jsonc
// StageCard/v1
{
  "Admits": [
    "candidate SPEC (specid_to)",
    "current EnvLock/v1",
    "prior specid_from",
    "pinned policy digests",
    "voter registry"
  ],
  "Emits": [
    "CANON_INPUT_VIEW",
    "EMIT_OK|EXT_OK|ROUNDTRIP_OK",
    "UpdateCert/v1",
    "BALLOT_OPEN_OK",
    "BALLOT_TALLY_OK",
    "GOV_GUARD_OK",
    "TRANSITION_OK (+ meta.rounding_receipt_digest if approx=true)",
    "CBF_LEDGER_POST",
    "OMEGA"
  ],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"}
  ],
  "FailFast": [
    "emit_fail","ext_fail","roundtrip_fail",
    "cert_schema_invalid",
    "ballot_window_violation","quorum_failure","duplicate_ucid",
    "kernel_id_mismatch","rounding_missing",
    "budget_cap_breach",
    "merkle_mismatch","tail_ext_fail"
  ],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules (normative):**

1. **Validate SPEC (diagnostic).** Run `specctl emit && specctl ext && specctl roundtrip --dry-run`. The three receipts **MUST** be present with `verdict: PASS`; else fail fast with one of `{emit_fail, ext_fail, roundtrip_fail}`.
2. **Mint UpdateCert (diagnostic).** Construct `UpdateCert/v1` mapping `specid_from → specid_to`, pinning policy digests and ballot window. The object **MUST** validate (`cert_schema_invalid` on failure).

```jsonc
// UpdateCert/v1 (canon/v1 example)
{
  "schema_id": "UpdateCert/v1",
  "schema_b3": "b3:…",
  "from_envlock": "b3:…",
  "to_envlock": "b3:…",
  "specid_from": "b3:old-spec",
  "specid_to": "b3:new-spec",
  "window": {"start":"2025-09-23T00:00:00Z","end":"2025-09-30T00:00:00Z"},
  "policies_b3": ["b3:p0","b3:p1"],
  "approvers": [{"role":"Custodian","sig":"base64:…","alg":"Ed25519","pubkey":"base64:…"}]
}
```

3. **Open ballot (mutation: governance).** `govctl ballot open --ucid <id> --voters voters.json --window <start..end>`. Must emit `BALLOT_OPEN_OK` with pinned policy/version; non-conformance ⇒ `ballot_window_violation` or `duplicate_ucid`.
4. **Close & deterministic tally (diagnostic).** `govctl ballot close --ucid <id> && govctl ballot tally --ucid <id>`. Must emit `BALLOT_TALLY_OK{ meta.tally_digest }`; quorum failure ⇒ `quorum_failure`.
5. **Commit adoption (mutation: Δ\_fr).** `govctl adopt --ucid <id> --updatecert UpdateCert.json`. Loader enforces governance guard and Δ\_fr axioms; if `approx=true`, `TRANSITION_OK` **MUST** include `meta.rounding_receipt_digest` (else `rounding_missing`). Must emit `GOV_GUARD_OK`, `TRANSITION_OK`, `CBF_LEDGER_POST`; budget breaches ⇒ `budget_cap_breach`.
6. **Finalize & verify (diagnostic).** `omegactl finalize` emits `OMEGA` with `proof_surface` + `merkle_root`. CI recomputation **MUST** match; else `merkle_mismatch`. Tail receipts must extend; else `tail_ext_fail`. Ω **MUST** echo `portability_stance` (see EnvLock).
   SSOT: `{ "anchor":"#commit-path","content_b3":"b3:…" }`

**Bounded-context requirement.** Any consumer operating on a CIV slice during this runbook **MUST** echo `view_digest` in subsequent calls to preserve determinism.

**Must-fail hooks (tiny fixtures):**

* *AdvertisedApproxNoWitness* — approx kernel adoption without `ROUNDING_RECEIPT` ⇒ `rounding_missing`.
* *BallotWindowPast* — open with `now ∉ [start,end]` ⇒ `ballot_window_violation`.

---
## 11.2 Auditor — Full Replay {#runbook-audit}
```jsonc
// StageCard/v1
{
  "Admits": [
    "evidence bundle manifest",
    "Transport Pack head",
    "seeds",
    "container digests",
    "toolchain lock",
    "axis catalog & budgets",
    "EdgeKernelMap"
  ],
  "Emits": [
    "REPLAY_PLAN_OK",
    "MERKLE_CHECK_OK",
    "LEDGER_REPLAY_OK",
    "findings bundle (diffs, mismatches)"
  ],
  "Guards": [
    {"anchor":"#commit-path","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"}
  ],
  "FailFast": [
    "replay_mismatch",
    "merkle_mismatch",
    "ledger_atomicity_fail",
    "duplicate_txid",
    "rounding_missing"
  ],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules (normative):**

1. **Plan & pin (diagnostic).** Load `(inputs, seeds, tool versions, container digests, policy hashes)`; verify `EnvLockSig/v1`. Emit `REPLAY_PLAN_OK`. Resume requires matching TP/bundle heads; else `replay_mismatch`.
2. **Merkle recompute (diagnostic).** Recompute bundle root from manifest bytes. Match ⇒ `MERKLE_CHECK_OK`; else `merkle_mismatch`. SSOT: `{ "anchor":"#commit-path","content_b3":"b3:…" }`
3. **Guard-first re-eval (diagnostic).** Re-run CIV creation and Unknowns Guard (priced-axis unknowns **halt** via `C_UNK_PRICED`); check governance and crossing receipts (hysteresis/dwell/saltation).
4. **Δ\_fr & ledger (diagnostic).** Using **Edge→Pricing Kernel Map**, assert every `axes_touched` posting appears exactly once in CBF ledger and preserves atomicity; else `ledger_atomicity_fail` or `duplicate_txid`. If any kernel advertised approximation, require the `ROUNDING_RECEIPT`; else `rounding_missing`. Emit `LEDGER_REPLAY_OK` on success.
5. **Compare receipts/ids/balances (diagnostic).** Multiset-equality on receipt digests; exact-equality on ids/balances. Any mismatch is emitted in a **findings bundle** (diff + witnesses).

---
## 11.3 Hotfix Roll-Forward (no rollback edits) {#runbook-hotfix}
```jsonc
// StageCard/v1
{
  "Admits": [
    "hotfix SPEC (specid_new)",
    "policy permitting emergency window",
    "current EnvLock"
  ],
  "Emits": [
    "EMIT_OK|EXT_OK|ROUNDTRIP_OK",
    "UpdateCert/v1 (short window when allowed)",
    "GOV_GUARD_OK",
    "TRANSITION_OK",
    "CBF_LEDGER_POST"
  ],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ],
  "FailFast": [
    "emit_fail","ext_fail","roundtrip_fail",
    "cert_schema_invalid",
    "policy_version_stale",
    "g ov_guard_fail"
  ],
  "Links": [
    {"anchor":"#negatives","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules (normative):**

1. **Prepare hotfix SPEC (diagnostic).** Produce `specid_new` via `emit/ext/roundtrip` (dry-run acceptable). Fail-fast on `{emit_fail, ext_fail, roundtrip_fail}`.
2. **Emergency window (diagnostic).** If policy allows, issue `UpdateCert/v1` with shortened window; else standard cadence. Must validate schema; else `cert_schema_invalid`.
3. **Adopt (mutation).** Ballot open/close/tally; adopt with `UpdateCert`. Must emit `GOV_GUARD_OK`, `TRANSITION_OK`, `CBF_LEDGER_POST`. **Never** edit prior bundles/ledgers.
4. **Counter-effects (mutation via supersede).** If effects require correction, submit **another** UpdateCert to supersede. Rolling back prior commits is **forbidden**.
5. **Tripwires (diagnostic must-fails).**
   (a) Wrong signer role with otherwise valid guard ⇒ `g ov_guard_fail`.
   (b) Valid signature but stale policy version ⇒ `policy_version_stale`.
   SSOT: `{ "anchor":"#negatives","content_b3":"b3:…" }`

---
## 11.4 Diagnostics (no state change) {#runbook-diagnostics}
```jsonc
// StageCard/v1
{
  "Admits": [
    "hash fixtures",
    "config files",
    "guard samples",
    "seed domains",
    "EdgeKernelMap",
    "axis catalog & budgets",
    "bundle manifest"
  ],
  "Emits": [
    "ADAPTER_AXIS_OK",
    "ADAPTER_MONO_OK",
    "CANON_INPUT_VIEW (preview)",
    "C_UNK_PRICED (fixture)",
    "ROUNDING_RECEIPT (fixture)",
    "MERKLE_CHECK_OK",
    "LEDGER_INTEGRITY_OK"
  ],
  "Guards": [
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ],
  "FailFast": [
    "adapter_mono_fail",
    "c_axis_leak",
    "merkle_mismatch",
    "ledger_atomicity_fail"
  ],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules (normative):**

1. **Diagnostic-only.** All diagnostic runs **MUST** set `diagnostic:true` in receipts and **MUST NOT** call Δ\_fr commit. Loader enforces `no-commit` mode.
2. **Fixtures.** Provide minimal fixtures for Unknowns Guard (`C_UNK_PRICED`) and rounding.
3. **Integrity checks.**
   *Merkle:* recompute from manifest bytes ⇒ `MERKLE_CHECK_OK` or `merkle_mismatch`.
   *Ledger:* verify atomicity and exactly-once postings ⇒ `LEDGER_INTEGRITY_OK` or `ledger_atomicity_fail`.
4. **Adapter conformance.** Require `ADAPTER_AXIS_OK` and `ADAPTER_MONO_OK`; violations ⇒ `{c_axis_leak, adapter_mono_fail}`.

---
## 11.5 Author To-Dos (keep short) {#runbooks-author-todos}
```jsonc
// StageCard/v1
{
  "Admits": ["runbook drafts"],
  "Emits": [
    "≤ 1-screen linear steps",
    "diagnostic vs mutation labeling",
    "dry-run parity rule",
    "tripwires coverage"
  ],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ],
  "FailFast": [
    "pillars_missing_on_first_mention",
    "pillars_pasted_multiple_times",
    "dryrun_receipt_divergence"
  ],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules (normative):**

1. **One screen, linear.** Keep each runbook ≤ 1 screen; push scripts/flags to `scripts/` and SSOT-point them.
2. **Label steps.** Tag each step as **diagnostic** (no state change) or **mutation** (Δ\_fr commit path) and name the guard it relies on via SSOT pointer.
3. **Dry-run parity.** `--dry-run` **MUST** reproduce the exact receipts (minus commit) as live mode; divergence ⇒ `dryrun_receipt_divergence`.
4. **Tripwires.** Include must-fails: priced-unknown halt, wrong signer role, missing rounding witness when approx is advertised.
5. **Merkle fixture.** Always recompute and compare the bundle Merkle root; mismatch hard-fails the runbook.

---
### Minimal must-fail(s) introduced in §11

* *AdvertisedApproxNoWitness* — approx kernel with `TRANSITION_OK` missing `meta.rounding_receipt_digest` ⇒ `rounding_missing`.
* *BallotWindowPast* — ballot open outside window ⇒ `ballot_window_violation`.
* *DryRunParityBreak* — `--dry-run` receipts differ from live mode ⇒ `dryrun_receipt_divergence`.
### New schemas defined in §11

*None.*
### New reason codes requested in §11

* `dryrun_receipt_divergence` — Dry-run receipts differ from live-mode receipts under identical inputs.
### Required cross-ref updates (outside scope)

* Register `UpdateCert/v1` (if not already) in Appendix **B** with `additionalProperties:false` and frozen `schema_b3`.
* Ensure EnvLock stance echo rule is enforced at Ω per §0.13 (SSOT).
* Confirm Appendix **G** includes negatives referenced here (wrong signer role, stale policy, approx witness missing).

---
# 12. Implementation Guide (Software-Enforced) {#implementation}
```jsonc
// StageCard/v1
{
  "Admits": ["EnvLock", "axis_catalog", "policy_digests", "Transport Pack head", "Evidence Bundle head"],
  "Emits": ["Implementation rules (machine-checkable)", "Failure reason codes", "Executables & fixtures"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"}
  ],
  "FailFast": ["envlock_unpinned","envlock_mismatch","envlock_expired","MERKLE_MISMATCH","rounding_missing","REPLAY_MISMATCH"],
  "Links": [
    {"anchor":"#gmm-replay","content_b3":"b3:…"},
    {"anchor":"#axis-and-budgets","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This section is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.&#x20;
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**PILLARS (paste-once macro for §12):** Receipts use **ReceiptEnvelope/v1**; each carries `checker_hash` that **MUST** be present in **EnvLock**; all guards operate over a content-addressed **CIV** produced before any kernel runs.&#x20;

---
## 12.1 EnvLock (runtime pin set) {#implementation-envlock}
```jsonc
// StageCard/v1
{
  "Admits": ["EnvLock body", "UpdateCert/v1 chain"],
  "Emits": ["checker_hash allowlist", "portability_stance echo in Ω", "ReceiptEnvelope/v1 with envlock_digest"],
  "Guards": [
    {"anchor":"#envlock","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"}
  ],
  "FailFast": ["envlock_unpinned","envlock_mismatch","envlock_expired"],
  "Links": [
    {"anchor":"#verification-ci-gates","content_b3":"b3:…"}
  ]
}
```

<!-- opener:canon/v1 -->
<!-- pillars:once -->

<!-- 3-line opener -->

**Rules (normative).**

1. **Receipt coupling (MUST).** Every **ReceiptEnvelope/v1** carries `(checker_hash, envlock_digest)`; reject if `checker_hash ∉ EnvLock.allowlist` or `envlock_digest ≠ active` (`envlock_unpinned`, `envlock_mismatch`, `envlock_expired`).&#x20;
2. **Portability stance echo (MUST).** Ω **MUST** echo `portability_stance` from EnvLock into both the final surface and `OMEGA.meta`. For `Strong`, CI **MUST** cross-replay across the allowed matrix.&#x20;
3. **Update discipline (MUST).** Advance only via linear `UpdateCert/v1`; no code/image mutations during a run.&#x20;
4. **Editorial lint (MUST).** First mention of “receipt” in any repo subsection includes the receipt-pinning one-liner exactly once; duplicates fail editorial CI.&#x20;

**Example (UpdateCert/v1).**

```jsonc
{
  "schema_id": "UpdateCert/v1",
  "schema_b3": "b3:…",
  "from_envlock": "b3:envlock_prev…",
  "to_envlock":   "b3:envlock_next…",
  "issued_at": "2025-09-15T12:00:00Z",
  "reason": "Pin kernel 0.3.2; rotate scoring checker",
  "approvers": [
    { "role": "SecEng", "sig": "base64:…", "alg": "Ed25519", "pubkey": "base64:…" },
    { "role": "Ops",    "sig": "base64:…", "alg": "Ed25519", "pubkey": "base64:…" }
  ],
  "meta": { "change_ticket": "CHG-4821" }
}
```

---
## 12.2 ReplayPlan (record → regenerate) {#implementation-replayplan}
```jsonc
// StageCard/v1
{
  "Admits": ["inputs digests", "CIV view digests", "rng_domains", "image/tool digests", "axis_catalog_digest", "policy_digests", "envlock_digest"],
  "Emits": ["ReplayPlan manifest row", "SEED_DERIVATION_OK", "REPLAY_MISMATCH on divergence"],
  "Guards": [
    {"anchor":"#gmm-replay","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ],
  "FailFast": ["REPLAY_MISMATCH","SEED_DOMAIN_UNKNOWN"],
  "Links": []
}
```

<!-- opener:canon/v1 -->
<!-- pillars:once -->

<!-- 3-line opener -->

**Rules (normative).**

1. **Manifest (MUST).** Capture the per-run tuple `(inputs_digests, civ_digests, rng_domains, container/k8s image digests, tool versions, axis_catalog_digest, policy_digests, envlock_digest)`.&#x20;
2. **Deterministic replayer (MUST).** Regenerate proposals/decisions/transactions/receipts bit-for-bit under the same EnvLock.&#x20;
3. **Seeds (MUST).** HKDF(RFC5869, BLAKE3) with `IKM` pinned to the run; `Salt = B3(EnvLock)||B3(code_commit)||B3(axis_catalog)`; `Info = "sirus/hkdf/<domain>/v1"`. Domains **must** be allow-listed in `seed_domains.json`; otherwise `SEED_DOMAIN_UNKNOWN`.&#x20;
4. **Audit hook (MUST).** `replay --last N` replays the last `N` blocks + governance acts; any mismatch in receipts/ids/Merkle root **fails CI** with `REPLAY_MISMATCH`.&#x20;

**Receipt (seed derivation).**

```jsonc
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "SEED_DERIVATION_OK",
  "inputs_digest": "b3:EnvLock|code_commit|axis_catalog",
  "checker_hash": "b3:hkdf_checker",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": { "rng_domain": "PR.kernel.hsic" },
  "witness_digest": "b3:master_seed"
}
```

---
## 12.3 Canonicalization & Hashing (bytes that bind) {#implementation-canonical}
```jsonc
// StageCard/v1
{
  "Admits": ["JSON payloads", "manifest bytes"],
  "Emits": ["canonical JSON (RFC8785/JCS)", "b3:<hex> digests", "Merkle fixture root"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": ["json_noncanonical","MERKLE_MISMATCH"],
  "Links": []
}
```

<!-- opener:canon/v1 -->
<!-- pillars:once -->

<!-- 3-line opener -->

**Rules (normative).**

1. **JSON canon (MUST).** RFC8785/JCS: sorted keys, UTF-8 NFC strings, fixed decimals, forbid `NaN`/`Inf`, no trailing zeros past policy precision.&#x20;
2. **Digesting (MUST).** Use **BLAKE3-256**; encode as `b3:<lower-hex>`. IDs derive **only** from canonical bytes.&#x20;
3. **Merkle fixture (MUST).** Leaf `BLAKE3(0x00||leaf)`, node `BLAKE3(0x01||L||R)`, odd duplication; CI recomputes the fixture and hard-fails on divergence (`MERKLE_MISMATCH`).&#x20;

---
## 12.4 Containers & Tooling (I/O, time, and isolation) {#implementation-containers}
```jsonc
// StageCard/v1
{
  "Admits": ["container image digests", "lockfiles", "explicit file/dir args"],
  "Emits": ["checker_hash re-derivation", "RFC3339-UTC timestamps"],
  "Guards": [{"anchor":"#envlock","content_b3":"b3:…"}],
  "FailFast": ["mutable_tag_used","implicit_cwd","unexpected_network_io"],
  "Links": []
}
```

<!-- opener:canon/v1 -->
<!-- pillars:once -->

<!-- 3-line opener -->

**Rules (normative).**

1. **Images (MUST).** Address by immutable digests only; reject mutable tags (`latest`, moving semvers).
2. **I/O discipline (MUST).** Explicit inputs only; **no implicit CWD** and **no network fetches** unless explicitly allow-listed and content-addressed.
3. **Locale/Time (MUST).** `LC_ALL=C.UTF-8`, `TZ=UTC`; timestamps are RFC3339-UTC; FP/arith modes fixed under EnvLock.
4. **Reproducible builds (MUST).** Toolchains pinned; Loader re-derives `checker_hash` before accepting any receipt.&#x20;

---
## 12.5 BLT: Build → Label → Trace (end-to-end) {#implementation-blt}
```jsonc
// StageCard/v1
{
  "Admits": ["spec sources", "container digests", "build graph"],
  "Emits": ["EdgeKernelMap/v1", "SpecEmitter outputs", "Ω manifest", "labeled receipts"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#tpl-edge-kernel-map","content_b3":"b3:…"}
  ],
  "FailFast": ["edge_kernel_map_missing","label_unpinned"],
  "Links": [{"anchor":"#blt-profile","content_b3":"b3:…"}]
}
```

<!-- opener:canon/v1 -->
<!-- pillars:once -->

<!-- 3-line opener -->

**Rules (normative).**

1. **Build deterministically**: emit SPEC JSON, LaTeX/PDF, transport pack, receipts, Ω manifest, **EdgeKernelMap/v1**, **SpecEmitter** outputs.
2. **Label all artifacts** with content hashes and container digests; embed `(checker_hash, envlock_digest)` on every receipt.
3. **Traceability (MUST).** ACCEPT paths are traceable back to inputs, policy, and toolchain; Ω binds the bundle root in `proof_surface`.&#x20;

---
## 12.6 Executable Contracts: Unknowns & Rounding {#implementation-exec-guards}
```jsonc
// StageCard/v1
{
  "Admits": ["CIVContract/v1", "kernel approx advertise flag"],
  "Emits": ["C_UNK_PRICED FAIL receipts + sidecar rows", "ROUNDING_RECEIPT digests bound into TRANSITION_OK"],
  "Guards": [
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"}
  ],
  "FailFast": ["C_UNK_PRICED","rounding_missing"],
  "Links": [{"anchor":"#tpl-transport-boundary","content_b3":"b3:…"}]
}
```

<!-- opener:canon/v1 -->
<!-- pillars:once -->

<!-- 3-line opener -->

**Rules (normative).**

1. **Unknowns Guard (MUST).** One file, one receipt. Any `⊥` on a **priced** axis emits `C_UNK_PRICED` (FAIL) and appends `UnknownPricedAxisEvent/v1` to **`Omega-unk_budget-v1.jsonl`**; the row **MUST NOT** proceed to any kernel.&#x20;
2. **Rounding hard-gate (MUST).** If a kernel advertises approximation, every `TRANSITION_OK` carries `meta.rounding_receipt_digest` referencing a `ROUNDING_RECEIPT{upper_bound=true, gap_bound≥0}`; missing witness ⇒ `rounding_missing`.&#x20;

---
## 12.7 Error Handling & Failure Receipts (fail-closed, machine-readable) {#implementation-errors}
```jsonc
// StageCard/v1
{
  "Admits": ["predicate failures", "guard rejections", "Ω recomputation results"],
  "Emits": ["ReceiptEnvelope/v1 (FAIL) with reason_code", "replay manifest inclusions"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["MERKLE_MISMATCH","BUNDLE_INCOMPLETE","TAIL_EXT_FAIL","envlock_unpinned","envlock_mismatch","envlock_expired","rounding_missing","REPLAY_MISMATCH","GOV_GUARD_FAIL","POLICY_VERSION_STALE"],
  "Links": []
}
```

<!-- opener:canon/v1 -->
<!-- pillars:once -->

<!-- 3-line opener -->

**Rules (normative).**
All failures are first-class **ReceiptEnvelope/v1** with registered reason codes; unknowns do **not** fallback—guards emit receipts/sidecar lines; failure receipts are content-addressed and included in replay manifests.&#x20;

---
## 12.8 CI & Conformance Gates (turn checklists into code) {#implementation-ci}
```jsonc
// StageCard/v1
{
  "Admits": ["spec tree", "CI config", "canonical fixtures", "EnvLock stance"],
  "Emits": ["Gate 0 verdict", "SSOT pointer lint report", "Merkle fixture check", "Negative-controls coverage", "EdgeKernelMap validation"],
  "Guards": [{"anchor":"#verification-ci-gates","content_b3":"b3:…"}],
  "FailFast": ["gate0_block","ssot_anchor_violation","receipt_first_mention_missing","json_noncanonical","rounding_missing","MERKLE_MISMATCH","predicate_family_coverage_gap","edge_kernel_map_missing"],
  "Links": [
    {"anchor":"#tpl-stagecard","content_b3":"b3:…"},
    {"anchor":"#chk-merkle-fixture","content_b3":"b3:…"}
  ]
}
```

<!-- opener:canon/v1 -->
<!-- pillars:once -->

<!-- 3-line opener -->

**Rules (normative).**

1. **Gate 0 (MUST).** Final QA Checklist (§10) must pass before minting a fresh `specid` or Ω acceptance.
2. **SSOT pointer lint (MUST).** Enforce `<!-- ssot-pointer:* -->` tokens, dupes/omissions fail; outside canonical homes are **link-only**.
3. **JSON example canon (MUST).** `jsonc` fences, sorted keys, fixed decimals, ban `NaN/Inf`.
4. **Merkle fixture (MUST).** Recompute bundle root and compare to the canonical fixture.
5. **Negative controls (MUST).** ≥1 must-fail per predicate family; CI fails if any returns PASS.
6. **EdgeKernelMap presence (MUST).** Fail if missing/malformed/unpinned.
7. **Portability cross-replay (MUST).** For `Strong`, run cross-replay matrix.&#x20;

---
## 12.9 Green-Path Skeleton (runnable, minimal) {#implementation-greenpath}
```jsonc
// StageCard/v1
{
  "Admits": ["scripts/", "fixtures/merkle/", "seed_domains.json"],
  "Emits": ["all-PASS bundle (≤10 receipts)", "tripwire path (must-fail)", "Ω proof_surface pairing"],
  "Guards": [
    {"anchor":"#commit-path","content_b3":"b3:…"},
    {"anchor":"#tpl-transport-boundary","content_b3":"b3:…"}
  ],
  "FailFast": ["MERKLE_MISMATCH","rounding_missing","GOV_GUARD_FAIL"],
  "Links": []
}
```

<!-- opener:canon/v1 -->
<!-- pillars:once -->

<!-- 3-line opener -->

**Required tree (normative).**

```
/scripts/              # stage drivers (EF→DRO→PR→CBF→Ω), --from/--to, --dry-run
/examples/green/       # all-PASS bundle (≤10 receipts)
/examples/tripwire/    # priced-unknown, wrong signer role, missing rounding witness
/artifacts/            # transport_pack.jsonl, receipts.jsonl, Omega-manifest-v1.json
/fixtures/merkle/      # canonical manifest + expected root
/seed_domains.json     # HKDF allow-list
```

CI must run both paths, recompute the Merkle root, and verify Ω’s `proof_surface`/surface preimage pairing.

---
## 12.10 Author Aids (point to Appendix E) {#implementation-author-todos}
```jsonc
// StageCard/v1
{
  "Admits": ["author intents"],
  "Emits": ["Appendix E links only (no restating)"],
  "Guards": [],
  "FailFast": ["todo_missing_negatives"],
  "Links": [
    {"anchor":"#tpl-transport-boundary","content_b3":"b3:…"},
    {"anchor":"#tpl-stagecard","content_b3":"b3:…"},
    {"anchor":"#chk-merkle-fixture","content_b3":"b3:…"},
    {"anchor":"#tpl-edge-kernel-map","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rule.** Retire ad-hoc “To-Dos”; use Appendix **E** templates & checklists only (EnvLock/containers, ReplayPlan skeleton, receipts checklist, ops runbook skeleton, must-fail/fixture matrix).&#x20;

---
### Minimal must-fail(s) introduced in §12

* *SeedDomainUnknown* — HKDF domain not in `seed_domains.json` ⇒ `SEED_DOMAIN_UNKNOWN`.&#x20;
* *ReplayMismatch* — `replay` divergence in receipts/ids/Merkle root ⇒ `REPLAY_MISMATCH`.&#x20;
* *MerkleFixtureMismatch* — fixture recomputation mismatch ⇒ `MERKLE_MISMATCH`.&#x20;
* *AdvertisedApproxNoWitness* — approx kernel missing `rounding_receipt_digest` ⇒ `rounding_missing`.&#x20;
* *PricedUnknownHalt* — priced-axis unknown triggers `C_UNK_PRICED`.&#x20;
### New schemas defined in §12

* *None* (all referenced via SSOT pointers to Appendix B).
### New reason codes requested in §12

* *None* (uses existing enums).
### Required cross-ref updates (outside scope)

* Add/update registry entries for any referenced schemas (`UpdateCert/v1`, `ReceiptEnvelope/v1`, `UnknownPricedAxisEvent/v1`) with frozen `schema_b3` in **Appendix B**.
* Ensure Ω stance echo rule is enforced per **§0.13** and **§2.8** (SSOT pointers already present).

&#x20;        &#x20;

---
# A. Glossary {#glossary}
```jsonc
// StageCard/v1
{
  "Admits": ["Concept terms", "Stable anchors"],
  "Emits": ["Canonical, single-source definitions", "SSOT pointers for related homes"],
  "Guards": [],
  "FailFast": ["duplicate_definition_outside_glossary", "non_ssot_crossref_in_def"],
  "Links": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"},
    {"anchor":"#axis-and-budgets","content_b3":"b3:…"},
    {"anchor":"#predicate-registry","content_b3":"b3:…"},
    {"anchor":"#foundations-verification","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples (if any) must validate via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

> **Scope & SSOT:** This Glossary is the single source of truth (SSOT) for terms. Other sections **link back here** via SSOT pointers. No section may restate or redefine these entries.

---

**Acceptance Algebra (Q)** — The *only* decision space: `Q = {ACCEPT, REJECT}` with order `REJECT < ACCEPT`; Boolean connectives are classical. Unknowns are handled by guards (not a third value). *SSOT links:* `{ "anchor":"#acceptance-algebra","content_b3":"b3:…" }`, `{ "anchor":"#unknowns-guard-first","content_b3":"b3:…" }`.&#x20;

**Acceptance Extensionality** — A checker’s verdict depends only on canonical tail bytes and the active EnvLock, not internal evaluation paths. Used by TailContracts and SPEC emission. *SSOT links:* `{ "anchor":"#receipt-canon","content_b3":"b3:…" }`, `{ "anchor":"#envlock","content_b3":"b3:…" }`, `{ "anchor":"#self-spec","content_b3":"b3:…" }`.&#x20;

**Adapter** — A pure (side-effect-free) module mapping artifacts to `Q`, with a declared axis whitelist. Must be *monotone* and *axis-isolating*. Conformance evidenced by `ADAPTER_AXIS_OK` and `ADAPTER_MONO_OK`. *SSOT links:* `{ "anchor":"#adapter-contracts","content_b3":"b3:…" }`, `{ "anchor":"#axis-and-budgets","content_b3":"b3:…" }`.&#x20;

**Axis Catalog** — Canonical registry of axes (name, class **S/M**, units, order, unknown-absorbing flag, caps, salts, policy groupings). **S-axes aggregate by sum; M-axes aggregate by max** in planning/posting contexts. Catalog is content-addressed and pinned. *SSOT links:* `{ "anchor":"#axis-and-budgets","content_b3":"b3:…" }`, `{ "anchor":"#delta-fr-invariants","content_b3":"b3:…" }`.&#x20;

**Bundle (Evidence Bundle)** — Immutable audit pack containing receipt leaves, tail witnesses, and a manifest with Merkle root, all bound into `proof_surface`. *SSOT links:* `{ "anchor":"#state-and-evidence","content_b3":"b3:…" }`, `{ "anchor":"#commit-path","content_b3":"b3:…" }`.&#x20;

**BUNDLE\_INCOMPLETE** — Ω-stage failure code when required receipts or manifest entries are missing from the Evidence Bundle. *SSOT links:* `{ "anchor":"#pipeline","content_b3":"b3:…" }`, `{ "anchor":"#commit-path","content_b3":"b3:…" }`.&#x20;

**canon/v1** — Canonical JSON rules (UTF-8; keys sorted; fixed decimals; forbid `NaN`/`±Inf`; no extraneous whitespace). All normative artifacts use `canon/v1`. *SSOT links:* `{ "anchor":"#howto","content_b3":"b3:…" }`, `{ "anchor":"#predicate-registry","content_b3":"b3:…" }`.&#x20;

**Canonical Input View (CIV)** — Minimal, content-addressed projection of inputs produced *before* any kernel. Guards reason over CIV, not raw inputs. *SSOT links:* `{ "anchor":"#civ-canon","content_b3":"b3:…" }`, `{ "anchor":"#evidence","content_b3":"b3:…" }`.&#x20;

**CIV Contract (CIVContract/v1)** — Executable JSON that adapters **must** consume verbatim: `{schema_id, source, axis_whitelist, view_digest, …}`. Establishes the universal pre-kernel interface. *SSOT links:* `{ "anchor":"#civ-canon","content_b3":"b3:…" }`, `{ "anchor":"#adapter-contracts","content_b3":"b3:…" }`.&#x20;

**CBF (Cost/Barrier/Frontier)** — Stage that prices Δ\_fr postings, enforces budget/group caps, and appends to the ledger. *SSOT links:* `{ "anchor":"#frontier-debit","content_b3":"b3:…" }`, `{ "anchor":"#axis-and-budgets","content_b3":"b3:…" }`.&#x20;

**Checker Hash (checker\_hash)** — BLAKE3-256 digest (prefixed) of canonicalized checker/kernel bytes; pairs with `envlock_digest` to bind receipts to code+environment. *SSOT links:* `{ "anchor":"#envlock","content_b3":"b3:…" }`, `{ "anchor":"#receipt-canon","content_b3":"b3:…" }`.&#x20;

**C\_UNK\_PRICED** — Deterministic `FAIL` receipt emitted by the Unknowns Guard when a priced axis would receive `⊥`; halts the row and logs an `UnknownPricedAxisEvent/v1`. *SSOT links:* `{ "anchor":"#unknowns-guard","content_b3":"b3:…" }`.&#x20;

**Δ\_fr (Frontier Debit)** — Multiaxis debit priced at frontier crossings; obeys monotonicity, subadditivity, and rounding axioms; posted once, atomically. *SSOT links:* `{ "anchor":"#frontier-debit","content_b3":"b3:…" }`, `{ "anchor":"#commit-path","content_b3":"b3:…" }`.&#x20;

**DETERMINISM\_OK** — Receipt asserting byte-identical outcomes across the EnvLock portability set (per stance). *SSOT links:* `{ "anchor":"#verification","content_b3":"b3:…" }`, `{ "anchor":"#envlock","content_b3":"b3:…" }`.&#x20;

**DRO (Data/Rules Onboarding)** — Stage that ingests corpora, adapters, policy artifacts; runs early guards. *SSOT links:* `{ "anchor":"#pipeline","content_b3":"b3:…" }`.&#x20;

**Edge→Pricing Kernel Map (EdgeKernelMap/v1)** — Generated artifact binding `edge_id → pricing_kernel → axes_touched → rounding_policy`; pinned in the bundle. *SSOT links:* `{ "anchor":"#frontier-debit","content_b3":"b3:…" }`, `{ "anchor":"#predicate-registry","content_b3":"b3:…" }`.&#x20;

**EnvLock** — Signed environment lock (allowed `checker_hash` set, runtime fingerprints, kernel ABIs, policies). Every receipt carries the active `envlock_digest`. *SSOT links:* `{ "anchor":"#envlock","content_b3":"b3:…" }`, `{ "anchor":"#receipt-canon","content_b3":"b3:…" }`.&#x20;

**Evidence Shape (ReceiptEnvelope/v1)** — Uniform receipt envelope: `(predicate_id, inputs_digest, checker_hash, envlock_digest, verdict, witness_digest?, meta?)`. **No variants permitted.** All PASS/FAIL envelopes are Merkle leaves. *SSOT links:* `{ "anchor":"#receipt-canon","content_b3":"b3:…" }`.&#x20;

**Expectiminimax (generalized)** — Planning objective over axes: S-axes sum; M-axes take worst-case (max). Applied over Δ\_fr/Q postings. *SSOT links:* `{ "anchor":"#frontier-debit","content_b3":"b3:…" }`, `{ "anchor":"#self-spec","content_b3":"b3:…" }`.&#x20;

**GMM (Generative/Inverse Layer)** — Propose → Score in `Q′` → Commit (`Q′ → Q`) with TailContracts. Deterministic via HKDF(BLAKE3) domain separation. *SSOT links:* `{ "anchor":"#gmm","content_b3":"b3:…" }`, `{ "anchor":"#gmm-replay","content_b3":"b3:…" }`.&#x20;

**Governance Guard** — Predicate on transitions (roles/signatures/quotas/attestations). Must-fail fixtures include `GOV_GUARD_FAIL` and `POLICY_VERSION_STALE`. *SSOT links:* `{ "anchor":"#governance","content_b3":"b3:…" }`, `{ "anchor":"#negatives","content_b3":"b3:…" }`.&#x20;

**HGraph (Hypothesis Graph)** — Content-addressed graph of generative proposals/diagnostics; checkpointable in the Ephemeral Pack. *SSOT links:* `{ "anchor":"#gmm","content_b3":"b3:…" }`.&#x20;

**HKDF(BLAKE3)** — Seed derivation (extract-then-expand) with domain allow-list; produces deterministic RNG streams per stage. *SSOT links:* `{ "anchor":"#runtime-semantics","content_b3":"b3:…" }`.&#x20;

**I11 / I12 / I13** — TailContract families: I11 (contraction), I12 (ISS/tube invariants), I13 (WSTS/closure). *SSOT links:* `{ "anchor":"#evidence","content_b3":"b3:…" }`, `{ "anchor":"#negatives","content_b3":"b3:…" }`.&#x20;

**Loader (Normative Loader)** — Drives guards/kernels, enforces rank and dwell (No-Zeno), validates receipts, and applies hard gates (unknowns/rounding). *SSOT links:* `{ "anchor":"#pipeline","content_b3":"b3:…" }`, `{ "anchor":"#foundations-verification","content_b3":"b3:…" }`.&#x20;

**MERKLE\_MISMATCH** — Ω-stage failure code when bundle manifest bytes recompute to a root that does not match the recorded Merkle root. *SSOT links:* `{ "anchor":"#commit-path","content_b3":"b3:…" }`, `{ "anchor":"#pipeline","content_b3":"b3:…" }`.&#x20;

**Ω (Omega)** — Terminal stage that verifies budgets, bundle completeness, Merkle root, portability stance echo, and emits `SurfaceV1.json` + `proof_surface`. *SSOT links:* `{ "anchor":"#pipeline","content_b3":"b3:…" }`, `{ "anchor":"#commit-path","content_b3":"b3:…" }`.&#x20;

**PerfReceipt** — Canonical performance metrics receipt bound to an EnvLock and bench manifest. *SSOT links:* `{ "anchor":"#verification","content_b3":"b3:…" }`.&#x20;

**Policy Artifact** — Content-addressed JSON for thresholds, budgets, search policy, guard lists; advanced via `UpdateCert/v1`. *SSOT links:* `{ "anchor":"#governance","content_b3":"b3:…" }`, `{ "anchor":"#axis-and-budgets","content_b3":"b3:…" }`.&#x20;

**Portability Stance** — `Strong | Qualified | Weak`. Ω echoes the stance; `Strong` requires CI cross-replay on the allowed platform set. *SSOT links:* `{ "anchor":"#envlock","content_b3":"b3:…" }`, `{ "anchor":"#verification","content_b3":"b3:…" }`.&#x20;

**proof\_surface** — BLAKE3-256 digest binding the Ω preimage (bundle Merkle root, EnvLock digest, input/policy digests, lineage). `SurfaceV1.json` hashes to this value. *SSOT links:* `{ "anchor":"#commit-path","content_b3":"b3:…" }`, `{ "anchor":"#pipeline","content_b3":"b3:…" }`.&#x20;

**Q′ (Uncertainty Lift / Result Contract)** — Tuple `(q ∈ Q, receipt_ref, metrics)` with projection `π(Q′)=q`. Metrics are informative and **cannot** upgrade `REJECT→ACCEPT`. *SSOT links:* `{ "anchor":"#uncertainty-lift","content_b3":"b3:…" }`.&#x20;

**Receipt Canon (ReceiptEnvelope/v1)** — See **Evidence Shape**; the Loader recomputes `checker_hash` and enforces membership in EnvLock. *SSOT links:* `{ "anchor":"#receipt-canon","content_b3":"b3:…" }`, `{ "anchor":"#envlock","content_b3":"b3:…" }`.&#x20;

**ReplayPlan** — Canonical plan pinning EnvLock, code commit, seed roots, input list, and stage order for byte-for-byte replay. *SSOT links:* `{ "anchor":"#runtime-semantics","content_b3":"b3:…" }`, `{ "anchor":"#verification","content_b3":"b3:…" }`.&#x20;

**RoundingReceipt (ROUNDING\_RECEIPT)** — Proof that an approximation is a *sound upper bound* with declared `gap_bound ≥ 0`. **Hard gate:** if a kernel advertises approximation mode, any `TRANSITION_OK` **must** include `meta.rounding_receipt_digest`; else `rounding_missing`. *SSOT links:* `{ "anchor":"#frontier-debit","content_b3":"b3:…" }`, `{ "anchor":"#pipeline","content_b3":"b3:…" }`.&#x20;

**Safety-or-Halt** — With Loader rank, dwell, and TailContracts, runs either emit `ACCEPT` receipts (and continue) or halt deterministically; no silent non-terminations. *SSOT links:* `{ "anchor":"#foundations-verification","content_b3":"b3:…" }`.&#x20;

**Seed Domain** — HKDF(BLAKE3) `info` string separating RNG streams; managed in a machine-readable allow-list (`seed_domains.json`). *SSOT links:* `{ "anchor":"#gmm-replay","content_b3":"b3:…" }`, `{ "anchor":"#runtime-semantics","content_b3":"b3:…" }`.&#x20;

**SPEC (SPECDoc/v1)** — Machine-consumable description of run behavior produced by SpecEmitter; must round-trip to receipts (`SPEC_ROUNDTRIP_OK`). *SSOT links:* `{ "anchor":"#self-spec","content_b3":"b3:…" }`, `{ "anchor":"#receipt-canon","content_b3":"b3:…" }`.&#x20;

**SSG (Self-Similarity Grammar)** — Canonical grammar for corpus structure with diagnostics and tail hooks; used by GMM/SSG tools. *SSOT links:* `{ "anchor":"#self-similarity","content_b3":"b3:…" }`.&#x20;

**SurfaceV1.json** — Canonical Ω preimage JSON that hashes to `proof_surface`. *SSOT links:* `{ "anchor":"#commit-path","content_b3":"b3:…" }`.&#x20;

**TAIL\_EXT\_FAIL** — Ω-stage failure code for TailContracts extensionality violation (tail bytes don’t justify the verdict under EnvLock). *SSOT links:* `{ "anchor":"#negatives","content_b3":"b3:…" }`, `{ "anchor":"#envlock","content_b3":"b3:…" }`.&#x20;

**Three Pillars (PILLARS)** — Atomic triad **EnvLock ⇄ Receipts ⇄ CIV**; a paste-once macro after the first mention of *Receipts* or *CIV* in any subsection prevents drift. *SSOT links:* `{ "anchor":"#howto","content_b3":"b3:…" }`, `{ "anchor":"#pipeline","content_b3":"b3:…" }`.&#x20;

**Transport Pack** — Transactional, append-only **state** carrier between stages; distinct from the Evidence Bundle (audit). Resume tokens reference its head digest. *SSOT links:* `{ "anchor":"#state-and-evidence","content_b3":"b3:…" }`.&#x20;

**TRANSITION\_OK** — Receipt that posts Δ\_fr for a priced edge. When approximation mode is advertised, **must** carry `meta.rounding_receipt_digest` referencing a `ROUNDING_RECEIPT`. *SSOT links:* `{ "anchor":"#frontier-debit","content_b3":"b3:…" }`, `{ "anchor":"#pipeline","content_b3":"b3:…" }`.&#x20;

**UnknownPricedAxisEvent/v1** — JSONL sidecar event logged when `C_UNK_PRICED` occurs (canonical filename `Omega-unk_budget-v1.jsonl`). *SSOT links:* `{ "anchor":"#unknowns-guard","content_b3":"b3:…" }`, `{ "anchor":"#state-and-evidence","content_b3":"b3:…" }`.&#x20;

**Unknowns Guard (⊥)** — Guard that enforces fail-closed handling of unknowns. For priced axes, emits `C_UNK_PRICED` and stops the row; unpriced behavior is policy-controlled. *SSOT links:* `{ "anchor":"#unknowns-guard","content_b3":"b3:…" }`.&#x20;

**UpdateCert (UpdateCert/v1)** — Proof-carrying policy change object (signatures, bisimulation/Σ-non-expansion proofs) that advances EnvLock/policy. *SSOT links:* `{ "anchor":"#governance","content_b3":"b3:…" }`, `{ "anchor":"#envlock","content_b3":"b3:…" }`.&#x20;

**Ω Merkle Recipe (fixture-backed)** — Single normative construction: `leaf = BLAKE3(0x00||leaf_bytes)`, `node = BLAKE3(0x01||left||right)`, odd-node duplication, root encoded `b3:<hex>`. **All repos MUST** prove compliance by recomputing the fixture root in CI. *SSOT links:* `{ "anchor":"#commit-path","content_b3":"b3:…" }`.&#x20;

**CI Gate 0 (Pre-publish)** — The Final QA Checklist promoted to a mandatory CI gate; spec cannot carry a fresh `specid` and Ω cannot accept a run unless Gate 0 passes. *SSOT links:* `{ "anchor":"#howto","content_b3":"b3:…" }`, `{ "anchor":"#verification","content_b3":"b3:…" }`.&#x20;

---

**Required cross-ref updates (outside scope):**

* Ensure each section that first mentions *Receipts* or *CIV* pastes the PILLARS one-liner and links back here via SSOT pointers.
* Confirm Appendix B registers schemas referenced by glossary terms (ReceiptEnvelope/v1, CIVContract/v1, UnknownPricedAxisEvent/v1, ROUNDING\_RECEIPT) with frozen `schema_b3`.&#x20;

---
## Appendix B — Schemas  {#appendix-b}
```jsonc
// StageCard/v1
{
  "Admits": ["Schema definitions", "Predicate registry entries", "EnvLock digest & checker hash allowlist"],
  "Emits": ["JSON Schema canon/v1 files", "ReceiptEnvelope/v1", "Omega surface shapes"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ],
  "FailFast": ["variant_envelope", "schema_additional_props", "receipt_missing_schema"],
  "Links": [
    {"anchor":"#examples","content_b3":"b3:…"},
    {"anchor":"#negatives","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This appendix is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.&#x20;
<!-- opener:canon/v1 -->
<!-- pillars:once -->

> **SSOT discipline (normative):** This appendix is the single source of truth for **all JSON schemas and receipt/envelope shapes**. Keep **one canonical version per type** (e.g., `ReceiptEnvelope/v1`, `TRANSITION_OK`, `ROUNDING_RECEIPT`, `EnvLock/v1`, `UpdateCert/v1`). Commentary and long examples live in Appendix D via SSOT pointers only.

> **Serialization:** canon/v1; digests are `b3:<hex>` (BLAKE3-256, lowercase). All schemas forbid `additionalProperties` unless explicitly stated.

> **Anchors (stable):** `#schema-receipt-envelope` (ReceiptEnvelope/v1) · `#schema-guards` (Guard receipts) · `#schema-tail` (TailReceipt) · `#schema-pricing` (Kernel & Pricing).

---
## B.1 Receipt Envelope (base) {#schema-receipt-envelope}
```jsonc
// StageCard/v1
{
  "Admits": ["Receipt bodies from guards/kernels/Ω"],
  "Emits": ["ReceiptEnvelope/v1"],
  "Guards": [{"anchor":"#envlock","content_b3":"b3:…"}],
  "FailFast": ["variant_envelope", "receipt_missing_schema"],
  "Links": [{"anchor":"#examples","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/receipt-envelope.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "ReceiptEnvelope/v1",
  "type": "object",
  "required": [
    "schema_id","schema_b3",
    "predicate_id","inputs_digest","checker_hash","envlock_digest","verdict"
  ],
  "properties": {
    "schema_id":      { "const": "ReceiptEnvelope/v1" },
    "schema_b3":      { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "predicate_id":   { "type": "string", "pattern": "^[A-Z0-9_]+$" },
    "inputs_digest":  { "type": "string", "pattern": "^b3:[a-f0-9]{64}(\\|\\|.*)?$" },
    "checker_hash":   { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "envlock_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "verdict":        { "type": "string", "enum": ["PASS", "FAIL"] },
    "witness_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "reason_code":    { "type": "string", "pattern": "^[A-Z0-9_]+$" },
    "meta":           { "type": "object", "additionalProperties": true }
  },
  "additionalProperties": false
}
```

**Rules (normative).**

1. **Uniform envelope.** **All** receipts must validate against **ReceiptEnvelope/v1**; **no variants** are permitted (`reason_code: variant_envelope`).
2. **EnvLock pinning.** Loader rejects any receipt whose `checker_hash` is not present in the active EnvLock or whose `envlock_digest` mismatches (see SSOT `{ "anchor":"#envlock","content_b3":"b3:…" }`).
3. **Schema presence.** Each receipt **MUST** include `schema_id` and `schema_b3` matching this schema; else `reason_code: receipt_missing_schema`.

---
## B.2 Guard Receipts {#schema-guards}
```jsonc
// StageCard/v1
{
  "Admits": ["CIVContract header", "Unknowns Guard outcomes", "Adapter conformance"],
  "Emits": ["CIVContract/v1", "CANON_INPUT_VIEW", "C_UNK_PRICED", "UnknownPricedAxisEvent/v1"],
  "Guards": [{"anchor":"#civ-canon","content_b3":"b3:…"}],
  "FailFast": ["unknown_on_priced_axis", "adapter_civ_reject"],
  "Links": [{"anchor":"#unknowns-guard","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->
### B.2.0 CIVContract/v1 (adapter-consumed)
```jsonc
// StageCard/v1
{
  "Admits": ["CIV header bytes"],
  "Emits": ["CIVContract/v1"],
  "Guards": [{"anchor":"#civ-canon","content_b3":"b3:…"}],
  "FailFast": ["adapter_civ_reject"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/guards/civ_contract.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "CIVContract/v1",
  "type": "object",
  "required": ["schema_id", "schema_b3", "source", "axis_whitelist", "view_digest"],
  "properties": {
    "schema_id":      { "const": "CIVContract/v1" },
    "schema_b3":      { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "created":        { "type": "string", "format": "date-time" },
    "source":         { "type": "string", "enum": ["transport_pack", "adapter", "other"] },
    "axis_whitelist": { "type": "array", "items": { "type": "string" }, "minItems": 1 },
    "view_digest":    { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" }
  },
  "additionalProperties": false
}
```

> **Role (normative).** Minimal, content-addressed CIV header adapters must accept verbatim as the pre-kernel gate. SSOT: `{ "anchor":"#civ-canon","content_b3":"b3:…" }`.
### B.2.1 CANON\_INPUT\_VIEW (receipt)
```jsonc
// StageCard/v1
{
  "Admits": ["CIVContract/v1 bytes"],
  "Emits": ["ReceiptEnvelope/v1 (predicate: CANON_INPUT_VIEW)"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["receipt_missing_schema"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/guards/canon_input_view.schema.json",
  "allOf": [
    { "$ref": "https://sirus/spec/v1/receipt-envelope.schema.json" },
    {
      "type": "object",
      "properties": {
        "predicate_id": { "const": "CANON_INPUT_VIEW" },
        "meta": {
          "type": "object",
          "required": ["view_digest"],
          "properties": {
            "view_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" }
          },
          "additionalProperties": false
        }
      }
    }
  ]
}
```

**Example (valid, minimal).**

```jsonc
// ReceiptEnvelope/v1
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "CANON_INPUT_VIEW",
  "inputs_digest": "b3:…",
  "checker_hash": "b3:…",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": { "view_digest": "b3:…" }
}
```
### B.2.2 C\_UNK\_PRICED (receipt; Unknowns Guard)
```jsonc
// StageCard/v1
{
  "Admits": ["Observation ⊥ on priced axis"],
  "Emits": ["ReceiptEnvelope/v1 (predicate: C_UNK_PRICED)", "UnknownPricedAxisEvent/v1 ledger line"],
  "Guards": [{"anchor":"#unknowns-guard","content_b3":"b3:…"}],
  "FailFast": ["unknown_on_priced_axis"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/guards/c_unk_priced.schema.json",
  "allOf": [
    { "$ref": "https://sirus/spec/v1/receipt-envelope.schema.json" },
    {
      "type": "object",
      "properties": {
        "predicate_id": { "const": "C_UNK_PRICED" },
        "verdict": { "const": "FAIL" },
        "reason_code": { "const": "UNKNOWN_ON_PRICED_AXIS" },
        "meta": {
          "type": "object",
          "required": ["axis", "row_id"],
          "properties": {
            "axis":  { "type": "string" },
            "row_id":{ "type": "string" }
          },
          "additionalProperties": false
        }
      }
    }
  ]
}
```

> **Behavior (normative).** On `⊥` for **priced** axes: emit this receipt, append one line to `Omega-unk_budget-v1.jsonl`, **stop processing the current row**, continue with next. SSOT pointer: `{ "anchor":"#unknowns-guard","content_b3":"b3:…" }`.
#### B.2.2.1 UnknownPricedAxisEvent/v1 (ledger sidecar)
```jsonc
// StageCard/v1
{
  "Admits": ["Priced-axis unknown detection"],
  "Emits": ["UnknownPricedAxisEvent/v1 JSONL line"],
  "Guards": [],
  "FailFast": ["ledger_sidecar_malformed"],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/guards/unknown_priced_axis_event.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "UnknownPricedAxisEvent/v1",
  "description": "JSONL event when ⊥ is encountered on a priced axis; row processing halts.",
  "type": "object",
  "required": ["schema", "schema_b3", "row_id", "axis", "ts"],
  "properties": {
    "schema":  { "const": "UnknownPricedAxisEvent/v1" },
    "schema_b3": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "row_id":  { "type": "string" },
    "axis":    { "type": "string" },
    "value":   {},
    "ts":      { "type": "string", "format": "date-time" },
    "run_id":  { "type": "string" },
    "source":  { "type": "string" }
  },
  "additionalProperties": false
}
```

---
## B.3 TailReceipt (TailContracts) {#schema-tail}
```jsonc
// StageCard/v1
{
  "Admits": ["Tail bytes + EnvLock echo", "Axis bindings"],
  "Emits": ["TAIL_(I11|I12|I13)_OK receipts with witness_digest"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["tail_ext_fail"],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/tail/tail_receipt.schema.json",
  "allOf": [
    { "$ref": "https://sirus/spec/v1/receipt-envelope.schema.json" },
    {
      "type": "object",
      "required": ["witness_digest"],
      "properties": {
        "predicate_id": { "type": "string", "pattern": "^TAIL_(I11|I12|I13)_OK$" },
        "meta": {
          "type": "object",
          "required": ["family", "accept_extensional_in", "axis_bindings", "expected_work_bound"],
          "properties": {
            "family": { "type": "string", "enum": ["I11", "I12", "I13"] },
            "accept_extensional_in": {
              "type": "object",
              "required": ["tail_bytes_digest", "envlock_digest"],
              "properties": {
                "tail_bytes_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
                "envlock_digest":    { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" }
              },
              "additionalProperties": false
            },
            "axis_bindings":        { "type": "object", "additionalProperties": { "type": "number" } },
            "expected_work_bound":  { "type": "number" }
          },
          "additionalProperties": false
        }
      }
    }
  ]
}
```

---
## B.4 Kernel & Pricing {#schema-pricing}
```jsonc
// StageCard/v1
{
  "Admits": ["Kernel transitions", "Rounding receipts when approx=true"],
  "Emits": ["TRANSITION_OK", "ROUNDING_RECEIPT"],
  "Guards": [{"anchor":"#delta-fr-invariants","content_b3":"b3:…"}],
  "FailFast": ["rounding_missing"],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->
### B.4.1 TRANSITION\_OK
```jsonc
// StageCard/v1
{
  "Admits": ["Edge transition data", "Kernel identity"],
  "Emits": ["ReceiptEnvelope/v1 (predicate: TRANSITION_OK)"],
  "Guards": [],
  "FailFast": ["rounding_missing"],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/pricing/transition_ok.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "TRANSITION_OK (Δ_fr posting)",
  "allOf": [
    { "$ref": "https://sirus/spec/v1/receipt-envelope.schema.json" },
    {
      "type": "object",
      "properties": {
        "predicate_id": { "const": "TRANSITION_OK" },
        "meta": {
          "type": "object",
          "required": ["edge_id", "kernel_id", "q_posting"],
          "properties": {
            "edge_id":  { "type": "string" },
            "kernel_id":{ "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "q_posting": {
              "type": "object",
              "description": "Axis → value mapping (numbers for Q; intervals serialized in Q′ contexts).",
              "additionalProperties": { "type": ["number", "string"] }
            },
            "rounding_receipt_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" }
          },
          "additionalProperties": false
        }
      }
    }
  ]
}
```

> **Approximation hard gate (normative).** If a kernel **advertises approximation mode** for a run, any `TRANSITION_OK` **without** `meta.rounding_receipt_digest` **MUST** be rejected (`reason_code: rounding_missing`). SSOT: `{ "anchor":"#delta-fr-invariants","content_b3":"b3:…" }`.
### B.4.2 ROUNDING\_RECEIPT
```jsonc
// StageCard/v1
{
  "Admits": ["Rounding/relaxation proof"],
  "Emits": ["ReceiptEnvelope/v1 (predicate: ROUNDING_RECEIPT)"],
  "Guards": [],
  "FailFast": [],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/pricing/rounding_receipt.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "ROUNDING_RECEIPT (sound upper bound)",
  "allOf": [
    { "$ref": "https://sirus/spec/v1/receipt-envelope.schema.json" },
    {
      "type": "object",
      "properties": {
        "predicate_id": { "const": "ROUNDING_RECEIPT" },
        "meta": {
          "type": "object",
          "required": ["kernel_id", "upper_bound", "gap_bound"],
          "properties": {
            "kernel_id":  { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "upper_bound":{ "type": "boolean", "const": true },
            "gap_bound":  { "type": "number", "minimum": 0 }
          },
          "additionalProperties": false
        }
      }
    }
  ]
}
```

> `upper_bound = true` certifies the rounding/relaxation is conservative; `gap_bound ≥ 0` is the numeric slack bound. Link from `TRANSITION_OK.meta.rounding_receipt_digest` when approximation is advertised.

---

> **Notes (link-only; do not restate here):**
> • Bundle manifest & Merkle recipe live at `{ "anchor":"#commit-path","content_b3":"b3:…" }`.
> • Edge→Pricing Kernel Map (generated artifact) is specified with the pricing flow in §§3.5–5; implementations **must** emit and pin it via SSOT pointer.

---
## B.5 Ω & Surface {#schema-omega}
```jsonc
// StageCard/v1
{
  "Admits": ["Ω close inputs", "Bundle manifest root", "EnvLock"],
  "Emits": ["OmegaReceipt/v1", "SurfaceV1.json (preimage of proof_surface)"],
  "Guards": [{"anchor":"#envlock","content_b3":"b3:…"}],
  "FailFast": ["merkle_mismatch", "tail_ext_fail"],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->
### B.5.1 OmegaReceipt (Ω finalization receipt; echoes portability stance)
```jsonc
// StageCard/v1
{
  "Admits": ["Final q_final and budgets", "Bundle Merkle root", "Surface digest"],
  "Emits": ["ReceiptEnvelope/v1 (predicate: OMEGA)"],
  "Guards": [],
  "FailFast": ["merkle_mismatch"],
  "Links": [{"anchor":"#envlock","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/omega/omega_receipt.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "OmegaReceipt/v1",
  "allOf": [
    { "$ref": "https://sirus/spec/v1/receipt-envelope.schema.json" },
    {
      "type": "object",
      "required": ["meta"],
      "properties": {
        "predicate_id": { "const": "OMEGA" },
        "meta": {
          "type": "object",
          "required": [
            "q_final",
            "budget_vector",
            "bundle_merkle_root",
            "proof_surface",
            "envlock_digest",
            "portability_stance"
          ],
          "properties": {
            "q_final": {
              "type": "object",
              "additionalProperties": { "type": "number" },
              "description": "Final aggregated Q (axis-wise)."
            },
            "budget_vector": {
              "type": "object",
              "additionalProperties": { "type": "number" },
              "description": "Per-axis caps B that Ω enforced."
            },
            "bundle_merkle_root": {
              "type": "string",
              "pattern": "^b3:[a-f0-9]{64}$",
              "description": "Merkle root of the Evidence Bundle manifest."
            },
            "proof_surface": {
              "type": "string",
              "pattern": "^b3:[a-f0-9]{64}$",
              "description": "BLAKE3-256 digest of SurfaceV1.json (see B.5.2)."
            },
            "envlock_digest": {
              "type": "string",
              "pattern": "^b3:[a-f0-9]{64}$",
              "description": "EnvLock/v1 digest that governed the run."
            },
            "portability_stance": {
              "type": "string",
              "enum": ["STRONG", "CONSTRAINED", "NONE"],
              "description": "Echo of EnvLock portability stance (see B.6.1); STRONG implies cross-replay CI."
            }
          },
          "additionalProperties": false
        }
      }
    }
  ]
}
```

> `q_final` reports the run’s final aggregated `Q`; `budget_vector` lists per-axis caps enforced at Ω; `bundle_merkle_root` ties to the evidence bundle; `proof_surface` is the digest of `SurfaceV1.json`; `envlock_digest` and `portability_stance` echo the governing EnvLock/v1.
### B.5.2 SurfaceV1 (preimage → `proof_surface`)
```jsonc
// StageCard/v1
{
  "Admits": ["Bundle Merkle root", "EnvLock digest", "code commit", "axis catalog", "policy digests", "replay plan", "slurm job ids"],
  "Emits": ["SurfaceV1.json", "proof_surface digest (b3:…)"],
  "Guards": [],
  "FailFast": ["merkle_mismatch"],
  "Links": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/omega/surface_v1.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "SurfaceV1.json",
  "type": "object",
  "required": [
    "schema_id","schema_b3",
    "bundle_merkle_root",
    "envlock_digest",
    "code_commit",
    "input_corpus",
    "axis_catalog_digest",
    "policy_digests",
    "replayplan_digest",
    "slurm_job_ids",
    "pillars"
  ],
  "properties": {
    "schema_id": { "const": "SurfaceV1.json" },
    "schema_b3": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "bundle_merkle_root": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "envlock_digest":     { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "code_commit":        { "type": "string", "pattern": "^[0-9a-f]{40}$" },
    "input_corpus": {
      "type": "array",
      "items": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" }
    },
    "axis_catalog_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "policy_digests": {
      "type": "array",
      "items": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" }
    },
    "replayplan_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "slurm_job_ids": {
      "type": "array",
      "items": { "type": "string", "pattern": "^[0-9]+$" }
    },
    "pillars": {
      "type": "object",
      "description": "Pins the triad (EnvLock ⇄ Receipts ⇄ CIV) as SSOT.",
      "required": ["receipt_envelope_schema", "civ_contract_schema"],
      "properties": {
        "receipt_envelope_schema": { "const": "ReceiptEnvelope/v1" },
        "civ_contract_schema":     { "const": "CIVContract/v1" }
      },
      "additionalProperties": false
    }
  },
  "additionalProperties": false
}
```

> `SurfaceV1.json` is the canonical preimage whose BLAKE3-256 digest is the run’s `proof_surface`. The `pillars` object locks the SSOT triad used throughout the run.

---
## B.6 EnvLock & ReplayPlan {#schema-envlock-replay}
### B.6.1 EnvLock/v1 (includes portability stance)
```jsonc
// StageCard/v1
{
  "Admits": ["EnvLock draft", "platform inventory", "checker set"],
  "Emits": ["EnvLock/v1 canonical JSON", "envlock_digest (b3:…)", "portability stance echo requirement"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": ["envlock_missing_fields", "portability_echo_missing", "fp_mode_unsupported"],
  "Links": [
    {"anchor":"#commit-path","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/envlock.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "EnvLock/v1",
  "type": "object",
  "required": ["object", "platforms", "container_digest", "python", "libs", "fp", "portability_stance"],
  "properties": {
    "object": { "const": "EnvLock/v1" },
    "platforms": { "type": "array", "minItems": 1, "items": { "type": "string" } },
    "container_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "python": { "type": "string" },
    "libs": { "type": "object", "additionalProperties": { "type": "string" } },
    "fp": {
      "type": "object",
      "required": ["fma", "round", "denormals"],
      "properties": {
        "fma": { "type": "string", "enum": ["on", "off"] },
        "round": { "type": "string", "enum": ["nearest"] },
        "denormals": { "type": "string", "enum": ["preserve", "flush"] }
      },
      "additionalProperties": false
    },
    "deterministic_gpu": { "type": "boolean" },
    "portability_stance": {
      "type": "string",
      "enum": ["STRONG", "CONSTRAINED", "NONE"],
      "description": "Declares replay expectations; Ω echoes this in OmegaReceipt."
    }
  },
  "additionalProperties": false
}
```

**Rules (normative).**

1. Ω **MUST** echo `portability_stance` into the final surface and `OMEGA` receipt; missing echo ⇒ `portability_echo_missing`.
2. Checkers referenced by receipts **MUST** be authorized by this EnvLock (SSOT pointer: `{ "anchor":"#receipt-canon","content_b3":"b3:…"}`).
3. Unsupported FP modes for the target `platforms` **MUST** fail (`fp_mode_unsupported`).

---
### B.6.2 ReplayPlan/v1
```jsonc
// StageCard/v1
{
  "Admits": ["envlock_digest", "code_commit", "seed domains", "inputs", "stage order"],
  "Emits": ["ReplayPlan/v1 canonical JSON", "Deterministic HKDF roots"],
  "Guards": [{"anchor":"#gmm-replay","content_b3":"b3:…"}],
  "FailFast": ["seed_domain_unauthorized", "stage_order_invalid"],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/replayplan.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "ReplayPlan/v1",
  "type": "object",
  "required": ["envlock_digest", "code_commit", "seed_roots", "inputs", "stage_order"],
  "properties": {
    "envlock_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "code_commit": { "type": "string", "pattern": "^[0-9a-f]{40}$" },
    "seed_roots": {
      "type": "object",
      "additionalProperties": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
      "description": "HKDF root seeds per named domain."
    },
    "inputs": { "type": "array", "items": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" } },
    "stage_order": {
      "type": "array",
      "items": { "type": "string", "enum": ["EF", "DRO", "PR", "CBF", "OMEGA"] },
      "minItems": 1
    }
  },
  "additionalProperties": false
}
```

**Rule.** `seed_roots` **MUST** be consumed only for registered domains; otherwise **FAIL** with `seed_domain_unauthorized` (SSOT pointer: `{ "anchor":"#gmm-replay","content_b3":"b3:…"}`).

---
### B.6.3 CIVContract/v1 (executable guard contract; adapters consume verbatim)
```jsonc
// StageCard/v1
{
  "Admits": ["Adapter boundary requirements"],
  "Emits": ["CIVContract/v1 canonical JSON", "view_digest"],
  "Guards": [{"anchor":"#civ-canon","content_b3":"b3:…"}],
  "FailFast": ["civ_contract_variant"],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/civ_contract.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "CIVContract/v1",
  "type": "object",
  "required": ["schema_id", "source", "axis_whitelist", "view_digest"],
  "properties": {
    "schema_id": { "const": "CIVContract/v1" },
    "created":   { "type": "string", "format": "date-time" },
    "source":    { "type": "string", "enum": ["transport_pack", "external", "synthetic"] },
    "axis_whitelist": { "type": "array", "minItems": 1, "items": { "type": "string" } },
    "view_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" }
  },
  "additionalProperties": false
}
```

**Rule.** Adapters **MUST** accept this field set **verbatim**. Variant shapes **MUST** fail (`civ_contract_variant`).

---
## B.7 SPEC & UpdateCert {#schema-spec-update}
### B.7.1 SPECDoc/v1 (SPEC.json)
```jsonc
// StageCard/v1
{
  "Admits": ["proof_surface", "envlock_digest", "policy_digests", "guards/kernels/tails lists"],
  "Emits": ["SPECDoc/v1 canonical JSON", "spec_digest (b3:…)"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["spec_roundtrip_fail"],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/specdoc.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "SPECDoc/v1",
  "type": "object",
  "required": ["proof_surface", "envlock_digest", "policy_digests", "guards", "kernels", "tails"],
  "properties": {
    "proof_surface": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "envlock_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "policy_digests": { "type": "array", "items": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" } },
    "guards":  { "type": "array", "items": { "type": "string" } },
    "kernels": { "type": "array", "items": { "type": "string" } },
    "tails":   { "type": "array", "items": { "type": "string" } }
  },
  "additionalProperties": false
}
```

**Rule.** `SPECDoc/v1` **MUST** round-trip against the evidence bundle; failure ⇒ `spec_roundtrip_fail`.

---
### B.7.2 UpdateCert/v1 (proof-carrying policy change)
```jsonc
// StageCard/v1
{
  "Admits": ["policy_old_digest", "policy_new_digest", "proof digests"],
  "Emits": ["UpdateCert/v1 canonical JSON"],
  "Guards": [{"anchor":"#governance","content_b3":"b3:…"}],
  "FailFast": ["policy_version_stale", "proof_missing"],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/updatecert.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "UpdateCert/v1",
  "type": "object",
  "required": ["policy_old_digest", "policy_new_digest", "bisim_proof_digest", "sigma_nonexpansion_proof_digest", "signatures"],
  "properties": {
    "policy_old_digest":              { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "policy_new_digest":              { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "bisim_proof_digest":             { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "sigma_nonexpansion_proof_digest":{ "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "signatures": { "type": "array", "minItems": 1, "items": { "type": "string" } }
  },
  "additionalProperties": false
}
```

**Rule.** Both proofs are **mandatory**; missing either ⇒ `proof_missing`.

---
### B.7.3 SPEC\_ADOPTED/v1 (receipt) {#schema-spec-adopted}
```jsonc
// StageCard/v1
{
  "Admits": ["UpdateCert/v1", "SPECDoc/v1"],
  "Emits": ["SPEC_ADOPTED receipt"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["policy_version_stale"],
  "Links": [{"anchor":"#envlock","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/spec/spec_adopted.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "SPEC_ADOPTED/v1",
  "allOf": [
    { "$ref": "receipt-envelope.schema.json" },
    {
      "type": "object",
      "properties": {
        "predicate_id": { "const": "SPEC_ADOPTED" },
        "meta": {
          "type": "object",
          "required": [
            "spec_digest",
            "spec_scope",
            "updatecert_digest",
            "policy_old_digest",
            "policy_new_digest",
            "envlock_digest"
          ],
          "properties": {
            "spec_digest":       { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "spec_scope":        { "type": "string", "enum": ["ALL", "SUBSET"] },
            "updatecert_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "policy_old_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "policy_new_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "adopt_list": { "type": "array", "items": { "type": "string" } },
            "envlock_digest":    { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" }
          },
          "additionalProperties": false
        }
      },
      "additionalProperties": false
    }
  ]
}
```

---
### B.7.4 UPDATE\_ADOPTED/v1 (receipt) {#schema-update-adopted}
```jsonc
// StageCard/v1
{
  "Admits": ["UpdateCert/v1"],
  "Emits": ["UPDATE_ADOPTED receipt"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["policy_version_stale"],
  "Links": [{"anchor":"#governance","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/spec/update_adopted.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "UPDATE_ADOPTED/v1",
  "allOf": [
    { "$ref": "receipt-envelope.schema.json" },
    {
      "type": "object",
      "properties": {
        "predicate_id": { "const": "UPDATE_ADOPTED" },
        "meta": {
          "type": "object",
          "required": [
            "updatecert_digest",
            "policy_old_digest",
            "policy_new_digest",
            "decision",
            "threshold_k",
            "threshold_n"
          ],
          "properties": {
            "updatecert_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "policy_old_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "policy_new_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "decision": { "type": "string", "enum": ["APPROVED", "REJECTED"] },
            "threshold_k": { "type": "integer", "minimum": 1 },
            "threshold_n": { "type": "integer", "minimum": 1 },
            "signer_ids": { "type": "array", "items": { "type": "string" } },
            "rationale_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" }
          },
          "additionalProperties": false
        }
      },
      "additionalProperties": false
    }
  ]
}
```

---
## B.8 Performance & CI {#schema-perf-ci}
### B.8.1 PerfReceipt/v1
```jsonc
// StageCard/v1
{
  "Admits": ["bench_manifest_digest", "EnvLock", "metrics"],
  "Emits": ["PERF_SAMPLE receipts"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["metrics_noncanonical"],
  "Links": [{"anchor":"#verification","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/perf/perf_receipt.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "PerfReceipt/v1",
  "allOf": [
    { "$ref": "receipt-envelope.schema.json" },
    {
      "type": "object",
      "properties": {
        "predicate_id": { "const": "PERF_SAMPLE" },
        "meta": {
          "type": "object",
          "required": ["metrics", "bench_manifest_digest", "envlock_digest"],
          "properties": {
            "bench_manifest_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "envlock_digest":        { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "metrics": {
              "type": "object",
              "additionalProperties": { "type": ["number", "string", "object", "array"] }
            }
          },
          "additionalProperties": false
        }
      },
      "additionalProperties": false
    }
  ]
}
```

---
### B.8.2 UnknownPricedAxisEvent/v1 (priced-unknowns ledger line)
```jsonc
// StageCard/v1
{
  "Admits": ["priced-axis halt reasons"],
  "Emits": ["Omega-unk_budget-v1.jsonl lines (canonical)"],
  "Guards": [{"anchor":"#unknowns-guard","content_b3":"b3:…"}],
  "FailFast": ["ledger_sidecar_malformed"],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/omega/unknown_priced_axis_event.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "UnknownPricedAxisEvent/v1",
  "type": "object",
  "required": ["row_id", "axis", "view_digest", "reason", "ts"],
  "properties": {
    "row_id":      { "type": "string" },
    "axis":        { "type": "string" },
    "view_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "reason":      { "type": "string", "enum": ["MISSING", "AMBIGUOUS", "INVALID_UNITS"] },
    "ts":          { "type": "string", "format": "date-time" }
  },
  "additionalProperties": false
}
```

**Rule.** Filename is frozen: **`Omega-unk_budget-v1.jsonl`**; malformed lines **MUST** fail with `ledger_sidecar_malformed`.

---
## B.9 GMM & HGraph schemas (PROPOSAL\_\* and HGraph artifacts) {#schema-gmm-hgraph}
### B.9.1 PROPOSAL\_CREATED/v1 (receipt)
```jsonc
// StageCard/v1
{
  "Admits": ["seed_digest", "proposal_id", "hgraph_node_digest"],
  "Emits": ["PROPOSAL_CREATED receipt"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["proposal_replay_mismatch"],
  "Links": [{"anchor":"#gmm-replay","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/gmm/proposal_created.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "PROPOSAL_CREATED/v1",
  "allOf": [
    { "$ref": "receipt-envelope.schema.json" },
    {
      "type": "object",
      "properties": {
        "predicate_id": { "const": "PROPOSAL_CREATED" },
        "meta": {
          "type": "object",
          "required": ["seed_digest", "proposal_id", "hgraph_node_digest"],
          "properties": {
            "seed_digest":        { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "proposal_id":        { "type": "string" },
            "hgraph_node_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "actor":              { "type": "string" },
            "provenance":         { "type": "string" }
          },
          "additionalProperties": false
        }
      },
      "additionalProperties": false
    }
  ]
}
```

---
### B.9.2 PROPOSAL\_SCORE/v1 (receipt)
```jsonc
// StageCard/v1
{
  "Admits": ["Q′ carriers", "score_checker_hash", "hgraph_node_digest"],
  "Emits": ["PROPOSAL_SCORE receipt"],
  "Guards": [{"anchor":"#q-prime","content_b3":"b3:…"}],
  "FailFast": ["carrier_encoding_invalid"],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/gmm/proposal_score.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "PROPOSAL_SCORE/v1",
  "allOf": [
    { "$ref": "receipt-envelope.schema.json" },
    {
      "type": "object",
      "properties": {
        "predicate_id": { "const": "PROPOSAL_SCORE" },
        "meta": {
          "type": "object",
          "required": ["q_prime", "score_checker_hash", "hgraph_node_digest"],
          "properties": {
            "q_prime": {
              "type": "object",
              "description": "Axis→carrier mapping. Carriers may be numbers or canonical carrier strings (e.g. intervals as \"[l,u]\" or envelopes).",
              "additionalProperties": { "anyOf": [ { "type": "number" }, { "type": "string" } ] }
            },
            "score_checker_hash":  { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "hgraph_node_digest":  { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "scoring_params":      { "type": "object", "additionalProperties": true }
          },
          "additionalProperties": false
        }
      },
      "additionalProperties": false
    }
  ]
}
```

---
### B.9.3 PROPOSAL\_COMMIT/v1 (receipt)
```jsonc
// StageCard/v1
{
  "Admits": ["rounded_q_posting", "rounding_receipt_digest", "hgraph_node_digest"],
  "Emits": ["PROPOSAL_COMMIT receipt (with witness_digest)"],
  "Guards": [{"anchor":"#delta-fr-invariants","content_b3":"b3:…"}],
  "FailFast": ["rounding_missing", "witness_missing"],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/gmm/proposal_commit.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "PROPOSAL_COMMIT/v1",
  "allOf": [
    { "$ref": "receipt-envelope.schema.json" },
    {
      "type": "object",
      "required": ["witness_digest"],
      "properties": {
        "predicate_id": { "const": "PROPOSAL_COMMIT" },
        "meta": {
          "type": "object",
          "required": ["rounded_q_posting", "rounding_receipt_digest", "hgraph_node_digest"],
          "properties": {
            "rounded_q_posting": {
              "type": "object",
              "description": "Axis→number mapping after conservative flattening Q'→Q.",
              "additionalProperties": { "type": "number" }
            },
            "rounding_receipt_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "hgraph_node_digest":      { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "governance_approval":     { "type": "string" },
            "commit_reason":           { "type": "string" }
          },
          "additionalProperties": false
        }
      },
      "additionalProperties": false
    }
  ]
}
```

**Rule.** Approximation mode **requires** `rounding_receipt_digest`; absence ⇒ `rounding_missing`. `witness_digest` **MUST** reference a canonical witness (B.9.6).

---
### B.9.4 PROPOSAL\_REJECT/v1 (receipt)
```jsonc
// StageCard/v1
{
  "Admits": ["reject reason", "hgraph_node_digest"],
  "Emits": ["PROPOSAL_REJECT receipt"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": [],
  "Links": [{"anchor":"#delta-fr-invariants","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/gmm/proposal_reject.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "PROPOSAL_REJECT/v1",
  "allOf": [
    { "$ref": "receipt-envelope.schema.json" },
    {
      "type": "object",
      "properties": {
        "predicate_id": { "const": "PROPOSAL_REJECT" },
        "verdict":      { "const": "FAIL" },
        "reason_code":  { "type": "string", "pattern": "^[A-Z0-9_\\-]+$" },
        "meta": {
          "type": "object",
          "properties": {
            "hgraph_node_digest":     { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "rejection_explanation":  { "type": "string" },
            "governance_approval":    { "type": "string" }
          },
          "additionalProperties": false
        }
      },
      "additionalProperties": false
    }
  ]
}
```

---
### B.9.5 HGRAPH\_NODE/v1 (artifact)
```jsonc
// StageCard/v1
{
  "Admits": ["proposal_digest", "parents", "q′ digest"],
  "Emits": ["HGraphNode/v1 artifact"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": ["evidence_copy_missing"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/gmm/hgraph_node.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "HGraphNode/v1",
  "type": "object",
  "required": ["object", "node_digest", "proposal_digest"],
  "properties": {
    "object":          { "const": "HGraphNode/v1" },
    "node_digest":     { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "proposal_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "parent_digests":  { "type": "array", "items": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" } },
    "q_prime_digest":  { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "diagnostics":     { "type": "object", "additionalProperties": true },
    "metadata":        { "type": "object", "additionalProperties": true }
  },
  "additionalProperties": false
}
```

**Rule.** If referenced by any `witness_digest`, the node **MUST** be copied into the Evidence Bundle (Ephemeral→Evidence). Missing copy ⇒ `evidence_copy_missing`.

---
### B.9.6 RoundingCommitWitness/v1 (canonical witness artifact)
```jsonc
// StageCard/v1
{
  "Admits": ["relaxation spec", "fractional/dual/rounded digests", "bounds"],
  "Emits": ["RoundingCommitWitness/v1 artifact"],
  "Guards": [{"anchor":"#delta-fr-invariants","content_b3":"b3:…"}],
  "FailFast": ["witness_field_missing"],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/gmm/rounding_commit_witness.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "RoundingCommitWitness/v1",
  "type": "object",
  "required": ["object", "method", "kernel_id", "input_digest", "computed_upper_bound", "gap_bound"],
  "properties": {
    "object":                   { "const": "RoundingCommitWitness/v1" },
    "method":                   { "type": "string" },
    "kernel_id":                { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "input_digest":             { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "relaxation_spec_digest":   { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "primal_fractional_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "dual_certificate_digest":  { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "rounding_description":     { "type": "object", "additionalProperties": true },
    "rounded_solution_digest":  { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
    "computed_upper_bound":     { "type": "object", "additionalProperties": { "type": "number" } },
    "gap_bound":                { "type": "number", "minimum": 0 },
    "compute_time_s":           { "type": "number", "minimum": 0 }
  },
  "additionalProperties": false
}
```

---
### B.9.7 PROOF\_SURFACE\_OK/v1 (receipt)
```jsonc
// StageCard/v1
{
  "Admits": ["witness_digest"],
  "Emits": ["PROOF_SURFACE_OK receipt"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["witness_missing"],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/gmm/proof_surface_ok.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "PROOF_SURFACE_OK/v1",
  "allOf": [
    { "$ref": "receipt-envelope.schema.json" },
    {
      "type": "object",
      "properties": {
        "predicate_id": { "const": "PROOF_SURFACE_OK" },
        "meta": {
          "type": "object",
          "required": ["witness_digest"],
          "properties": {
            "witness_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" }
          },
          "additionalProperties": false
        }
      },
      "additionalProperties": false
    }
  ]
}
```

---
### B.9.8 C\_UNK\_PRICED/v1 (receipt stub, Unknowns Guard)
```jsonc
// StageCard/v1
{
  "Admits": ["priced-axis unknowns"],
  "Emits": ["C_UNK_PRICED receipt", "sidecar line (B.8.2)"],
  "Guards": [{"anchor":"#unknowns-guard","content_b3":"b3:…"}],
  "FailFast": ["UNKNOWN_ON_PRICED_AXIS", "ledger_sidecar_malformed"],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/guards/c_unk_priced.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "C_UNK_PRICED/v1",
  "allOf": [
    { "$ref": "receipt-envelope.schema.json" },
    {
      "type": "object",
      "properties": {
        "predicate_id": { "const": "C_UNK_PRICED" },
        "verdict":      { "const": "FAIL" },
        "meta": {
          "type": "object",
          "required": ["axis", "row_id"],
          "properties": {
            "axis":        { "type": "string" },
            "row_id":      { "type": "string" },
            "view_digest": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
            "reason":      { "type": "string", "enum": ["MISSING", "AMBIGUOUS", "INVALID_UNITS"] }
          },
          "additionalProperties": false
        }
      },
      "additionalProperties": false
    }
  ]
}
```

**Pairing Rule.** Emit together with **`UnknownPricedAxisEvent/v1`** lines in `Omega-unk_budget-v1.jsonl` (B.8.2).

---
### B.9.9 EdgeKernelMap/v1 (edge → kernel → axes → rounding)
```jsonc
// StageCard/v1
{
  "Admits": ["edge ids", "kernel ids", "axis sets", "rounding policies"],
  "Emits": ["EdgeKernelMap/v1 artifact"],
  "Guards": [{"anchor":"#delta-fr-invariants","content_b3":"b3:…"}],
  "FailFast": ["rounding_missing", "ledger_atomicity_fail"],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// canon/v1
{
  "$id": "https://sirus/spec/v1/pricing/edge_kernel_map.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "EdgeKernelMap/v1",
  "type": "object",
  "required": ["edges"],
  "properties": {
    "edges": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["edge_id", "pricing_kernel", "axes_touched", "rounding_policy"],
        "properties": {
          "edge_id":        { "type": "string" },
          "pricing_kernel": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
          "axes_touched":   { "type": "array", "minItems": 1, "items": { "type": "string" } },
          "rounding_policy": {
            "type": "object",
            "required": ["mode"],
            "properties": {
              "mode":      { "type": "string", "enum": ["exact", "upper_bound"] },
              "gap_bound": { "type": "number", "minimum": 0 }
            },
            "additionalProperties": false
          }
        },
        "additionalProperties": false
      }
    }
  },
  "additionalProperties": false
}
```

**Norms.** If `mode=="upper_bound"`, `TRANSITION_OK.meta.rounding_receipt_digest` is **mandatory**; every `TRANSITION_OK` for a priced axis **MUST** appear exactly once in the CBF ledger (atomic).

---
### B.9.10 Minimal examples & CI notes
```jsonc
// StageCard/v1
{
  "Admits": ["bundle manifest", "witness references"],
  "Emits": ["CI checks for schema conformance", "Merkle recompute", "Approx gate"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": ["merkle_mismatch", "rounding_missing", "evidence_copy_missing"],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**
CI **MUST** validate each artifact/receipt against its schema, recompute the bundle Merkle root, and enforce the approximation hard gate. Any witness referencing Ephemeral Pack nodes **MUST** be present in the Evidence Bundle prior to Ω finalization.

---
## B.10 Notes & Authoring Guidance
```jsonc
// StageCard/v1
{
  "Admits": ["author edits", "policy updates", "fixtures"],
  "Emits": ["schema evolution rules", "receipt/witness binding rules", "PILLARS enforcement"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": ["variant_envelope", "rounding_missing", "tail_ext_fail"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules (concise).**

1. **Schema evolution.** Policy-affecting changes require `UpdateCert/v1`; additive, backward-compatible updates bump version + pin new `policy_digests`.
2. **Canon discipline.** CI rejects any artifact whose canonical bytes deviate from serialization rules.
3. **Receipts & proofs.** Any acceptance-/budget-impacting receipt **MUST** include `witness_digest` or canonical pointers in `meta.*_digest`.
4. **PILLARS.** All receipts are **ReceiptEnvelope/v1**; `checker_hash` **MUST** be authorized by active **EnvLock**.
5. **Unknowns.** Use `C_UNK_PRICED` with the ledger sidecar (B.8.2) to halt priced rows deterministically.
6. **Fixtures.** Use the canonical Merkle fixture and seed-derivation tests.

---
### Minimal must-fail(s) introduced in B.6–B.10

* *EnvLockMissingFields* — missing required EnvLock keys ⇒ `envlock_missing_fields`.
* *PortabilityEchoMissing* — Ω surface/receipt missing stance echo ⇒ `portability_echo_missing`.
* *FpModeUnsupported* — FP mode not supported on declared platforms ⇒ `fp_mode_unsupported`.
* *SpecRoundtripFail* — SPECDoc fails evidence round-trip ⇒ `spec_roundtrip_fail`.
* *ProofMissing* — `UpdateCert/v1` lacking one of the required proofs ⇒ `proof_missing`.
* *UnknownOnPricedAxis* — priced-axis `⊥` without `C_UNK_PRICED`+sidecar ⇒ `UNKNOWN_ON_PRICED_AXIS`.
* *LedgerSidecarMalformed* — unknowns JSONL line missing required fields ⇒ `ledger_sidecar_malformed`.
* *RoundingMissing* — approx kernel without `rounding_receipt_digest` ⇒ `rounding_missing`.
* *EvidenceCopyMissing* — witness references Ephemeral node not in Evidence Bundle ⇒ `evidence_copy_missing`.

**New schemas defined (canon/v1, `$id` URIs):**

* `https://sirus/spec/v1/envlock.schema.json`
* `https://sirus/spec/v1/replayplan.schema.json`
* `https://sirus/spec/v1/civ_contract.schema.json`
* `https://sirus/spec/v1/specdoc.schema.json`
* `https://sirus/spec/v1/updatecert.schema.json`
* `https://sirus/spec/v1/spec/spec_adopted.schema.json`
* `https://sirus/spec/v1/spec/update_adopted.schema.json`
* `https://sirus/spec/v1/perf/perf_receipt.schema.json`
* `https://sirus/spec/v1/omega/unknown_priced_axis_event.schema.json`
* `https://sirus/spec/v1/gmm/proposal_created.schema.json`
* `https://sirus/spec/v1/gmm/proposal_score.schema.json`
* `https://sirus/spec/v1/gmm/proposal_commit.schema.json`
* `https://sirus/spec/v1/gmm/proposal_reject.schema.json`
* `https://sirus/spec/v1/gmm/hgraph_node.schema.json`
* `https://sirus/spec/v1/gmm/rounding_commit_witness.schema.json`
* `https://sirus/spec/v1/gmm/proof_surface_ok.schema.json`
* `https://sirus/spec/v1/guards/c_unk_priced.schema.json`
* `https://sirus/spec/v1/pricing/edge_kernel_map.schema.json`

**New reason codes requested:**

* `envlock_missing_fields` — EnvLock required keys absent.
* `portability_echo_missing` — Ω failed to echo portability stance.
* `fp_mode_unsupported` — FP setting not available on declared platforms.
* `spec_roundtrip_fail` — SPEC failed evidence round-trip.
* `proof_missing` — UpdateCert missing a required proof.
* `evidence_copy_missing` — Witness references artifact not present in Evidence Bundle.

**Required cross-ref updates (outside scope):**

* Ensure §4 and §5 “approximation hard gate” SSOT point to `B.9.3` and `B.9.6`.
* Confirm Ω echo rule for `portability_stance` is referenced in §0.13 and Ω receipt schema (Appendix B index).
* Verify Unknowns Guard narrative in §4 SSOT-points to `B.8.2` and `B.9.8`.

---
# Appendix C — Axis Catalog {#axis-catalog}

> **Scope note:** This appendix is fully normative where marked, paste-ready, and machine-verifiable. It replaces the prior Appendix C text in its entirety.

---
## C.1 Purpose & high-level rules
```jsonc
// StageCard/v1
{
  "Admits": ["AxisCatalog/v1 file (canon bytes)", "EnvLock", "BudgetVector/v1"],
  "Emits": ["axis_catalog_digest (pinned in SurfaceV1)", "Axis metadata used by adapters/Ω"],
  "Guards": [
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ],
  "FailFast": [
    "axis_duplicate",
    "axis_missing",
    "catalog_noncanonical"
  ],
  "Links": [
    {"anchor":"#acceptance-algebra","content_b3":"b3:…"},
    {"anchor":"#axis-and-budgets","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules (normative).**

1. Every run **MUST** pin `axis_catalog_digest` (canon bytes) into `SurfaceV1`.
2. Each axis entry **MUST** declare: `axis` (name), `class ∈ {"S","M"}`, `units`, `unknown_absorbing ∈ {true,false}`, and `policy` (see **C.3**).
3. Catalog bytes **MUST** be canon/v1 and content-addressed with **BLAKE3-256**; noncanonical serialization **MUST** fail (`reason_code: catalog_noncanonical`).
4. Axis names **MUST** be unique within a catalog; duplicates **MUST** fail (`reason_code: axis_duplicate`).&#x20;

---
## C.2 Typed semantics (S vs M)
```jsonc
// StageCard/v1
{
  "Admits": ["Axis entries with class tags"],
  "Emits": ["Aggregation law per axis", "Order relation per axis"],
  "Guards": [],
  "FailFast": ["order_undefined", "aggregation_mismatch"],
  "Links": [{"anchor":"#axis-and-budgets","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Definitions (normative).**

* **S (sum-axis):** aggregation `+`, identity `0.0`, order `≤`.
* **M (max-axis):** aggregation `max`, identity “unset” (encode as `null`/omitted), order `≥` (or lattice order induced by `max`).

**Rules.**

1. Adapters/kernels **MUST** aggregate by class (`S: +`, `M: max`); deviations **MUST** hard-fail at lint with `reason_code: aggregation_mismatch`.
2. Each axis **MUST** choose an order consistent with its class; absence ⇒ `order_undefined`.&#x20;

---
## C.3 Axis Catalog JSON schema (canon/v1)

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.

```jsonc
// axis_catalog.schema.json (canon/v1)
{
  "$id": "https://sirus/spec/v1/axis_catalog.schema.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "AxisCatalog/v1",
  "type": "object",
  "required": ["object", "generated_at", "axes"],
  "additionalProperties": false,
  "properties": {
    "object": { "const": "AxisCatalog/v1" },
    "generated_at": { "type": "string", "format": "date-time" },
    "version": { "type": "string" },
    "axes": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["axis", "class", "units", "unknown_absorbing", "policy"],
        "additionalProperties": false,
        "properties": {
          "axis": { "type": "string", "pattern": "^[A-Za-z][A-Za-z0-9_\\-]*$" },
          "class": { "type": "string", "enum": ["S", "M"] },
          "description": { "type": "string" },
          "units": { "type": "string" },
          "order": { "type": "string", "enum": ["≤", "≥"] },
          "unknown_absorbing": { "type": "boolean" },
          "display_precision": { "type": "integer", "minimum": 0 },
          "policy": {
            "type": "object",
            "required": ["cap"],
            "additionalProperties": false,
            "properties": {
              "cap": { "type": ["number", "null"] },
              "group": { "type": "string" },
              "hysteresis": {
                "type": "object",
                "additionalProperties": false,
                "properties": {
                  "green": { "type": "number" },
                  "amber": { "type": "number" },
                  "red":   { "type": "number" }
                }
              },
              "rounding": {
                "type": "object",
                "additionalProperties": false,
                "properties": {
                  "mode": { "type": "string", "enum": ["upper_bound", "quantile", "exact", "hybrid"] },
                  "quantile": { "type": "number", "minimum": 0, "maximum": 1 }
                }
              },
              "salt": { "type": "string", "pattern": "^b3:[a-f0-9]{64}$" },
              "kernel_hint": { "type": "string" },
              "unit_scale": { "type": "number" }
            }
          }
        }
      }
    },
    "groups": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["name"],
        "additionalProperties": false,
        "properties": {
          "name": { "type": "string" },
          "cap": { "type": ["number", "null"] },
          "description": { "type": "string" }
        }
      }
    },
    "notes": { "type": "string" }
  }
}
```

**CI gates (normative).**

* Reject: non-conformant to `$id` above; duplicate `axis` (`axis_duplicate`); non-lower-hex `b3:` salts; non-canon serialization (`catalog_noncanonical`).
* Enforce: no unspecified keys anywhere (`additionalProperties: false`).

---
## C.4 Minimal canonical catalog (example)

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.

```jsonc
// AxisCatalog/v1 (excerpt; canon/v1)
{
  "object": "AxisCatalog/v1",
  "generated_at": "2025-09-23T05:30:00Z",
  "version": "axis_catalog_v1",
  "axes": [
    {
      "axis": "Qfr",
      "class": "S",
      "description": "Frontier debit (dimensionless)",
      "units": "dimensionless",
      "order": "≤",
      "unknown_absorbing": true,
      "display_precision": 6,
      "policy": {
        "cap": 0.20,
        "group": "frontier_group_g1",
        "hysteresis": { "green": 0.05, "amber": 0.10, "red": 0.15 },
        "rounding": { "mode": "upper_bound" },
        "salt": "b3:1111111111111111111111111111111111111111111111111111111111111111",
        "kernel_hint": "pricing.kernel.deltafr.v1",
        "unit_scale": 1.0
      }
    },
    {
      "axis": "Qrisk_peak",
      "class": "M",
      "description": "Peak risk index (higher=bad)",
      "units": "index",
      "order": "≥",
      "unknown_absorbing": true,
      "policy": {
        "cap": 3,
        "group": "risk_group_g1",
        "rounding": { "mode": "exact" },
        "salt": "b3:2222222222222222222222222222222222222222222222222222222222222222"
      }
    }
  ],
  "groups": [
    { "name": "frontier_group_g1", "cap": 0.20, "description": "Frontier debit budget group" },
    { "name": "risk_group_g1",      "cap": 5,    "description": "Collective risk budget" }
  ]
}
```

**Rule.** `policy.cap` is a **default**; per-run `BudgetVector/v1` may override. Semantic flips (class, `unknown_absorbing`, order) **require** UpdateCert (SSOT: `{ "anchor":"#governance","content_b3":"b3:…" }`).

---
## C.5 Budget vectors, groups, and enforcement
```jsonc
// StageCard/v1
{
  "Admits": ["BudgetVector/v1", "AxisCatalog/v1"],
  "Emits": ["CBF_BUDGET_CHECK", "Ledger posts"],
  "Guards": [
    {"anchor":"#axis-and-budgets","content_b3":"b3:…"},
    {"anchor":"#ledger-discipline","content_b3":"b3:…"}
  ],
  "FailFast": ["budget_cap_breach", "group_budget_breach", "budget_vector_incomplete"],
  "Links": [{"anchor":"#unknowns-guard","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**

1. Ω **MUST** enforce `q_final ≤ B` axis-wise under the declared order; absent required axis in `B` ⇒ `budget_vector_incomplete`.
2. If an axis belongs to a `group`, CBF **MUST** enforce group caps in addition to per-axis caps; breach ⇒ `group_budget_breach`.
3. Unknowns Guard: if any **priced** axis in a row has `⊥` and its catalog entry has `unknown_absorbing=true`, the row **MUST** halt before pricing with `C_UNK_PRICED`. (SSOT pointer: `{ "anchor":"#unknowns-guard","content_b3":"b3:…" }`.)&#x20;

**Receipt (example).**

```jsonc
// ReceiptEnvelope/v1 (CBF_BUDGET_CHECK)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "CBF_BUDGET_CHECK",
  "inputs_digest": "b3:q_final|B|groups",
  "checker_hash": "b3:cbf_checker_v1",
  "envlock_digest": "b3:…",
  "verdict": "PASS",
  "meta": { "axis_ok": ["Qfr","Qrisk_peak"], "group_ok": ["frontier_group_g1","risk_group_g1"] }
}
```

**Example (must-fail):** `Qfr` sum exceeds `B["Qfr"]` ⇒ `verdict=FAIL`, `reason_code: budget_cap_breach`.

---
## C.6 Salts & seed derivation (HKDF/BLAKE3)
```jsonc
// StageCard/v1
{
  "Admits": ["policy.salt (per axis)", "EnvLock", "code_commit", "axis_catalog_digest"],
  "Emits": ["Seed derivations per domain", "SEED_DERIVATION_OK"],
  "Guards": [{"anchor":"#gmm-replay","content_b3":"b3:…"}],
  "FailFast": ["seed_domain_unauthorized", "salt_format_invalid"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**

1. `policy.salt` **MUST** match `^b3:[a-f0-9]{64}$`; otherwise `salt_format_invalid`.
2. Seeds **MUST** be derived via HKDF(BLAKE3) with canon inputs: `IKM=master_seed`, `Salt=BLAKE3(EnvLock)||BLAKE3(code_commit)||axis_catalog_digest`, `Info="sirus/hkdf/<domain>/v1"`.
3. Derivation for an unregistered domain **MUST** fail (`seed_domain_unauthorized`).&#x20;

---
## C.7 Rounding & Q′→Q flattening policy (catalog hints)
```jsonc
// StageCard/v1
{
  "Admits": ["policy.rounding per axis", "TRANSITION_OK receipts"],
  "Emits": ["Flattening rule per class", "ROUNDING_RECEIPT linkage"],
  "Guards": [{"anchor":"#delta-fr-invariants","content_b3":"b3:…"}],
  "FailFast": ["rounding_missing", "rounding_mode_unsupported"],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**

1. `mode` ∈ `{upper_bound, quantile, exact, hybrid}`; unknown mode ⇒ `rounding_mode_unsupported`.
2. When kernels operate in `Q′`, flatten using per-axis policy:

   * `upper_bound`: S → upper endpoint; M → worst-case envelope.
   * `quantile`: use declared conservative `quantile`.
   * `exact`: no rounding.
   * `hybrid`: implementation-defined by kernel; must be documented in run policy artifact.
3. If a kernel advertises approximation mode, any `TRANSITION_OK` without `meta.rounding_receipt_digest` **MUST** be rejected (`reason_code: rounding_missing`).&#x20;

---
## C.8 Authoring workflow (add/change an axis)
```jsonc
// StageCard/v1
{
  "Admits": ["PR with catalog delta", "Adapter tests", "CI config"],
  "Emits": ["Axis addition/change", "Digest pins", "Worked trace"],
  "Guards": [
    {"anchor":"#predicate-registry","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ],
  "FailFast": ["schema_violation", "unknowns_guard_missing", "proof_surface_regression"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Procedure (normative).**

1. Draft the entry per **C.3** with `description`, `units`, `policy.rounding`, `kernel_hint`, and `salt`.
2. Add tests: schema validation; S/M aggregation; Unknowns Guard if `unknown_absorbing=true` (expect `C_UNK_PRICED`).
3. Verify historical `proof_surface` digests unchanged unless intentional; drift ⇒ `proof_surface_regression`.
4. PR **MUST** include rationale, intended kernel(s), and a worked trace (FrontierRow → `q_posting` → receipts → CBF/Ω).
5. Semantic changes (class/order/`unknown_absorbing`/group caps) **require** an UpdateCert (SSOT pointer: `{ "anchor":"#governance","content_b3":"b3:…" }`).

---
## C.9 Auditing & CI checks
```jsonc
// StageCard/v1
{
  "Admits": ["AxisCatalog/v1 delta", "CI job"],
  "Emits": ["Gate results"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": [
    "schema_violation",
    "axis_duplicate",
    "salt_entropy_low",
    "unknowns_tests_missing",
    "roundtrip_fail",
    "compat_regression"
  ],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Gates (normative).**

* **Schema validation** (AxisCatalog/v1).
* **Dedup** (`axis_duplicate`); **salt check** (format & entropy).
* **Unknowns tests** (simulate `⊥` on each `unknown_absorbing` axis; expect `C_UNK_PRICED`).
* **Round-trip** (dummy `SurfaceV1` pin to recompute `proof_surface`); mismatch ⇒ `roundtrip_fail`.
* **Compat** (regression on historical surfaces); drift ⇒ `compat_regression`.

---
## C.10 Worked example: mesh retune → FrontierRow → Δ\_fr → budget check
```jsonc
// StageCard/v1
{
  "Admits": ["FrontierRow", "AxisCatalog/v1", "BudgetVector/v1"],
  "Emits": ["q_posting", "TRANSITION_OK", "CBF_BUDGET_CHECK"],
  "Guards": [
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"}
  ],
  "FailFast": ["rounding_missing", "budget_cap_breach", "C_UNK_PRICED"],
  "Links": [{"anchor":"#unknowns-guard","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Trace (minimal).**

1. Adapter maps retune to postings: `Qfr=0.032 (S)`, `Qrisk_peak=0.4 (M)`, `work_steps=120 (S)`.
2. Kernel emits `TRANSITION_OK`; if approx, includes `rounding_receipt_digest`.
3. Loader aggregates to `q_final` (S: `+`; M: `max`) and CBF checks per-axis and group caps → `CBF_BUDGET_CHECK`.
4. If any priced axis had `⊥` and `unknown_absorbing=true`, row halts via Unknowns Guard (`C_UNK_PRICED`) and writes to `Omega-unk_budget-v1.jsonl`.&#x20;

---
## C.11 Security, provenance, and change control
```jsonc
// StageCard/v1
{
  "Admits": ["Salts", "AxisCatalog/v1 history", "UpdateCert"],
  "Emits": ["Immutable catalog series", "Owner-signed caps when required"],
  "Guards": [{"anchor":"#governance","content_b3":"b3:…"}],
  "FailFast": ["salt_reuse", "unsigned_policy", "mutable_catalog"]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules.**

1. Salts **MUST** be high-entropy and not reused across unrelated axes (`salt_reuse`).
2. Published catalogs are immutable; amendments require a new version pinned by UpdateCert; mutation attempt ⇒ `mutable_catalog`.
3. Governance-sensitive cap changes **MUST** be owner-signed and included in policy digests (`unsigned_policy`).

---
## C.12 Author checklist (quick)
```jsonc
// StageCard/v1
{
  "Admits": ["Author intent to submit a catalog change"],
  "Emits": ["Checklist outcomes"],
  "Guards": [],
  "FailFast": ["todo_missing_negatives"]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Checklist.**

* [ ] Axis name chosen; matches pattern; unique.
* [ ] `class` set; `order` coherent; S/M aggregation tests pass.
* [ ] `unknown_absorbing` decided (conservative default: **true** for priced axes).
* [ ] `policy.cap`, `group`, `rounding`, `hysteresis` (if used), `salt`, `kernel_hint`, `unit_scale` set.
* [ ] Schema validated; salts `b3:`; **BLAKE3-256** digests verified.
* [ ] Unknowns Guard tests in place.
* [ ] `proof_surface` round-trip check passes.
* [ ] PR includes worked trace and SSOT pointers (Δ\_fr in §5 only by link).

---
## C.13 References (SSOT pointers only)
```jsonc
// StageCard/v1
{
  "Admits": ["Anchor lookups"],
  "Emits": ["Pointer set"],
  "Guards": [],
  "FailFast": [],
  "Links": [
    {"anchor":"#acceptance-algebra","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#axis-and-budgets","content_b3":"b3:…"},
    {"anchor":"#gmm-replay","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

*Definitions live only at their canonical homes; this appendix links by SSOT pointer objects.*

---
### Minimal must-fail(s) introduced in Appendix C

* *DuplicateAxis* — two entries share the same `axis` ⇒ `axis_duplicate`.
* *CatalogNonCanonical* — bytes not canon/v1/JCS ⇒ `catalog_noncanonical`.
* *AggregationMismatch* — observed aggregation conflicts with class ⇒ `aggregation_mismatch`.
* *BudgetCapBreach* — per-axis cap violated ⇒ `budget_cap_breach`.
* *GroupBudgetBreach* — group cap violated ⇒ `group_budget_breach`.
* *BudgetVectorIncomplete* — required axis missing in `B` ⇒ `budget_vector_incomplete`.
* *SaltFormatInvalid* — `policy.salt` not `b3:[0-9a-f]{64}` ⇒ `salt_format_invalid`.
* *SeedDomainUnauthorized* — seed derived for unregistered domain ⇒ `seed_domain_unauthorized`.
* *RoundingMissing* — approx kernel transition lacks rounding receipt ⇒ `rounding_missing`.
* *UnknownsGuardTrip* — priced axis with `unknown_absorbing=true` has `⊥` ⇒ `C_UNK_PRICED`.
### New schemas defined

* `$id: https://sirus/spec/v1/axis_catalog.schema.json` (canon/v1).
### New reason codes requested

* `axis_duplicate` — duplicate `axis` name in a catalog.
* `catalog_noncanonical` — catalog bytes fail canon/JCS check.
* `aggregation_mismatch` — aggregation not consistent with axis class.
* `group_budget_breach` — cumulative usage exceeded group cap.
* `salt_format_invalid` — `policy.salt` not well-formed.
### Required cross-ref updates (outside this scope)

* Register `axis_catalog.schema.json` in Appendix B index under Predicate Registry.
* Ensure Ω’s enforcement text in §2.3/§12 references `budget_vector_incomplete`, `group_budget_breach`.
* Confirm Unknowns Guard (§4) anchor exposes `C_UNK_PRICED` schema; Appendix C relies on that anchor.
* Keep Δ\_fr mathematics in §5; this appendix links only by SSOT pointer.

*Source for prior draft being revised:* Appendix C baseline text and examples.&#x20;

---
# Appendix D — Canonical Examples {#examples}

> **Purpose:** short, one-screen walkthroughs that illustrate normative flows.
> **Keep it lean:** examples **MUST** SSOT-point into Appendices B/C instead of restating schemas/rules.
>
> **Anchors (stable set to use/expand):**
>
> * `#ex-ssg` — SSG Pattern Binding
> * `#ex-spec-gov` — SPEC Emission & Governance Adoption
> * `#ex-replay` — Replay & Audit
> * `#ex-fail` — Failure Case (Must-Fail)
> * `#ex-hotfix` — Minimal Hotfix Adoption
> * *(optional future)* `#ex-budget`, `#ex-gmm`, `#ex-replayplan` — add if/when examples are authored

**Editorial rules (normative for Appendix D only)**

1. If an older appendix contains a verbose example that duplicates a flow here, **remove** the duplicate and keep the clearer D-variant.
2. All “Author To-Dos” in §§5–12 **MUST** point here for illustrations; templates live in Appendix E.
3. Any schema snippet shown inline **MUST** be a **link to B** (SSOT pointer), not a re-copy.

---
## D.3 CANON\_INPUT\_VIEW receipt
```jsonc
// StageCard/v1
{
  "Admits": [
    "CIVContract/v1",
    "EnvLock"
  ],
  "Emits": [
    "ReceiptEnvelope/v1: CANON_INPUT_VIEW"
  ],
  "Guards": [
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": [
    "civ_invalid",
    "receipt_missing_schema"
  ],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules (normative).**

1. A guard validates inputs and **MUST** produce a content-addressed CIV **before** any kernel runs.
   SSOT: `{ "anchor":"#civ-canon","content_b3":"b3:…" }`.
2. The receipt **MUST** be `ReceiptEnvelope/v1` with `schema_id` and `schema_b3`, and carry `(checker_hash, envlock_digest)` pinned in EnvLock.
   SSOT: `{ "anchor":"#receipt-canon","content_b3":"b3:…" }`, `{ "anchor":"#envlock","content_b3":"b3:…" }`.
3. Bounded context: Consumers that operate on a CIV slice **MUST** echo `meta.view_digest` in downstream adapter inputs.

**Example (valid — CIV receipt).**

```jsonc
// ReceiptEnvelope/v1 — CANON_INPUT_VIEW (PASS) (canon/v1)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "CANON_INPUT_VIEW",
  "inputs_digest": "b3:transportpack_digest",
  "checker_hash": "b3:canon_view_checker_v1",
  "envlock_digest": "b3:active_envlock",
  "verdict": "PASS",
  "meta": {
    "schema_ptr": {"anchor":"#civ-canon","content_b3":"b3:…"},
    "view_digest": "b3:civ_frontierrow_digest"
  },
  "witness_digest": "b3:frontierrow_digest"
}
```

**Example (must-fail).** CIV bytes fail contract validation (shape/units mismatch) → `verdict=FAIL`, `reason_code: civ_invalid`.

---
## D.4 Adapter mapping (Adapter A) — CIV → q\_posting
```jsonc
// StageCard/v1
{
  "Admits": [
    "CIVContract/v1 slice (echoes meta.view_digest)",
    "AdapterDecl/v1 (axis whitelist)"
  ],
  "Emits": [
    "AdapterPosting/v1 (witness bytes; content-addressed)",
    "Unknowns event line (priced) in Omega-unk_budget-v1.jsonl"
  ],
  "Guards": [
    {"anchor":"#adapter-contracts","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"},
    {"anchor":"#axis-catalog","content_b3":"b3:…"}
  ],
  "FailFast": [
    "C_UNK_PRICED"
  ],
  "Links": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules (normative).**

1. Adapter `mesh2q.v1` **MUST** consume `CIVContract/v1`, declare a write-whitelist present in the Axis Catalog, and produce an `AdapterPosting/v1` witness (state/evidence split per §2.2 via SSOT).
2. **Unknowns Guard (pre-kernel):** if any **priced** axis would be `⊥`, the runtime **MUST halt this row** with predicate `C_UNK_PRICED` and append `UnknownPricedAxisEvent/v1` to `Omega-unk_budget-v1.jsonl`. No kernels run for this row.
   SSOT: `{ "anchor":"#unknowns-guard","content_b3":"b3:…" }`.

**Adapter witness (canonical).**

```jsonc
// AdapterPosting/v1 (canon/v1)
{
  "schema_id": "AdapterPosting/v1",
  "schema_b3": "b3:…",
  "object": "AdapterPosting/v1",
  "adapter": "mesh2q.v1",
  "input_view": "b3:civ_frontierrow_digest",
  "q_partial": { "Qfr": 0.032, "Qrisk_peak": 0.4, "work_steps": 120.0 }
}
```

**Minimal halt receipt stub (must-fail path for this row only).**

```jsonc
// ReceiptEnvelope/v1 — C_UNK_PRICED (FAIL) (canon/v1)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "C_UNK_PRICED",
  "inputs_digest": "b3:frontier_row_digest",
  "checker_hash": "b3:unknowns_guard_checker",
  "envlock_digest": "b3:active_envlock",
  "verdict": "FAIL",
  "meta": { "axis": "Qfr", "row_id": "r-182" }
}
```

---
## D.5 Kernel pricing — `pricing.kernel.deltafr.v1`
```jsonc
// StageCard/v1
{
  "Admits": [
    "AdapterPosting/v1",
    "Kernel image: pricing.kernel.deltafr.v1"
  ],
  "Emits": [
    "KernelOutput/v1 (witness)",
    "ReceiptEnvelope/v1: ROUNDING_RECEIPT (when approx advertised)"
  ],
  "Guards": [
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"}
  ],
  "FailFast": [
    "rounding_missing"
  ],
  "Links": [
    {"anchor":"#kernel-rounding","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules (normative).**

1. A Δ\_fr kernel **MAY** use a sound upper-bounding approximation **only** if it emits a **ROUNDING\_RECEIPT** and later binds it from `TRANSITION_OK`.
   SSOT: `{ "anchor":"#kernel-rounding","content_b3":"b3:…" }`.
2. The kernel output **MUST** be content-addressed `KernelOutput/v1`, disclosing method/params and an explicit `approx_upper_bound` when approximation is advertised.

**Kernel outputs (canonical witness).**

```jsonc
// KernelOutput/v1 (canon/v1)
{
  "schema_id": "KernelOutput/v1",
  "schema_b3": "b3:…",
  "object": "KernelOutput/v1",
  "kernel": "pricing.kernel.deltafr.v1",
  "input_adapter_posting": "b3:adapter_posting_digest",
  "q_posting": { "Qfr": 0.032, "Qrisk_peak": 0.4, "work_steps": 120.0 },
  "approx_method": "relax-and-round-v1",
  "approx_params": { "width": 8, "timeout_s": 30 },
  "approx_upper_bound": { "Qfr": 0.033, "Qrisk_peak": 0.4, "work_steps": 120.0 }
}
```

**Rounding witness (certificate).**

```jsonc
// ReceiptEnvelope/v1 — ROUNDING_RECEIPT (PASS) (canon/v1)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "ROUNDING_RECEIPT",
  "inputs_digest": "b3:pricing_context_digest",
  "checker_hash": "b3:rounding_checker_v1",
  "envlock_digest": "b3:active_envlock",
  "verdict": "PASS",
  "meta": { "upper_bound": true, "gap_bound": 0.001 }
}
```

---
## D.6 Emit TRANSITION\_OK (pricing success)
```jsonc
// StageCard/v1
{
  "Admits": [
    "KernelOutput/v1",
    "ROUNDING_RECEIPT (if approx advertised)"
  ],
  "Emits": [
    "ReceiptEnvelope/v1: TRANSITION_OK"
  ],
  "Guards": [
    {"anchor":"#delta-fr-invariants","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#kernel-rounding","content_b3":"b3:…"}
  ],
  "FailFast": [
    "rounding_missing",
    "kernel_id_mismatch"
  ],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules (normative).**

1. `TRANSITION_OK` **MUST** bind `meta.rounding_receipt_digest` **whenever** the kernel advertises approximation; absence **MUST** be rejected with `reason_code: rounding_missing`.
2. The checker identity in `checker_hash` **MUST** match the kernel (`kernel_id`/ABI); mismatch ⇒ `reason_code: kernel_id_mismatch`.
3. The `witness_digest` **MUST** be the content address of the `KernelOutput/v1` witness.

**Transition receipt (canonical).**

```jsonc
// ReceiptEnvelope/v1 — TRANSITION_OK (PASS) (canon/v1)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "TRANSITION_OK",
  "inputs_digest": "b3:frontierrow_digest",
  "checker_hash": "b3:pricing.kernel.deltafr.v1",
  "envlock_digest": "b3:active_envlock",
  "verdict": "PASS",
  "meta": {
    "edge_id": "edge_000123",
    "kernel_id": "b3:pricing.kernel.deltafr.v1",
    "q_posting": { "Qfr": 0.033, "Qrisk_peak": 0.4, "work_steps": 120.0 },
    "rounding_receipt_digest": "b3:rounding_receipt_digest"
  },
  "witness_digest": "b3:kernel_output_digest"
}
```

**Example (must-fail).** Approximation advertised, but `meta.rounding_receipt_digest` absent → reject with `reason_code: rounding_missing`.

---
## D.7 Loader aggregation & provisional q\_final
```jsonc
// StageCard/v1
{
  "Admits": [
    "One or more AdapterPosting/v1",
    "AxisCatalog/v1",
    "EnvLock FP modes"
  ],
  "Emits": [
    "q_final (provisional)",
    "ReceiptEnvelope/v1: LOADER_AGG_OK"
  ],
  "Guards": [
    {"anchor":"#axis-catalog","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": [
    "receipt_unpinned",
    "order_undefined"
  ],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules (normative).**

1. Aggregation **MUST** follow Axis Catalog rules: **S-axes sum**, **M-axes take max**; orders derive from the catalog (SSOT pointer).
   SSOT: `{ "anchor":"#axis-catalog","content_b3":"b3:…" }`.
2. Arithmetic **MUST** be deterministic under EnvLock FP modes; canonical numeric formatting per Appendix B.
3. **Provenance binding:** for each included receipt, the Loader **MUST** recompute `checker_hash` and require membership in EnvLock; any unmapped hash **MUST** hard-fail with `reason_code: receipt_unpinned`.

**Toy arithmetic (illustrative, not normative values).**

```
q_prev    = { "Qfr": 0.10,  "Qrisk_peak": 0.35, "work_steps": 500 }
q_posting = { "Qfr": 0.033, "Qrisk_peak": 0.40, "work_steps": 120 }
q_new     = { "Qfr": 0.133, "Qrisk_peak": 0.40, "work_steps": 620 }
```

**Loader receipt (canonical).**

```jsonc
// ReceiptEnvelope/v1 — LOADER_AGG_OK (PASS) (canon/v1)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "LOADER_AGG_OK",
  "inputs_digest": "b3:agg(q_prev,q_posting,axis_catalog,fp_modes)",
  "checker_hash": "b3:loader_agg_checker_v1",
  "envlock_digest": "b3:active_envlock",
  "verdict": "PASS",
  "meta": {
    "q_prev": { "Qfr": 0.10,  "Qrisk_peak": 0.35, "work_steps": 500 },
    "q_posting": { "Qfr": 0.033, "Qrisk_peak": 0.40, "work_steps": 120 },
    "q_final": { "Qfr": 0.133, "Qrisk_peak": 0.40, "work_steps": 620 }
  }
}
```

**Example (must-fail).** A referenced transition receipt’s `checker_hash` is not in EnvLock → `reason_code: receipt_unpinned`.

---
### Minimal must-fail(s) introduced in Appendix D

* *CIVContractInvalid* — CIV fails contract/shape/units → `civ_invalid`.
* *UnknownPricedAxisHalt* — priced-axis `⊥` pre-kernel → `C_UNK_PRICED`.
* *TransitionOkMissingRounding* — approx kernel transition without rounding receipt → `rounding_missing`.
* *LoaderUnpinnedReceipt* — Loader aggregates a receipt whose `checker_hash` is not in EnvLock → `receipt_unpinned`.

**New schemas defined (canon/v1 URIs referenced):**

* `$id: AdapterPosting/v1`
* `$id: KernelOutput/v1`

**New reason codes requested:**

* `receipt_unpinned` — referenced receipt’s `checker_hash` not present in EnvLock at evaluation time.

**Required cross-ref updates (outside scope):**

* Register `$id: AdapterPosting/v1` and `$id: KernelOutput/v1` in Appendix **B** with `additionalProperties: false`.
* Ensure Appendix **B** includes `UnknownPricedAxisEvent/v1` and the sidecar schema for `Omega-unk_budget-v1.jsonl`.
* Confirm `#kernel-rounding` (Appendix B/§5) enumerates the binding of `ROUNDING_RECEIPT` into `TRANSITION_OK`.

---
# Appendix E — Templates & Checklists {#appendix-templates}

> **SSOT for author aids.** This appendix hosts all templates and checklists. Do not inline ad-hoc “Author To-Dos” in §§5–12—link here instead.
> **Editorial rules:** (1) Templates/checklists only—**no new rules**. (2) Link all “Author To-Dos” in §§5–12 to E; remove scattered lists elsewhere. (3) Centralize failure-code lookups by linking to Appendix B’s registry.

**Anchors (stable):**

* `#tpl-section` — Section skeleton (3-line opener)
* `#tpl-pillars-macro` — **PILLARS** paste-once macro (EnvLock ⇄ Receipts ⇄ CIV)
* `#chk-ssot-pointer` — SSOT pointer-lint checklist (editorial CI)
* `#chk-guardspec` — GuardSpec authoring checklist
* `#tpl-civ-contract` — CIV Contract JSON (adapter input)
* `#tpl-unk-priced-ledger` — Unknowns-priced sidecar (filename + line shape)
* `#chk-receipts` — Receipt usage checklist (uniform envelope + pinning)
* `#chk-roundinggate` — Approximation/Rounding hard-gate checklist
* `#tpl-stagecard` — Stage card skeleton (Admits/Emits/Guards/Fail-fast/Links)
* `#tpl-transport-boundary` — Transport Pack ⇄ Evidence Bundle boundary (ASCII + filenames) — *(includes Merkle manifest stub; see also `#chk-merkle-fixture`)*
* `#chk-merkle-fixture` — Merkle recipe fixture gate (CI)
* `#tpl-edge-kernel-map` — Edge→Pricing Kernel Map (generated artifact)
* `#tpl-runbook` — Runbook skeleton (ops)
* `#chk-tests` — Test matrix checklist
* `#tpl-ssg` — SSG authoring templates
* `#tpl-failure` — Failure receipt template
* `#chk-envlock` — EnvLock & Containers checklist
* `#tpl-seed-domains` — Deterministic seed-domains registry file
* `#chk-ci-gate0` — Final QA → **CI Gate 0** checklist
* *(optional future)* `#tpl-replayplan`, `#chk-spec`, `#chk-tx`, `#chk-updatecert` — add if/when authored

---
## E.1 Section Skeleton (3-line opener) {#tpl-section}
```jsonc
// StageCard/v1
{
  "Admits": ["A new subsection draft"],
  "Emits": ["Three-line opener", "PILLARS one-liner placement"],
  "Guards": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#envlock","content_b3":"b3:…"}
  ],
  "FailFast": ["ci_stagecard_missing", "pillars_missing_on_first_mention"],
  "Links": [{"anchor":"#ssot-dedup-impl","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Template (paste into the top of any normative subsection):**

```
> **Learn:** • … • … • …
> **Do:** • … • … • …
> **Verify:** • … • … • …
```

*Keep ≤3 bullets each. Link to canonical anchors via SSOT pointers—no restating rules.*

---
## E.2 PILLARS paste-once macro (copy as-is) {#tpl-pillars-macro}
```jsonc
// StageCard/v1
{
  "Admits": ["First mention of 'receipt' or 'CIV' in a subsection"],
  "Emits": ["PILLARS one-liner (exact text)", "Editor markers for lint"],
  "Guards": [
    {"anchor":"#envlock","content_b3":"b3:…"},
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"}
  ],
  "FailFast": ["pillars_pasted_multiple_times", "pillars_missing_on_first_mention"],
  "Links": [{"anchor":"#ssot-dedup-impl","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Paste once (exact text):**

*CI enforces presence exactly once per subsection; use optional editor marker `<!-- ssot-pointer:receipt-canon -->`.*

---
## E.3 SSOT pointer-lint checklist (editorial CI) {#chk-ssot-pointer}
```jsonc
// StageCard/v1
{
  "Admits": ["Draft with cross-references"],
  "Emits": ["Pointer lint markers", "Dup/omission CI rules"],
  "Guards": [{"anchor":"#ssot-dedup-impl","content_b3":"b3:…"}],
  "FailFast": ["ssot_pointer_duplicate", "ssot_pointer_missing"],
  "Links": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Checklist**

* [ ] On first mention: insert `#tpl-pillars-macro`.
* [ ] Include **exactly one** “receipt pinning line” per subsection (SSOT to `#receipt-canon`).
* [ ] Add one `<!-- ssot-pointer:* -->` marker per concept used (no dupes).
* [ ] No restated definitions—**link to canonical anchors** only.
* [ ] CI scans for duplicates/omissions and **fails** on either.

---
## E.4 GuardSpec authoring checklist {#chk-guardspec}
```jsonc
// StageCard/v1
{
  "Admits": ["Author's GuardSpec draft"],
  "Emits": ["Required keys & units", "Determinism constraints"],
  "Guards": [{"anchor":"#predicate-registry","content_b3":"b3:…"}],
  "FailFast": ["missing_hysteresis", "missing_saltation", "noncanonical_numbers"],
  "Links": [{"anchor":"#envlock","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Checklist**

* [ ] `name`, `version` set.
* [ ] Inputs typed **with units**.
* [ ] **Hysteresis** declared (`on`, `off`, `dir`) — **required**.
* [ ] **Dwell** declared (`dwell.tau_min_s`).
* [ ] **Saltation** = `none` or content-addressed reset map (`reset_hash`) with `sensitivity_cap`.
* [ ] Predicate deterministic & replayable under EnvLock.
* [ ] Stable anchors for success/failure events.
* [ ] Canonical JSON (RFC8785/JCS: sorted keys, fixed decimals).

**Starter (canon/v1):**

```jsonc
// GuardSpec/v1
{
  "schema_id": "GuardSpec/v1",
  "schema_b3": "b3:…",
  "name": "<guard-name>",
  "version": "1.0.0",
  "inputs": [ { "name": "x", "type": "decimal(9,3)", "units": "units" } ],
  "hysteresis": { "on": "0.10", "off": "0.05", "dir": "increasing" },
  "dwell": { "tau_min_s": 0.050 },
  "saltation": { "reset_hash": "b3:…", "sensitivity_cap": "0.05" },
  "predicate": { "expr": "x >= 0.10" },
  "anchors": {
    "success_event": "GUARD_OK",
    "failure_event": "FAILURE"
  }
}
```

---
## E.5 CIV Contract JSON (adapter input) {#tpl-civ-contract}
```jsonc
// StageCard/v1
{
  "Admits": ["Adapter emitting/consuming CIV slice"],
  "Emits": ["CIVContract/v1 object (verbatim)", "CANON_INPUT_VIEW receipt rule"],
  "Guards": [{"anchor":"#civ-canon","content_b3":"b3:…"}],
  "FailFast": ["adapter_civ_field_mismatch"],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Copy this object verbatim when emitting the CIV contract (adapters must consume it as-is).**

```jsonc
// CIVContract/v1
{
  "schema_id": "CIV/v1",
  "schema_b3": "b3:…",
  "created": "<RFC3339>",           // auditing; not part of digest
  "source": "transport_pack",
  "axis_whitelist": ["Qfr", "Qrisk_peak"],
  "view_digest": "b3:<digest-of-minimal-CIV-bytes>"
}
```

**Checklist**

* [ ] Emit `CANON_INPUT_VIEW` receipt that includes `meta.view_digest`.
* [ ] Axis whitelist present and minimal.
* [ ] Content address (`view_digest`) deterministic under EnvLock.
* [ ] Adapters **MUST NOT** mutate field set (else `adapter_civ_field_mismatch`).

---
## E.6 Unknowns-priced sidecar (filename + line shape) {#tpl-unk-priced-ledger}
```jsonc
// StageCard/v1
{
  "Admits": ["Priced-axis unknown event"],
  "Emits": ["Append-only sidecar line", "FAIL receipt"],
  "Guards": [{"anchor":"#unknowns-guard","content_b3":"b3:…"}],
  "FailFast": ["unk_sidecar_missing", "row_advanced_after_unknowns_halt"],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Filename (frozen):** `Omega-unk_budget-v1.jsonl`
**Each line (`UnknownPricedAxisEvent/v1`):**

```jsonc
// UnknownPricedAxisEvent/v1
{
  "schema_id": "UnknownPricedAxisEvent/v1",
  "schema_b3": "b3:…",
  "row_id": "<r-id>",
  "axis": "Qfr",
  "view_digest": "b3:…",
  "note": "priced-axis unknown; row halted by Unknowns Guard"
}
```

**Checklist**

* [ ] Emit `C_UNK_PRICED` receipt (`verdict: FAIL`) and append one line to the sidecar.
* [ ] Do **not** advance the halted row to kernels.
* [ ] Sidecar included in bundle manifest.
* [ ] CI fails if filename differs (`unk_sidecar_missing`) or if halted row advances (`row_advanced_after_unknowns_halt`).

---
## E.7 Receipt usage checklist (uniform envelope) {#chk-receipts}
```jsonc
// StageCard/v1
{
  "Admits": ["Any guard/kernel/adaptor outcome"],
  "Emits": ["ReceiptEnvelope/v1 objects", "Merkle leaves"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["receipt_missing_schema", "envlock_unpinned_checker", "variant_envelope_format"],
  "Links": [{"anchor":"#commit-path","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Checklist**

* [ ] Use **ReceiptEnvelope/v1** only (no variants).
* [ ] Envelope **MUST** carry `(checker_hash, envlock_digest)`.
* [ ] `predicate_id`, `inputs_digest`, `verdict` present; optional `meta`, `witness_digest`.
* [ ] First mention of “receipt” in any subsection includes the **pinning line** (see `#tpl-pillars-macro`).
* [ ] Failure receipts set `verdict:"FAIL"` + `meta.reason_code` from registry.
* [ ] All PASS receipts are Merkle leaves in the Evidence Bundle.

**Starter (canon/v1):**

```jsonc
// ReceiptEnvelope/v1
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "<PREDICATE_ID>",
  "inputs_digest": "b3:<…>",
  "checker_hash": "b3:<…>",
  "envlock_digest": "b3:<active-lock>",
  "verdict": "PASS",
  "meta": {},
  "witness_digest": "b3:<…>"
}
```

---
## E.8 Approximation / Rounding hard-gate checklist {#chk-roundinggate}
```jsonc
// StageCard/v1
{
  "Admits": ["Kernel advertising approximation"],
  "Emits": ["ROUNDING_RECEIPT", "TRANSITION_OK with bound digest"],
  "Guards": [{"anchor":"#delta-fr-invariants","content_b3":"b3:…"}],
  "FailFast": ["rounding_missing"],
  "Links": [{"anchor":"#receipt-canon","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Checklist**

* [ ] If a pricing kernel **advertises approximation**, emit a `ROUNDING_RECEIPT` (PASS) for each posting context.
* [ ] Every `TRANSITION_OK` from an approximating kernel **includes** `meta.rounding_receipt_digest`.
* [ ] `ROUNDING_RECEIPT.meta.upper_bound == true` and `gap_bound ≥ 0`.
* [ ] Loader rejects any missing digest with `reason_code: rounding_missing`.
* [ ] Round-trip witness rechecks under EnvLock.

---
## E.9 Stage card skeleton (keep prose minimal) {#tpl-stagecard}
```jsonc
// StageCard/v1
{
  "Admits": ["Stage authoring intent"],
  "Emits": ["Five-bullet stage card", "Filename alignment rule"],
  "Guards": [],
  "FailFast": ["stagecard_wrong_key_order", "filename_mismatch_fixture"],
  "Links": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#commit-path","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Skeleton (paste, then fill):**

```
Title: <STAGE> — <short role>
Admits: <state inputs>
Emits (state): <artifact names>
Emits (evidence): <predicate_ids>
Guards: <anchor links only>
Fail-fast: <deterministic rejects>
Links: <SSOT anchors (no restating)>
```

**Checklist**

* [ ] Exactly five bullets: **Admits / Emits / Guards / Fail-fast / Links**.
* [ ] No theory—link to §4/§5/Appendix B anchors only.
* [ ] Filenames match the runnable green-path fixture. CI fails on name drift (`filename_mismatch_fixture`).
* [ ] StageCard keys ordered as specified (`stagecard_wrong_key_order` if not).

---
## E.10 Transport Pack ⇄ Evidence Bundle boundary (ASCII + filenames) {#tpl-transport-boundary}
```jsonc
// StageCard/v1
{
  "Admits": ["Transport Pack rows/head", "Evidence artifacts"],
  "Emits": ["Canonical boundary diagram", "Bundle manifest stub", "Resume-head rule"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": ["merkle_mismatch", "replay_mismatch"],
  "Links": [
    {"anchor":"#receipt-canon","content_b3":"b3:…"},
    {"anchor":"#civ-canon","content_b3":"b3:…"},
    {"anchor":"#unknowns-guard","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Paste & fill the diagram for your run (filenames frozen):**

```
          ┌──────────────────────────┐
          │  Transport Pack (state)  │
          │  transport_pack.jsonl    │
          │  rows:{ids, frontiers,   │
          │       axes_delta, seeds} │
          └─────────────┬────────────┘
                        │ (Ω collects)
                        ▼
┌────────────────────────────────────────────────────────────┐
│ Evidence Bundle (audit, append-only)                       │
│ manifest: Omega-manifest-v1.json → merkle_root (b3:…)      │
│ receipts/: *.jsonl (ReceiptEnvelope/v1 leaves)             │
│ tails/: I11|I12|I13 witnesses                              │
└────────────────────────────────────────────────────────────┘
```

**Manifest stub (canon/v1):**

```jsonc
// BundleManifest/v1
{
  "schema_id": "BundleManifest/v1",
  "schema_b3": "b3:…",
  "merkle_root": "b3:<root>",
  "artifacts": [
    { "name": "attestation_receipt", "digest": "b3:…" },
    { "name": "guard_receipts/0001.json", "digest": "b3:…" }
  ]
}
```

**Checklist**

* [ ] Filenames frozen as shown (versioned).
* [ ] TP ∧ Bundle head digests recorded for resume checks (mismatch ⇒ `replay_mismatch`).
* [ ] CI recomputes `merkle_root` from manifest bytes (mismatch ⇒ `merkle_mismatch`).
* [ ] Include priced-unknowns sidecar `Omega-unk_budget-v1.jsonl` in manifest.

---
## E.11 Merkle recipe fixture gate (CI) {#chk-merkle-fixture}
```jsonc
// StageCard/v1
{
  "Admits": ["BundleManifest/v1 canonical bytes", "artifact digests"],
  "Emits": ["merkle_root (b3:<lower-hex>)", "MERKLE_MISMATCH failure on recomputation"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": ["merkle_mismatch", "root_encoding_invalid"],
  "Links": [{"anchor":"#tpl-transport-boundary","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Rules (normative).**

1. **Single recipe (MUST).** Leaf: `BLAKE3(0x00 || leaf_bytes)`; Node: `BLAKE3(0x01 || left || right)`; odd-node duplication; encoding `b3:<lower-hex>` (256-bit).
2. **Fixture enforcement (MUST).** Repo **MUST** include a reference `Omega-manifest-v1.json` fixture; CI recomputes the root from canonical bytes and fails closed on mismatch with `reason_code: merkle_mismatch`.
3. **No per-repo variants (MUST NOT).** Implementations MUST reuse the exact recipe and bytes; no alternative encodings or prefix tags.

**Example (must-fail).** Alter any artifact digest in the manifest by 1 bit → recomputation yields a different root ⇒ reject with `merkle_mismatch`.

---
## E.12 Edge→Pricing Kernel Map (generated artifact) {#tpl-edge-kernel-map}
```jsonc
// StageCard/v1
{
  "Admits": ["Priced edge set from receipts", "Kernel IDs"],
  "Emits": ["EdgeKernelMap/v1 artifact", "proof_surface pin to bundle"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["edge_missing_from_map", "axes_touched_incomplete"],
  "Links": [{"anchor":"#delta-fr-invariants","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Canonical artifact (generated at build; pinned in bundle manifest).**

```jsonc
// EdgeKernelMap/v1 (canon/v1)
{
  "schema_id": "EdgeKernelMap/v1",
  "schema_b3": "b3:…",
  "edges": [
    {
      "edge_id": "<e_id>",
      "pricing_kernel": "b3:<kernel_id>",
      "axes_touched": ["Qfr", "Qrisk_peak"],
      "rounding_policy": { "mode": "upper_bound", "gap_bound": "0.001" }
    }
  ]
}
```

**Rules (normative).**

1. **Completeness (MUST).** Every priced `edge_id` observed in `TRANSITION_OK` receipts appears **exactly once** with a non-empty `axes_touched`. Missing entry ⇒ `edge_missing_from_map`.
2. **Policy declaration (MUST).** `rounding_policy.mode ∈ {"exact","upper_bound"}`; when `upper_bound`, `gap_bound ≥ "0.000"` (fixed-decimal string).
3. **Audit use (SHOULD).** Auditors SHOULD sample edges to verify subadditivity given `axes_touched` and rounding policy.

---
## E.13 Runbook skeleton (ops) {#tpl-runbook}
```jsonc
// StageCard/v1
{
  "Admits": ["Operational action request"],
  "Emits": ["Runbook/v1 skeleton"],
  "Guards": [{"anchor":"#commit-path","content_b3":"b3:…"}],
  "FailFast": ["mutation_on_failure"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```
Title: <Action> (Role: <custodian|auditor|...>)
Mode: dry-run | live

1) Prechecks (diagnostic receipts only)
2) Execute guarded step (anchor: #<guard-anchor>)
3) Verify receipts, capture ids
4) If failure → stop; attach FAILURE receipt; do NOT mutate state
5) If success → proceed / commit via Δ_fr (#commit-path)

Expected receipts: <list>
Rollback: compensating transaction only (no history edits)
```

**Rule.** Any failure path MUST emit a `ReceiptEnvelope/v1` with `verdict="FAIL"` and a `reason_code` from Appendix B; no state mutation occurs on failure.

---
## E.14 Test matrix checklist {#chk-tests}
```jsonc
// StageCard/v1
{
  "Admits": ["Module guard/receipt set", "EnvLock"],
  "Emits": ["Executable test matrix"],
  "Guards": [{"anchor":"#delta-fr-invariants","content_b3":"b3:…"}],
  "FailFast": ["must_fail_missing"],
  "Links": [{"anchor":"#bench-suites","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Checklist (normative).**

* **Must-pass:** happy path for each guard/receipt.
* **Must-fail:** each failure code exercised (Appendix B registry).
* **Replay:** end-to-end determinism under EnvLock.
* **Property-based:** conservation, rounding, uniqueness.
* **Benchmarks:** isolated; advisory unless policy-pinned.

---
## E.15 SSG authoring templates {#tpl-ssg}
```jsonc
// StageCard/v1
{
  "Admits": ["SSGSpec/v1", "SSGBind/v1 drafts"],
  "Emits": ["Canonical authoring templates"],
  "Guards": [{"anchor":"#ssg-spec","content_b3":"b3:…"}],
  "FailFast": ["unknown_param_type", "units_missing", "guard_anchor_unstable"],
  "Links": [{"anchor":"#ssg-bind","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**SSGSpec/v1 (canon/v1)**

```jsonc
{
  "schema_id": "SSGSpec/v1",
  "schema_b3": "b3:…",
  "type": "SSGSpec/v1",
  "name": "<pattern-name>",
  "version": "1.0.0",
  "pivot": { "name": "<pivot>", "type": "string" },
  "parameters": [ { "name": "cap", "type": "decimal(9,2)", "units": "credits" } ],
  "guards": [ { "ref": {"anchor":"#<guard-anchor>","content_b3":"b3:…"}, "hysteresis": { "on": "0.01", "off": "0.00", "dir": "increasing" }, "saltation": "none" } ],
  "expects": [ "ReceiptEnvelope/v1" ],
  "notes": ""
}
```

**SSGBind/v1 (canon/v1)**

```jsonc
{
  "schema_id": "SSGBind/v1",
  "schema_b3": "b3:…",
  "pattern_ref": "hash:<pattern_id>",
  "pivot_value": "<value>",
  "args": { "cap": "50000.00" },
  "context": "hash:<state_ctx>",
  "memo": ""
}
```

**Checklist (normative).**

* Parameters typed & unit-checked.
* Hysteresis/saltation explicit.
* Guard anchors are stable SSOT pointers.
* Optional Δ\_fr commit when binding changes resources/policy.

---
## E.16 Failure receipt template (machine-readable) {#tpl-failure}
```jsonc
// StageCard/v1
{
  "Admits": ["Failure scenarios"],
  "Emits": ["ReceiptEnvelope/v1 FAIL shape"],
  "Guards": [{"anchor":"#receipt-canon","content_b3":"b3:…"}],
  "FailFast": ["reason_code_free_text", "guard_stage_missing"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

```jsonc
// ReceiptEnvelope/v1 (FAIL template)
{
  "schema_id": "ReceiptEnvelope/v1",
  "schema_b3": "b3:…",
  "predicate_id": "FAILURE",
  "inputs_digest": "b3:<subject>",
  "checker_hash": "b3:<component>",
  "envlock_digest": "b3:<lock>",
  "verdict": "FAIL",
  "meta": { "reason_code": "<ENUM>", "guard_stage": {"anchor":"#<guard-anchor>","content_b3":"b3:…"} },
  "created_at": "<RFC3339>"
}
```

**Checklist (normative).**

* `reason_code` from Appendix B registry.
* `guard_stage` anchor present (SSOT pointer).
* `inputs_digest` resolvable by replay.

---
## E.17 EnvLock & Containers checklist {#chk-envlock}
```jsonc
// StageCard/v1
{
  "Admits": ["Container image digest", "Toolchain versions", "Locale/TZ settings"],
  "Emits": ["Portability stance echo", "Cross-replay result (if Strong)"],
  "Guards": [{"anchor":"#envlock","content_b3":"b3:…"}],
  "FailFast": ["envlock_drift", "portability_echo_missing"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Checklist (normative).**

* Fixed container digest (no mutable tags).
* Fixed toolchain versions.
* Locale `C.UTF-8`, TZ `UTC`.
* RNG seeds explicit; no hidden randomness.
* Hashes over **canonical JSON bytes** only.
* Portability stance echoed at Ω; cross-replay for “Strong”.

---
## E.18 Deterministic seed-domains registry file {#tpl-seed-domains}
```jsonc
// StageCard/v1
{
  "Admits": ["rng_domain allow-list"],
  "Emits": ["seed_domains.json"],
  "Guards": [{"anchor":"#gmm-replay","content_b3":"b3:…"}],
  "FailFast": ["seed_domain_unauthorized"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Filename (repo root).** `seed_domains.json`

```jsonc
{
  "version": 1,
  "domains": [
    { "rng_domain": "PR.kernel.hsic", "info": "sirus/hkdf/PR.kernel.hsic/v1" },
    { "rng_domain": "GMM.actor",      "info": "sirus/hkdf/GMM.actor/v1"     },
    { "rng_domain": "SSG.bind",       "info": "sirus/hkdf/SSG.bind/v1"      },
    { "rng_domain": "Ω.tail.i11",     "info": "sirus/hkdf/Omega.tail.i11/v1"}
  ]
}
```

**Checklist (normative).**

* Any new domain added **with** a must-fail if missing from allow-list.
* HKDF inputs (EnvLock, code commit, axis catalog) pinned.

---
## E.19 Final QA → **CI Gate 0** checklist (pre-publish) {#chk-ci-gate0}
```jsonc
// StageCard/v1
{
  "Admits": ["Spec tree at hand-back", "Bundle manifest fixture"],
  "Emits": ["Gate 0 decision", "SPEC_EMIT/EXT/ROUNDTRIP receipts (if enabled)"],
  "Guards": [{"anchor":"#final-qa-checklist","content_b3":"b3:…"}],
  "FailFast": ["pillars_missing_on_first_mention", "merkle_mismatch", "ssot_pointer_duplicate"],
  "Links": [{"anchor":"#chk-merkle-fixture","content_b3":"b3:…"}]
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Checklist (normative).**

* SSOT pointers present & unique; no duplicate definitions outside canonical homes.
* **PILLARS** macro appears once per subsection that mentions receipts or CIV.
* JSON examples canonicalized (sorted keys, fixed decimals; `NaN/±Inf` banned).
* Merkle root recomputes from manifest bytes (**fixture-based**).
* Negative-controls library: ≥1 must-fail per predicate family (CIV, Unknowns, TRANSITION, ROUNDING, TAIL, OMEGA).
* EnvLock portability stance echoed; cross-replay (for “Strong”) green.
* Edge→Pricing Kernel Map present and pinned.
* SpecEmitter round-trip receipts captured for the build.

---
## E.20 TransactionSpec authoring checklist (optional) {#chk-tx}
```jsonc
// StageCard/v1
{
  "Admits": ["TransactionSpec drafts"],
  "Emits": ["Canonical TransactionSpec/v1"],
  "Guards": [],
  "FailFast": ["rounding_residual_missing", "evidence_anchor_missing"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Checklist (normative).**

* All entries in one `unit`.
* Sum(amt) = 0 after normalization.
* Rounding residual booked explicitly.
* Fees explicit, not implicit.
* Evidence anchor present (if required).
* Canonical JSON; `txid` = hash of canonical bytes.

**Starter (advisory exemplar).**

```jsonc
{
  "type": "TransactionSpec/v1",
  "unit": "credits.v1",
  "entries": [
    { "account": "budget/<pivot>", "amt": "-0.00" },
    { "account": "counterparty/<id>", "amt": "+0.00" }
  ],
  "memo": "",
  "evidence": { "anchor": "#receipt-envelope", "ref": "hash:..." },
  "policy_version": "budget/1.0.0",
  "created_at": "<RFC3339>"
}
```

---
## E.21 UpdateCert proposal checklist (optional) {#chk-updatecert}
```jsonc
// StageCard/v1
{
  "Admits": ["SPEC transition drafts", "governance policy pins"],
  "Emits": ["UpdateCert/v1 candidate"],
  "Guards": [],
  "FailFast": ["policy_pin_missing", "emit_ext_roundtrip_missing"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Checklist (normative).**

* `spec_transition.from` = current SPEC hash.
* `spec_transition.to` = new SPEC hash.
* Attach **EMIT/EXT/ROUNDTRIP** receipts for `to`.
* Pin quorum/eligibility/timing policies by hash.
* Voting window set; clocks in UTC.
* Canonical JSON; `ucid` = hash of canonical bytes.

**Starter (advisory exemplar).**

```jsonc
{
  "type": "UpdateCert/v1",
  "spec_transition": { "from": "hash:<old>", "to": "hash:<new>" },
  "attachments": {
    "SPEC_EMIT_OK": "hash:...", "SPEC_EXT_OK": "hash:...", "SPEC_ROUNDTRIP_OK": "hash:..."
  },
  "governance_pins": {
    "quorum_policy": "hash:...", "eligibility_policy": "hash:...", "timing_policy": "hash:..."
  },
  "ballot_config": { "opens_at": "<RFC3339>", "closes_at": "<RFC3339>" },
  "memo": ""
}
```

---
## E.22 ReplayPlan manifest template (optional) {#tpl-replayplan}
```jsonc
// StageCard/v1
{
  "Admits": ["Range, inputs, seeds, containers, tools"],
  "Emits": ["ReplayPlan/v1 manifest", "expected ids & receipts"],
  "Guards": [{"anchor":"#envlock","content_b3":"b3:…"}],
  "FailFast": ["container_digest_mutable", "seed_missing"],
  "Links": []
}
```

<!-- 3-line opener -->

This subsection is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->

**Template (canon/v1).**

```jsonc
{
  "schema_id": "ReplayPlan/v1",
  "schema_b3": "b3:…",
  "type": "ReplayPlan/v1",
  "range": { "blocks": [100, 110], "governance": true },
  "inputs": ["hash:<state_ctx>", "hash:<policy>", "hash:<dataset>"],
  "seeds": [{ "actor": "rebalancer@1.0", "seed": "42" }],
  "containers": ["sha256:<env>"],
  "tools": [{ "name": "sirus", "version": "2025.09" }],
  "expect": { "receipts": ["b3:…"], "ids": ["txid:…", "blockid:…"] }
}
```

**Rules (normative).**

* Freeze container/tool digests.
* Record all seeds & inputs.
* Expectation set includes **ids and receipts**.
* Single command replays and compares byte-for-byte.

---
### Minimal must-fail(s) introduced in Appendix E

* *PillarsMissing*: first mention of receipt/CIV without PILLARS one-liner ⇒ `pillars_missing_on_first_mention`.
* *PillarsDuplicated*: macro pasted more than once ⇒ `pillars_pasted_multiple_times`.
* *UnkSidecarMissing*: priced-unknowns event without sidecar or wrong filename ⇒ `unk_sidecar_missing`.
* *RowAdvancedAfterUnknowns*: halted row advanced after `C_UNK_PRICED` ⇒ `row_advanced_after_unknowns_halt`.
* *RoundingDigestMissing*: approx kernel transition without rounding receipt digest ⇒ `rounding_missing`.
* *StageCardOrderWrong*: StageCard keys out of order ⇒ `stagecard_wrong_key_order`.
* *FilenameMismatchFixture*: artifact name drift from fixture ⇒ `filename_mismatch_fixture`.
* *ReplayHeadMismatch*: TP/Bundle heads mismatch at resume ⇒ `replay_mismatch`.
* *MerkleMismatch*: bundle root recomputation mismatch ⇒ `merkle_mismatch`.
* *AdapterCivFieldMismatch*: adapter mutated CIV contract fields ⇒ `adapter_civ_field_mismatch`.

**New schemas defined in Appendix E:** *None.* (All shapes point to existing canon/v1 schemas via SSOT.)
**New reason codes requested in Appendix E:**
`ssot_pointer_duplicate`, `ssot_pointer_missing`, `noncanonical_numbers`, `unk_sidecar_missing`, `row_advanced_after_unknowns_halt`, `stagecard_wrong_key_order`, `filename_mismatch_fixture`, `adapter_civ_field_mismatch`.
**Required cross-ref updates (outside scope):**

* Appendix B: ensure registry entries exist for `UnknownPricedAxisEvent/v1` and `BundleManifest/v1` with frozen `schema_b3`; list all reason codes above.
* §4 (Evidence) and §5 (Δ\_fr): confirm first-mention **PILLARS** macro and pinning line usage per E.2/E.7.
* SSOT anchor table for Appendix E entries remains as in Appendix E preamble.&#x20;

---
# Appendix Z — Final QA Checklist (editorial + CI Gate 0) {#final-qa-checklist}
```jsonc
// StageCard/v1
{
  "Admits": ["Spec at hand-back", "CI config", "Bundle manifest fixture"],
  "Emits": ["Gate 0 PASS/FAIL"],
  "Guards": [{"anchor":"#chk-ci-gate0","content_b3":"b3:…"}],
  "FailFast": ["pillars_missing_on_first_mention", "schema_block_outside_appendix_b", "examples_placement_violation", "merkle_mismatch"],
  "Links": [
    {"anchor":"#chk-merkle-fixture","content_b3":"b3:…"},
    {"anchor":"#chk-envlock","content_b3":"b3:…"}
  ]
}
```

<!-- 3-line opener -->

This appendix section is normative and machine-verified under canon/v1.
All content-bound digests are BLAKE3-256; cross-references are SSOT pointers.
Receipts and examples must validate against their declared schemas via `schema_id` and `schema_b3`.
<!-- opener:canon/v1 -->
<!-- pillars:once -->
### Z.1 Automated checks (CI MUST enforce; fail-closed)

* [ ] **Anchors resolve & are unique.** All anchors referenced in §4.1–§4.2 and §§5–7 exist and resolve exactly; no duplicates.
* [ ] **No duplicate schemas outside Appendix B.** All schema blocks appear **only** in Appendix B (present or stubbed).
* [ ] **Receipt pinning “first-mention” line.** In every subsection that emits receipts, the envelope+pinning sentence appears **exactly once** immediately after the **first** occurrence of “receipt.”
* [ ] **SSOT one-liners present once.** Any prior re-definitions were replaced by a single correct one-liner (see §0 SSOT Map / §0.3). No repeats in the same subsection.
* [ ] **Examples placement.** Exactly **one** exemplar remains per mainline section; others moved to Appendix D with a one-line pointer.
* [ ] **Test anchors for §§5–7.** All required `#test-*` anchors exist and are unique:
  §5: `#test-determinism`, `#test-conservation`, `#test-uniqueness`, `#test-atomicity`, `#test-immutability`, `#test-budget-policies`, `#test-rounding`
  §6: `#test-gmm-determinism`, `#test-gmm-context-binding`, `#test-gmm-receipt-uniformity`, `#test-gmm-no-hidden-rng`, `#test-gmm-projection-qprime`
  §6.9 (if present): `#test-gmm-proof-surface-determinism`, `#test-gmm-proof-surface-minimality`, `#test-gmm-proof-surface-pin`, `#test-gmm-proof-surface-bind`
  §7: `#test-ssg-rebind-determinism`, `#test-ssg-hash-integrity`, `#test-ssg-governance-upgrade`, `#test-ssg-guard-first`, `#test-ssg-receipt-pinning`
* [ ] **Terminology normalization (`Q` / `Q′`).** No bespoke “maybe/partial” wording remains.
* [ ] **JSON example canonicalization.** All example blocks are fenced as `jsonc`; keys sorted where applicable; decimals fixed (`"0.20"`, not `"0.2"`); `NaN/±Inf` banned.
* [ ] **Nested code fences render.** Four-backtick wrapper is used wherever nested triple-backticks appear; no premature closures.&#x20;

**Hard gates derived from the spec’s normative rules (must be implemented by CI linters where mechanically checkable):**

* [ ] **PILLARS macro enforcement.** Each subsection that mentions Receipts or CIV includes the **PILLARS** one-liner exactly once (see Appendix E `#tpl-pillars-macro`).
* [ ] **Unknowns Guard executable contract.** If any priced axis is `⊥`, CI expects a `C_UNK_PRICED` receipt and a line in `Omega-unk_budget-v1.jsonl` conforming to `UnknownPricedAxisEvent/v1`; the row **must not** advance to kernels.
* [ ] **Rounding hard-gate.** If any kernel advertises approximation mode, **every** `TRANSITION_OK` includes `meta.rounding_receipt_digest`; otherwise reject with `rounding_missing`. (Also ensure `meta.upper_bound=true` and a non-negative `gap_bound`.)
* [ ] **Merkle recipe fixture match.** Recompute the bundle root from manifest bytes using the single Merkle recipe (leaf `0x00`, node `0x01`, odd-node duplicate). Mismatch ⇒ `MERKLE_MISMATCH`.
* [ ] **Ω extensionality guards present.** Tail contracts are extensional; declare/verify failure code `TAIL_EXT_FAIL` in Ω when violated.
* [ ] **Edge→Pricing Kernel Map pinned.** Build emits `EdgeKernelMap/v1` and pins it in the bundle; every priced `edge_id` in receipts appears exactly once in the ledger (atomic post).
* [ ] **CIV Contract JSON present where adapters consume input.** Adapters ingest `CIVContract/v1` verbatim with `view_digest` and `axis_whitelist` fields.
* [ ] **SSOT pointer-lint passes.** `<!-- ssot-pointer:* -->` markers exist where required; no dupes/omissions.
* [ ] **EnvLock portability stance echoed.** Final surface and `OMEGA` receipt `meta` echo the active EnvLock portability stance; CI cross-replays for “Strong.”
* [ ] **Seeds registry emitted.** `seed_domains.json` exists and matches the allow-list; any new domain includes a must-fail if missing.
* [ ] **SpecEmitter round-trip present (if enabled).** When §8 emission is in scope, require `SPEC_EMIT_OK`, `SPEC_EXT_OK`, and `SPEC_ROUNDTRIP_OK` receipts, pinned in an `UpdateCert` if advancing.&#x20;
### Z.2 Manual spot checks (editor signs off)

* [ ] **Green-path narrative is skim-fast.** Stage cards use *only* “Admits / Emits / Guards / FailFast / Links.” No prose restatements.
* [ ] **Transport vs. Evidence boundary is clear.** ASCII diagram + canonical filenames match actual artifacts (manifest, receipts/, tails/).
* [ ] **Governance negatives exist.** Must-fail fixtures for wrong signer role (`GOV_GUARD_FAIL`) and stale `UpdateCert` (`POLICY_VERSION_STALE`) are referenced from Appendix G.

**Passing Appendix Z (Gate 0) is mandatory** before publishing a new `specid` and before Ω accepts any run under this spec. *(This promotion of the checklist to a CI gate is normative.)*