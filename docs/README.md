# Introduction

VcRedist is a PowerShell module for downloading and installing the [Microsoft Visual C++ Redistributables](https://support.microsoft.com/en-au/help/2977003/the-latest-supported-visual-c-downloads). The module supports creating applications in the Microsoft Deployment Toolkit or System Center Configuration Manager to install the Redistributables for reference images or operating system deployments.

## Why

The Microsoft Visual C++ Redistributables are a core component of any Windows desktop deployment. Because multiple versions are often deployed to support various applications, they need to be imported into your deployment solution or installed locally, which can be time consuming. The aim of this module is to reduce the time required to deploy the Redistributables.

The module includes two manifests that list the supported Redistributables or all available Redistributables making it simple to download and deploy the Redistributes required for your environment.

### Supported vs. Unsupported Redistributables

It is important to understand that Microsoft no longer supports and provides updates for certain Redistributables. The list of supported Redistributables is maintained here [Microsoft Visual C++ Redistributables](https://support.microsoft.com/en-au/help/2977003/the-latest-supported-visual-c-downloads). Deployment of unsupported Redistributables should be done at your own risk.
