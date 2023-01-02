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
    [CmdletBinding(SupportsShouldProcess = $false)]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Force
    )

    # Get path to the MDT PowerShell module via the Registry and fail if we can't read the properties
    $RegPath = "HKLM:SOFTWARE\Microsoft\Deployment 4"
    if (Test-Path -Path $RegPath -ErrorAction "SilentlyContinue") {
        Write-Verbose -Message "Get MDT details from registry at: $RegPath"
        $MdtReg = Get-ItemProperty -Path $RegPath -ErrorAction "SilentlyContinue"
    }
    else {
        $Msg = "Unable to read MDT Registry path properties at '$RegPath'. Ensure the Microsoft Deployment Toolkit is installed and try again."
        throw [System.IO.DirectoryNotFoundException]::New($Msg)
    }

    # Attempt to load the module
    $MdtInstallDir = Resolve-Path -Path $MdtReg.Install_Dir
    $MdtModule = [System.IO.Path]::Combine($MdtInstallDir, "bin", "MicrosoftDeploymentToolkit.psd1")
    if (Test-Path -Path $mdtModule -ErrorAction "SilentlyContinue") {
        Write-Verbose -Message "Loading MDT module from: $MdtInstallDir."
        try {
            $params = @{
                Name        = $MdtModule
                ErrorAction = "SilentlyContinue"
                Force       = if ($Force) { $true } else { $false }
            }
            Import-Module @params
        }
        catch [System.Exception] {
            throw $_
        }
        Write-Output -InputObject $true
    }
    else {
        $Msg = "Unable to find the MDT PowerShell module at $MdtModule. Ensure the Microsoft Deployment Toolkit is installed and try again."
        throw [System.IO.FileNotFoundException]::New($Msg)
    }
}
