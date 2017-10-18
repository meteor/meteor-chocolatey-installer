# Meteor Chocolatey Installer

# 🍫  + ☄

## Building

To build the `.nupkg` from the `.nuspec`, use `choco pack` with the `meteor.nuspec` found at the root of this repository.

```ps1
PS> choco pack meteor.nuspec --outputdirectory path/to/build-output
```

## Testing

This is best performed in a VirtualBox or other disposable environment.

```ps1
PS> choco install -fy meteor --pre --source path/to/build-output
```

> `-f` is to force the install and `-y` is to answer "yes" to prompts.

## Publishing

### Clear Comments before publishing.

It's not clear to me if we need to do this, as I think the idea is to remove a lot of the irrelevant guiding information provided in the `choco new` boilerplate, but leaving this helpful command here for now.

```ps1
# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:\path\to\thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f
```

### Publish

```ps1
PS> choco push build-output\meteor.<version>.nupkg --source 'https://push.chocolatey.org/' --key '<api-key>'
```