---
title: "Known issues"
keywords: vcredist
tags: [getting_started]
sidebar: home_sidebar
permalink: known-issues.html
summary: 
---
* 'English - United States' is the only supported language. The module will only download the en-US versions of the Visual C++ Redistributables
* `Get-VcList` will attempt to match the VcRedist version in the manifest to the `ProductVersion` property on the downloaded file. Because Product Version on the 2005 and 2008 VcRedist installers doesn't match the installed VcRedist, the file will be re-downloaded even though the installer is the correct version
* Visual C++ Redistributable 2012 Update 5 is available. This update is available on the Visual Studio download site, but requires a login to download. The [Visual Studio public downloads page](https://visualstudio.microsoft.com/vs/older-downloads/) still offers Update 4, so that is the version provided by VcRedist
* Visual C++ Redistributable 2008 9.0.30729.7523 is available; however, only [as a private hotfix](https://support.microsoft.com/en-us/help/2834565/fix-visual-c-2008-mfc-application-that-was-created-by-using-visual-stu) and not publicly downloadable from Microsoft.
