Function Save-VcRedist {
    <#
        .SYNOPSIS
            Downloads the Visual C++ Redistributables from an array returned by Get-VcXml.

        .DESCRIPTION
            Downloads the Visual C++ Redistributables from an array returned by Get-VcXml into a folder structure that represents release and processor architecture.
            If the redistributable exists in the specified path, it will not be re-downloaded.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://docs.stealthpuppy.com/docs/vcredist/usage/downloading-the-redistributables

        .PARAMETER VcList
            Sepcifies the array that lists the Visual C++ Redistributables to download

        .PARAMETER Path
            Specify a target folder to download the Redistributables to, otherwise use the current folder.

        .PARAMETER Proxy
            Specifies a proxy server for the request, rather than connecting directly to the internet resource. Enter the URI of a network proxy server.

        .PARAMETER ProxyCredential
            Specifies a user account that has permission to use the proxy server that is specified by the Proxy parameter. The default is the current user.

        .EXAMPLE
            Save-VcRedist -VcList (Get-VcList) -Path C:\Redist

            Description:
            Downloads the supported Visual C++ Redistributables to C:\Redist.
            
        .EXAMPLE
            Get-VcList | Save-VcRedist -Path C:\Redist

            Description:
            Passes the list of supported Visual C++ Redistributables to Save-VcRedist and downloads the Redistributables to C:\Redist.

        .EXAMPLE
            $VcList = Get-VcList -Release 2013, 2019 -Architecture x86
            Save-VcRedist -VcList $VcList -Path C:\Redist

            Description:
            Passes the list of 2013 and 2019 x86 supported Visual C++ Redistributables to Save-VcRedist and downloads the Redistributables to C:\Redist.

        .EXAMPLE
            Save-VcRedist -VcList (Get-VcList -Release 2010, 2012, 2013, 2019) -Path C:\Redist

            Description:
            Downloads the 2010, 2012, 2013, and 2019 Visual C++ Redistributables to C:\Redist.

        .EXAMPLE
            Save-VcRedist -VcList (Get-VcList -Release 2010, 2012, 2013, 2019) -Path C:\Redist -Proxy proxy.domain.local

            Description:
            Downloads the 2010, 2012, 2013, and 2019 Visual C++ Redistributables to C:\Redist using the proxy server 'proxy.domain.local'
        #>
    [Alias("Get-VcRedist")]
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://docs.stealthpuppy.com/docs/vcredist/usage/downloading-the-redistributables")]
    [OutputType([System.Management.Automation.PSObject])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [System.String] $Path = (Resolve-Path -Path $PWD),

        [Parameter(Mandatory = $False)]
        [System.ObsoleteAttribute("This parameter should no longer be used. Invoke-WebRequest is used for all download operations.")]
        [System.Management.Automation.SwitchParameter] $ForceWebRequest,

        [Parameter(Mandatory = $False, Position = 2)]
        [System.ObsoleteAttribute("This parameter should no longer be used. Invoke-WebRequest is used for all download operations.")]
        [ValidateSet('Foreground', 'High', 'Normal', 'Low')]
        [System.String] $Priority = "Foreground",

        [Parameter(Mandatory = $False, Position = 3)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $False, Position = 4)]
        [System.Management.Automation.PSCredential]
        $ProxyCredential = [System.Management.Automation.PSCredential]::Empty
    )

    Begin { 
        # Disable the Invoke-WebRequest progress bar for faster downloads
        If ($PSBoundParameters.ContainsKey('Verbose')) {
            $ProgressPreference = "Continue"
        }
        Else {
            $ProgressPreference = "SilentlyContinue"
        }
    }

    Process {
        # Loop through each Redistributable and download to the target path
        ForEach ($Vc in $VcList) {

            # Create the folder to store the downloaded file. Skip if it exists
            Write-Verbose -Message "$($MyInvocation.MyCommand): Test: [$($Vc.Name), $($Vc.Release), $($Vc.Architecture)]"
            $folder = Join-Path (Join-Path (Join-Path $(Resolve-Path -Path $Path) $Vc.Release) $Vc.Architecture) $Vc.ShortName
            If (Test-Path -Path $folder) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Folder '$folder' exists. Skipping."
            }
            Else {
                If ($pscmdlet.ShouldProcess($folder, "Create")) {
                    try {
                        New-Item -Path $folder -Type Directory -Force -ErrorAction SilentlyContinue > $Null
                    }
                    catch [System.Exception] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to create folder: [$folder]."
                        Throw $_.Exception.Message
                        Continue
                    }
                }
            }
            
            # Test whether the VcRedist is already on disk
            $target = Join-Path $folder $(Split-Path -Path $Vc.Download -Leaf)
            Write-Verbose -Message "$($MyInvocation.MyCommand): Testing target: $($target)"

            If (Test-Path -Path $target -PathType Leaf) {
                $ProductVersion = $(Get-FileMetadata -Path $target).ProductVersion
                
                # If the target Redistributable is already downloaded, compare the version
                If (($Vc.Version -gt $ProductVersion) -or ($Null -eq $ProductVersion)) {
                    # Download the newer version
                    Write-Verbose -Message "$($MyInvocation.MyCommand): $($Vc.Version) > $ProductVersion."
                    $download = $True
                }
                Else {
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Manifest version: $($Vc.Version) matches file version: $ProductVersion."
                    $download = $False
                }
            }
            Else {
                $download = $True
            }

            # The VcRedist needs to be downloaded
            If ($download) {
                If ($pscmdlet.ShouldProcess($Vc.Download, "WebDownload")) {
                    # Use Invoke-WebRequest with no progress bar by default for best compatibility and speed
                    try {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Download: [$($Vc.Name), $($Vc.Release), $($Vc.Architecture)]"
                        # Enable TLS 1.2
                        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                        $iwrParams = @{
                            Uri             = $Vc.Download
                            OutFile         = $target
                            UseBasicParsing = $True
                            ErrorAction     = "SilentlyContinue"
                        }
                        If ($PSBoundParameters.ContainsKey('Proxy')) {
                            $iwrParams.Proxy = $Proxy
                        }
                        If ($PSBoundParameters.ContainsKey('ProxyCredential')) {
                            $iwrParams.ProxyCredential = $ProxyCredential
                        }
                        Invoke-WebRequest @iwrParams
                        $return = $True
                    }
                    catch [System.Net.Http.HttpRequestException] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): HttpRequestException: Check URL is valid: [$($Vc.Download)]."
                        Throw $_.Exception.Message
                        $return = $False
                    }
                    catch [System.Net.WebException] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): WebException."
                        Throw $_.Exception.Message
                        $return = $False
                    }
                    catch [System.Exception] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to download VcRedist from: [$($Vc.Download)]."
                        Throw $_.Exception.Message
                        $return = $False
                    }
                    finally {
                        If ($return) {
                            # Return the $VcList array on the pipeline so that we can act on what was downloaded
                            Write-Output -InputObject $Vc
                        }
                    }
                }
            }
            Else {
                Write-Verbose -Message "$($MyInvocation.MyCommand): $($target) exists."
            }
        }
    }

    End { }
}
