## How to Orchestrate AI Agents for SIRUS Contributions

Your role is that of a **Spec Steward**: you provide direction and verify outputs, while the AI agents act as specialized contributors. Your primary goal is to keep the agents grounded in the project's "Single Source of Truth" (SSOT) to produce deterministic, verifiable artifacts. This workflow uses multiple agents as a defense against hallucinations.

-----

## The Core Loop: Ground → Prompt → Cross-Validate → Commit

This four-step process ensures that AI-generated artifacts are correct, compliant, and free of invention.

### Step 1: Assemble the "Grounding Packet" 🗂️

For any given `WorkCard`, your first job is to create a minimal, self-contained context bundle. This is the most critical step to prevent the AI from inventing file paths or rules.

Your packet for the AI should contain only:

1.  **The Mission:** The specific `.workcard.yaml` file for the task.
2.  **The Rules:** The exact text of any schemas (`.schema.json`), registry files (`registries/*.yaml`), or specification snippets referenced in the `WorkCard`'s `inputs`.
3.  **The Guardrails:** A concise set of custom instructions summarizing the project's core principles (SSOT, Guard-First, Must-Fail).

**Do not** provide the entire spec. By giving the AI only what it needs, you force it to work within the verified bounds of the system.

-----

### Step 2: Write a Precision Prompt 🎯

Use a consistent, directive prompt for each agent. This is not a conversation; it's an instruction.

**Copy-Pastable Prompt Template:**

```
You are a specialist systems engineer contributing to a formal specification called SIRUS.

**Your Task:**
Execute the attached WorkCard: `[Paste WorkCard ID, e.g., PR-A-001]`

**Context & Rules:**
The attached files contain the full and complete context for this task:
1. The WorkCard defining your scope, inputs, and outputs.
2. All necessary schemas and input files.

**Critical Instructions:**
1.  **Generate all files** listed in the WorkCard's `outputs` section.
2.  **Strictly adhere to SSOT:** Do not restate or summarize rules. All references must be file paths as defined in the provided context.
3.  **Validate against schemas:** Your output artifacts MUST validate against the provided schemas.
4.  **Generate a "Must-Fail" fixture:** For every rule or constraint artifact you produce, you MUST also produce the corresponding `must-fail` fixture specified in the WorkCard. This is a non-negotiable part of the task.

Begin generation now.
```

-----

### Step 3: Dispatch to Multiple Agents & Cross-Validate 🕵️

This is your defense against "artifact-based hallucinations."

1.  **Dispatch:** Give the exact same **Grounding Packet** and **Prompt** to at least two different AI models (e.g., Gemini, GPT-5).
2.  **Compare the Outputs:** Look for discrepancies. A hallucination in this context is when an AI invents an artifact that wasn't in the Grounding Packet.

**What to look for:**

  * **File Paths:** Do the generated `outputs` use the *exact* paths specified in the `WorkCard` and the `SIRUS_CARDED` sitemap?
  * **Schema Keys:** Did one AI invent a YAML or JSON key that doesn't exist in the provided schema?
  * **ID Casing:** Did one AI use `LONG_CONTEXT` while another used `LongContext`?

If the outputs differ, trust the one that aligns perfectly with the Grounding Packet. The discrepancy is a detected hallucination.

-----

### Step 4: Commit and Trust the CI 🤖

Once you have a set of artifacts that are consistent across agents and appear correct, your job is nearly done.

1.  **Commit the Artifacts:** Add the AI-generated files to a new branch.
2.  **Open the Pull Request:** Push and open the PR.
3.  **Trust the CI as the Final Arbiter:** The project's automated CI is the ultimate, non-negotiable source of truth. It will perform the final, rigorous checks that even a careful human review might miss:
      * Strict schema validation
      * Merkle root recomputation
      * SSOT link integrity checks
      * Verification that your "must-fail" tests actually fail

If the CI passes, the work is correct. If it fails, its report will provide the exact `reason_code` needed to refine your prompt or Grounding Packet for the next attempt.