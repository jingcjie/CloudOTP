<#
.SYNOPSIS
  Pre-publish verification gate for CloudOTP.

.DESCRIPTION
  Runs the static + unit-test gate, and (with -Build) the release builds for the
  three ship targets (Android APKs, Web, Windows MSIX). Stops at the first
  failure so a broken step never gets published.

.EXAMPLE
  ./tool/preflight.ps1            # fast gate: pub get + analyze + test
  ./tool/preflight.ps1 -Build     # gate + Android/Web/Windows release builds
#>
param(
  [switch]$Build
)

$ErrorActionPreference = 'Stop'

function Invoke-Step($name, [scriptblock]$cmd) {
  Write-Host "`n=== $name ===" -ForegroundColor Cyan
  & $cmd
  if ($LASTEXITCODE -ne 0) {
    Write-Host "FAILED: $name (exit $LASTEXITCODE)" -ForegroundColor Red
    exit $LASTEXITCODE
  }
}

# Fast gate — runs on any machine, no device needed.
Invoke-Step 'flutter pub get'  { flutter pub get }
# --no-fatal-infos: halt on warnings/errors but tolerate the known pre-existing
# `info` lints (see todo.md "Remaining"). New warnings/errors still fail the gate.
Invoke-Step 'flutter analyze'  { flutter analyze --no-fatal-infos }
Invoke-Step 'flutter test'     { flutter test }

if ($Build) {
  # Android: 3 ABI APKs for the GitHub Release.
  Invoke-Step 'build apk (split-per-abi)' { flutter build apk --split-per-abi }
  # Web: deploy build/web to the host.
  Invoke-Step 'build web'                 { flutter build web }
  # Windows: MSIX for the Microsoft Store (uses msix_config in pubspec.yaml).
  Invoke-Step 'msix:create'               { dart run msix:create }
}

Write-Host "`nAll preflight steps passed." -ForegroundColor Green
if (-not $Build) {
  Write-Host "Run with -Build to also produce the Android/Web/Windows release artifacts." -ForegroundColor DarkGray
}
