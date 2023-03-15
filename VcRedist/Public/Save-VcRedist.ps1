function Save-VcRedist {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [Alias("Get-VcRedist")]
    [CmdletBinding(SupportsShouldProcess = $true, HelpURI = "https://vcredist.com/save-vcredist/")]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Pass a VcList object from Get-VcList.")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateScript( { if (Test-Path -Path $_ -PathType "Container") { $true } else { throw "Cannot find path $_" } })]
        [System.String] $Path = (Resolve-Path -Path $PWD),

        [Parameter(Mandatory = $false)]
        [System.ObsoleteAttribute("This parameter should no longer be used. Invoke-WebRequest is used for all download operations.")]
        [System.Management.Automation.SwitchParameter] $ForceWebRequest,

        [Parameter(Mandatory = $false)]
        [System.ObsoleteAttribute("This parameter should no longer be used. Invoke-WebRequest is used for all download operations.")]
        [ValidateSet("Foreground", "High", "Normal", "Low")]
        [System.String] $Priority = "Foreground",

        [Parameter(Mandatory = $false, Position = 3)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $false, Position = 4)]
        [System.Management.Automation.PSCredential]
        $ProxyCredential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $false, Position = 5)]
        [ValidateNotNullOrEmpty()]
        [System.String] $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $ShowProgress
    )

    begin {

        # Disable the Invoke-WebRequest progress bar for faster downloads
        if ($PSBoundParameters.ContainsKey("Verbose") -or ($PSBoundParameters.ContainsKey("ShowProgress"))) {
            $ProgressPreference = "Continue"
        }
        else {
            $ProgressPreference = "SilentlyContinue"
        }

        # Enable TLS 1.2
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    }

    process {
        foreach ($VcRedist in $VcList) {
            # Loop through each Redistributable and download to the target path

            # Build the path to save the VcRedist into; Create the folder to store the downloaded file. Skip if it exists
            $TargetDirectory = [System.IO.Path]::Combine((Resolve-Path -Path $Path), $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)
            Write-Verbose -Message "Test directory exists: $TargetDirectory."
            if (Test-Path -Path $TargetDirectory) {
                Write-Verbose -Message "Directory exists: $TargetDirectory. Skipping."
            }
            else {
                if ($PSCmdlet.ShouldProcess($TargetDirectory, "Create")) {
                    $params = @{
                        Path        = $TargetDirectory
                        Type        = "Directory"
                        Force       = $true
                        ErrorAction = "Continue"
                    }
                    New-Item @params > $null
                }
            }

            # Test whether the VcRedist is already on disk
            $TargetVcRedist = Join-Path -Path $TargetDirectory -ChildPath $(Split-Path -Path $VcRedist.URI -Leaf)
            Write-Verbose -Message "Testing for downloaded VcRedist: $($TargetVcRedist)"

            if (Test-Path -Path $TargetVcRedist -PathType "Leaf") {
                $ProductVersion = $(Get-Item -Path $TargetVcRedist).VersionInfo.ProductVersion

                # If the target Redistributable is already downloaded, compare the version
                if (([System.Version]$VcRedist.Version -gt [System.Version]$ProductVersion) -or ($null -eq [System.Version]$ProductVersion)) {

                    # Download the newer version
                    Write-Verbose -Message "Manifest version: '$($VcRedist.Version)' > file version: '$ProductVersion'."
                    $DownloadRequired = $true
                }
                else {
                    Write-Verbose -Message "Manifest version: '$($VcRedist.Version)' matches file version: '$ProductVersion'."
                    $DownloadRequired = $false
                }
            }
            else {
                $DownloadRequired = $true
            }

            # The VcRedist needs to be downloaded
            if ($DownloadRequired -eq $true) {
                if ($PSCmdlet.ShouldProcess($VcRedist.URI, "Invoke-WebRequest")) {

                    try {
                        # Download the file
                        Write-Verbose -Message "Download VcRedist: '$($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)'"
                        $iwrParams = @{
                            Uri             = $VcRedist.URI
                            OutFile         = $TargetVcRedist
                            UseBasicParsing = $true
                            UserAgent       = $UserAgent
                            ErrorAction     = "SilentlyContinue"
                        }
                        if ($PSBoundParameters.ContainsKey("Proxy")) {
                            $iwrParams.Proxy = $Proxy
                        }
                        if ($PSBoundParameters.ContainsKey("ProxyCredential")) {
                            $iwrParams.ProxyCredential = $ProxyCredential
                        }
                        Invoke-WebRequest @iwrParams
                        $Downloaded = $true
                    }
                    catch [System.Exception] {
                        $Downloaded = $false
                        throw $_
                    }

                    # Return the $VcList array on the pipeline so that we can act on what was downloaded
                    # Add the Path property pointing to the downloaded file
                    if ($Downloaded -eq $true) {
                        Write-Verbose -Message "Add Path property: $TargetVcRedist"
                        $VcRedist | Add-Member -MemberType "NoteProperty" -Name "Path" -Value $TargetVcRedist
                        Write-Output -InputObject $VcRedist
                    }
                }
            }
            else {
                # Return the $VcList array on the pipeline so that we can act on what was downloaded
                # Add the Path property pointing to the downloaded file
                Write-Verbose -Message "VcRedist exists: $TargetVcRedist."
                Write-Verbose -Message "Add Path property: $TargetVcRedist"
                $VcRedist | Add-Member -MemberType "NoteProperty" -Name "Path" -Value $TargetVcRedist
                Write-Output -InputObject $VcRedist
            }
        }
    }

    end { }
}
