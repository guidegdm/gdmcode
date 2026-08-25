[CmdletBinding()]
param(
    [string]$InstallDir = (Join-Path $env:LOCALAPPDATA "Programs\GDMCode"),
    [switch]$WithModel
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$BundleUrl = "https://github.com/guidegdm/gdmcode/releases/download/v0.1.0-adtc/gdmcode-v0.1.0-windows-x64.zip"
$BundleSha256 = "e676433c0705cfb3a2dd522cbb77bed7dfbee6cd48f2b8544915c1cf603d8de8"
$ModelUrl = "https://d2aewvy0a2lorh.cloudfront.net/adtc-2026/sha256-514c57feaeead5cc7803421327389a3cdca397cb5d84a6848f4616b916fd2ee9/qwen35-4b-Q4_K_M.gguf"
$ModelSha256 = "514c57feaeead5cc7803421327389a3cdca397cb5d84a6848f4616b916fd2ee9"
$ModelBytes = 2708803840
$Stage = Join-Path ([IO.Path]::GetTempPath()) "gdmcode-install-$PID"
$Zip = Join-Path $Stage "gdmcode-windows-x64.zip"

function Assert-Sha256([string]$Path, [string]$Expected) {
    $Actual = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($Actual -ne $Expected) {
        throw "SHA-256 mismatch for $Path (expected $Expected, found $Actual)"
    }
}

try {
    New-Item -ItemType Directory -Force -Path $Stage | Out-Null
    curl.exe --fail --location --retry 3 --retry-all-errors --output $Zip $BundleUrl
    if ($LASTEXITCODE -ne 0) { throw "GDMCode bundle download failed" }
    Assert-Sha256 $Zip $BundleSha256

    Expand-Archive -LiteralPath $Zip -DestinationPath $Stage
    $Source = Join-Path $Stage "gdmcode-v0.1.0-windows-x64"
    if (-not (Test-Path -LiteralPath (Join-Path $Source "bin\gdmcode.exe"))) {
        throw "verified bundle has an unexpected layout"
    }
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    Copy-Item -Path (Join-Path $Source "*") -Destination $InstallDir -Recurse -Force

    $BinDir = Join-Path $InstallDir "bin"
    $CurrentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $PathItems = @($CurrentUserPath -split ";" | Where-Object { $_ })
    if ($PathItems -notcontains $BinDir) {
        $NewPath = (@($PathItems) + $BinDir) -join ";"
        [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
    }

    if ($WithModel) {
        $ModelDir = Join-Path $InstallDir "model"
        $ModelPath = Join-Path $ModelDir "qwen35-4b-Q4_K_M.gguf"
        $Partial = "$ModelPath.partial"
        New-Item -ItemType Directory -Force -Path $ModelDir | Out-Null
        if (Test-Path -LiteralPath $ModelPath) {
            if ((Get-Item -LiteralPath $ModelPath).Length -ne $ModelBytes) {
                throw "existing model has the wrong size; refusing to overwrite it"
            }
            Assert-Sha256 $ModelPath $ModelSha256
        } else {
            curl.exe --fail --location --retry 5 --retry-all-errors --continue-at - --output $Partial $ModelUrl
            if ($LASTEXITCODE -ne 0) { throw "model download failed; partial file kept at $Partial" }
            if ((Get-Item -LiteralPath $Partial).Length -ne $ModelBytes) {
                throw "downloaded model has the wrong size; partial file kept at $Partial"
            }
            Assert-Sha256 $Partial $ModelSha256
            Move-Item -LiteralPath $Partial -Destination $ModelPath
        }

        $ServerPath = Join-Path $InstallDir "runtime\llama-server.exe"
        $ServerSha = (Get-FileHash -LiteralPath $ServerPath -Algorithm SHA256).Hash.ToLowerInvariant()
        $ManifestPath = Join-Path $InstallDir "model-manifest.json"
        $Manifest = @{
            schema_version = 1
            id = "gdmcode-qwen35-4b-q4km-windows"
            model = @{ path = $ModelPath; sha256 = $ModelSha256; bytes = $ModelBytes }
            llama_server = @{ path = $ServerPath; sha256 = $ServerSha; bytes = (Get-Item -LiteralPath $ServerPath).Length }
            runtime = @{ host = "127.0.0.1"; port = 8767; context_size = 4096; threads = [Math]::Max(1, [Math]::Min(8, [Environment]::ProcessorCount)); extra_args = @("--jinja", "--no-webui") }
        }
        $Manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $ManifestPath -Encoding utf8
        & (Join-Path $BinDir "gdmcode.exe") offline on
        & (Join-Path $BinDir "gdmcode.exe") model add $ManifestPath
        if ($LASTEXITCODE -ne 0) { throw "model registration failed" }
    }

    Write-Host "GDMCode installed at $InstallDir"
    if ($WithModel) {
        Write-Host "Open a new terminal and run: gdmcode learn"
    } else {
        Write-Host "Rerun with -WithModel to fetch and register the 2.71 GB model."
    }
} finally {
    if (Test-Path -LiteralPath $Stage) {
        Remove-Item -LiteralPath $Stage -Recurse -Force
    }
}
