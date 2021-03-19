Function Save-VcRedist {
    <#
        .SYNOPSIS
            Downloads the Visual C++ Redistributables from an manifest returned by Get-VcList.

        .DESCRIPTION
            Downloads the Visual C++ Redistributables from an manifest returned by Get-VcList into a folder structure that represents release, version and processor architecture.
            If the redistributable exists in the specified path, it will not be re-downloaded.

            For example, the following folder structure will be created when downloading the 2010, 2012, 2013 and 2019 Redistributables to C:\VcRedist:

                C:\VcRedist\2010\10.0.40219.325\x64
                C:\VcRedist\2010\10.0.40219.325\x86
                C:\VcRedist\2012\11.0.61030.0\x64
                C:\VcRedist\2012\11.0.61030.0\x86
                C:\VcRedist\2013\12.0.40664.0\x64
                C:\VcRedist\2013\12.0.40664.0\x86
                C:\VcRedist\2019\14.28.29913.0\x64
                C:\VcRedist\2019\14.28.29913.0\x86

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://stealthpuppy.com/VcRedist/save-vcredist.html

        .PARAMETER VcList
            Specifies the array that lists the Visual C++ Redistributables to download

        .PARAMETER Path
            Specify a target folder to download the Redistributables to, otherwise use the current folder.

        .PARAMETER Proxy
            Specifies a proxy server for the request, rather than connecting directly to the internet resource. Enter the URI of a network proxy server.

        .PARAMETER ProxyCredential
            Specifies a user account that has permission to use the proxy server that is specified by the Proxy parameter. The default is the current user.

        .PARAMETER NoProgress
            Specify this switch with -Verbose to show verbose output but also suppress Invoke-WebRequest progress to speed downloads.

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
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://stealthpuppy.com/VcRedist/save-vcredist.html")]
    [OutputType([System.Management.Automation.PSObject])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateScript( { If (Test-Path -Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [System.String] $Path = (Resolve-Path -Path $PWD),

        [Parameter(Mandatory = $False)]
        [System.ObsoleteAttribute("This parameter should no longer be used. Invoke-WebRequest is used for all download operations.")]
        [System.Management.Automation.SwitchParameter] $ForceWebRequest,

        [Parameter(Mandatory = $False)]
        [System.ObsoleteAttribute("This parameter should no longer be used. Invoke-WebRequest is used for all download operations.")]
        [ValidateSet('Foreground', 'High', 'Normal', 'Low')]
        [System.String] $Priority = "Foreground",

        [Parameter(Mandatory = $False, Position = 3)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $False, Position = 4)]
        [System.Management.Automation.PSCredential]
        $ProxyCredential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $NoProgress
    )

    Begin { 

        # Disable the Invoke-WebRequest progress bar for faster downloads
        If ($PSBoundParameters.ContainsKey("Verbose") -and !($PSBoundParameters.ContainsKey("NoProgress"))) {
            $ProgressPreference = "Continue"
        }
        Else {
            $ProgressPreference = "SilentlyContinue"
        }
    }

    Process {

        # Loop through each Redistributable and download to the target path
        ForEach ($VcRedist in $VcList) {

            # Build the path to save the VcRedist into
            # Target folder structure
            $folder = [System.IO.Path]::Combine((Resolve-Path -Path $Path), $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)

            # Create the folder to store the downloaded file. Skip if it exists
            Write-Verbose -Message "$($MyInvocation.MyCommand): Test folder: [$folder]."
            If (Test-Path -Path $folder -ErrorAction "SilentlyContinue") {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Folder [$folder] exists. Skipping."
            }
            Else {
                If ($PSCmdlet.ShouldProcess($folder, "Create")) {
                    try {
                        $params = @{
                            Path        = $folder
                            Type        = "Directory"
                            Force       = $True
                            ErrorAction = "SilentlyContinue"
                        }
                        New-Item @params > $Null
                    }
                    catch [System.Exception] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to create folder: [$folder]."
                        Throw $_.Exception.Message
                        Continue
                    }
                }
            }
            
            # Test whether the VcRedist is already on disk
            $target = Join-Path -Path $folder -ChildPath $(Split-Path -Path $VcRedist.Download -Leaf)
            Write-Verbose -Message "$($MyInvocation.MyCommand): Testing target: $($target)"

            If (Test-Path -Path $target -PathType "Leaf" -ErrorAction "SilentlyContinue") {
                $ProductVersion = $(Get-FileMetadata -Path $target).ProductVersion
                
                # If the target Redistributable is already downloaded, compare the version
                If (($VcRedist.Version -gt $ProductVersion) -or ($Null -eq $ProductVersion)) {
                    
                    # Download the newer version
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Manifest version: [$($VcRedist.Version)] > file version: [$ProductVersion]."
                    $download = $True
                }
                Else {
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Manifest version: [$($VcRedist.Version)] matches file version: [$ProductVersion]."
                    $download = $False
                }
            }
            Else {
                $download = $True
            }

            # The VcRedist needs to be downloaded
            If ($download) {
                If ($PSCmdlet.ShouldProcess($VcRedist.Download, "Invoke-WebRequest")) {
                    
                    try {
                        # Enable TLS 1.2
                        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

                        # Download the file
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Download VcRedist: [$($VcRedist.Release), $($VcRedist.Architecture), $($VcRedist.Version)]"
                        $iwrParams = @{
                            Uri             = $VcRedist.Download
                            OutFile         = $target
                            UseBasicParsing = $True
                            ErrorAction     = "SilentlyContinue"
                        }
                        If ($PSBoundParameters.ContainsKey("Proxy")) {
                            $iwrParams.Proxy = $Proxy
                        }
                        If ($PSBoundParameters.ContainsKey("ProxyCredential")) {
                            $iwrParams.ProxyCredential = $ProxyCredential
                        }
                        Invoke-WebRequest @iwrParams
                    }
                    catch [System.Net.Http.HttpRequestException] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): HttpRequestException: Check URL is valid: [$($VcRedist.Download)]."
                        Throw $_.Exception.Message
                    }
                    catch [System.Net.WebException] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): WebException."
                        Throw $_.Exception.Message
                    }
                    catch [System.Exception] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to download VcRedist from: [$($VcRedist.Download)]."
                        Throw $_.Exception.Message
                    }
                    finally {

                        # Return the $VcList array on the pipeline so that we can act on what was downloaded
                        If (Test-Path -Path $target -PathType "Leaf" -ErrorAction "SilentlyContinue") {
                            Write-Output -InputObject $VcRedist
                        }
                    }
                }
            }
            Else {
                Write-Verbose -Message "$($MyInvocation.MyCommand): [$($target)] exists."
            }
        }
    }

    End { }
}
