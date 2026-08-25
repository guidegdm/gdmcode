# Data provenance summary (private draft)

This document describes the public-boundary decision, not the private model-lab
records.

## Comparison lane

The staged candidate is the privately trained Qwen3.5-4B checkpoint. Its gated
specialization records, generator evidence, AWS/S3 paths, raw responses, and
private eval cases are not copied into this handoff.

## Provisional raw alternative

The raw Qwen3.5-2B alternative has no GDMCode fine-tuning data applied. It is
the lower-resource lane and is not the frozen public winner.

## Reproducibility and contamination controls

The candidate identity is fixed by the GGUF SHA-256 in
`artifact-manifest.json`. The two public prompts are fixed in `metadata.json`.
The public tree contains no raw corpus, credentials, private URLs, or model
weights. Any final publication must add a reviewed source-level provenance and
license notice for the exact hosted base artifact.
