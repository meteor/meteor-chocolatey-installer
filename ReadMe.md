# Meteor Chocolatey Installer

<h2>(Windows Only)</h2>

## Usage

The installer is available on [Chocolatey](https://chocolatey.org/) (a Windows package manager), using the [`meteor` package](https://chocolatey.org/packages/meteor).  Please consult that repository for specific details, but the general idea is:

```ps1
C:\> choco install meteor
```

> **Note:** This will only work for the latest published package.  When trying to install a package which is pre-release (or not yet approved by Chocolatey moderators), it is necessary to pass the explicit version of the installer package.  For example: `choco install meteor --version x.y.z`.

## Versioning

The version of this Meteor installer is **not to be confused with Meteor** itself.  Meteor, once installed, will always "springboard" to (download, install and run) the correct version of Meteor necessary for the application being executed.

On the other hand the installer, which focuses on installing the Meteor files necessary for the springboarding process, will always install the latest version of Meteor unless specified otherwise.  To override the version which is installed, follow the directions in the next section.

### Installing a specific version of Meteor

> This section is not to be confused with the next section about using a different version of the _installer_.

**Generally speaking, it shouldn't be necessary to install a specific version of Meteor.**  The `meteor` tool itself will always "springboard" to the correct version of Meteor for the application being executed.

When necessary, specific versions of Meteor can be installed using Chocoloatey's `--params` argument which will download that specific version from Meteor's installation server.  For example, to install Meteor 1.5.4.4:

```ps1
C:\> choco install meteor --params="'/RELEASE:1.6.0.1'"
```

> **Note:** Prior to Meteor 1.6, 64-bit versions were not available.  Therefore, in order to install versions prior to Meteor 1.6, you'll also need to pass Chocolatey's `--x86` option when running `choco install` on 64-bit Windows platforms.  For example:
>
> ```ps1
> C:\> choco install meteor --x86 --params="'/RELEASE:1.5.4.4'"
> ```


### Using a specific version of the installer

> This section is not to be confused with the previous section about installing a different version of _Meteor_.

The most recent version of the installer should be the only version typically necessary to use, but re-installing Meteor with the latest installer shouldn't be necessary unless a developer is experiencing problems with the current installation.  To use the latest, stable version of the installer, do not pass the `--version` flag to `choco install meteor`.  In order to specify a pre-release or older version of the installer, use the `--version` flag and pass one of the versions listed on the [`meteor` Chocolatey package page](https://chocolatey.org/packages/meteor).

## Development
This section is about making modifications, testing and publishing the Chocolatey `meteor` package itself, not for general Meteor development.  For more on Meteor, please see [Meteor on GitHub](https://github.com/meteor/meteor/).

### Branches

The `devel` branch is used for active development, including pull requests.  Official releases should be merged to the `master` branch.

### Building

To build the `.nupkg` from the `.nuspec`, use `choco pack` with the `meteor.nuspec` found at the root of this repository.

```ps1
C:\> choco pack meteor.nuspec --outputdirectory C:\path\to\build-output
```

### Testing

#### Automatically

We use [AppVeyor](https://appveyor.com/) to automatically test the installer on actual Windows hardware.  Any push to this repository will automatically kick off tests which build and install Meteor in an isolated environment, using the current installer.

> **Note:** Git "tags" pushed to this repository which are prefixed with `release/`, will trigger publishing of the Chocolatey package if the testing is successful.  Please see the [Publishing](#Publishing) section below for more information.

#### Locally

This is best performed in a VirtualBox or other disposable environment.

```ps1
C:\> choco install -force -yes meteor --pre --source "'C:\\path\\to\\build-output;https://chocolatey.org/api/v2/'"
```

> **Note:** The escape characters in the `--source` path are important!

### Publishing

#### Automatically

Any tag pushed to this repository in the format of `release/x.y.z` will automatically be published to Chocolatey after passing automated testing.  Only collaborators with push access to this repository can kick off this process.

> Note: Releases can also be suffixed with `-beta-#` or `-rc-#` suffixes!
#### Manually

The above release process is preferred as it will force the package to go through automated testing, however the `choco push` can still be done manually when in posssession of the Chocolatey publishing key.
```ps1
C:\> choco push build-output\meteor.<version>.nupkg --source 'https://push.chocolatey.org/' --key '<api-key>'
```
