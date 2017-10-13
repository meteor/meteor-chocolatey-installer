# Meteor Chocolatey Installer

# 🍫  + ☄

[WIP]

## To build

From within the root of this repo...

```ps1
PS> choco pack meteor.nuspec --outputdirectory build-output
```

## To test

Maybe best to do in a VirtualBox!

```ps1
PS> choco install -fy meteor --prerelease --source build-output
```

## To push

```ps1
ps> choco push build-output\meteor.<version>.spec --source 'https://push.chocolatey.org/' --key '<api-key>'
```
