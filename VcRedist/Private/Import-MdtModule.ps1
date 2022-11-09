function Import-MdtModule {
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
    param (
        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Force
    )

    # Get path to the MDT PowerShell module via the Registry and fail if we can't read the properties
    try {
        $mdtReg = Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Deployment 4" -ErrorAction "SilentlyContinue"
    }
    catch [System.Exception] {
        Write-Warning "$($MyInvocation.MyCommand): Unable to read MDT Registry path properties."
        throw $_.Exception.Message
    }

    # Attempt to load the module
    $mdtInstallDir = Resolve-Path -Path $mdtReg.Install_Dir
    $mdtModule = [System.IO.Path]::Combine($mdtInstallDir, "bin", "MicrosoftDeploymentToolkit.psd1")
    if (Test-Path -Path $mdtModule -ErrorAction "SilentlyContinue") {
        Write-Verbose "$($MyInvocation.MyCommand): Loading MDT module from: [$mdtInstallDir]."
        try {
            $params = @{
                Name        = $mdtModule
                ErrorAction = "SilentlyContinue"
                Force       = if ($Force) { $True } else { $False }
            }
            Import-Module @params
        }
        catch [System.Exception] {
            Write-Output -InputObject $False
            Write-Warning "$($MyInvocation.MyCommand): Could not load MDT PowerShell Module. Please make sure that the MDT console is installed correctly."
            throw $_.Exception.Message
        }
        finally {
            Write-Output -InputObject $True
        }
    }
    else {
        Write-Warning "$($MyInvocation.MyCommand): Cannot find the MDT PowerShell module. Is the MDT console installed?"
        Write-Output -InputObject $False
    }
}
