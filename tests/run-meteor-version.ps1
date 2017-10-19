Write-Host "Adding 'meteor' to `$Path..." -ForegroundColor Magenta
# Find where 'meteor.bat' should be installed...
$localAppData = [Environment]::GetFolderPath('LocalApplicationData')
$meteorDir = Join-Path $localAppData '.meteor'

# Append it to the $Path
$env:Path += ";${meteorDir}"

# This also might be a suitable way of checking...
# Get-Command "meteor" -ErrorAction SilentlyContinue

Write-Host "Running 'meteor --version'..." -ForegroundColor Magenta
# Try calling it!
try {
  $result = (& "meteor" --version)
  $meteorExitCode = $LASTEXITCODE
} catch {
  # Nothing means it worked.
}

# If there was an error, Exit 1.
If ($meteorExitCode -ne 0) {
  Exit 1
}

$result -Replace '^Meteor '