# GDMCode — local coding agent and adaptive learning studio

GDMCode is a local-first programming tutor and coding harness for beginners,
students, and unreliable-connectivity environments. It combines a small local
language model with a typed lesson UI, a bounded practice checker, and a
permission-gated Build tether. The model suggests; the harness controls what is
rendered, checked, written, and rolled back.

GDMCode has a terminal coding-agent TUI and a visual learning PWA. The release
executable contains both surfaces and the PWA assets, while the bundled CPU
inference runtime is shipped beside it. The TUI provides the local coding
harness, repository tools, permissions, and model conversation; `gdmcode learn`
starts the authenticated local service and opens the learner interface.
Management commands handle model registration, Offline policy, status,
backups, and launch. Both surfaces use the same verified model and policy
boundary.

This public ADTC submission distributes the Windows application, model setup,
checksums, licenses, notices, and evaluation metadata. Application source,
development records, private datasets, and cloud configuration are not part of
the distribution. `model/` remains empty in Git and is populated by the
download scripts on the user's machine.

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

## Install on Windows

The release bundle contains the Windows x64 application and official
`llama.cpp` CPU runtime. Models are downloaded separately so either public
model can be selected without replacing the application.

On Windows 10/11 x64, run from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-gdmcode.ps1 -WithModel
```

The installer verifies the release bundle, installs it per-user without
administrator privileges, downloads and registers the Spark 2B model, and
adds `gdmcode` to the user PATH. Then open a new PowerShell window:

```powershell
gdmcode
gdmcode learn
```

`gdmcode` opens the terminal coding-agent TUI. `gdmcode learn` starts the local
service and prints the authenticated `/learn` URL. `-WithModel` installs the
smaller Spark 2B by default; use `-Models Forge` for the 4B model or
`-Models Both` to install both public models. The installer writes models to
`%LOCALAPPDATA%\Programs\GDMCode\model`, creates checksum-pinned manifests,
and registers them in the local catalog so the binary can identify them.

The installer and models use credential-free HTTPS downloads and pinned
SHA-256 checks. See [`docs/INSTALLATION.md`](docs/INSTALLATION.md) for the
release layout, checksums, licenses, and notices.

## ADTC evaluation

The challenge's reference environment is Ubuntu 22.04. For a quick local test,
download the smaller public Spark 2B artifact with:

```bash
./download_model.sh
```

To download the submitted 4B Forge artifact instead, run:

```bash
./download_model.sh forge
```

The downloader rejects missing or non-HTTPS URLs, downloads to a temporary
file, verifies the selected model's pinned SHA-256, and atomically moves the
verified artifact into `model/`. It never needs AWS credentials. Do not commit
the resulting `.gguf` file. `GDMCODE_MODEL_URL` is available only as an
explicit HTTPS override for controlled mirrors and tests.

Run the pinned participant profiler from the repository root:

```bash
python3 -m pip install \
  "git+https://github.com/Africa-Deep-Tech-Foundation/adtc-profiler.git@ac2e137dca65ea3b09d997774f17dd8907b489fb"
adtc-profiler run --submission . --mode participant --output submission.json
```

See [`docs/EVALUATION.md`](docs/EVALUATION.md) for the clean-room procedure
and [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the harness boundary.

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
| `RELEASE_CHECKSUMS.txt` | Release bundle and public model SHA-256 values |
| `licenses/` | GDMCode, llama.cpp, and runtime license texts |
| `THIRD-PARTY-NOTICES.md` | Redistribution notice for bundled components |
| `REPORT.md` | Problem, design decisions, constraints, and evidence |
| `MODEL_CARD.md` | Intended use, limitations, and model provenance |
| `BENCHMARKS.md` | Clearly labelled audit and participant status |
| `SELF_EVALUATION.md` | Held-out beginner, student, course, child-build, and harness results |
| `docs/ARCHITECTURE.md` | Product and safety boundaries |
| `docs/EVALUATION.md` | Reproducible evaluator procedure |
| `docs/INSTALLATION.md` | Binary installation, checksums, and notices |
| `docs/media/` | Real runtime screenshots plus labelled design previews |
| `install-gdmcode.ps1` | Checksum-pinned per-user Windows installer |
| `update-gdmcode.ps1` | Checksum-pinned release updater |
| `model/` | Empty in git; populated by the downloader |

The upstream ADTC template license remains in `LICENSE`; bundled application
and runtime license texts are in [`licenses/`](licenses/).

## UI preview gallery

The [`docs/media/`](docs/media/) gallery includes four real captures from the
Windows binary and frozen 4B model: Offline hero, lesson/quiz, bounded local
practice, and Build tether with a streamed local-model answer. Older design
previews remain explicitly labelled as previews.
