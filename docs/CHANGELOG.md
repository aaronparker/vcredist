# Change log

## v1.1.0.36

## Public Functions

- Fix inline help examples for `Import-LatestUpdate` to address issue #11 

## Tests

- Update Pester tests in `PublicFunctions.Tests.ps1` to ensure successful tests for `Get-LatestUpdate` using `Should -Not -BeNullOrEmpty`

## v1.1.0.34

### General

- Update module version
- Inline help updates
- Module description updates

### Public Functions

- Add support for Windows 8.1 / 7 (and Windows Server 2012 R2 / 2008 R2) to `Get-LatestUpdate`
- Change parameters with -WindowsVersion, -Build, -Architecture in `Get-LatestUpdate` to support Windows OS changes

### Private Functions
- Add private function New-DynamicParam to support -WindowsVersion, -Build, -Architecture in `Get-LatestUpdate`

### Tests

- Update Pester tests

## v1.0.1.27

### General

- Inline help updates, code style formatting
- Update module description
- Update module release notes link

### Private functions

- Add `Test-PSCore` for testing when environment is PowerShell Core
- Add suppression of PSUseDeclaredVarsMoreThanAssignments for PSScriptAnalyzer false positive in `Select-LatestUpdate`; Pester tests now test `Select-LatestUpdate`

### Public functions

- Update `Get-LatestUpdate` and `Save-LatestUpdate` with support for PowerShell Core
- Better error handling in `Import-LatestUpdate`

### Tests

- Add Pester tests for `Test-PSCore`

## v1.0.1.20


### General

- Fix ProjectUri

### Private functions

- Rename `Get-ValidPath`
- Simplify `Import-MdtModule` output
- Add `New-MdtDrive`
- Improve `New-MdtPackagesFolder` robustness, update output
- Add `Remove-MdtDrive`
- Update `Select-LatestUpdate` notes
- Update `Select-UniqueUrl` notes

### Public functions
- Update `Get-LatestUpdate` inline help
- Update `Import-LatestUpdate` inline help, parameters, new MDT drive, more robust action when creating the MDT package folder
- Fix pipeline support for `Save-LatestUpdate`

### Tests
- Detailed Pester tests for Private and Public functions

## v1.0.1.11

- First v1 public release
- Published to the [PowerShell Gallery](https://www.powershellgallery.com/packages/LatestUpdate/)