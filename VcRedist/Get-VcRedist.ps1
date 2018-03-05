# Requires -Version 3
Function Get-VcRedist {
    <#
    .SYNOPSIS
        Downloads the Visual C++ Redistributables from an array returned by Get-VcXml.

    .DESCRIPTION
        Downloads the Visual C++ Redistributables from an array returned by Get-VcXml into a folder structure that represents release and processor architecture.
        If the redistributable exists in the specified path, it will not be re-downloaded.

    .NOTES
        Name: Get-VcRedist
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        https://stealthpuppy.com

    .PARAMETER VcXml
        Sepcifies the array that lists the Visual C++ Redistributables to download

    .EXAMPLE
        Get-VcRedist -VcXml $VcRedists -Path C:\Redist

        Description:
        Downloads the Visual C++ Redistributables listed in VisualCRedistributables.xml to C:\Redist.

    .PARAMETER Path
        Specify a target folder to download the Redistributables to, otherwise use the current folder.

    .EXAMPLE
        Get-VcXml | Get-VcRedist -Path C:\Redist

        Description:
        Downloads the Visual C++ Redistributables listed in $VcRedists to C:\Redist.

    .PARAMETER Release
        Specifies the release (or version) of the redistributables to download or install.

    .EXAMPLE
        Get-VcRedist -VcXml $VcRedists -Release "2012","2013",2017"

        Description:
        Downloads only the 2012, 2013 & 2017 releases of the  Visual C++ Redistributables listed in $VcRedists

    .PARAMETER Architecture
        Specifies the processor architecture to download or install.

    .EXAMPLE
        Get-VcRedist -VcXml $VcRedists -Architecture "x64"

        Description:
        Downloads only the 64-bit versions of the Visual C++ Redistributables listed in $VcRedists.

        $Vc.Name
        $Vc.ProductCode
        $Vc.URL
        $Vc.Download
        $Vc.Release
        $Vc.Architecture
        $Vc.ShortName
#>
    [CmdletBinding(SupportsShouldProcess = $True)]
    PARAM (
        [Parameter(Mandatory = $True, HelpMessage = ".", Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $False)]
        [array]$VcXml,

        [Parameter(Mandatory = $False, HelpMessage = "Specify a target path to download the Redistributables to.")]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string]$Path = ".\",

        [Parameter(Mandatory = $False, HelpMessage = "Specify the version of the Redistributables to download.")]
        [ValidateSet('2005', '2008', '2010', '2012', '2013', '2015', '2017')]
        [string[]]$Release = @("2008", "2010", "2012", "2013", "2015", "2017"),

        [Parameter(Mandatory = $False, HelpMessage = "Specify the processor architecture/s to download.")]
        [ValidateSet('x86', 'x64')]
        [string[]]$Architecture = @("x86", "x64")
    )
    BEGIN {
    }
    PROCESS {

        # Filter release and architecture if specified
        If ($PSBoundParameters.ContainsKey('Release')) {
            Write-Verbose "Filtering releases for platform."
            $VcXml = $VcXml | Where-Object { $_.Release -eq $Release }
        }
        If ($PSBoundParameters.ContainsKey('Architecture')) {
            Write-Verbose "Filtering releases for architecture."
            $VcXml = $VcXml | Where-Object { $_.Architecture -eq $Architecture }
        }

        # Loop through each Redistributable and download to the target path
        ForEach ($Vc in $VcXml) {
            Write-Verbose "Downloading: [$($Vc.Name)][$($Vc.Release)][$($Vc.Architecture)]"

            # Create the folder to store the downloaded file. Skip if it exists
            $Target = "$($(Get-Item -Path $Path).FullName)\$($Vc.Release)\$($Vc.Architecture)\$($Vc.ShortName)"
            If (Test-Path -Path $Target) {
                Write-Verbose "Folder '$Target' exists. Skipping."
            }
            Else {
                If ($pscmdlet.ShouldProcess($target, "Create")) {
                    New-Item -Path $Target -Type Directory -Force -ErrorAction SilentlyContinue | Out-Null
                }
            }

            # If the target Redistributable is already downloaded, skip it.
            # If running on Windows PowerShell use Start-BitsTransfer, otherwise use Invoke-WebRequest
            If (Test-Path -Path "$Target\$(Split-Path -Path $Vc.Download -Leaf)" -PathType Leaf) {
                Write-Verbose "Redistributable exists. Skipping."
            }
            Else {
                If (Get-Command Start-BitsTransfer -ErrorAction SilentlyContinue) {
                    If ($pscmdlet.ShouldProcess($Vc.Download, "BitsDownload")) {
                        Start-BitsTransfer -Source $Vc.Download -Destination "$Target\$(Split-Path -Path $Vc.Download -Leaf)" `
                            -Priority High -TransferPolicy Always -ErrorAction Continue -ErrorVariable $ErrorBits -Verbose `
                            -DisplayName "Visual C++ Redistributable Download" -Description $Vc.Name
                    }
                }
                Else {
                    If ($pscmdlet.ShouldProcess($Vc.Download, "WebDownload")) {
                        Invoke-WebRequest -Uri $Vc.Download -OutFile "$Target\$(Split-Path -Path $Vc.Download -Leaf)"
                    }
                }
            }
        }
    }
    END {
        # Return the $VcXml array on the pipeline so that we can act on what was downloaded
        $VcXml
    }
}