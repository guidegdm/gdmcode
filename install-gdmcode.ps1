[CmdletBinding()]
param(
    [string]$InstallDir = (Join-Path $env:LOCALAPPDATA "Programs\GDMCode"),
    [ValidateSet("None", "Spark", "Forge", "Both")]
    [string]$Models = "None",
    [string]$BundlePath,
    [string]$BundleSha256Override,
    [switch]$WithModel
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$BundleUrl = "https://github.com/guidegdm/gdmcode/releases/download/v0.2.112-adtc/gdmcode-v0.2.112-windows-x64.zip"
$BundleSha256 = "e7696572ba688e4837c62408fa8278561780826b13bb1ab130c8bd0bd5193778"
if ($BundleSha256Override) { $BundleSha256 = $BundleSha256Override.ToLowerInvariant() }
$ModelSpecs = @{
    Spark = @{
        File = "qwen35-2b-Q4_K_M.gguf"
        Url = "https://d2aewvy0a2lorh.cloudfront.net/adtc-2026/sha256-ea443cd07fb307e0bfb332864c569ebbd8419427de7547029e3a36ca1f231e4b/qwen35-2b-Q4_K_M.gguf"
        Sha256 = "ea443cd07fb307e0bfb332864c569ebbd8419427de7547029e3a36ca1f231e4b"
        Bytes = 1274396512
        Id = "gdmcode-qwen35-2b-q4km-windows"
    }
    Forge = @{
        File = "qwen35-4b-Q4_K_M.gguf"
        Url = "https://d2aewvy0a2lorh.cloudfront.net/adtc-2026/sha256-514c57feaeead5cc7803421327389a3cdca397cb5d84a6848f4616b916fd2ee9/qwen35-4b-Q4_K_M.gguf"
        Sha256 = "514c57feaeead5cc7803421327389a3cdca397cb5d84a6848f4616b916fd2ee9"
        Bytes = 2708803840
        Id = "gdmcode-qwen35-4b-q4km-windows"
    }
}
$Stage = Join-Path ([IO.Path]::GetTempPath()) "gdmcode-install-$PID"
$Zip = Join-Path $Stage "gdmcode-windows-x64.zip"

if ($WithModel) {
    if ($Models -ne "None") { throw "Use either -WithModel or -Models, not both" }
    $Models = "Spark"
}

function Assert-Sha256([string]$Path, [string]$Expected) {
    $Actual = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($Actual -ne $Expected) {
        throw "SHA-256 mismatch for $Path (expected $Expected, found $Actual)"
    }
}

try {
    New-Item -ItemType Directory -Force -Path $Stage | Out-Null
    if ($BundlePath) {
        if (-not (Test-Path -LiteralPath $BundlePath -PathType Leaf)) {
            throw "specified bundle does not exist: $BundlePath"
        }
        Copy-Item -LiteralPath $BundlePath -Destination $Zip
    } else {
        curl.exe --fail --location --retry 3 --retry-all-errors --output $Zip $BundleUrl
        if ($LASTEXITCODE -ne 0) { throw "GDMCode bundle download failed" }
    }
    Assert-Sha256 $Zip $BundleSha256

    Expand-Archive -LiteralPath $Zip -DestinationPath $Stage
    $ReleaseRoots = @(Get-ChildItem -LiteralPath $Stage -Directory | Where-Object {
        Test-Path -LiteralPath (Join-Path $_.FullName "bin\gdmcode.exe")
    })
    if ($ReleaseRoots.Count -ne 1) {
        throw "verified bundle must contain exactly one release root with bin\gdmcode.exe"
    }
    $Source = $ReleaseRoots[0].FullName
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    Copy-Item -Path (Join-Path $Source "*") -Destination $InstallDir -Recurse -Force

    $BinDir = Join-Path $InstallDir "bin"
    $LegacyBinDir = Join-Path $InstallDir "current\bin"
    $CurrentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $PathItems = @($CurrentUserPath -split ";" | Where-Object {
        $_ -and
        -not [String]::Equals($_.TrimEnd('\'), $LegacyBinDir.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase) -and
        -not [String]::Equals($_.TrimEnd('\'), $BinDir.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase)
    })
    $NewPath = (@($BinDir) + $PathItems) -join ";"
    if ($NewPath -ne $CurrentUserPath) {
        [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
    }

    if ($Models -ne "None") {
        $ModelDir = Join-Path $InstallDir "model"
        New-Item -ItemType Directory -Force -Path $ModelDir | Out-Null
        $ServerPath = Join-Path $InstallDir "runtime\llama-server.exe"
        $ServerSha = (Get-FileHash -LiteralPath $ServerPath -Algorithm SHA256).Hash.ToLowerInvariant()
        & (Join-Path $BinDir "gdmcode.exe") offline on
        $SelectedModels = if ($Models -eq "Both") { @("Spark", "Forge") } else { @($Models) }
        foreach ($ModelName in $SelectedModels) {
            $Spec = $ModelSpecs[$ModelName]
            $ModelPath = Join-Path $ModelDir $Spec.File
            $Partial = "$ModelPath.partial"
            if (Test-Path -LiteralPath $ModelPath) {
                if ((Get-Item -LiteralPath $ModelPath).Length -ne $Spec.Bytes) {
                    throw "existing model has the wrong size; refusing to overwrite it"
                }
                Assert-Sha256 $ModelPath $Spec.Sha256
            } else {
                curl.exe --fail --location --retry 5 --retry-all-errors --continue-at - --output $Partial $Spec.Url
                if ($LASTEXITCODE -ne 0) { throw "model download failed; partial file kept at $Partial" }
                if ((Get-Item -LiteralPath $Partial).Length -ne $Spec.Bytes) {
                    throw "downloaded model has the wrong size; partial file kept at $Partial"
                }
                Assert-Sha256 $Partial $Spec.Sha256
                Move-Item -LiteralPath $Partial -Destination $ModelPath
            }

            $ManifestPath = Join-Path $InstallDir "model-$ModelName-manifest.json"
            $Manifest = @{
                schema_version = 1
                id = $Spec.Id
                model = @{ path = $ModelPath; sha256 = $Spec.Sha256; bytes = $Spec.Bytes }
                llama_server = @{ path = $ServerPath; sha256 = $ServerSha; bytes = (Get-Item -LiteralPath $ServerPath).Length }
                # Keep Spark light on 8 GB machines while giving Forge enough
                # room for repository prompts. Both values leave headroom for
                # the local UI, SQLite, and the rest of the desktop.
                runtime = @{ host = "127.0.0.1"; port = 8767; context_size = $(if ($ModelName -eq "Spark") { 4096 } else { 8192 }); threads = [Math]::Max(1, [Math]::Min($(if ($ModelName -eq "Spark") { 4 } else { 8 }), [Environment]::ProcessorCount)); extra_args = @("--jinja", "--no-webui") }
            }
            $ManifestJson = $Manifest | ConvertTo-Json -Depth 8
            [IO.File]::WriteAllText(
                $ManifestPath,
                $ManifestJson,
                (New-Object System.Text.UTF8Encoding($false))
            )
            $RegisterArgs = @("model", "add", $ManifestPath)
            if ($Models -eq "Both" -and $ModelName -eq "Forge") {
                $RegisterArgs += "--no-activate"
            }
            & (Join-Path $BinDir "gdmcode.exe") @RegisterArgs
            if ($LASTEXITCODE -ne 0) { throw "model registration failed for $ModelName" }
        }
    }

    Write-Host "GDMCode installed at $InstallDir"
    if ($Models -ne "None") {
        Write-Host "Open a new terminal and run: gdmcode learn"
    } else {
        Write-Host "Rerun with -Models Spark, -Models Forge, or -Models Both to fetch and register public models."
    }
} finally {
    if (Test-Path -LiteralPath $Stage) {
        Remove-Item -LiteralPath $Stage -Recurse -Force
    }
}
