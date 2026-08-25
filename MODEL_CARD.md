# GDMCode model card

**Status:** ADTC 2026 submitted candidate.

## Model summary

- **Candidate:** Qwen3.5-4B trained checkpoint
- **Artifact:** GGUF Q4_K_M
- **Runtime:** `llama.cpp`
- **SHA-256:** `514c57feaeead5cc7803421327389a3cdca397cb5d84a6848f4616b916fd2ee9`
- **Intended role:** offline English programming tutor inside a local coding
  harness with a bounded runner, typed lesson UI, and permission-gated edits
- **Target profile:** Ubuntu 22.04, 4 vCPUs, 8 GB RAM, integrated graphics

This lane uses the privately fine-tuned 4B checkpoint. It is not the raw 2B
low-resource alternative.

## Intended and out-of-scope use

The intended use is beginner-friendly programming explanation, small debugging
help, and study assistance when inference must run locally. GDMCode adds the
product value around the model: a local coding workspace, structured lesson
rendering, a bounded checker, and rollback-safe repository transactions. It is
not intended for autonomous production changes, security-critical code without
expert review, or claims that code was executed when it was not.

## Training and data

The privately trained 4B comparison uses gated model-lab records; those records,
generator evidence, and private evaluations are not included in this handoff.
The raw 2B alternative has no GDMCode fine-tuning data applied.

## Evaluation status

The current audit evidence is reported in `BENCHMARKS.md`. It was collected on
an audit cloud VM and must not be represented as the official participant-laptop
score. Accuracy is `NOT MEASURED` in that audit. The local participant-mode
performance pass and its explicit accuracy limitation are documented in
`BENCHMARKS.md`. A full hidden-accuracy audit remains open. The candidate is
frozen at the checksum above and publicly hosted through the credential-free
URL in `download_model.sh`.

## Limitations and privacy

Small local models can misunderstand ambiguous requirements, produce incorrect
code, or omit edge cases. Verify all generated code. The model artifact is
intended to run offline after download; the broader GDMCode product may have
separate optional online capabilities. No training data, credentials, AWS
configuration, or private evaluation cases are present in this repository.

## License and reproducibility

The project model-selection record identifies the Qwen base as Apache-2.0.
The ADTC template license and notices are kept in `LICENSE`. See
`artifact-manifest.json`, `metadata.json`, and `download_model.sh`
for the pinned artifact path, checksum, and credential-free download contract.
