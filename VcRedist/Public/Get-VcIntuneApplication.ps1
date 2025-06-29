function Get-VcIntuneApplication {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $false, HelpURI = "https://vcredist.com/get-vcintuneapplication/")]
    param ()

    begin {
    }

    process {
        # Get the existing VcRedist Win32 applications from Intune
        $WarningPreference = "SilentlyContinue"
        $VcList = Get-VcList -Export "All"
        $ExistingIntuneApps = Get-VcRedistAppsFromIntune -VcList $VcList
        return $ExistingIntuneApps
    }
}
