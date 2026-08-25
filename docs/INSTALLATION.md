# Install and run GDMCode

## Windows 10/11 x64 — prebuilt

Download the repository and run PowerShell from its root:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-gdmcode.ps1 -WithModel
```

The installer downloads the checksum-pinned 22 MB application/runtime bundle,
then the separately pinned 2.71 GB model. It installs to the current user's
local application directory, adds the binary directory to the user PATH, sets
Offline mode, and registers the verified model. No administrator account or
AWS credential is required.

Open a new terminal and run:

```powershell
gdmcode status
gdmcode learn
```

Open the one-time local URL printed by `gdmcode learn`. Keep that terminal open
while using the app.

## Ubuntu 22.04 — build the locked source

Install a Rust toolchain and build the reviewed standalone workspace:

```bash
cargo test --manifest-path app/Cargo.toml --locked --workspace
cd app
./gdmcode/local-core/scripts/package-linux.sh
./gdmcode/local-core/scripts/install-linux.sh \
  dist/gdmcode-local-core-0.1.0-x86_64-unknown-linux-gnu
```

The participant evaluator can download the model independently with
`./download_model.sh`. The final Ubuntu binary release and profiler evidence
are recorded separately so a cloud audit is never presented as a participant
score.

## Uninstall

Windows installs only under `%LOCALAPPDATA%\Programs\GDMCode` plus one user-PATH
entry. Remove that directory and PATH entry to uninstall. Local learning state
is stored separately under the user's application-data directory; back it up
with `gdmcode data backup` before removal if it matters.
