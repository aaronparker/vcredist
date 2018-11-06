# Introduction

VcRedist is a PowerShell module for downloading and installing the [Microsoft Visual C++ Redistributables](https://support.microsoft.com/en-au/help/2977003/the-latest-supported-visual-c-downloads).

The module enables the download of the Redistributables for installing locally, or creating applications in the Microsoft Deployment Toolkit and System Center Configuration Manager to install the Redistributables for reference images or operating system deployments. All downloads are directly from Microsoft and are therefore only from a trusted source.

## Why

The Microsoft Visual C++ Redistributables are a core component of any Windows desktop deployment (physical PCs or virtual desktop environments). Multiple versions are commonly deployed to support various applications, thus they need to be imported into your deployment solution or installed locally, which can be time consuming. The aim of this module is to simplify obtaining current versions of the Redistributables and to speed deployments.

### Supported vs. Unsupported Redistributables

The module includes two manifests that list the supported Redistributables or all available Redistributables making it simple to download and deploy the Redistributes required for your environment.

It is important to understand that Microsoft no longer supports and provides security updates for certain Redistributables. The list of supported Redistributables is maintained here [Microsoft Visual C++ Redistributables](https://support.microsoft.com/en-au/help/2977003/the-latest-supported-visual-c-downloads). Deployment of unsupported Redistributables should be done at your own risk.
