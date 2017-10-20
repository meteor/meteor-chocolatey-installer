# Meteor Chocolatey Installer

<h2>(Windows Only)</h2>

## Usage

The installer is available on [Chocolatey](https://chocolatey.org/) (a Windows package manager), using the [`meteor` package](https://chocolatey.org/packages/meteor).  Please consult that repository for specific details, but the general idea is:

```ps1
C:\> choco install meteor
```

## Development
This section is about making modifications, testing and publishing the Chocolatey `meteor` package itself, not for general Meteor development.  For more on Meteor, please see [Meteor on GitHub](https://github.com/meteor/meteor/).

### Branches

The `devel` branch is used for active development, including pull requests.  Official releases should be merged to the `master` branch.

### Building

To build the `.nupkg` from the `.nuspec`, use `choco pack` with the `meteor.nuspec` found at the root of this repository.

```ps1
C:\> choco pack meteor.nuspec --outputdirectory path/to/build-output
```

### Testing

#### Automatically

We use [AppVeyor](https://appveyor.com/) to automatically test the installer on actual Windows hardware.  Any push to this repository will automatically kick off tests which build and install Meteor in an isolated environment, using the current installer.

> **Note:** Git "tags" pushed to this repository which are prefixed with `release/`, will trigger publishing of the Chocolatey package if the testing is successful.  Please see the [Publishing](#Publishing) section below for more information.

#### Locally

This is best performed in a VirtualBox or other disposable environment.

```ps1
C:\> choco install -force -yes meteor --pre --source path/to/build-output
```

### Publishing

#### Automatically

Any tag pushed to this repository in the format of `release/x.y.z` will automatically be published to Chocolatey after passing automated testing.  Only collaborators with push access to this repository can kick off this process.

> Note: Releases can also be suffixed with `-beta-#` or `-rc-#` suffixes!
#### Manually

The above release process is preferred as it will force the package to go through automated testing, however the `choco push` can still be done manually when in posssession of the Chocolatey publishing key.
```ps1
C:\> choco push build-output\meteor.<version>.nupkg --source 'https://push.chocolatey.org/' --key '<api-key>'
```