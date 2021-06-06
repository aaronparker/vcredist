# Introduction

![PowerShell Gallery version](https://img.shields.io/powershellgallery/v/vcredist.svg?style=flat-square)
![PowerShell Gallery downloads](https://img.shields.io/powershellgallery/dt/vcredist.svg?style=flat-square)

VcRedist is a PowerShell module for lifecycle management of the [Microsoft Visual C++ Redistributables](https://support.microsoft.com/en-au/help/2977003/the-latest-supported-visual-c-downloads).

VcRedist downloads the supported (and unsupported) Redistributables, for local install, master image deployment or importing as applications into the Microsoft Deployment Toolkit or Microsoft Endpoint Configuration Manager. Supports passive and silent installs and uninstalls of the Visual C++ Redistributables.

## Why

The Microsoft Visual C++ Redistributables are a core component of any Windows desktop deployment (physical PCs or virtual desktops). Multiple versions are commonly deployed to support various applications, thus they need to be imported into your deployment solution or installed locally. The aim of this module is to simplify obtaining, deploying an updating to the current versions of the Redistributables.

## Supported vs. Unsupported Redistributables

The module includes two manifests that list the supported Redistributables or all available Redistributables making it simple to download and deploy the Redistributes required for your environment.

It is important to understand that Microsoft no longer supports and provides security updates for certain Redistributables. The list of supported Redistributables is maintained here [Microsoft Visual C++ Redistributables](https://support.microsoft.com/en-au/help/2977003/the-latest-supported-visual-c-downloads). Deployment of unsupported Redistributables should be done at your own risk.

## Unsupported Redistributables

As at March 2021, the Unsupported list of Redistributables includes the following versions:

|Name                                                                      |Version       |
|--------------------------------------------------------------------------|--------------|
|Visual C++ 2005 Redistributable Package                                   |8.0.50727.42  |
|Visual C++ 2005 SP1 Redistributable Package                               |8.0.56336     |
|Visual C++ 2005 Service Pack 1 Redistributable Package ATL Security Update|8.0.59192     |
|Visual C++ 2005 Service Pack 1 Redistributable Package MFC Security Update|8.0.61000     |
|Visual C++ 2008 Redistributable Package                                   |9.0.21022     |
|Visual C++ 2008 Feature Pack Redistributable Package                      |9.0.21022.218 |
|Visual C++ 2008 Redistributable Package ATL Security Update               |9.0.30411     |
|Visual C++ 2008 SP1 Redistributable Package                               |9.0.30729     |
|Visual C++ 2008 Service Pack 1 Redistributable Package ATL Security Update|9.0.30729.4148|
|Visual C++ 2008 Service Pack 1 Redistributable Package MFC Security Update|9.0.30729.6161|
|Visual C++ Redistributable Packages for Visual Studio 2013                |12.0.30501.0  |
