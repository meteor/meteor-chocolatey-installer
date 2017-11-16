Param(
  [string]$releaseVersion
)

Write-Host "Installing chocolatey-core extensions..." -ForegroundColor Magenta
& choco.exe install chocolatey-core.extension

$testsDirectory = Split-Path $MyInvocation.MyCommand.Path -Parent
$checkoutDirectory = (Get-Item $testsDirectory).parent.FullName
$buildDirectory = Join-Path $checkoutDirectory 'build'

# Trying to install the package we just made.
$nupkg = Get-ChildItem -Path $buildDirectory -Filter '*.nupkg' |
  Select-Object -First 1

If (!(Test-Path -PathType 'Leaf' -Path $nupkg.FullName)) {
  throw "Couldn't find the '.nupkg'.  It should be the only file in '.\build'!"
}

Write-Host "Trying to install $($nupkg.FullName)..." `
  -ForegroundColor Magenta

If ($releaseVersion) {
  & choco.exe install meteor --force --yes -d `
    --allow-downgrade `
    --prerelease `
    --source $buildDirectory `
    --params="'/Release:${releaseVersion}'"
} Else {
  & choco.exe install meteor --force --yes -d `
    --allow-downgrade `
    --prerelease `
    --source $buildDirectory
}

Write-Host "The result was '$result'"