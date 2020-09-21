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
Function Remove-OldMeteorInstallerIfDetected {
  [array]$existing = Get-UninstallRegistryKey -SoftwareName "Meteor"
  If ($existing.Count -And $existing.QuietUninstallString) {
    Write-Output "Removing exising Meteor installation with installer"

    # It should be much quicker to uninstall if we remove the data directory
    # using our own mechanism, without waiting for the installer, which may not
    # work properly with long file paths.
    Remove-MeteorDataDirectory

    Write-Output " => $($existing.QuietUninstallString)"
    & cmd /c $($existing.QuietUninstallString)
  }
}

<#
  .Synopsis
  Obtain a checksum by release
#>
Function Get-Checksum {
  Param (
    [Parameter(Position=0)]
    [string]$Release
  )
  switch ($Release) {
    '1.11' {
      $checksum = "25CEF0B5D7C59D4B2D0A45AC3B278C1F5257FEA3A92A578CFFEC9F115707CA22"
      break
    }
    '1.10.1' {
      $checksum = "4ED9946063CF2A4BFBBC11417C01CC45CF53853E545EE9407A1C86E1677B5D05"
      break
    }
    '1.9.3' {
      $checksum = "BC8058A2DCBC33B71F6F15D935C0E524CB56838DB2967DBC6493A82566D1AA6B"
      break
    }
    '1.9.2' {
      $checksum = "945A463010F160C0413BC1EE1964857A8F9244EED69858142F644A5C7E1EF018"
      break
    }
    '1.9.1' {
      $checksum = "57C65077022A1041E0C9579379312470E6353FF2F57A60D60B1895C57D2989F8"
      break
    }
    '1.9' {
      $checksum = "4CE976625F444DED91EC26337E0D7B1EC91A62FA9A078DE89567BF6141C18180"
      break
    }
    '1.8.3' {
      $checksum = "059E7B312657D53A99885C5BD4C1E833BC55BA841EE3C24F2028467EE79DB0F5"
      break
    }
    '1.8.2' {
      $checksum = "FB31A82A7B8E90E1FD7286874C9144B7E5B9F6CB89227294F9E51AF507A28B2C"
      break
    }
    '1.8.1' {
      $checksum = "05B37062FD251432F5469B42DD64A60F83593CF0A0C1968C5A1977F5F96AB199"
      break
    }
    '1.8.0.2' {
      $checksum = "FCB2499FE6F078F7568ADD60B20C5FA6E21139550C00ECA2E3987FC42D727A3E"
      break
    }
    '1.8.0.1' {
      $checksum = "22AD86E226919E8838C0383C10D68CE9E94A242F75F3EA8A91581588B2F1C80F"
      break
    }
    '1.8' {
      $checksum = "E2709312C0E389507E287E65487789198FE338854DBA0D5058A844EF90C76153"
      break
    }
    '1.7.0.5' {
      $checksum = "60D698EF2A4F48C7463FAA17D432D936C845EF743EBD5DC06E344F0AB952A4E1"
      break
    }
    '1.7.0.4' {
      $checksum = "AFA7172E3D98E63E83EA20DBE169FE5034087C9D9F725B9AEE3134CFB3831886"
      break
    }
    '1.7.0.3' {
      $checksum = "82BA4AE44919FC85C2911EC5C4A7B11927800BBBADF2B353FF98B7A57574336D"
      break
    }
    '1.7.0.2' {
      $checksum = "132F5C87577289680D805DB5DCE703C72F0481AADF34777DD6090E30C9B95DFC"
      break
    }
    '1.7.0.1' {
      $checksum = "1667D8473A333666799B91AC176CB58D0F32950137FFD995239A8F139C5C2276"
      break
    }
    '1.7' {
      $checksum = "8F956FB0BB9A6B0470AAE5D76A71E8708D907AA3662821A6F92417E090520644"
      break
    }
    '1.6-rc.15' {
      $checksum = "BBE7DFB435F19AD0D25A04A2B81DE7C7CCBDAEDF60684F88BC16D84E068D8E58"
      break
    }
    '1.6-rc.14' {
      $checksum = "C782E3465704873999F1A956270C55E42BC7AECB1EBA14086AFB3BA11C137DF4"
      break
    }
    '1.6-rc.13' {
      $checksum = "5F1BE7CE007D90767F4A6A89FCE228CA503FF79BB8767258E60A72D22397B5DB"
      break
    }
    '1.6.1.4' {
      $checksum = "FD64A981633D1DCBC87019F4F6899599A44BFD3A86579F34863FCFFAA2CB9BC4"
      break
    }
    '1.6.1.1' {
      $checksum = "D6A92DAA169D62E30F81644A50560C1FB80C3F5CA1A50522EE9D9B588230B01A"
      break
    }
    '1.6.0.1' {
      $checksum = "49B12E6BE26F93AE951209DBD979346C7677D490034184192B1CA95BBB78C0F0"
      break
    }
    '1.6.1' {
      $checksum = "12854CCAB3F0FC94AB428DECCA29D3C625FAB2D0FEC0E87F8809DAFF19140A10"
      break
    }
    '1.6' {
      $checksum = "9087FA9E26F1597481C87A69E7D991BA4F91584021F48F5A60D46C06633DFE83"
      break
    }
    default {
      # current release v 1.11.1
      $checksum = "2EAE676CEF07425FBE6A3F79F75A6984A8A6C3137E6961883DC8CF2D8D56A053"
    }
  }
}

Export-ModuleMember -Function `
  Assert-LocalAppData,
  Get-InstallerTempDirectory,
  Get-MeteorDataDirectory,
  Initialize-MeteorDataDirectory,
  New-BootstrapLinkQueryString,
  Get-Checksum,
  Remove-MeteorDataDirectory,
  Remove-OldMeteorInstallerIfDetected
