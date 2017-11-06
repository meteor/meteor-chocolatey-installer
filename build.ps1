Write-Host "Ensuring 'build' directory exists..." -ForegroundColor Magenta
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$buildDirectory = Join-Path $PSScriptRoot 'build'
New-Item -Type Directory -Force $buildDirectory

$nuspecFile = Join-Path $PSScriptRoot 'meteor.nuspec'

Write-Host "Installing chocolatey-core extensions..." -ForegroundColor Magenta
& choco.exe install chocolatey-core.extension

Write-Host "Running 'choco pack' for ${testVersion}..." -ForegroundColor Magenta
& choco.exe pack $nuspecFile --outputdirectory $buildDirectory

Get-ChildItem $buildDirectory
