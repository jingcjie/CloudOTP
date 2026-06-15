<#
.SYNOPSIS
  Loads local Microsoft Store publishing secrets from an ignored .env file.

.EXAMPLE
  Copy-Item .env.local.example .env.local
  notepad .env.local
  ./tool/Import-StorePublishingEnv.ps1 -ConfigureMsstore
#>
param(
  [string]$EnvPath = ".env.local",
  [switch]$ConfigureMsstore
)

$ErrorActionPreference = 'Stop'

function Resolve-LocalPath {
  param([string]$Path)

  if ([System.IO.Path]::IsPathRooted($Path)) {
    return $Path
  }

  return Join-Path (Get-Location) $Path
}

function Unquote-EnvValue {
  param([string]$Value)

  $trimmed = $Value.Trim()
  if ($trimmed.Length -ge 2) {
    $first = $trimmed[0]
    $last = $trimmed[$trimmed.Length - 1]
    if (($first -eq '"' -and $last -eq '"') -or ($first -eq "'" -and $last -eq "'")) {
      return $trimmed.Substring(1, $trimmed.Length - 2)
    }
  }

  return $trimmed
}

$resolvedEnvPath = Resolve-LocalPath $EnvPath
if (-not (Test-Path -LiteralPath $resolvedEnvPath)) {
  throw "Local env file not found: $resolvedEnvPath. Copy .env.local.example to .env.local first."
}

$loaded = New-Object System.Collections.Generic.List[string]
foreach ($line in Get-Content -LiteralPath $resolvedEnvPath) {
  $trimmed = $line.Trim()
  if (-not $trimmed -or $trimmed.StartsWith('#')) {
    continue
  }

  $separatorIndex = $trimmed.IndexOf('=')
  if ($separatorIndex -lt 1) {
    throw "Invalid .env line: $line"
  }

  $name = $trimmed.Substring(0, $separatorIndex).Trim()
  $value = Unquote-EnvValue $trimmed.Substring($separatorIndex + 1)

  if ($name -notmatch '^MSSTORE_[A-Z0-9_]+$') {
    throw "Unexpected .env key '$name'. Only MSSTORE_* keys are allowed."
  }

  [Environment]::SetEnvironmentVariable($name, $value, 'Process')
  $loaded.Add($name) | Out-Null
}

$required = @(
  'MSSTORE_TENANT_ID',
  'MSSTORE_CLIENT_ID',
  'MSSTORE_CLIENT_SECRET',
  'MSSTORE_SELLER_ID',
  'MSSTORE_PRODUCT_ID'
)

$missing = $required | Where-Object {
  [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($_, 'Process'))
}

if ($missing.Count -gt 0) {
  throw "Missing required local env values: $($missing -join ', ')"
}

Write-Host "Loaded local Store publishing environment values:"
$loaded | Sort-Object | ForEach-Object { Write-Host "  $_" }

if ($ConfigureMsstore) {
  msstore reconfigure `
    --tenantId $env:MSSTORE_TENANT_ID `
    --sellerId $env:MSSTORE_SELLER_ID `
    --clientId $env:MSSTORE_CLIENT_ID `
    --clientSecret $env:MSSTORE_CLIENT_SECRET
}
