Function Uninstall-VcRedist {
    <#
        .SYNOPSIS
            Uninstall all of the installed Visual C++ Redistributables on the local system
        
        .DESCRIPTION
            Installs the Visual C++ Redistributables from a list created by Get-VcList and downloaded locally with Get-VcRedist.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://docs.stealthpuppy.com/docs/vcredist/usage/installing-the-redistributables

        .PARAMETER Release
            Specifies the release (or version) of the redistributables to uninstall.

        .PARAMETER Architecture
            Specifies the processor architecture to of the redistributables to uninstall. Can be x86 or x64.

        .EXAMPLE
            Uninstall-VcRedist

            Description:
            Uninstalls installs all installed x64, x86 2005-2019 Visual C++ Redistributables.

        .EXAMPLE
            Uninstall-VcRedist -Release 2008, 2010

            Description:
            Uninstalls installs all installed x64, x86 2008 and 2010 Visual C++ Redistributables.
    #>
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = "High", 
        HelpURI = "https://docs.stealthpuppy.com/docs/vcredist/usage/uninstalling-the-redistributables")]
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False)]
        [ValidateSet("2005", "2008", "2010", "2012", "2013", "2015", "2017", "2019")]
        [System.String[]] $Release = @("2005", "2008", "2010", "2012", "2013", "2015", "2017", "2019"),

        [Parameter(Mandatory = $False)]
        [ValidateSet("x86", "x64")]
        [System.String[]] $Architecture = @("x86", "x64")
    )

    # Get the installed VcRedists and filter
    Write-Warning -Message "$($MyInvocation.MyCommand): Uninstalling Visual C++ Redistributables"
    Write-Verbose -Message "$($MyInvocation.MyCommand): Getting locally installed Visual C++ Redistributables"
    $VcRedistsToRemove = Get-InstalledVcRedist | Where-Object { $Release -contains $_.Release }
    $VcRedistsToRemove = $VcRedistsToRemove | Where-Object { $Architecture -contains $_.Architecture }

    # Walk through each VcRedist and uninstall
    ForEach ($VcRedist in $VcRedistsToRemove) {
        If ($pscmdlet.ShouldProcess("[$($VcRedist.Name), $($VcRedist.Architecture)]", "Uninstall")) {
            $invokeProcessParams = @{
                FilePath = "$env:SystemRoot\System32\cmd.exe"
            }
            If ($Null -ne $VcRedist.QuietUninstallString) {
                $invokeProcessParams.ArgumentList = "/c $($VcRedist.QuietUninstallString)"
                Write-Verbose -Message "$($MyInvocation.MyCommand): VcRedist has quiet uninstall string."
                Write-Verbose -Message "$($MyInvocation.MyCommand): Uninstalling with: [$($VcRedist.QuietUninstallString)]."
            }
            Else {
                $invokeProcessParams.ArgumentList = "/c $($VcRedist.UninstallString) /quiet"
                Write-Verbose -Message "$($MyInvocation.MyCommand): VcRedist does not have quiet uninstall string. Adding [/quiet]."
                Write-Verbose -Message "$($MyInvocation.MyCommand): Uninstalling with: [$($VcRedist.UninstallString)]."
            }
            try {
                Invoke-Process @invokeProcessParams
            }
            catch [System.Exception] {
                Write-Warning -Message "$($MyInvocation.MyCommand): Failure in uninstalling Visual C++ Redistributable."
                Throw $_.Exception.Message
                Continue
            }
        }
    }

    # Output remaining installed VcRedists to the pipeline
    $InstalledVcRedist = Get-InstalledVcRedist
    If ($Null -eq $InstalledVcRedist) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): No VcRedists installed or all VcRedists uninstalled successfully."
    }
    Else {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Output remaining installed VcRedists."
        Write-Output -InputObject $InstalledVcRedist
    }
}
