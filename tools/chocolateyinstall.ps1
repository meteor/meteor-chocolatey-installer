# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:\path\to\thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

$ErrorActionPreference = 'Stop'; # stop on all errors

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

$bootstrapLinkUrl = 'https://packages.meteor.com/bootstrap-link'

# Get the path to %LocalAppData\.meteor, which is where Meteor lives.
$localAppData = [Environment]::GetFolderPath('LocalApplicationData')
if (!(Test-Path -LiteralPath $localAppData -PathType 'Container')) {
  throw "LocalAppData must be available to install in."
}

$meteorLocalAppData = Join-Path $localAppData '.meteor'

# If an installation from the deprecated installer was found, uninstall it.
Remove-OldMeteorInstall

# If the data from a previous install was found, delete it.
Remove-DirectoryRecursively $meteorLocalAppData

# Create the new '.meteor' directory as our tarball target.
[System.IO.Directory]::CreateDirectory($meteorLocalAppData) | Out-Null

# Find the tar.gz, if it's locally available.  This is helpful
# if testing the package installer because the 200MB installer tar.gz
# can simply be placed in the tools directory.  It must match the
# pattern we're looking for and exist, otherwise we'll just download it.
$gciTarGzArgs = @{
  'path'    = $toolsDir
  'filter'  = 'meteor-bootstrap-os.windows.*.tar.gz'
  'file'    = $true
}
$bootstrapTarGzFileName = Get-ChildItem @gciTarGzArgs | Select -First 1
$bootstrapTarGzPath = Join-Path $toolsDir $bootstrapTarGzFileName

# If we find it locally, we'll extract it from there, but otherwise
# we'll download it from the bootstrap provider.
if (Test-Path -LiteralPath $bootstrapTarGzPath -PathType 'Leaf') {
  $unzipLocalTarGzArgs = @{
    fileFullPath    = $bootstrapTarGzPath
    destination     = $tempDir
  }
  Get-ChocolateyUnzip @unzipLocalTarGzArgs
} else {
  $installTarGzArgs = @{
    packageName   = $env:ChocolateyPackageName
    url           = "${bootstrapLinkUrl}?arch=os.windows.x86_32"
    url64bit      = "${bootstrapLinkUrl}?arch=os.windows.x86_32" # TODO
    unzipLocation = $tempDir
  }
  Install-ChocolateyZipPackage @installTarGzArgs
}

# 7z only supports extracting one archive type at a time, so it's not
# possible to get the .tar and .gz extracted in a single pass.  So, we
# find the tarball which was extracted from the Gzip file.  It should
# be the only file with this pattern in this directory.
$gciTarArgs = @{
  path    = $tempDir
  filter  = 'meteor-bootstrap-os.windows.*.tar'
  file    = $true
}
$bootstrapTarFileName = Get-ChildItem @gciTarArgs | Select -First 1
$bootstrapTarPath = Join-Path $tempDir $bootstrapTarFileName

# Stop if for whatever reason, we failed to find the tarball.
if (!(Test-Path -LiteralPath $bootstrapTarPath -PathType 'Leaf')) {
  throw "Couldn't find bootstrap tarball to extract"
}

# Unzip the bootstrap tarball.
$unzipTarArgs = @{
  fileFullPath    = $bootstrapTarPath
  destination     = $localAppData
}
Get-ChocolateyUnzip @unzipTarArgs

# Remove the tarball now that it has been extracted.
Remove-Item $bootstrapTarPath

# Update $PATH so "meteor" is available on the command line anywhere.
$installPathArgs = @{
  pathToInstall = $meteorLocalAppData
  pathType      = 'User'
}
Install-ChocolateyPath @installPathArgs

# Since PATH has changed, we'll reload so the current shell can use it.
Update-SessionEnvironment

$messageGettingStarted = @"
***************************************

Meteor has been installed!

To get started fast:

  $ meteor create ~/my_cool_app
  $ cd ~/my_cool_app
  $ meteor

Or see the docs at:

  https://docs.meteor.com

***************************************
"@

Write-Host $messageGettingStarted -ForegroundColor Magenta
