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

$BundleUrl = "https://github.com/guidegdm/gdmcode/releases/download/v0.1.0-adtc/gdmcode-v0.1.0-windows-x64.zip"
$BundleSha256 = "e676433c0705cfb3a2dd522cbb77bed7dfbee6cd48f2b8544915c1cf603d8de8"
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
    $Models = "Forge"
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
                runtime = @{ host = "127.0.0.1"; port = 8767; context_size = 4096; threads = [Math]::Max(1, [Math]::Min(8, [Environment]::ProcessorCount)); extra_args = @("--jinja", "--no-webui") }
            }
            $Manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $ManifestPath -Encoding utf8
            & (Join-Path $BinDir "gdmcode.exe") model add $ManifestPath
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
