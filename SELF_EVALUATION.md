# GDMCode self-evaluation

This page answers the product questions behind the submission. It is separate
from the official ADTC profiler: the profiler measures runtime performance and
memory, while this held-out suite measures whether the model is useful inside
the GDMCode learning and coding workflow.

## Method

Both candidate GGUFs were evaluated CPU-only with the same 19 held-out cases,
seed, sampling settings, GDMCode system prompt, and 768-token response ceiling.
The deterministic rubric covers six capability families. Cases were kept out
of training. Scores are proportions from 0 to 1, not official ADTC scores.

## Submitted 4B result

| Question | Capability score | What the evidence supports |
|---|---:|---|
| Can it teach a complete beginner? | **0.9722** | Strong explanations across the beginner ladder; still needs a teacher or verifier for high-stakes correctness. |
| Can a child build a small, enjoyable project? | **0.8080** | The strongest 4B advantage; good project guidance, with some missed milestones and safeguards. |
| Can it assist a programming student? | **0.8785** | Useful for explanation, debugging, and tests; generated code still requires review. |
| Can it generate courses and quizzes? | **1.0000** | Both held-out structured course/quiz cases passed under the full output budget. |
| Can it work through the GDMCode/GrokBuild harness? | **0.6932** | Two real bounded read/edit/test traces completed, but broad agentic reliability is not claimed. |
| Is it ready for the local ADTC contract? | **0.5000** | The GGUF and offline runtime work; the remaining gap is standardized participant-hardware evidence and some explicit safety wording. |

**Aggregate:** **0.8666**. **Full rubric passes:** **9/19**.

The actual harness adds guarantees the model cannot provide by itself: typed
lesson rendering, an authenticated loopback daemon, forced Offline policy,
bounded practice checks, local SQLite progress, permission gates, and
transactional commit-or-rollback behavior. The curated Windows core passed
43 unit tests, and the journal layer passed 18 tests.

## Lower-resource comparison

The documented raw 2B alternative scored **0.9078** overall with **10/19** full
passes. It led the 4B on aggregate beginner, student, harness, and local-readiness
rubrics; the submitted trained 4B led child-build behavior. Both scored 1.0000
on the structured course/quiz family. We submit the 4B as the larger-capacity,
fine-tuned model and disclose the 2B rather than hiding the comparison.

## What this does not prove

- Nineteen cases cannot establish universal coding expertise.
- A rubric pass is not a security proof or permission to execute generated code.
- The product suite is not the hidden ADTC accuracy set.
- Cloud audit measurements are not relabelled as participant-laptop results.
- English is the tested language scope; no African-language performance claim is made.

The frozen 4B artifact, public downloader, official profiler report, and this
product evaluation therefore answer different questions and should be read
together.
