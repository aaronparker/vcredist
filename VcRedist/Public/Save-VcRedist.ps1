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
            https://docs.stealthpuppy.com/vcredist/usage/downloading-the-redistributables

        .PARAMETER VcList
            Sepcifies the array that lists the Visual C++ Redistributables to download

        .PARAMETER Path
            Specify a target folder to download the Redistributables to, otherwise use the current folder.

        .PARAMETER Release
            Specifies the release (or version) of the redistributables to download or install.

        .PARAMETER Architecture
            Specifies the processor architecture to download or install.

        .PARAMETER ForceWebRequest
            Forces the use of Invoke-WebRequest over Start-BitsTransfer

        .EXAMPLE
            Save-VcRedist -VcList (Get-VcList) -Path C:\Redist

            Description:
            Downloads the supported Visual C++ Redistributables to C:\Redist.
            
        .EXAMPLE
            $VcRedists = Get-VcList
            Save-VcRedist -VcList $VcRedists -Release "2012","2013",2017"

            Description:
            Downloads only the 2012, 2013 & 2017 releases of the  Visual C++ Redistributables listed in $VcRedists

        .EXAMPLE
            Save-VcRedist -VcList (Get-VcList) -Path C:\Temp\VcRedist -Architecture x64

            Description:
            Downloads only the 64-bit versions of the Visual C++ Redistributables listed in $VcRedists.
    #>
    [Alias("Get-VcRedist")]
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://docs.stealthpuppy.com/vcredist/usage/downloading-the-redistributables")]
    [OutputType([Array])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [PSCustomObject] $VcList,

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string] $Path,

        [Parameter(Mandatory = $False)]
        [ValidateSet('2005', '2008', '2010', '2012', '2013', '2015', '2017')]
        [string[]] $Release = @("2008", "2010", "2012", "2013", "2015", "2017"),

        [Parameter(Mandatory = $False)]
        [ValidateSet('x86', 'x64')]
        [string[]] $Architecture = @("x86", "x64"),

        [Parameter(Mandatory = $False)]
        [switch] $ForceWebRequest
    )

    Begin {
        # Output variable
        $output = @()
    }

    Process {
        # Filter release and architecture if specified
        If ( $PSBoundParameters.ContainsKey('Release') ) {
            Write-Verbose "Filtering releases for platform."
            $VcList = $VcList | Where-Object { $_.Release -eq $Release }
        }
        If ( $PSBoundParameters.ContainsKey('Architecture') ) {
            Write-Verbose "Filtering releases for architecture."
            $VcList = $VcList | Where-Object { $_.Architecture -eq $Architecture }
        }

        # Loop through each Redistributable and download to the target path
        ForEach ($Vc in $VcList) {
            Write-Verbose "[$($Vc.Name)][$($Vc.Release)][$($Vc.Architecture)]"

            # Create the folder to store the downloaded file. Skip if it exists
            # $folder = "$($(Get-Item -Path $Path).FullName)\$($Vc.Release)\$($Vc.Architecture)\$($Vc.ShortName)"
            $folder = Join-Path (Join-Path (Join-Path $(Resolve-Path -Path $Path) $Vc.Release) $Vc.Architecture) $Vc.ShortName
            If (Test-Path -Path $folder) {
                Write-Verbose "Folder '$folder' exists. Skipping."
            }
            Else {
                If ($pscmdlet.ShouldProcess($folder, "Create")) {
                    try {
                        New-Item -Path $folder -Type Directory -Force -ErrorAction SilentlyContinue | Out-Null
                    }
                    catch {
                        Throw "Failed to create folder $folder."
                    }
                }
            }
            
            # Test whether the VcRedist is already on disk
            $target = Join-Path $folder $(Split-Path -Path $Vc.Download -Leaf)
            Write-Verbose "Testing target: $($target)"
            If (Test-Path -Path $target -PathType Leaf) {
                $ProductVersion = $(Get-FileMetadata -Path $target).ProductVersion
                
                # If the target Redistributable is already downloaded, compare the version
                If (($Vc.Version -gt $ProductVersion) -or ($Null -eq $ProductVersion)) {
                    # Download the newer version
                    Write-Verbose "$($Vc.Version) > $ProductVersion."
                    $download = $True
                }
                Else {
                    Write-Verbose "Manifest version: $($Vc.Version) matches file version: $ProductVersion."
                    $download = $False
                }
            }
            Else {
                $download = $True
            }

            # The VcRedist needs to be downloaded
            If ($download) {

                # If -ForceWebRequest or running on PowerShell Core (or Start-BitsTransfer is unavailable) download with Invoke-WebRequest
                If ($ForceWebRequest -or (!(Get-Command -Name Start-BitsTransfer -ErrorAction SilentlyContinue))) {
                    If ($pscmdlet.ShouldProcess($Vc.Download, "WebDownload")) {

                        # Use Invoke-WebRequest in instances where Start-BitsTransfer isn't supported or won't work
                        try {
                            Invoke-WebRequest -Uri $Vc.Download -OutFile $target
                        }
                        catch {
                            Throw "Failed to download VcRedist from $Vc.Download."
                        }
                    }
                }
                Else {
                    If ($pscmdlet.ShouldProcess($Vc.Download, "BitsDownload")) {
                        
                        # Use Start-BitsTransfer
                        try {
                            Start-BitsTransfer -Source $Vc.Download -Destination $target `
                                -Priority High -ErrorAction Continue -ErrorVariable $ErrorBits `
                                -DisplayName "Visual C++ Redistributable Download" -Description $Vc.Name
                        }
                        catch {
                            Throw "Failed to download VcRedist from $Vc.Download."
                        }
                    }
                }
            }
            Else {
                Write-Verbose "$($target) exists."
            }
        }
    }
    
    End {
        # Return the $VcList array on the pipeline so that we can act on what was downloaded
        Write-Output $VcList
    }
}
