<#
.SYNOPSIS
  Signs a local copy of the Store MSIX for sideload testing.

.DESCRIPTION
  The Store submission MSIX is intentionally unsigned when `store: true`;
  Partner Center signs that file. This script leaves that artifact untouched,
  copies it to `*.local-test.msix`, signs the copy with a CurrentUser test
  certificate whose subject matches the Store Publisher.

  For Add-AppxPackage, Windows must trust the signing certificate in the
  LocalMachine certificate stores. Run once from an elevated PowerShell with
  -TrustMachine, then future local test installs can use -Install without
  changing pubspec.yaml.

.EXAMPLE
  ./tool/sign-msix-local.ps1

.EXAMPLE
  ./tool/sign-msix-local.ps1 -TrustMachine -Install
#>
param(
  [string]$MsixPath = "build\windows\x64\runner\Release\cloud_otp.msix",
  [string]$OutputPath = "build\windows\x64\runner\Release\cloud_otp.local-test.msix",
  [string]$CertificateOutputPath = "build\windows\x64\runner\Release\cloud_otp.local-test.cer",
  [string]$Publisher = "CN=79F5182C-F623-427B-BB35-112212334FEE",
  [switch]$TrustMachine,
  [switch]$Install
)

$ErrorActionPreference = 'Stop'

function Find-SignTool {
  $pubCache = Join-Path $env:LOCALAPPDATA 'Pub\Cache\hosted\pub.dev'
  if (Test-Path $pubCache) {
    $bundled = Get-ChildItem -Path $pubCache -Directory -Filter 'msix-*' |
        Sort-Object Name -Descending |
        ForEach-Object { Join-Path $_.FullName 'lib\assets\MSIX-Toolkit\Redist.x64\signtool.exe' } |
        Where-Object { Test-Path $_ } |
        Select-Object -First 1

    if ($bundled) {
      return $bundled
    }
  }

  $command = Get-Command signtool.exe -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }

  throw 'signtool.exe was not found. Run `flutter pub get` first so the msix package assets are available.'
}

function Test-IsAdministrator {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal]::new($identity)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-OrCreate-TestCertificate {
  param([string]$Subject)

  $cert = Get-ChildItem Cert:\CurrentUser\My |
      Where-Object { $_.Subject -eq $Subject -and $_.HasPrivateKey } |
      Sort-Object NotAfter -Descending |
      Select-Object -First 1

  if (-not $cert) {
    $cert = New-SelfSignedCertificate `
      -Type CodeSigningCert `
      -Subject $Subject `
      -FriendlyName 'CloudOTP local MSIX test signing' `
      -CertStoreLocation Cert:\CurrentUser\My `
      -KeyAlgorithm RSA `
      -KeyLength 2048 `
      -NotAfter (Get-Date).AddYears(3)
  }

  $trustedPeople = Get-ChildItem Cert:\CurrentUser\TrustedPeople |
      Where-Object { $_.Thumbprint -eq $cert.Thumbprint } |
      Select-Object -First 1
  $trustedRoot = Get-ChildItem Cert:\CurrentUser\Root |
      Where-Object { $_.Thumbprint -eq $cert.Thumbprint } |
      Select-Object -First 1

  if (-not $trustedPeople -or -not $trustedRoot) {
    $tempCert = Join-Path $env:TEMP 'cloudotp-local-msix-test.cer'
    Export-Certificate -Cert $cert -FilePath $tempCert | Out-Null
    if (-not $trustedPeople) {
      Import-Certificate -FilePath $tempCert -CertStoreLocation Cert:\CurrentUser\TrustedPeople | Out-Null
    }
    if (-not $trustedRoot) {
      Import-Certificate -FilePath $tempCert -CertStoreLocation Cert:\CurrentUser\Root | Out-Null
    }
    Remove-Item -LiteralPath $tempCert -Force
  }

  return $cert
}

function Add-MachineTrust {
  param(
    [string]$CertificatePath,
    [string]$Thumbprint
  )

  if (-not (Test-IsAdministrator)) {
    throw "Machine certificate trust requires an elevated PowerShell. Re-run this script as Administrator with -TrustMachine."
  }

  $machineRoot = Get-ChildItem Cert:\LocalMachine\Root |
      Where-Object { $_.Thumbprint -eq $Thumbprint } |
      Select-Object -First 1
  $machineTrustedPeople = Get-ChildItem Cert:\LocalMachine\TrustedPeople |
      Where-Object { $_.Thumbprint -eq $Thumbprint } |
      Select-Object -First 1

  if (-not $machineRoot) {
    Import-Certificate -FilePath $CertificatePath -CertStoreLocation Cert:\LocalMachine\Root | Out-Null
  }
  if (-not $machineTrustedPeople) {
    Import-Certificate -FilePath $CertificatePath -CertStoreLocation Cert:\LocalMachine\TrustedPeople | Out-Null
  }
}

$resolvedMsix = Resolve-Path $MsixPath
$resolvedOutput = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
$outputDir = Split-Path -Parent $resolvedOutput
if (-not (Test-Path $outputDir)) {
  New-Item -ItemType Directory -Path $outputDir | Out-Null
}

Copy-Item -LiteralPath $resolvedMsix -Destination $resolvedOutput -Force

$signTool = Find-SignTool
$cert = Get-OrCreate-TestCertificate -Subject $Publisher
$resolvedCertificateOutput = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($CertificateOutputPath)
Export-Certificate -Cert $cert -FilePath $resolvedCertificateOutput | Out-Null

if ($TrustMachine) {
  Add-MachineTrust -CertificatePath $resolvedCertificateOutput -Thumbprint $cert.Thumbprint
}

& $signTool sign /fd SHA256 /sha1 $cert.Thumbprint $resolvedOutput
if ($LASTEXITCODE -ne 0) {
  throw "signtool failed with exit code $LASTEXITCODE"
}

$signature = Get-AuthenticodeSignature $resolvedOutput
Write-Host "Signed local test package:" -ForegroundColor Green
Write-Host "  $resolvedOutput"
Write-Host "Certificate:"
Write-Host "  Subject: $($cert.Subject)"
Write-Host "  Thumbprint: $($cert.Thumbprint)"
Write-Host "  Public cert: $resolvedCertificateOutput"
Write-Host "Signature status:"
Write-Host "  $($signature.Status) - $($signature.StatusMessage)"

if ($Install) {
  $machineRoot = Get-ChildItem Cert:\LocalMachine\Root |
      Where-Object { $_.Thumbprint -eq $cert.Thumbprint } |
      Select-Object -First 1
  if (-not $machineRoot) {
    Write-Host ""
    Write-Host "This package is signed, but Windows will not install it until the certificate is trusted by LocalMachine." -ForegroundColor Yellow
    Write-Host "Run once from an elevated PowerShell:"
    Write-Host "  .\tool\sign-msix-local.ps1 -TrustMachine -Install"
    Write-Host ""
    throw "LocalMachine certificate trust is missing."
  }

  Add-AppxPackage -Path $resolvedOutput -ForceUpdateFromAnyVersion -ForceApplicationShutdown
  Write-Host "Installed local test package." -ForegroundColor Green
}
