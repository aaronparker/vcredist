#
# Module manifest for module 'VcRedist'
#
# Generated by: Aaron Parker
#
# Generated on: 7/11/2025
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'VcRedist.psm1'

# Version number of this module.
ModuleVersion = '4.1.522'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '9139778c-9a1a-4faf-aa88-5ac6fd3b3e48'

# Author of this module
Author = 'Aaron Parker'

# Company or vendor of this module
CompanyName = 'stealthpuppy'

# Copyright statement for this module
Copyright = '(c) 2025 stealthpuppy. All rights reserved.'

# Description of the functionality provided by this module
Description = 'A module for lifecycle management of the Microsoft Visual C++ Redistributables. VcRedist downloads, installs and uninstalls the supported (and unsupported) Redistributables. Use for local install, gold image creation and update, or importing as applications into the Microsoft Deployment Toolkit, Microsoft Configuration Manager or Microsoft Intune. Supports passive and silent installs, and uninstalls of the Visual C++ Redistributables.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @('Export-VcManifest', 'Get-InstalledVcRedist', 
               'Get-VcIntuneApplication', 'Get-VcList', 
               'Import-VcConfigMgrApplication', 'Import-VcIntuneApplication', 
               'Import-VcMdtApplication', 'Install-VcRedist', 'New-VcMdtBundle', 
               'Remove-VcIntuneApplication', 'Save-VcRedist', 'Test-VcRedistUri', 
               'Uninstall-VcRedist', 'Update-VcMdtApplication', 'Update-VcMdtBundle')

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = 'VcManifest'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = 'Get-VcRedist', 'Export-VcXml', 'Import-VcCmApp', 'Import-VcMdtApp', 
               'Test-VcRedistDownload'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    #RepositorySourceLocation of this module
    RepositorySourceLocation = 'https://github.com/aaronparker/vcredist/'

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'Redistributables','C++','VisualC','VisualStudio','MDT','ConfigMgr','SCCM','Intune','Windows'

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/aaronparker/vcredist/blob/main/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://vcredist.com/'

        # A URL to an icon representing this module.
        IconUri = 'https://vcredist.com/img/logo.png'

        # ReleaseNotes of this module
        ReleaseNotes = 'https://vcredist.com/changelog/'

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

