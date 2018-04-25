# Change log

## v1.3.2.35

- Code formatting updates
- Use `Join-Path` to build folder/file paths to better work on PSCore
- Pester tests updates
- Version update to better align with feature changes

## v1.3.1.4

- Fixes to ConfigMgr application import

## v1.3.1.2

- Add `-Bundle` to `Import-VcMdtApp` to create an Application Bundle with the Redistributables as dependencies. Redistributables will be hidden so that only the Bundle is selectable in the deployment wizard
- Updating simple Pester tests and getting Appveyor integration working
- Cleanup inline help
- Generated external help with platyPS

## v1.3.1.0

- Added function Import-VcCmApp for importing Visual C++ Redistributables into ConfigMgr.

## v1.3.0.0

- Refactored into a PowerShell module to simplify coding and publishing to the PowerShell Gallery.