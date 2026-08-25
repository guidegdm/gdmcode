# ADTC evaluation procedure

This is the clean-room procedure for the repository evaluator. It intentionally
does not use the cloud audit values in `BENCHMARKS.md` as participant scores.

## Target environment

Use the organizer's participant profile: Ubuntu 22.04, 4 vCPUs, 8 GB RAM,
integrated graphics, and 256 GB SSD. Start from a fresh checkout with network
available only for the model download and profiler installation.

## Reproduce the model pin

1. Run `./download_model.sh` from a clean `model/` directory; the frozen public
   CloudFront URL is embedded in the script.
2. Remove only the downloaded model, then run `./download_model.sh` again.
3. Confirm both downloads produce the SHA-256 in `metadata.json` and
   `artifact-manifest.json`.
4. Disconnect the network. The model must remain usable from `model/`.

The downloader must not receive AWS credentials, S3 credentials, or a
presigned URL. `GDMCODE_MODEL_URL` is an optional HTTPS-only mirror override;
the default evaluator path requires no environment variable.

## Run the official profiler

Install the pinned profiler revision and run participant mode from this
directory:

```bash
python3 -m pip install \
  "git+https://github.com/Africa-Deep-Tech-Foundation/adtc-profiler.git@ac2e137dca65ea3b09d997774f17dd8907b489fb"
adtc-profiler run --submission . --mode participant --output submission.json
```

Use the two prompts in `metadata.json` exactly, without adding hidden setup
prompts or changing the model between runs. Preserve the profiler output as
the submission evidence. Report tokens/s, first-token latency, peak RSS,
thermal result, and the profiler's accuracy result exactly as measured.

## What not to claim

The 2.92 tokens/s and 2,846.14 MiB values are from an `audit_cloud_vm` run on a
different machine. They are useful for an engineering envelope but are not the
participant scores. The local participant-mode performance pass measured 2.48
tokens/s and 4,428.49 MiB peak RSS, producing Sperf 16.53 and Seff 38.22.
Because that pass used `--skip-accuracy` and Windows exposed no temperature
sensor, no participant accuracy or temperature claim is made.

The four `*-real.png` gallery images were captured from the frozen model and
real local daemon. Files named `*-preview.png` remain fixture-only design
references and are not model-generation, latency, or profiler evidence.
