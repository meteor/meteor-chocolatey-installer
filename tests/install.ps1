Write-Host "Installing chocolatey-core extensions..." -ForegroundColor Magenta
& choco.exe install chocolatey-core.extension

# Trying to install the package we just made.
$nupkg = Get-ChildItem -Path .\build\ -Filter '*.nupkg' | Select-Object -First 1

If (!(Test-Path -PathType 'Leaf' -Path $nupkg.FullName)) {
  throw "Couldn't find the '.nupkg'.  It should be the only file in '.\build'!"
}

Write-Host "Trying to install $($nupkg.FullName)..." `
  -ForegroundColor Magenta
& choco.exe install -fdy --allow-downgrade $nupkg.FullName
