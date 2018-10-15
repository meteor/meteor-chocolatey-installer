# Stop on all errors.
$ErrorActionPreference = 'Stop';

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
Import-Module -Force "$toolsDir\helpers.psm1"

$packageParameters = Get-PackageParameters

$bootstrapLinkUrl = 'https://packages.meteor.com/bootstrap-link'

$installerTempDir = Get-InstallerTempDirectory

Assert-LocalAppData

# If an installation from the (deprecated) installer was found, uninstall it.
Remove-OldMeteorInstallerIfDetected

# If the data from a previous install was found, delete it.
Remove-MeteorDataDirectory

# Start fresh with a new directory.
Initialize-MeteorDataDirectory

# Find the tar.gz, if it's locally available.  This is helpful
# if testing the package installer because the 200MB installer tar.gz
# can simply be placed in the tools directory.  It must match the
# pattern we're looking for and exist, otherwise we'll just download it.
$gciTarGzArgs = @{
  path    = $toolsDir
  filter  = 'meteor-bootstrap-os.windows.*.tar.gz'
}
$bootstrapTarGzFileName = Get-ChildItem @gciTarGzArgs | Select -First 1
$bootstrapTarGzPath = Join-Path $toolsDir $bootstrapTarGzFileName

# If we find it locally, we'll extract it from there, but otherwise
# we'll download it from the bootstrap provider.
if (Test-Path -LiteralPath $bootstrapTarGzPath -PathType 'Leaf') {
  $unzipLocalTarGzArgs = @{
    fileFullPath    = $bootstrapTarGzPath
    destination     = $installerTempDir
  }
  Get-ChocolateyUnzip @unzipLocalTarGzArgs
} else {
  $bootstrapQueryString32 = New-BootstrapLinkQueryString `
    -Arch 'os.windows.x86_32' `
    -Release $packageParameters.Release
  $bootstrapQueryString64 = New-BootstrapLinkQueryString `
    -Arch 'os.windows.x86_64' `
    -Release $packageParameters.Release
  $installTarGzArgs = @{
    packageName   = $env:ChocolateyPackageName
    url           = "${bootstrapLinkUrl}${bootstrapQueryString32}"
    url64bit      = "${bootstrapLinkUrl}${bootstrapQueryString64}"
    unzipLocation = $installerTempDir
  }
  Install-ChocolateyZipPackage @installTarGzArgs
}

# 7z only supports extracting one archive type at a time, so it's not
# possible to get the .tar and .gz extracted in a single pass.  So, we
# find the tarball which was extracted from the Gzip file.  It should
# be the only file with this pattern in this directory.
$gciTarArgs = @{
  path    = $installerTempDir
  filter  = 'meteor-bootstrap-os.windows.*.tar'
}
$bootstrapTarFileName = Get-ChildItem @gciTarArgs | Select -First 1
$bootstrapTarPath = Join-Path $installerTempDir $bootstrapTarFileName

# Stop if for whatever reason, we failed to find the tarball.
if (!(Test-Path -LiteralPath $bootstrapTarPath -PathType 'Leaf')) {
  throw "Couldn't find bootstrap tarball to extract"
}

$meteorDataDirectory = Get-MeteorDataDirectory

# Unzip the bootstrap tarball.
$unzipTarArgs = @{
  fileFullPath    = $bootstrapTarPath
  destination     = (Get-Item $meteorDataDirectory).parent.FullName
}

Get-ChocolateyUnzip @unzipTarArgs

# Remove the tarball now that it has been extracted.
Remove-Item $bootstrapTarPath

# Update $PATH so "meteor" is available on the command line anywhere.
$installPathArgs = @{
  pathToInstall = $meteorDataDirectory
  pathType      = 'User'
}

Install-ChocolateyPath @installPathArgs
# Since PATH has changed, we'll reload so the current shell can use it.
Update-SessionEnvironment

$messageGettingStarted = @"
***************************************

Meteor has been installed!

Get Started Fast:

  Spin up a new (non-admin) shell
  
  $ meteor create ~/my_cool_app
  $ cd ~/my_cool_app
  $ meteor

Or see the docs at:

  https://docs.meteor.com
  
NOTE: DO NOT RUN METEOR AS ADMIN

***************************************
"@

Write-Host $messageGettingStarted -ForegroundColor Magenta
