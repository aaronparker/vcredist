Function Uninstall-VcRedist {
    <#
        .SYNOPSIS
            Uninstall the installed Visual C++ Redistributables on the local system
        
        .DESCRIPTION
            Uninstall the specified Release and/or Architecture of the installed Visual C++ Redistributables on the local system.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://stealthpuppy.com/VcRedist/install-vcredist.html

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
        HelpURI = "https://stealthpuppy.com/VcRedist/install-vcredist.html")]
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateSet("2005", "2008", "2010", "2012", "2013", "2015", "2017", "2019")]
        [System.String[]] $Release = @("2005", "2008", "2010", "2012", "2013", "2015", "2017", "2019"),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateSet("x86", "x64")]
        [System.String[]] $Architecture = @("x86", "x64")
    )

    # Get the installed VcRedists and filter
    Write-Warning -Message "$($MyInvocation.MyCommand): Uninstalling Visual C++ Redistributables"
    Write-Verbose -Message "$($MyInvocation.MyCommand): Getting locally installed Visual C++ Redistributables"
    $VcRedistsToRemove = Get-InstalledVcRedist | Where-Object { $Release -contains $_.Release } | Where-Object { $Architecture -contains $_.Architecture }

    # Walk through each VcRedist and uninstall
    ForEach ($VcRedist in $VcRedistsToRemove) {
        If ($PSCmdlet.ShouldProcess("[$($VcRedist.Name), $($VcRedist.Architecture), $($VcRedist.Version)]", "Uninstall")) {
            $invokeProcessParams = @{
                FilePath = "$env:SystemRoot\System32\cmd.exe"
            }
            If ($Null -ne $VcRedist.QuietUninstallString) {
                $invokeProcessParams.ArgumentList = "/c $($VcRedist.QuietUninstallString)"
                Write-Verbose -Message "$($MyInvocation.MyCommand): VcRedist has quiet uninstall string."
                Write-Verbose -Message "$($MyInvocation.MyCommand): Uninstalling with: [$($VcRedist.QuietUninstallString)]."
            }
            Else {
                $invokeProcessParams.ArgumentList = "/c $($VcRedist.UninstallString) /quiet /noreboot"
                Write-Verbose -Message "$($MyInvocation.MyCommand): VcRedist does not have quiet uninstall string. Adding [/quiet]."
                Write-Verbose -Message "$($MyInvocation.MyCommand): Uninstalling with: [$($VcRedist.UninstallString)]."
            }
            try {
                $result = Invoke-Process @invokeProcessParams
            }
            catch [System.Exception] {
                Write-Warning -Message "$($MyInvocation.MyCommand): Failure in uninstalling Visual C++ Redistributable."
                Write-Warning -Message "$($MyInvocation.MyCommand): Captured error (if any): [$result]."
                Throw "Failed to uninstall VcRedist $($VcRedist.Release), $($VcRedist.Architecture), $($VcRedist.Version)"
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
