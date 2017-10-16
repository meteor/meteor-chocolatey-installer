# Meteor Helpers
#
# "Temp" logic borrowed from Install-ChocolateyZipPackage: https://git.io/vdEZj
$chocTempDir = $env:TEMP
$tempDir = Join-Path $chocTempDir "$($env:chocolateyPackageName)"
if ($env:chocolateyPackageVersion -ne $null) {
  $tempDir = Join-Path $tempDir "$($env:chocolateyPackageVersion)";
}
$tempDir = $tempDir -replace '\\chocolatey\\chocolatey\\','\chocolatey\'

# The current user's %LOCALAPPDATA% directory.  We'll set it once, as
# it should not change.
$localAppData = [Environment]::GetFolderPath('LocalApplicationData')

<#
  .Synopsis
  Obtain a unique temporary directory, within the installer temporary directory.
#>
Function Get-InstallerTempDirectory {
  [System.IO.Directory]::CreateDirectory($tempDir) | Out-Null
  "$tempDir"
}

<#
  .Synopsis
  Obtain a unique temporary directory, within the installer temporary directory.
#>
Function New-TempDirectory {
  [string] $name = [System.Guid]::NewGuid()
  New-Item -ItemType Directory -Path (Join-Path $tempDir $name)
}

Function Assert-LocalAppData {
  if (!(Test-Path -LiteralPath $localAppData -PathType 'Container')) {
    throw "LocalAppData must be available to install in."
  }
}

<#
  .Synopsis
  Retrieve the path to the Meteor data directory.
#>
Function Get-MeteorDataDirectory {
  Join-Path $localAppData '.meteor'
}

<#
  .Synopsis
  Completely remove the Meteor data directory.
#>
Function Initialize-MeteorDataDirectory {
  Assert-LocalAppData
  $meteorLocalAppData = Get-MeteorDataDirectory
  [System.IO.Directory]::CreateDirectory($meteorLocalAppData) | Out-Null
}

<#
  .Synopsis
  Completely remove the Meteor data directory.
#>
Function Remove-MeteorDataDirectory {
  Remove-DirectoryRecursively $(Get-MeteorDataDirectory)
}

<#
  .Synopsis
  Obtain the query string parameters for the boostrap link
#>
Function New-BootstrapLinkQueryString {
  Param (
    [Parameter(Mandatory=$True, Position=0)]
    [string]$Arch,
    [Parameter(Position=1)]
    [string]$Release
  )

  $queryString = "?arch=${Arch}"
  if ($Release) {
    $queryString += "&release=${Release}"
  }
  $queryString
}

<#
  .Synopsis
  Remove longer directory paths in a more aggressive way.

  .Description
  Meteor directories are very long due to deeply nested npm 'node_modules'
  directories.  This assists with removing those deep folder trees.
#>
Function Remove-DirectoryRecursively {
  Param (
    [Parameter(Mandatory=$True, Position=0)]
    [string]$Path
  )
  if (Test-Path -LiteralPath $Path -PathType 'Container') {
    if (Get-Command "robocopy.exe" -ErrorAction SilentlyContinue) {
      # Quietly use Robocopy to sync the Path with an empty directory.
      $emptyTempDir = New-TempDirectory
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

Export-ModuleMember -Function `
  Assert-LocalAppData,
  Get-InstallerTempDirectory,
  Get-MeteorDataDirectory,
  Initialize-MeteorDataDirectory,
  New-BootstrapLinkQueryString,
  Remove-OldMeteorInstall,
  Remove-MeteorDataDirectory