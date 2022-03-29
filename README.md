# VcRedist

[![License][license-badge]][license]
[![PowerShell Gallery Version][psgallery-version-badge]][psgallery]
[![PowerShell Gallery][psgallery-badge]][psgallery]

## About

VcRedist is a PowerShell module for lifecycle management of the [Microsoft Visual C++ Redistributables](https://support.microsoft.com/en-au/help/2977003/the-latest-supported-visual-c-downloads). VcRedist downloads the supported (and unsupported) Redistributables, for local install, gold image deployment or importing as applications into the Microsoft Deployment Toolkit, Microsoft Endpoint Configuration Manager or Microsoft Intune. Supports passive and silent installs and uninstalls of the Visual C++ Redistributables.

[![validate-module](https://github.com/aaronparker/vcredist/actions/workflows/validate-module.yml/badge.svg)](https://github.com/aaronparker/vcredist/actions/workflows/validate-module.yml)

### Visual C++ Redistributables

The Microsoft Visual C++ Redistributables are a core component of any Windows desktop deployment. Because multiple versions are often deployed they need to be imported into your deployment solution or installed locally, which can be time consuming. The aim of this module is to provide a definitive list of available Redistributables and functions for managing deployment of those Redistributables across various mechanisms.

### Documentation

Full documentation for the module is located at [https://vcredist.com/](https://vcredist.com/)

### PowerShell Gallery

The VcRedist module is published to the PowerShell Gallery and can be found here: [VcRedist](https://www.powershellgallery.com/packages/VcRedist/). Install the module from the gallery with:

```powershell
Install-Module -Name "VcRedist" -Force
```

[psgallery-badge]: https://img.shields.io/powershellgallery/dt/vcredist.svg?logo=PowerShell&style=flat-square
[psgallery]: https://www.powershellgallery.com/packages/vcredist
[psgallery-version-badge]: https://img.shields.io/powershellgallery/v/vcredist.svg?logo=PowerShell&style=flat-square
[psgallery-version]: https://www.powershellgallery.com/packages/vcredist
[license-badge]: https://img.shields.io/github/license/aaronparker/Install-VisualCRedistributables.svg?style=flat-square
[license]: https://github.com/aaronparker/vcredist/blob/main/LICENSE
