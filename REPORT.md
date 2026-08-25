# Technical Report — GDMCode offline programming tutor and coding harness

**Status:** ADTC 2026 public submission.

**Team ID:** gdmcode  
**Domain:** coding_assistants  
**Model:** Qwen3.5-4B trained Q4_K_M

## Problem

GDMCode is an offline programming tutor and coding assistant for beginners,
students, and people working on modest computers or unreliable connections.
The intended experience explains core programming concepts, diagnoses small
bugs, and helps learners build simple projects without requiring a network
connection during inference. The model is one component of a local harness:
the harness owns the coding workspace, typed lesson rendering, bounded local
verification, permission checks, and transactional repository changes.

## Design decisions

The current submission lane uses the privately trained Qwen3.5-4B model in GGUF
Q4_K_M form. It is the larger-capacity candidate from the Goal 6 tournament.
The raw Qwen3.5-2B Q4_K_M artifact remains the documented lower-resource
alternative; the trained 4B candidate is the submitted model.

The exact 4B artifact checksum is:

`514c57feaeead5cc7803421327389a3cdca397cb5d84a6848f4616b916fd2ee9`

The raw 2B Q4_K_M candidate is retained as a lower-resource comparison in the
engineering record, not as the primary submission lane.

## Harness design

GDMCode keeps model output behind typed boundaries. Lessons use `LessonIR`
validation before trusted UI components render them; generated code is kept
separate from explanation text; the local verifier reports syntax/tests/policy
outcomes instead of claiming execution; and repository edits use a snapshot,
preview, verify, commit-or-rollback transaction. The loopback daemon and
`llama.cpp` provider are authenticated, bounded, and subject to the effective
offline network policy. The learning PWA stores progress in local SQLite and
does not require cloud services.

The product exposes this core through two connected surfaces: a CLI for model
lifecycle, policy, status, chat, backups, and launch, plus a browser PWA for
lessons, quizzes, bounded practice, and Build tether. `gdmcode learn` joins the
two through a one-time authenticated loopback handoff.

## Constraints

The target contract is the organizer's Ubuntu 22.04, 4-vCPU, 8-GB RAM laptop
profile. The model is packaged for `llama.cpp`, downloaded without credentials,
and run offline after download. No model weights are committed to this repository.

## Current evidence

The existing Linux cloud audit measured the 4B Q4 candidate at 2.92 tokens/s
with 2,846.14 MiB peak RSS on the audit VM. This is explicitly a cloud audit
envelope, not the official participant-laptop score. The candidate is frozen at
the checksum above, and its credential-free public URL is pinned in
`download_model.sh`. Participant-profiler evidence is recorded in
`BENCHMARKS.md` and `submission.json` when available.

The curated harness source has separately passed 43 local-core unit tests and
18 journal tests in the current working tree, plus a network-disabled Linux
runtime rehearsal. Those are harness/source results, not participant-model
scores.

The separate 19-case held-out product suite scored the submitted 4B model at
0.8666 overall with 9/19 full rubric passes. Beginner teaching scored 0.9722,
child-build 0.8080, student assistance 0.8785, structured course/quiz generation
1.0000, harness integration 0.6932, and local-readiness 0.5000. Methodology,
the disclosed 2B comparison, and limitations are in `SELF_EVALUATION.md`.

## Reproducibility and privacy

The downloader requires an immutable public HTTPS URL, verifies SHA-256, and
uses an atomic move after a successful download. Private datasets, generator
records, AWS identifiers, private evaluations, and the live website are
excluded from this public repository.
