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
    [CmdletBinding(SupportsShouldProcess = $False)]
    [OutputType([Boolean])]
    Param (
        [Parameter(Mandatory = $False)]
        [switch] $Force
    )

    # Get path to the MDT PowerShell module via the Registry and fail if we can't read the properties
    try {
        $mdtReg = Get-ItemProperty "HKLM:SOFTWARE\Microsoft\Deployment 4" -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warning "Unable to read MDT Registry path properties."
        Write-Output $False
        Break
    }
    finally {
        If ($Null -ne $mdtReg.Install_Dir) {
            $mdtInstallDir = Get-ValidPath $mdtReg.Install_Dir
            Write-Verbose "MDT Workbench install directory is: $mdtInstallDir"
        }
        Else {
            Write-Warning "Failed to read MDT Workbench path from the Registry."
        }
    }

    # Attempt to load the module
    $mdtModule = "$mdtInstallDir\bin\MicrosoftDeploymentToolkit.psd1"
    If (Test-Path -Path $mdtModule) {
        try {
            #If ($pscmdlet.ShouldProcess($mdtModule, "Importing module")) {
                If ($Force) {
                    Import-Module -Name $mdtModule -ErrorAction SilentlyContinue
                }
                Else {
                    Write-Verbose "Importing the MDT module with -Force."
                    Import-Module -Name $mdtModule -ErrorAction SilentlyContinue -Force
                }
            #}
        }
        catch {
            Write-Warning "Could not load MDT PowerShell Module. Please make sure that the MDT console is installed correctly."
            Write-Output $False
            Break
        }
        finally {
            Write-Output $True
        }
    }
    Else {
        Write-Warning "Cannot find the MDT PowerShell module. Is the MDT console installed?"
        Write-Output $False
    }
}
