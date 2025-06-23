function Get-VcRedistFromIntune {
    <#
        
    #>
    [CmdletBinding(SupportsShouldProcess = $false)]
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
        # Get the existing Win32 applications from Intune
        Write-Verbose -Message "Retrieving existing Win32 applications from Intune."
        $ExistingIntuneApps = Get-IntuneWin32App | `
            Where-Object { $_.displayName -match "^Microsoft Visual C*" } | `
            Select-Object -Property * -ExcludeProperty "largeIcon"
        if ($ExistingIntuneApps.Count -gt 0) {
            Write-Verbose -Message "Found $($ExistingIntuneApps.Count) existing Visual C++ applications in Intune."
        }
    }

    process {
        foreach ($Application in $ExistingIntuneApps) {
            try {
                $AppNote = $Application.notes | ConvertFrom-Json -ErrorAction "Stop"
            }
            catch {
                $AppNote = $null
            }

            if ($null -ne $AppNote) {
                $MatchedApp = $VcList | Where-Object { $_.PackageId -eq $AppNote.Guid }
                if ($null -ne $MatchedApp) {
                    Write-Verbose -Message "Matched VcRedist Id $($AppNote.Guid) to Intune app $($Application.id)."

                    $Update = $false
                    if ([System.Version]$MatchedApp.Version -gt [System.Version]$Application.displayVersion) {
                        $Update = $true
                        Write-Verbose -Message "Update required for $($Application.displayName): $($MatchedApp.Version) > $($Application.displayVersion)."
                    }

                    $Object = [PSCustomObject]@{
                        "AppId"          = $Application.Id
                        "IntuneVersion"  = $Application.displayVersion
                        "UpdateVersion"  = $MatchedApp.Version
                        "UpdateRequired" = $Update
                    }
                    Write-Output -InputObject $Object
                }
            }
            else {
                Write-Verbose -Message "$($Application.displayName): application not imported by VcRedist."
            }
        }
    }
}
