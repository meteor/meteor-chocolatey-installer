# Borrowed from Install-ChocolateyZipPackage: https://git.io/vdEZj
$chocTempDir = $env:TEMP
$tempDir = Join-Path $chocTempDir "$($env:chocolateyPackageName)"
if ($env:chocolateyPackageVersion -ne $null) {
  $tempDir = Join-Path $tempDir "$($env:chocolateyPackageVersion)";
}
$tempDir = $tempDir -replace '\\chocolatey\\chocolatey\\','\chocolatey\'

Function New-TemporaryDirectory {
  [string] $name = [System.Guid]::NewGuid()
  New-Item -ItemType Directory -Path (Join-Path $tempDir $name)
}

<#
  .Synopsis
  Remove longer directory paths in a more aggressive way.

  .Description
  Meteor directories are very long due to the presence of deeply nested
  node_modules directories.  This assists with removing those deep folder trees.
#>
Function Remove-DirectoryRecursively {
  Param (
    [Parameter(Mandatory=$True, Position=0)]
    [string]$Path
  )
  if (Test-Path -LiteralPath $Path -PathType 'Container') {
    if (Get-Command "robocopy.exe" -ErrorAction SilentlyContinue) {
      # Quietly use Robocopy to sync the Path with an empty directory.
      $emptyTempDir = New-TemporaryDirectory
      & robocopy.exe $emptyTempDir $Path /purge | Out-Null
      Remove-Item $Path -Recurse -Force
      Remove-Item $emptyTempDir -Force
    } else {
      [System.IO.Directory]::Delete($Path, $true)
    }
  }
}

<#
  .Synopsis
  Remove the old, Wix-based installer, which is no longer used.

  .Description
  Previously, Meteor was installed with a WiX-based installer.  This installer
  is no longer actively maintained and this removes any such install.
#>
Function Remove-OldMeteorInstall {
  [array]$existing = Get-UninstallRegistryKey -SoftwareName "Meteor"
  If ($existing.Count -And $existing.QuietUninstallString) {
    Write-Output "$existing"
    Write-Output "Removing exising Meteor installation with installer"
    Write-Output " => $($existing.QuietUninstallString)"
    & cmd /c $($existing.QuietUninstallString)
  }
}