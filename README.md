# GDMCode — an offline coding tutor for the laptop Africa actually has

GDMCode is a local-first programming tutor and coding harness for beginners,
students, and unreliable-connectivity environments. It combines a small local
language model with a typed lesson UI, a bounded practice checker, and a
permission-gated Build tether. The model suggests; the harness controls what is
rendered, checked, written, and rolled back.

GDMCode has both a CLI and a visual PWA. The CLI manages model registration,
Offline policy, status, terminal chat, backups, and launch; `gdmcode learn`
starts the authenticated local service and opens the learner interface. Both
surfaces use the same verified model and policy boundary.

This is the clean ADTC submission repository. It is
deliberately weight-free: personal workbench notes, private datasets, AWS
configuration, private evaluations, and the live website are not part of this
tree. `model/` is populated only by `download_model.sh` on the evaluator's
machine.

## Why this is different

The project is not a chat box wrapped around a model. GDMCode is an offline
learning loop:

1. The learner opens `/learn` and sees an explicit `OFFLINE · LOCAL` state.
2. A lesson is rendered through validated `LessonIR` data rather than raw
   model markup.
3. Quick checks and Practice use bounded, explainable checks instead of
   claiming arbitrary host execution.
4. Build tether keeps explanation beside the code and makes write/execute
   boundaries visible.
5. Repository changes are previewed, verified, and committed or rolled back as
   one transaction.

The default path needs no cloud service after the model download. Online mode
is an explicit user choice and is outside the offline benchmark contract.

## Submission candidate

- Candidate: privately fine-tuned Qwen3.5-4B
- Artifact: GGUF `Q4_K_M`, served by `llama.cpp`
- SHA-256: `514c57feaeead5cc7803421327389a3cdca397cb5d84a6848f4616b916fd2ee9`
- Public Devpost project/team slug: `gdmcode`
- Public model URL: immutable, credential-free CloudFront object embedded in
  `download_model.sh`; the path includes the frozen SHA-256
- Exactly two evaluator prompts: see [`metadata.json`](metadata.json)

The raw Qwen3.5-2B Q4_K_M artifact is retained as the lower-resource comparison
in the engineering record; it is not silently substituted for this 4B lane.

## Quick start

On a clean Ubuntu 22.04 checkout:

```bash
./download_model.sh
```

The downloader rejects missing or non-HTTPS URLs, downloads to a temporary
file, verifies the pinned SHA-256, and atomically moves the verified artifact
into `model/`. It never needs AWS credentials. Do not commit the resulting
`.gguf` file. `GDMCODE_MODEL_URL` remains available only as an explicit HTTPS
override for controlled mirrors and tests.

Run the pinned participant profiler exactly as the organizer specifies:

```bash
python3 -m pip install \
  "git+https://github.com/Africa-Deep-Tech-Foundation/adtc-profiler.git@ac2e137dca65ea3b09d997774f17dd8907b489fb"
adtc-profiler run --submission . --mode participant --output submission.json
```

See [`docs/EVALUATION.md`](docs/EVALUATION.md) for the clean-room procedure
and [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the harness boundary.

## Install the GDMCode application

The repository includes the reviewed application source under [`app/`](app/)
and a checksum-pinned Windows installer. On Windows 10/11 x64:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-gdmcode.ps1 -WithModel
gdmcode learn
```

The first command installs the GDMCode binary, official llama.cpp CPU runtime,
and exact 4B model without administrator privileges. The second starts the
local daemon and prints the authenticated `/learn` URL. Ubuntu build/package
instructions are in [`docs/INSTALLATION.md`](docs/INSTALLATION.md).

## Evidence and honest limits

[`BENCHMARKS.md`](BENCHMARKS.md) separates the existing cloud audit envelope
from the official participant-laptop score. The cloud audit measured 2.92
tokens/s and 2,846.14 MiB peak RSS on its own VM; those numbers are **not** an
ADTC participant score. The checked-in profiler report and benchmark page
distinguish measured results from claims that have not been tested.

Small local models can be wrong, omit edge cases, or misunderstand ambiguous
requirements. Review generated code, do not use it for security-critical work
without an expert, and do not treat a checker result as proof of correctness.

## Repository map

| File | Purpose |
|---|---|
| `metadata.json` | ADTC identity, model pin, and exactly two test prompts |
| `download_model.sh` | Credential-free HTTPS download plus checksum gate |
| `REPORT.md` | Problem, design decisions, constraints, and evidence |
| `MODEL_CARD.md` | Intended use, limitations, and model provenance |
| `BENCHMARKS.md` | Clearly labelled audit and participant status |
| `SELF_EVALUATION.md` | Held-out beginner, student, course, child-build, and harness results |
| `docs/ARCHITECTURE.md` | Product and safety boundaries |
| `docs/EVALUATION.md` | Reproducible evaluator procedure |
| `docs/INSTALLATION.md` | Windows binary and Ubuntu source installation |
| `docs/media/` | Real runtime screenshots plus labelled design previews |
| `app/` | Reviewed standalone Rust core and embedded Learn PWA |
| `install-gdmcode.ps1` | Checksum-pinned per-user Windows installer |
| `model/` | Empty in git; populated by the downloader |

The upstream ADTC template license and notices remain in `LICENSE`.

## UI preview gallery

The [`docs/media/`](docs/media/) gallery includes four real captures from the
Windows binary and frozen 4B model: Offline hero, lesson/quiz, bounded local
practice, and Build tether with a streamed local-model answer. Older design
previews remain explicitly labelled as previews.
