<#
  Builds the RemoteBox Windows installer by running make-bundle.sh in the MSYS2
  UCRT64 environment created by setup-msys2.ps1.

  Usage:
      powershell -ExecutionPolicy Bypass -File misc\windows\make-installer.ps1 [-Msys2Root C:\msys64] [-OutDir <dir>]
#>
param(
    [string]$Msys2Root = 'C:\msys64',
    [string]$OutDir = ''
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$bash = Join-Path $Msys2Root 'usr\bin\bash.exe'
if (-not (Test-Path $bash)) { throw "MSYS2 not found in $Msys2Root. Run setup-msys2.ps1 first." }

# Windows PowerShell mangles embedded double quotes passed to native commands,
# so pass MSYS paths in single quotes only
function ConvertTo-MsysPath([string]$p) {
    $p = $p -replace '\\', '/'
    [regex]::Replace($p, '^([A-Za-z]):', { param($m) '/' + $m.Groups[1].Value.ToLower() })
}

$cmd = "bash '" + (ConvertTo-MsysPath (Join-Path $scriptDir 'make-bundle.sh')) + "'"
if ($OutDir) {
    $OutDir = [IO.Path]::GetFullPath($OutDir)
    $cmd += " '" + (ConvertTo-MsysPath $OutDir) + "'"
}

$env:MSYSTEM = 'UCRT64'
$env:CHERE_INVOKING = '1'
& $bash -lc $cmd
if ($LASTEXITCODE -ne 0) { throw "make-bundle.sh failed ($LASTEXITCODE)" }
