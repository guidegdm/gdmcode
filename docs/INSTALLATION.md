# Install and run GDMCode

This public repository distributes the GDMCode application as a prebuilt
binary. The release executable contains the terminal TUI, local coding
harness, and learning PWA assets; the bundled CPU inference runtime is shipped
beside it. The package includes release checksums, applicable licenses/notices,
and installation scripts. The application source is maintained separately in
a private repository and is not required for installation.

## Windows 10/11 x64 — prebuilt

Download the repository and run PowerShell from its root:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-gdmcode.ps1 -WithModel
```

The installer downloads and verifies the checksum-pinned application/runtime
bundle, then optionally downloads and verifies a public model. `-WithModel`
selects Spark 2B by default. It installs to
the current user's local application directory, adds the binary directory to
the user PATH, sets Offline mode, and registers the verified model. No
administrator account or AWS credential is required.

Open a new terminal and run:

```powershell
gdmcode status
gdmcode learn
```

Open the one-time local URL printed by `gdmcode learn`. Keep that terminal open
while using the app.

## Model choices

The public model downloads are credential-free HTTPS objects with immutable
paths and pinned SHA-256 values:

| Model | Size | SHA-256 |
|---|---:|---|
| Qwen3.5-2B Q4_K_M | 1,274,396,512 bytes | `ea443cd07fb307e0bfb332864c569ebbd8419427de7547029e3a36ca1f231e4b` |
| Qwen3.5-4B Q4_K_M | 2,708,803,840 bytes | `514c57feaeead5cc7803421327389a3cdca397cb5d84a6848f4616b916fd2ee9` |

`download_model.sh` downloads Spark 2B by default; pass `forge` for the
submitted 4B artifact. The Windows
installer's `-Models Spark`, `-Models Forge`, and `-Models Both` options select
the corresponding public artifacts.

On Windows, the installer places weights under
`%LOCALAPPDATA%\Programs\GDMCode\model`, writes a manifest beside the install,
and invokes `gdmcode model add` for each verified file. The binary uses that
verified catalog; it does not guess from arbitrary model files elsewhere on
the disk.

## Release contents and notices

Each public Windows release contains the application binary, the official
llama.cpp CPU runtime, a release checksum file, and a `licenses/` directory.
The repository's [`LICENSE`](../LICENSE) covers the public submission material;
the repository [`licenses/`](../licenses/) directory and the release archive
carry the GDMCode, llama.cpp, and runtime notices for the bundled components.
Do not redistribute a release after removing those notices.

The public release does not include the application source code, private model
training records, private evaluations, credentials, or cloud configuration.

## Uninstall

Windows installs only under `%LOCALAPPDATA%\Programs\GDMCode` plus one user-PATH
entry. Remove that directory and PATH entry to uninstall. Local learning state
is stored separately under the user's application-data directory; back it up
with `gdmcode data backup` before removal if it matters.
