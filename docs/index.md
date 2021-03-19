---
title: "Getting started with VcRedist"
keywords: vcredist
tags: [getting_started]
sidebar: home_sidebar
permalink: index.html
summary: These instructions will help you get started with using VcRedist to manage the Microsoft Visual C++ Redistributables.
---
VcRedist is a PowerShell module for lifecycle management of the [Microsoft Visual C++ Redistributables](https://support.microsoft.com/en-au/help/2977003/the-latest-supported-visual-c-downloads).

VcRedist downloads the supported (and unsupported) Redistributables, for local install, master image deployment or importing as applications into the Microsoft Deployment Toolkit or Microsoft Endpoint Configuration Manager. Supports passive and silent installs and uninstalls of the Visual C++ Redistributables.

## Why

The Microsoft Visual C++ Redistributables are a core component of any Windows desktop deployment (physical PCs or virtual desktops). Multiple versions are commonly deployed to support various applications, thus they need to be imported into your deployment solution or installed locally. The aim of this module is to simplify obtaining, deploying an updating to the current versions of the Redistributables.

### Supported vs. Unsupported Redistributables

The module includes two manifests that list the supported Redistributables or all available Redistributables making it simple to download and deploy the Redistributes required for your environment.

It is important to understand that Microsoft no longer supports and provides security updates for certain Redistributables. The list of supported Redistributables is maintained here [Microsoft Visual C++ Redistributables](https://support.microsoft.com/en-au/help/2977003/the-latest-supported-visual-c-downloads). Deployment of unsupported Redistributables should be done at your own risk.

{% include links.html %}
