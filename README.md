# Install-VisualCRedistributables

A module for downloading and installing the Microsoft Visual C++ Redistributables. The module also supports creating applications in MDT or ConfigMgr to install the Redistributables.

## Module

This repository contains a folder named VcRedist. The folder needs to be installed into one of your PowerShell Module Paths. To see the full list of available PowerShell Module paths, use `$env:PSModulePath.split(';')` in a PowerShell console.

Common PowerShell module paths include:

* Current User: `%USERPROFILE%\Documents\WindowsPowerShell\Modules\`
* All Users: `%ProgramFiles%\WindowsPowerShell\Modules\`
* OneDrive: `$env:OneDrive\Documents\WindowsPowerShell\Modules\`

### Manual Installation

1. Download the `master branch` to your workstation.
2. Copy the contents of the VcRedist folder onto your workstation into the desired PowerShell Module path.
3. Open a Powershell console with the Run as Administrator option.
4. Run `Set-ExecutionPolicy` using the parameter `RemoteSigned` or `Bypass`.

Once installation is complete, you can validate that the module exists by running `Get-Module -ListAvailable VcRedist`. To use the module, load it with:

    Import-Module VcRedist

## Usage

Deploying the Microsoft Visual C++ Redistributables in any complex desktop environment kinda sucks because there are so many versions that might be required. I got tired of updating my MDT deployment share with the redistributables manually, so wrote a module to automate the process.

This module will download the Visual C++ Redistributables listed in an external XML file into a folder structure that represents major release, processor architecture and update release (e.g. SP1, MFC, ATL etc.). The script defines the available redistributables and can be updated with each release with no changes made to the script.

*NOTE:* some validation of the Redistributables listed in the XML file is required, as not all may need to be installed in your environment.

This can be run to download and optionally install the Visual C++ (2005 - 2017) Redistributables as specified in the external XML file passed to the module.

The basic structure of the XML file should be as follows (an XSD schema is included in the repository):

    <Redistributables>
        <Platform Architecture="x64" Release="" Install="">
            <Redistributable>
                <Name></Name>
                <ShortName></ShortName>
                <URL></URL>
                <ProductCode></ProductCode>
                <Download></Download>
                <Install></Install>
            </Redistributable>
        </Platform>
        <Platform Architecture="x86" Release="" Install="">
            <Redistributable>
                <Name></Name>
                <ShortName></ShortName>
                <URL></URL>
                <ProductCode></ProductCode>
                <Download></Download>
                <Install></Install>
            </Redistributable>
        </Platform>
    </Redistributables>

Each major version of the redistributables is grouped by `<Platform>` that defines the major release, processor architecture and install arguments passed to the installer.

The properties of each redistributable are defined in each `<Redistributable>` node:

* Name - the name of the redistributable as displayed on the download page. Not used in the script, but useful for reading the XML file.
* ShortName - the redistributable will be downloaded to Release\Architecture\ShortName
* URL - this is the URL to the page at microsoft.com/downloads. Not used in the script, but useful for referencing the download as needed
* ProductCode - this is the MSI Product Code for the specified VC++ App that will be used to import the package into Configuration Manager
* Download - this is the URL to the installer so that the script can download each redistributable

## To Do

* Finalise function to import Visual C++ Redistributables into ConfigMgr
* Additional testing
* Documentation update