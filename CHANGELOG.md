# Meteor Chocolatey Installer Changelog

## 0.0.10 2021-01-20

* Adding checksum to Meteor version 2.0

## 0.0.6 - 0.0.8 2020-10-04

* Adding checksum to Meteor version 1.12

## 0.0.5 2020-09-19

* Adding checksum to Meteor version 1.11.1

## 0.0.3 - 0.0.4, 2020-08-22

* Since version 1.10.1 we stop support to systems 32-bit (https://github.com/meteor/meteor/blob/devel/History.md#v1101-2020-03-12), but our installer on Windows (Chocolatey) was still trying to download the 32-bit version, and for that, the users ended up with an error saying that was not possible download Meteor. Now Chocolatey shouldn't try to download the 32-bit Meteor version.

## 0.0.2, 2017-11-23

* Support for PowerShell 2.0 by using older CmdLet syntax, enabling the
  installer to work on Windows Vista (and other older Windows releases).
  [PR #4](https://github.com/meteor/meteor-chocolatey-installer/pull/4)
  ([@dhulme](https://github.com/dhulme))

## 0.0.1, 2017-10-19

* Initial release of the Chocolatey `meteor` package which
  implements similar (and better) functionality to the previous
  generation InstallMeteor.exe, which is no longer maintained.
