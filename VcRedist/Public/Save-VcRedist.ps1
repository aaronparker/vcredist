Function Save-VcRedist {
    <#
        .SYNOPSIS
            Downloads the Visual C++ Redistributables from an array returned by Get-VcXml.

        .DESCRIPTION
            Downloads the Visual C++ Redistributables from an array returned by Get-VcXml into a folder structure that represents release and processor architecture.
            If the redistributable exists in the specified path, it will not be re-downloaded.

        .OUTPUTS
            System.Array

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://docs.stealthpuppy.com/docs/vcredist/usage/downloading-the-redistributables

        .PARAMETER VcList
            Sepcifies the array that lists the Visual C++ Redistributables to download

        .PARAMETER Path
            Specify a target folder to download the Redistributables to, otherwise use the current folder.

        .PARAMETER ForceWebRequest
            Forces the use of Invoke-WebRequest over Start-BitsTransfer

        .EXAMPLE
            Save-VcRedist -VcList (Get-VcList) -Path C:\Redist

            Description:
            Downloads the supported Visual C++ Redistributables to C:\Redist.
            
        .EXAMPLE
            Get-VcList | Save-VcRedist -Path C:\Redist -ForceWebRequest

            Description:
            Passes the list of supported Visual C++ Redistributables to Save-VcRedist and uses Invoke-WebRequest to download the Redistributables to C:\Redist.

        .EXAMPLE
            $VcList = Get-VcList -Release 2013, 2019 -Architecture x86
            Save-VcRedist -VcList $VcList -Path C:\Redist -ForceWebRequest

            Description:
            Passes the list of 2013 and 2019 x86 supported Visual C++ Redistributables to Save-VcRedist and uses Invoke-WebRequest to download the Redistributables to C:\Redist.
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
        [System.Management.Automation.SwitchParameter] $ForceWebRequest,

        [Parameter(Mandatory = $False, Position = 2)]
        [ValidateSet('Foreground', 'High', 'Normal', 'Low')]
        [System.String] $Priority = "Foreground",

        [Parameter(Mandatory = $False, Position = 3)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $False, Position = 4)]
        [System.Management.Automation.PSCredential]
        $ProxyCredential = [System.Management.Automation.PSCredential]::Empty
    )

    # Loop through each Redistributable and download to the target path
    ForEach ($Vc in $VcList) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Download: [$($Vc.Name), $($Vc.Release), $($Vc.Architecture)]"

        # Create the folder to store the downloaded file. Skip if it exists
        $folder = Join-Path (Join-Path (Join-Path $(Resolve-Path -Path $Path) $Vc.Release) $Vc.Architecture) $Vc.ShortName
        If (Test-Path -Path $folder) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Folder '$folder' exists. Skipping."
        }
        Else {
            If ($pscmdlet.ShouldProcess($folder, "Create")) {
                try {
                    New-Item -Path $folder -Type Directory -Force -ErrorAction SilentlyContinue | Out-Null
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

            # If -ForceWebRequest or running on PowerShell Core (or Start-BitsTransfer is unavailable) download with Invoke-WebRequest
            If ($ForceWebRequest -or (Test-PSCore)) {
                If ($pscmdlet.ShouldProcess($Vc.Download, "WebDownload")) {

                    # Use Invoke-WebRequest in instances where Start-BitsTransfer isn't supported or won't work
                    try {
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
                            $iwrParams.ProxyCredentials = $ProxyCredential
                        }
                        Invoke-WebRequest @iwrParams
                    }
                    catch [System.Net.Http.HttpRequestException] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): HttpRequestException: Check URL is valid: [$($Vc.Download)]."
                        Throw $_.Exception.Message
                        Continue
                    }
                    catch [System.Net.WebException] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): WebException."
                        Throw $_.Exception.Message
                        Continue
                    }
                    catch [System.Exception] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to download VcRedist from: [$($Vc.Download)]."
                        Throw $_.Exception.Message
                        Continue
                    }
                }
            }
            Else {
                If ($pscmdlet.ShouldProcess($Vc.Download, "BitsDownload")) {
                        
                    # Use Start-BitsTransfer
                    try {
                        $sbtParams = @{
                            Source      = $Vc.Download
                            Destination = $target
                            Priority    = $Priority
                            DisplayName = "Visual C++ Redistributable Download"
                            Description = $Vc.Name
                            ErrorAction = "SilentlyContinue"
                        }
                        If ($PSBoundParameters.ContainsKey('Proxy')) {
                            # Set priority to Foreground because the proxy will remove the Range protocol header
                            $sbtParams.Priority = "Foreground"
                            $sbtParams.ProxyUsage = "Override"
                            $sbtParams.ProxyList = $Proxy
                        }
                        If ($PSBoundParameters.ContainsKey('ProxyCredential')) {
                            $sbtParams.ProxyCredential = $ProxyCredentials
                        }
                        Start-BitsTransfer @sbtParams
                    }
                    catch [System.Exception] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to download VcRedist from: [$($Vc.Download)]."
                        Throw $_.Exception.Message
                        Continue
                    }
                }
            }
        }
        Else {
            Write-Verbose -Message "$($MyInvocation.MyCommand): $($target) exists."
        }
    }

    # Return the $VcList array on the pipeline so that we can act on what was downloaded
    Write-Output -InputObject $filteredVcList
}
