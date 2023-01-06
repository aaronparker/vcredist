function Test-VcRedistDownload {
    <#
        .EXTERNALHELP Vcredist-help.xml
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $true, HelpURI = "https://stealthpuppy.com/vcredist/test/", DefaultParameterSetName = "Path")]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline,
            HelpMessage = "Pass an object from Get-VcList.")]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $InputObject,

        [Parameter(Mandatory = $false, Position = 1)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $false, Position = 2)]
        [System.Management.Automation.PSCredential]
        $ProxyCredential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $ShowProgress
    )

    begin {
        # Disable the Invoke-WebRequest progress bar for faster downloads
        if ($PSBoundParameters.ContainsKey("Verbose") -or ($PSBoundParameters.ContainsKey("ShowProgress"))) {
            $ProgressPreference = [System.Management.Automation.ActionPreference]::Continue
        }
        else {
            $ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        }

        # Enable TLS 1.2
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    }

    process {
        # Loop through each object and download to the target path
        foreach ($Object in $InputObject) {

            #region Validate the URI property and find the output filename
            if ([System.Boolean]($Object.URI) -eq $false) {
                $Msg = "Object does not have valid Download property."
                throw [System.Management.Automation.PropertyNotFoundException]::New($Msg)
            }
            #endregion

            try {
                $params = @{
                    Uri             = $Object.URI
                    Method          = "HEAD"
                    UseBasicParsing = $true
                    ErrorAction     = "SilentlyContinue"
                }
                if ($PSBoundParameters.ContainsKey("Proxy")) {
                    $params.Proxy = $Proxy
                }
                if ($PSBoundParameters.ContainsKey("ProxyCredential")) {
                    $params.ProxyCredential = $ProxyCredential
                }
                $Result = $true
                Invoke-WebRequest @params | Out-Null
            }
            catch [System.Exception] {
                $Result = $false
            }
            $PSObject = [PSCustomObject] @{
                Result       = $Result
                Release      = $Object.Release
                Architecture = $Object.Architecture
                Version      = $Object.Version
                URI          = $Object.URI
            }
            Write-Output -InputObject $PSObject
        }
    }

    end {
        if ($PSCmdlet.ShouldProcess("Remove variables")) {
            if (Test-Path -Path Variable:params) { Remove-Variable -Name "params" -ErrorAction "SilentlyContinue" }
            Remove-Variable -Name "OutPath", "OutFile" -ErrorAction "SilentlyContinue"
        }
    }
}
