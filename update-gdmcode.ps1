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
  stages and verifies the bundle before moving the current application aside;
  learner state and verified GGUFs live outside the bundle and are untouched.
  Run this after closing active GDMCode windows. A failed switch restores the
  previous bundle automatically.
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
    throw "GDMCode update failed; the prior bundle remains selected when rollback was possible"
}
Write-Host "GDMCode application bundle updated. Existing models and learner state were preserved."
