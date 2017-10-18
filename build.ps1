Write-Host "Ensuring 'build' directory exists..." -ForegroundColor Magenta
$buildDirectory = Join-Path $PSScriptRoot 'build'
New-Item -Type Directory -Force $buildDirectory

$nuspecFile = Join-Path $PSScriptRoot 'meteor.nuspec'

# Get the version information out of this file.
[xml]$nuspec = Get-Content -Path $nuspecFile
$testPackageId = $nuspec.package.metadata.id
$testVersion = $nuspec.package.metadata.version

Write-Host "Installing chocolatey-core extensions..." -ForegroundColor Magenta
& choco.exe install chocolatey-core.extension

Write-Host "Running 'choco pack' for ${testVersion}..." -ForegroundColor Magenta
& choco.exe pack $nuspecFile --outputdirectory $buildDirectory

$nupkgFile = "${testPackageId}.${testVersion}.nupkg"
$nupkgPath = Join-Path $buildDirectory $nupkgFile

Get-ChildItem $buildDirectory
