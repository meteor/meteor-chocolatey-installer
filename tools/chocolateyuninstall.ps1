# Stop on all errors.
$ErrorActionPreference = 'Stop';

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
Import-Module -Force "$toolsDir\helpers.psm1"

Write-Host "Removing the Meteor data directory..."
# The Meteor data holds all of the information about a Meteor install.
Remove-MeteorDataDirectory
