# VcRedist

[![Build status][appveyor-badge]][appveyor-build]
[![PowerShell Gallery][psgallery-badge]][psgallery]
[![GitHub Release][github-release]][github-release-badge]
[![Book status][gitbooks-badge]][gitbooks-build]

A PowerShell module for downloading and installing the [Microsoft Visual C++ Redistributables](https://support.microsoft.com/en-au/help/2977003/the-latest-supported-visual-c-downloads). The module also supports creating applications in the Microsoft Deployment Toolkit or System Center Configuration Manager to install the Redistributables.

## Visual C++ Redistributables

The Microsoft Visual C++ Redistributables are a core component of any Windows desktop deployment. Because multiple versions are often deployed they need to be imported into your deployment solution or installed locally, which can be time consuming. The aim of this module is to reduce the time required to import the Redistributables or install them locally.

## Documentation

Full documentation for the module is located on GitBook at [https://aaronparker.gitbooks.io/vcredist/content/](https://aaronparker.gitbooks.io/vcredist/content/)

## PowerShell Gallery

The VcRedist module is published to the PowerShell Gallery and can be found here: [VcRedist](https://www.powershellgallery.com/packages/VcRedist/). Install the module from the gallery with:

```powershell
Install-Module -Name VcRedist -Force
```

[appveyor-badge]: https://ci.appveyor.com/api/projects/status/ijnl2agu5ey3l1u7?svg=true
[appveyor-build]: https://ci.appveyor.com/project/aaronparker/install-visualcredistributables
[psgallery-badge]: https://img.shields.io/powershellgallery/dt/vcredist.svg
[psgallery]: https://www.powershellgallery.com/packages/vcredist
[gitbooks-badge]: https://www.gitbook.com/button/status/book/aaronparker/vcredist/
[gitbooks-build]: https://www.gitbook.com/book/aaronparker/vcredist
[github-release-badge]: https://img.shields.io/github/release/aaronparker/Install-VisualCRedistributables.svg
[github-release]: https://github.com/aaronparker/Install-VisualCRedistributables/releases/latest