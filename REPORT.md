# Technical Report — GDMCode offline programming tutor and coding harness (draft)

**Status:** private staging draft; not an official submission.

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
The raw Qwen3.5-2B Q4_K_M artifact remains the lower-resource alternative while
participant-profile evidence is collected.

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

## Constraints

The target contract is the organizer's Ubuntu 22.04, 4-vCPU, 8-GB RAM laptop
profile. The model is packaged for `llama.cpp`, downloaded without credentials,
and run offline after download. No model weights are committed to this draft.

## Current evidence

The existing Linux cloud audit measured the 4B Q4 candidate at 2.92 tokens/s
with 2,846.14 MiB peak RSS on the audit VM. This is explicitly a cloud audit
envelope, not the official participant-laptop score. The participant profiler
run, final candidate freeze, and public model URL remain open.

The curated harness source has separately passed 43 local-core unit tests and
18 journal tests in the current working tree, plus a network-disabled Linux
runtime rehearsal. Those are harness/source results, not participant-model
scores.

## Reproducibility and privacy

The downloader requires an immutable public HTTPS URL, verifies SHA-256, and
uses an atomic move after a successful download. Private datasets, generator
records, AWS identifiers, private evaluations, and the live website are
excluded from this handoff.
