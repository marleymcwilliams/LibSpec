# PR-0 (recommended): WorkCard schema + verifiable backlog + onboarding

**Branch:** `chore/workcard-backlog-ci`
**Why first:** makes the work *itself* machine-verifiable before the main PRs begin.

## 1) Files & contents

### 1.1 WorkCard schema (and one example)

**`.github/schemas/WorkCard.v1.schema.json`**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "sirus://schemas/WorkCard/v1",
  "title": "WorkCard/v1",
  "type": "object",
  "required": ["schema_id", "id", "owner", "scope", "inputs", "outputs", "acceptance_criteria"],
  "properties": {
    "schema_id": { "const": "WorkCard/v1" },
    "id":        { "type": "string", "pattern": "^[A-Z]{2,}(-[A-Z]{2,})?-\\d{3}$" },
    "title":     { "type": "string", "minLength": 3 },
    "owner":     { "type": "string", "minLength": 3 },
    "scope":     { "type": "string", "minLength": 10 },
    "inputs":    { "type": "array", "items": { "type": "string" } },
    "outputs":   { "type": "array", "items": { "type": "string" } },
    "acceptance_criteria": { "type": "array", "items": { "type": "string", "minLength": 5 } },
    "hitl_gate": { "type": "string", "enum": ["none", "low", "medium", "high"], "default": "none" },
    "links":     { "type": "array", "items": { "type": "string" } }
  },
  "additionalProperties": false
}
```

**`/spec/backlog/cards/PR-A.workcard.yaml`** (example you’ll replicate for each PR)

```yaml
schema_id: WorkCard/v1
id: PR-A-001
title: "Registry Hardening + Patterns Index + Eval Seed"
owner: "Spec Steward"
scope: >
  Create/validate registries; add four pattern cards; seed eval metrics/protocol;
  add must-fail fixtures and CI wiring.
inputs:
  - "/spec/SIRUS_CARDED.md#registries"
  - "/spec/SIRUS_CARDED.md#patterns"
outputs:
  - "/spec/registries/*.yaml"
  - "/spec/patterns/*.card.yaml"
  - "/spec/eval/metrics.yaml"
acceptance_criteria:
  - "All registry IDs unique and referenced by at least one pattern"
  - "Each pattern card has MUST/SHOULD + observability + links"
  - "≥2 must-fail fixtures added and detected by CI"
hitl_gate: "low"
links:
  - "/.github/schemas/WorkCard.v1.schema.json"
```

### 1.2 Critique backlog with schema + CI

**`.github/schemas/CritiqueItem.v1.schema.json`**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "sirus://schemas/CritiqueItem/v1",
  "type": "object",
  "required": ["id", "home", "rationale", "risk", "success_checks", "related_cards"],
  "properties": {
    "id": { "type": "string", "pattern": "^CRQ-\\d{3,4}$" },
    "home": { "type": "string", "minLength": 3 },   // path or md#anchor
    "rationale": { "type": "string", "minLength": 10 },
    "risk": { "type": "string", "enum": ["low", "medium", "high"] },
    "success_checks": { "type": "array", "items": { "type": "string", "minLength": 5 } },
    "related_cards": { "type": "array", "items": { "type": "string" } }
  },
  "additionalProperties": false
}
```

**`/spec/backlog/critique_index.yaml`**

```yaml
schema_id: CritiqueIndex/v1
items:
  - id: CRQ-101
    home: "/spec/router/decision_matrix.yaml"
    rationale: "Queries requiring fact grounding should route to RAG by default."
    risk: "medium"
    success_checks:
      - "Router tests include ≥1 RAG, ≥1 LONG_CONTEXT, ≥1 DIRECT case"
      - "Router emits routing_decision + features to trace model"
    related_cards: ["PR-B-001", "PR-C-001"]
```

**`/spec/ci/scripts/validate_backlog.py`**

```python
import os, sys, yaml, json, re
from jsonschema import validate

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
with open(os.path.join(ROOT, ".github/schemas/CritiqueItem.v1.schema.json")) as f:
    CRIT_SCHEMA = json.load(f)

idx_path = os.path.join(ROOT, "spec", "backlog", "critique_index.yaml")
with open(idx_path) as f:
    data = yaml.safe_load(f)

errors = 0
items = data.get("items", [])
for it in items:
    try:
        validate(it, CRIT_SCHEMA)
    except Exception as e:
        print(f"[schema] {it.get('id')} invalid: {e}")
        errors += 1
        continue
    home = it["home"]
    # basic existence check: file path part must exist
    path, anchor = (home.split("#", 1) + [""])[:2]
    path = path.strip("/") or ""
    abspath = os.path.join(ROOT, path.lstrip("/"))
    if not os.path.exists(abspath):
        print(f"[home] {it['id']}: path not found -> {abspath}")
        errors += 1
    elif anchor and abspath.endswith(".md"):
        with open(abspath, encoding="utf-8") as md:
            content = md.read()
        if not re.search(rf"(^|\n)#+\s*{re.escape(anchor)}\s*$", content):
            print(f"[anchor] {it['id']}: anchor '#{anchor}' not found in {path}")
            errors += 1
    # related_cards must point to existing WorkCards if present
    for cid in it.get("related_cards", []):
        wc = os.path.join(ROOT, "spec", "backlog", "cards", f"{cid}.workcard.yaml")
        if not os.path.exists(wc):
            print(f"[related] {it['id']}: related card missing -> {wc}")
            errors += 1

sys.exit(1 if errors else 0)
```

**`.github/workflows/ci-backlog-and-workcards.yml`**

```yaml
name: Backlog & WorkCards
on: [pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.11' }
      - run: pip install pyyaml jsonschema
      - name: Validate WorkCards
        run: |
          python - <<'PY'
          import os, json, yaml
          from jsonschema import validate
          root=".github/schemas/WorkCard.v1.schema.json"
          import pathlib; import glob
          with open(root) as f: schema=json.load(f)
          errs=0
          for p in glob.glob("spec/backlog/cards/*.workcard.yaml"):
            with open(p) as y: data=yaml.safe_load(y)
            try: validate(data, schema)
            except Exception as e:
              print(f"[workcard] {p} invalid: {e}"); errs+=1
          exit(1 if errs else 0)
          PY
      - name: Validate Critique Index
        run: python spec/ci/scripts/validate_backlog.py
```

### 1.3 Human onboarding

**`CONTRIBUTING.md`**

```md
# Contributing to SIRUS

## Step 0: Required reading
All contributors MUST read `/spec/research/Architecting_SIRUS.md` before their first contribution.
It explains the hybrid-spec philosophy, guard-first posture, and validation ladder.

## PR Expectations
- Keep PRs ≤800 LoC / ≤15 files.
- Include at least one must-fail fixture when adding new rules/schemas.
- Use WorkCards (`/spec/backlog/cards/*.workcard.yaml`) to define the scope and acceptance.
```

### 1.4 PR template (extend)

**`.github/pull_request_template.md`** (add)

```md
### WorkCard
- [ ] Linked WorkCard ID: `PR-?-???` (file path in `/spec/backlog/cards/`)

### Required Reading
- [ ] I have read `/spec/research/Architecting_SIRUS.md`
```

## 2) Commands

```bash
git checkout -b chore/workcard-backlog-ci
mkdir -p .github/schemas spec/backlog/cards spec/ci/scripts
# add files above
git add .
git commit -m "chore: WorkCard schema, verifiable backlog, onboarding & CI"
git push -u origin chore/workcard-backlog-ci
```

---

# Repo conventions (apply to all PRs)

* **Branch naming:** `feat/<area>-<slug>` (e.g., `feat/registry-hardening`, `feat/router-matrix`).
* **PR size target:** ≤800 LOC changed, ≤15 files touched.
* **Labels:** `spec`, `schema`, `must-fail-added`, `hitl-impact:low|med|high`.
* **Reviewers by default:** Spec Steward, CI/Lintsmith, Observability Lead (auto-assigned in CODEOWNERS).
* **CI gates (fast):** schema validation, link/anchor checks, hidden-char scan, must-fail presence, example fixtures run.

Suggested top-level paths (adjust to match your repo):

```
/spec
  /registries
  /patterns
  /eval
  /router
  /memory
  /saga
  /observability
  /abstraction
  /examples
  /ci
```

---

# PR-A: Registry Hardening + Patterns Index + Evaluation Harness Seed

**Branch:** `feat/registry-hardening`

### 1) Files to add/modify

```
/spec/registries/constraints.yaml
/spec/registries/guardrails.yaml
/spec/registries/negatives.yaml
/spec/registries/predicates.yaml

/spec/patterns/_index.card.yaml
/spec/patterns/reflection.card.yaml
/spec/patterns/tooluse.card.yaml
/spec/patterns/planning.card.yaml
/spec/patterns/multiagent.card.yaml

/spec/eval/metrics.yaml
/spec/eval/ab_protocol.yaml

/spec/ci/must_fail/registries/duplicate_id.yaml
/spec/ci/must_fail/patterns/missing_must_should.yaml
```

### 2) Minimal content templates

**`/spec/registries/constraints.yaml`**

```yaml
$schema: "https://json-schema.org/draft/2020-12/schema"
$id: "sirus://registries/constraints/v1"
version: 1
items:
  - id: CON-CTX-001
    title: "Context window ceiling"
    description: "Working context for any agent MUST remain ≤ 10k tokens."
    binds_to: ["router", "memory", "planning"]
    severity: "high"
  - id: CON-API-002
    title: "Tool call timeout"
    description: "External tool calls MUST timeout ≤ 20s (p95)."
    binds_to: ["action", "observability"]
    severity: "med"
```

**`/spec/patterns/reflection.card.yaml`** (pattern card format for all four)

```yaml
schema_id: PatternCard/v1
name: Reflection
must:
  - "Agent MUST produce a draft then a critique pass before final."
  - "Critique MUST reference constraints IDs if violated."
should:
  - "Limit to ≤2 internal reflection rounds to control latency."
observability:
  - emits: ["reflection_rounds", "token_usage", "latency_ms"]
hitl_hooks:
  - when: "risk>medium OR external-facing text"
    pattern: "Review/Edit"
links:
  constraints: ["CON-CTX-001"]
  metrics: ["/spec/eval/metrics.yaml#agent-level"]
```

**`/spec/eval/metrics.yaml`**

```yaml
$schema: "sirus://schemas/metrics/v1"
metrics:
  agent:
    - id: M-ACCURACY
      name: "Task accuracy"
      unit: "%"
      owner: "Eval Lead"
    - id: M-LAT-P95
      name: "Latency p95"
      unit: "ms"
    - id: M-COST
      name: "Token cost"
      unit: "tokens"
  workflow:
    - id: M-SAGA-ROLLBACK-RATE
      name: "Saga rollback rate"
      unit: "%"
```

**Must-fail fixtures** (examples)

```yaml
# /spec/ci/must_fail/registries/duplicate_id.yaml
case: "Registry IDs must be unique"
input:
  registries: ["/spec/registries/constraints.yaml"]
should_fail: true
reason_code: "REGISTRY_DUPLICATE_ID"
```

```yaml
# /spec/ci/must_fail/patterns/missing_must_should.yaml
case: "Pattern card missing MUST/SHOULD"
input:
  card: "/spec/patterns/tooluse.card.yaml"
mutations:
  drop_fields: ["must"]
should_fail: true
reason_code: "PATTERN_CARD_INCOMPLETE"
```

### 3) PR checklist

* [ ] All four registries exist; IDs unique, kebab/upper style (`AAA-BBB-###`).
* [ ] 4 pattern cards present; each has MUST/SHOULD + observability + links.
* [ ] `metrics.yaml` + `ab_protocol.yaml` exist (ab_protocol can be stubbed).
* [ ] ≥2 must-fail fixtures included and wired to CI.
* [ ] CI green (except intentional red tests isolated to `must_fail` runner).

---

# PR-B: Router Decision Matrix + Unit Tests

**Branch:** `feat/router-matrix`

### 1) Files

```
/spec/router/decision_matrix.yaml
/spec/router/tests/route_matrix.valid.yaml
/spec/ci/must_fail/router/unknown_route.yaml
```

### 2) Decision matrix (minimal, runnable)

**`/spec/router/decision_matrix.yaml`**

```yaml
schema_id: RouterMatrix/v1
routes:
  - id: RAG
    when:
      - if: "intent == 'fact_lookup' OR kb_required == true"
      - if: "doc_size_mb < 5"
    slo:
      p95_latency_ms: 2000
      p95_cost_tokens: 3000
  - id: LONG_CONTEXT
    when:
      - if: "doc_size_mb >= 5 AND doc_count == 1 AND holistic_reasoning == true"
    slo:
      p95_latency_ms: 6000
      p95_cost_tokens: 12000
  - id: DIRECT
    when:
      - if: "complexity == 'low' AND kb_required == false"
    slo:
      p95_latency_ms: 1200
      p95_cost_tokens: 1200
observability:
  emits: ["routing_decision", "routing_features", "latency_ms", "token_usage"]
constraints:
  - "CON-CTX-001"
tests:
  - name: "FAQ fact lookup → RAG"
    input: {intent: "fact_lookup", kb_required: true, doc_size_mb: 0.1, doc_count: 5, holistic_reasoning: false, complexity: "med"}
    expect_route: "RAG"
  - name: "Single long legal brief → LONG_CONTEXT"
    input: {intent: "analysis", kb_required: false, doc_size_mb: 25, doc_count: 1, holistic_reasoning: true, complexity: "high"}
    expect_route: "LONG_CONTEXT"
  - name: "Simple chit-chat → DIRECT"
    input: {intent: "chat", kb_required: false, doc_size_mb: 0, doc_count: 0, holistic_reasoning: false, complexity: "low"}
    expect_route: "DIRECT"
```

**Must-fail**

```yaml
# /spec/ci/must_fail/router/unknown_route.yaml
case: "Route IDs must be known"
input:
  file: "/spec/router/decision_matrix.yaml"
mutations:
  replace:
    path: "routes[0].id"
    value: "MAGIC_ROUTE"
should_fail: true
reason_code: "ROUTER_UNKNOWN_ROUTE"
```

### 3) PR checklist

* [ ] Three routes present (RAG/LONG_CONTEXT/DIRECT) with SLOs.
* [ ] At least 3 passing tests in `/spec/router/tests/`.
* [ ] Emits required observability fields.
* [ ] Must-fail for unknown route included.

---

# PR-C: Working Memory Policy + Observability Trace Links

**Branch:** `feat/memory-policy-observability`

### 1) Files

```
/spec/memory/working_policy.yaml
/spec/observability/trace_model.yaml
/spec/ci/must_fail/memory/policy_no_eviction.yaml
```

### 2) Policy + trace model

**`/spec/memory/working_policy.yaml`**

```yaml
schema_id: WorkingMemoryPolicy/v1
window:
  strategy: "last_n_observations"
  n: 12
  fallback: "observation_masking"  # replaces old outputs with placeholders; preserves trace refs
eviction:
  when_token_utilization_pct: ">= 80"
  action: "truncate_middle"       # mitigates lost-in-the-middle
  guardrails:
    - "Preserve last user turn"
    - "Preserve latest tool outputs"
observability:
  emits: ["context_utilization_pct", "eviction_event", "eviction_strategy"]
constraints: ["CON-CTX-001"]
```

**`/spec/observability/trace_model.yaml`**

```yaml
schema_id: TraceModel/v1
fields:
  - name: "routing_decision"      ; type: "enum[RAG,LONG_CONTEXT,DIRECT]" ; required: true
  - name: "token_usage"           ; type: "int"                           ; required: true
  - name: "latency_ms"            ; type: "int"                           ; required: true
  - name: "context_utilization_pct"; type: "int"                          ; required: true
  - name: "eviction_event"        ; type: "bool"                          ; required: false
  - name: "plan_state"            ; type: "enum[PENDING,EXECUTING,SUCCESS,FAILED]" ; required: false
  - name: "retry_count"           ; type: "int"                           ; required: false
```

**Must-fail**

```yaml
# /spec/ci/must_fail/memory/policy_no_eviction.yaml
case: "Working memory MUST define eviction"
input:
  file: "/spec/memory/working_policy.yaml"
mutations:
  remove: ["eviction"]
should_fail: true
reason_code: "MEMORY_POLICY_MISSING_EVICTION"
```

### 3) PR checklist

* [ ] Policy defines `window`, `eviction`, `observability`, `constraints`.
* [ ] Trace model includes required fields referenced by router/memory/pillars.
* [ ] Must-fail verifies eviction presence.

---

# PR-D: Saga Compensations Template

**Branch:** `feat/saga-compensations-template`

### 1) Files

```
/spec/saga/compensations_template.yaml
/spec/saga/validators/card.yaml
/spec/ci/must_fail/saga/missing_compensation.yaml
```

### 2) Template + validator stub

**`/spec/saga/compensations_template.yaml`**

```yaml
schema_id: SagaCompensations/v1
principle: "Every external side-effecting tool MUST define a compensating action."
tools:
  - tool_id: "book_flight"
    action: "book_flight"
    compensation: "cancel_flight"
    idempotent: false
    validator: "reservation_validator"
  - tool_id: "charge_credit_card"
    action: "charge_credit_card"
    compensation: "refund_credit_card"
    idempotent: false
    validator: "payment_validator"
policy:
  commit_requires:
    - "validator_approval == true"
    - "all_prev_steps_committed == true"
observability:
  emits: ["saga_step", "saga_compensation_run", "validator_result"]
```

**`/spec/saga/validators/card.yaml`**

```yaml
schema_id: ValidatorCard/v1
validators:
  - id: "reservation_validator"
    checks:
      - "PNR exists"
      - "status in [HOLD,CONFIRMED]"
  - id: "payment_validator"
    checks:
      - "charge_status == 'SETTLED'"
      - "amount == requested_amount"
```

**Must-fail**

```yaml
# /spec/ci/must_fail/saga/missing_compensation.yaml
case: "Compensation required for side-effecting tools"
input:
  file: "/spec/saga/compensations_template.yaml"
mutations:
  remove_tool: "charge_credit_card"
should_fail: true
reason_code: "SAGA_MISSING_COMPENSATION"
```

### 3) PR checklist

* [ ] Every listed side-effect tool has a compensation + validator.
* [ ] Commit policy defined and explicit.
* [ ] Must-fail proves the gate works.

---

# PR-E: LLM Abstraction Interface

**Branch:** `feat/llm-abstraction-interface`

### 1) Files

```
/spec/abstraction/interface.yaml
/spec/abstraction/providers/mock.adapter.yaml
/spec/ci/must_fail/abstraction/direct_call.yaml
```

### 2) Interface + mock adapter

**`/spec/abstraction/interface.yaml`**

```yaml
schema_id: LLMInterface/v1
endpoints:
  - name: "generate_text"
    input_schema: "sirus://schemas/generate_text_input/v1"
    output_schema: "sirus://schemas/generate_text_output/v1"
    must:
      - "No agent may call provider APIs directly."
      - "All calls emit token_usage and latency_ms."
  - name: "call_tools"
    input_schema: "sirus://schemas/call_tools_input/v1"
    output_schema: "sirus://schemas/call_tools_output/v1"
  - name: "embed_document"
    input_schema: "sirus://schemas/embed_input/v1"
    output_schema: "sirus://schemas/embed_output/v1"
observability:
  emits: ["token_usage", "latency_ms", "provider_name"]
providers:
  allowed: ["mock", "openai", "anthropic", "local"]
```

**`/spec/abstraction/providers/mock.adapter.yaml`**

```yaml
schema_id: LLMAdapter/v1
name: "mock"
routes:
  generate_text: "echo"
  call_tools:    "noop"
  embed_document:"hash"
```

**Must-fail**

```yaml
# /spec/ci/must_fail/abstraction/direct_call.yaml
case: "No direct provider calls"
input:
  code_scan:
    patterns:
      - "https://api.openai.com"
      - "https://api.anthropic.com"
should_fail: true
reason_code: "ABSTRACTION_DIRECT_PROVIDER_CALL"
```

### 3) PR checklist

* [ ] Three canonical endpoints defined with input/output schemas referenced.
* [ ] Observability fields required and documented.
* [ ] Mock adapter present so downstream examples/tests can run.
* [ ] Must-fail ensures no direct provider URLs appear in code/spec.

---

## Example PR template (paste into `.github/pull_request_template.md`)

```md
### Summary
<!-- What this PR adds and why -->

### Scope & Size
- Files changed: N (≤15)
- LoC delta: N (≤800)
- Affected areas: [registries|router|memory|saga|observability|abstraction]

### Artifacts
- [ ] Schemas/YAML
- [ ] Examples (≥1)
- [ ] Must-fail fixtures (≥1)

### Observability
Emits: <list fields>

### Constraints & Patterns
- Constraints touched: <IDs>
- Patterns referenced: <names>

### Tests
- Passing examples: N
- Must-fails: N
- CI status: ✅/❌

### HITL
- Impact: low/med/high
- Triggers: (if any)
```

---

## Git one-liners to bootstrap each PR

```bash
# PR-A
git checkout -b feat/registry-hardening
mkdir -p spec/{registries,patterns,eval,ci/must_fail/{registries,patterns}}
# (add files as above)
git add spec && git commit -m "feat: registries + pattern index + eval seed (+ must-fails)"
git push -u origin feat/registry-hardening

# PR-B
git checkout -b feat/router-matrix
mkdir -p spec/router/tests spec/ci/must_fail/router
# (add files)
git add spec && git commit -m "feat(router): decision matrix + tests + must-fail"
git push -u origin feat/router-matrix

# PR-C
git checkout -b feat/memory-policy-observability
mkdir -p spec/memory spec/observability spec/ci/must_fail/memory
# (add files)
git add spec && git commit -m "feat(memory,obs): working policy + trace model + must-fail"
git push -u origin feat/memory-policy-observability

# PR-D
git checkout -b feat/saga-compensations-template
mkdir -p spec/saga spec/ci/must_fail/saga
# (add files)
git add spec && git commit -m "feat(saga): compensations template + validators + must-fail"
git push -u origin feat/saga-compensations-template

# PR-E
git checkout -b feat/llm-abstraction-interface
mkdir -p spec/abstraction/providers spec/ci/must_fail/abstraction
# (add files)
git add spec && git commit -m "feat(abstraction): interface + mock adapter + must-fail"
git push -u origin feat/llm-abstraction-interface
```

---

## Review flow & merge order

1. **PR-A** (registries/patterns/eval) → unblocks constraints links for the rest.
2. **PR-B** (router) → depends on CON-CTX-001; emits observability fields.
3. **PR-C** (memory policy + trace) → relies on constraint IDs; defines common telemetry.
4. **PR-D** (saga) → leverages registries, adds validator scaffolding and compensation policy.
5. **PR-E** (abstraction) → can ship anytime after PR-A (to inherit constraints & observability).

---

## “Done” signal per PR (what to look for in CI)

* **Schema validation:** all YAML/JSON conform to declared `$id`/`schema_id`.
* **Link integrity:** all `links:` and `constraints:` anchors resolve.
* **Must-fail runner:** intentional failures are detected with the right `reason_code`.
* **Hidden-char scan:** passes (no zero-width or non-printing chars).
* **Observability lint:** every card that “emits” fields references ones defined in `trace_model.yaml`.