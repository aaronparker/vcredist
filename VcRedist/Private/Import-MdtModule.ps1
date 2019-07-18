Function Import-MdtModule {
    <#
        .SYNOPSIS
            Tests for and imports the MDT PowerShell module. Returns True or False depending on whether the module can be loaded.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .PARAMETER Force
            Re-imports the MDT module and its members, even if the module or its members have an access mode of read-only.
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    Param (
        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Force
    )

    # Get path to the MDT PowerShell module via the Registry and fail if we can't read the properties
    try {
        $mdtReg = Get-ItemProperty "HKLM:SOFTWARE\Microsoft\Deployment 4" -ErrorAction SilentlyContinue
    }
    catch [System.Exception] {
        Write-Warning "$($MyInvocation.MyCommand): Unable to read MDT Registry path properties."
        Throw $_.Exception.Message
        Write-Output -InputObject $False
        Exit
    }
    finally {
        If ($Null -ne $mdtReg.Install_Dir) {
            $mdtInstallDir = Get-ValidPath $mdtReg.Install_Dir
            Write-Verbose "$($MyInvocation.MyCommand): MDT Workbench install directory is: [$mdtInstallDir]."
        }
        Else {
            Write-Warning "$($MyInvocation.MyCommand): Failed to read MDT Workbench path from the Registry."
        }
    }

    # Attempt to load the module
    $mdtModule = "$mdtInstallDir\bin\MicrosoftDeploymentToolkit.psd1"
    If (Test-Path -Path $mdtModule) {
        try {
            If ($Force) {
                Write-Verbose "$($MyInvocation.MyCommand): Importing the MDT module with -Force."
                Import-Module -Name $mdtModule -Force -ErrorAction SilentlyContinue
            }
            Else {
                Import-Module -Name $mdtModule -ErrorAction SilentlyContinue
            }
        }
        catch [System.Exception] {
            Write-Warning "$($MyInvocation.MyCommand): Could not load MDT PowerShell Module. Please make sure that the MDT console is installed correctly."
            Write-Output -InputObject $False
            Break
        }
        finally {
            Write-Output -InputObject $True
        }
    }
    Else {
        Write-Warning "$($MyInvocation.MyCommand): Cannot find the MDT PowerShell module. Is the MDT console installed?"
        Write-Output -InputObject $False
    }
}
