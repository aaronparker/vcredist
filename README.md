# VcRedist

[![Build status][appveyor-badge]][appveyor-build]
[![GitHub Release][github-release-badge]][github-release]
[![PowerShell Gallery][psgallery-badge]][psgallery]
[![PowerShell Gallery Version][psgallery-version-badge]][psgallery]
[![License][license-badge]][license]

VcRedist is PowerShell module for downloading and installing the [Microsoft Visual C++ Redistributables](https://support.microsoft.com/en-au/help/2977003/the-latest-supported-visual-c-downloads). The module also supports creating applications in the Microsoft Deployment Toolkit or System Center Configuration Manager to install the Redistributables.

## Visual C++ Redistributables

The Microsoft Visual C++ Redistributables are a core component of any Windows desktop deployment. Because multiple versions are often deployed they need to be imported into your deployment solution or installed locally, which can be time consuming. The aim of this module is to reduce the time required to import the Redistributables or install them locally.

## Documentation

Full documentation for the module is located at [https://docs.stealthpuppy.com/vcredist/](https://docs.stealthpuppy.com/vcredist/)

## PowerShell Gallery

The VcRedist module is published to the PowerShell Gallery and can be found here: [VcRedist](https://www.powershellgallery.com/packages/VcRedist/). Install the module from the gallery with:

```powershell
Install-Module -Name VcRedist -Force
```

[appveyor-badge]: https://img.shields.io/appveyor/ci/aaronparker/Install-VisualCRedistributables/master.svg?style=flat-square&logo=appveyor
[appveyor-build]: https://ci.appveyor.com/project/aaronparker/install-visualcredistributables
[psgallery-badge]: https://img.shields.io/powershellgallery/dt/vcredist.svg?style=flat-square
[psgallery]: https://www.powershellgallery.com/packages/vcredist
[psgallery-version-badge]: https://img.shields.io/powershellgallery/v/vcredist.svg?style=flat-square
[psgallery-version]: https://www.powershellgallery.com/packages/vcredist
[gitbooks-badge]: https://www.gitbook.com/button/status/book/aaronparker/vcredist/
[gitbooks-build]: https://www.gitbook.com/book/aaronparker/vcredist
[github-release-badge]: https://img.shields.io/github/release/aaronparker/Install-VisualCRedistributables.svg?style=flat-square
[github-release]: https://github.com/aaronparker/Install-VisualCRedistributables/releases/latest
[license-badge]: https://img.shields.io/github/license/aaronparker/Install-VisualCRedistributables.svg?style=flat-square
[license]: https://github.com/aaronparker/vcredist/blob/master/LICENSE