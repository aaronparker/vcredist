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
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $VcList
    )

    begin {
        # Get script elevation status
        [System.Boolean] $Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
        if ($Elevated -eq $false) {
            $Msg = "Uninstalling the Visual C++ Redistributables requires elevation. The current Windows PowerShell session is not running as Administrator. Start Windows PowerShell by using the Run as Administrator option, and then try running the script again"
            throw [System.Management.Automation.ScriptRequiresException]::New($Msg)
        }
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

            # Build the uninstall command
            switch -Regex ($VcRedist.UninstallString) {
                "^Msiexec*$" {
                    Write-Verbose -Message "VcRedist uninstall uses Msiexec."
                    $params = @{
                        FilePath     = "$Env:SystemRoot\System32\msiexec.exe"
                        ArgumentList = "/uninstall $($VcRedist.ProductCode) /quiet /norestart"
                        PassThru     = $true
                        Wait         = $true
                        NoNewWindow  = $true
                    }
                }
                default {
                    $FilePath = [Regex]::Match($VcRedist.UninstallString, '\"(.*)\"').Captures.Groups[1].Value
                    Write-Verbose -Message "VcRedist uninstall uses '$FilePath'."
                    $params = @{
                        FilePath     = $FilePath
                        ArgumentList = "/uninstall /quiet /norestart"
                        PassThru     = $true
                        Wait         = $true
                        NoNewWindow  = $true
                    }
                }
            }

            if ($PSCmdlet.ShouldProcess($VcRedist.Name, "Uninstall")) {
                try {
                    $Result = Start-Process @params
                    $State = "Uninstalled"
                }
                catch [System.Exception] {
                    Write-Warning -Message "Failure in uninstalling $($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)"
                    $State = "Failed"
                }
                finally {
                    $Object = [PSCustomObject] @{
                        Name         = $VcRedist.Name
                        Version      = $VcRedist.Version
                        Release      = $VcRedist.Release
                        Architecture = $VcRedist.Architecture
                        State        = $State
                        ExitCode     = $Result.ExitCode
                    }
                    Write-Output -InputObject $Object
                }
            }
        }
    }

    end {
    }
}
