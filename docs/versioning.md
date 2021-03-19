---
title: "Understanding VcRedist Versioning"
keywords: vcredist
tags: [getting_started]
sidebar: home_sidebar
permalink: versioning.html
summary: 
---
VcRedist uses a major.minor[.build] versioning scheme.

## Major release

Major releases typically introduce breaking changes. Major releases are likely to break scripts using the VcRedist module.

## Minor release

Minor releases typically add new features such as additional public functions. Minor releases should not break scripts using the VcRedist module, but testing is always recommended.

## Build

New builds will introduce improvements in code quality, fixes or improved output. The build number in a release tracks the number of builds performed by [AppVeyor](https://ci.appveyor.com/project/aaronparker/install-visualcredistributables).
