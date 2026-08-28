[CmdletBinding()]
param(
    [string]$InstallDir = (Join-Path $env:LOCALAPPDATA "Programs\GDMCode"),
    [string]$BundlePath,
    [string]$BundleSha256Override
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

<#
  Apply a complete, checksum-pinned GDMCode bundle update. The installer
  downloads and verifies the complete bundle before copying it into the
  existing per-user installation. Learner state and verified GGUFs are
  preserved. Run this after closing active GDMCode windows; if a file is still
  locked, the installer stops and can be rerun after the process exits.
#>

$Installer = Join-Path $PSScriptRoot "install-gdmcode.ps1"
if (-not (Test-Path -LiteralPath $Installer -PathType Leaf)) {
    throw "install-gdmcode.ps1 is missing beside the updater"
}

$Arguments = @(
    "-InstallDir", $InstallDir,
    "-Models", "None"
)
if ($BundlePath) {
    $Arguments += @("-BundlePath", $BundlePath)
}
if ($BundleSha256Override) {
    $Arguments += @("-BundleSha256Override", $BundleSha256Override)
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Installer @Arguments
if ($LASTEXITCODE -ne 0) {
    throw "GDMCode update failed; close active GDMCode processes and rerun the updater"
}
Write-Host "GDMCode application bundle updated. Existing models and learner state were preserved."
