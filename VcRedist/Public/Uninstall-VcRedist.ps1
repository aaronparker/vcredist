function Uninstall-VcRedist {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(DefaultParameterSetName = 'Manual', SupportsShouldProcess = $True, ConfirmImpact = "High",
        HelpURI = "https://vcredist.com/uninstall-vcredist/")]
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    param (
        [Parameter(Mandatory = $False, Position = 0, ParameterSetName = 'Manual')]
        [ValidateSet("2005", "2008", "2010", "2012", "2013", "2015", "2017", "2019", "2022")]
        [System.String[]] $Release = @("2005", "2008", "2010", "2012", "2013", "2015", "2017", "2019", "2022"),

        [Parameter(Mandatory = $False, Position = 1, ParameterSetName = 'Manual')]
        [ValidateSet("x86", "x64")]
        [System.String[]] $Architecture = @("x86", "x64"),

        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline, ParameterSetName = 'Pipeline')]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $VcList
    )

    begin {
        if ($PSBoundParameters.ContainsKey("Confirm")) { Write-Warning -Message "Uninstalling Visual C++ Redistributables" }
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            "Manual" {
                # Get the installed VcRedists and filter
                Write-Verbose -Message "Getting locally installed Visual C++ Redistributables"
                $VcRedistsToRemove = Get-InstalledVcRedist | Where-Object { $Release -contains $_.Release } | Where-Object { $Architecture -contains $_.Architecture }
            }
            "Pipeline" {
                Write-Verbose -Message "Removing installed Visual C++ Redistributables passed via the pipeline"
                $VcRedistsToRemove = $VcList
            }
        }

        # Walk through each VcRedist and uninstall
        foreach ($VcRedist in $VcRedistsToRemove) {
            if ($PSCmdlet.ShouldProcess($VcRedist.Name, "Uninstall")) {
                $invokeProcessParams = @{
                    FilePath = "$env:SystemRoot\System32\cmd.exe"
                }
                if ($null -ne $VcRedist.QuietUninstallString) {
                    $invokeProcessParams.ArgumentList = "/c $($VcRedist.QuietUninstallString)"
                    Write-Verbose -Message "VcRedist has quiet uninstall string."
                    Write-Verbose -Message "Uninstalling with: [$($VcRedist.QuietUninstallString)]."
                }
                elseif ($null -ne $VcRedist.SilentUninstall) {
                    $invokeProcessParams.ArgumentList = "/c $($VcRedist.SilentUninstall)"
                    Write-Verbose -Message "VcRedist has quiet uninstall string."
                    Write-Verbose -Message "Uninstalling with: [$($VcRedist.SilentUninstall)]."
                }
                else {
                    $invokeProcessParams.ArgumentList = "/c $($VcRedist.UninstallString) /quiet /noreboot"
                    Write-Verbose -Message "VcRedist does not have quiet uninstall string. Adding [/quiet]."
                    Write-Verbose -Message "Uninstalling with: [$($VcRedist.UninstallString)]."
                }

                try {
                    $result = Invoke-Process @invokeProcessParams
                }
                catch [System.Exception] {
                    Write-Warning -Message "Failure in uninstalling Visual C++ Redistributable."
                    Write-Warning -Message "Captured error (if any): [$result]."
                    # throw "Failed to uninstall VcRedist $($VcRedist.Name) with error code: $($result.ExitCode)"
                }
            }
        }
    }

    end {
        # Output remaining installed VcRedists to the pipeline
        $InstalledVcRedist = Get-InstalledVcRedist
        if ($null -eq $InstalledVcRedist) {
            Write-Verbose -Message "No VcRedists installed or all VcRedists uninstalled successfully."
        }
        else {
            Write-Verbose -Message "Output remaining installed VcRedists."
            Write-Output -InputObject $InstalledVcRedist
        }
    }
}
