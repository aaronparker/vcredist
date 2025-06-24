function Remove-VcIntuneApplication {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High", HelpURI = "https://vcredist.com/remove-vcintuneapplication/")]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline,
            HelpMessage = "Pass a VcList object from Save-VcRedist.")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $VcList
    )

    begin {
        # Get the existing VcRedist Win32 applications from Intune
        $ExistingIntuneApps = Get-VcRedistAppsFromIntune -VcList $VcList
    }

    process {
        foreach ($Application in $ExistingIntuneApps) {
            if ($PSCmdlet.ShouldProcess($Application.displayName, "Remove")) {
                Write-Verbose -Message "Removing application: $($Application.displayName) with ID: $($Application.Id)."
                Remove-IntuneWin32App -Id $Application.Id
            }
        }
    }
}
