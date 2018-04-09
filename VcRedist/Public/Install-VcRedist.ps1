Function Install-VcRedist {
    <#
    .SYNOPSIS
        Installs the Visual C++ Redistributables.

    .DESCRIPTION
        Installs the Visual C++ Redistributables from a list created by Get-VcList and downloaded locally with Get-VcRedist.

    .OUTPUTS
         System.Array

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        https://github.com/aaronparker/Install-VisualCRedistributables

    .PARAMETER VcList
        An array containing details of the Visual C++ Redistributables from Get-VcList.

    .PARAMETER Path
        A folder containing the downloaded Visual C++ Redistributables.

    .PARAMETER Release
        Specifies the release (or version) of the redistributables to download or install.

    .PARAMETER Architecture
        Specifies the processor architecture to download or install.

    .EXAMPLE
        Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists

        Description:
        Installs the Visual C++ Redistributables listed in $VcRedists and downloaded to C:\Temp\VcRedists.

    .EXAMPLE
        Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists -Release "2012","2013",2017" -Architecture x64

        Description:
        Installs only the 64-bit 2012, 2013 and 2017 Visual C++ Redistributables listed in $VcRedists and downloaded to C:\Temp\VcRedists.
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([Array])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $False, `
                HelpMessage = "An array containing details of the Visual C++ Redistributables from Get-VcList.")]
        [ValidateNotNull()]
        [array]$VcList,

        [Parameter(Mandatory = $True, Position = 1, HelpMessage = "A folder containing the downloaded Visual C++ Redistributables.")]
        [ValidateScript({If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string]$Path,

        [Parameter(Mandatory = $False, HelpMessage = "Specify the version of the Redistributables to install.")]
        [ValidateSet('2005', '2008', '2010', '2012', '2013', '2015', '2017')]
        [string[]]$Release = @("2008", "2010", "2012", "2013", "2015", "2017"),

        [Parameter(Mandatory = $False, HelpMessage = "Specify the processor architecture/s to install.")]
        [ValidateSet('x86', 'x64')]
        [string[]]$Architecture = @("x86", "x64")
    )
    Begin {
        # Get script elevation status
        [bool]$Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
        If ( !($Elevated) ) { Throw "Installing the Visual C++ Redistributables requires elevation."}
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

        # Loop through each Redistributable and install
        ForEach ( $Vc in $VcList ) {
            $UninstallPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
            If (Get-ChildItem -Path $UninstallPath | Where-Object { $_.Name -like "*$($Vc.ProductCode)" }) {
                Write-Verbose "Skip:    [$($Vc.Release)][$($Vc.Architecture)][$($Vc.Name)]"
            }
            Else {
                Write-Verbose "Install: [$($Vc.Release)][$($Vc.Architecture)][$($Vc.Name)]"
                # $folder = "$($(Get-Item -Path $Path).FullName)\$($Vc.Release)\$($Vc.Architecture)\$($Vc.ShortName)"
                $folder = Join-Path (Join-Path (Join-Path $(Resolve-Path -Path $Path) $Vc.Release) $Vc.Architecture) $Vc.ShortName
                $filename = Join-Path $Folder $(Split-Path -Path $Vc.Download -Leaf)
                $filename = Split-Path -Path $Vc.Download -Leaf
                If (Test-Path -Path (Join-Path $folder $filename)) {
                    If ($pscmdlet.ShouldProcess("$(Join-Path $folder $filename) $($Vc.Install)'", "Install")) {
                        Start-Process -FilePath (Join-Path $folder $filename) -ArgumentList $Vc.Install -Wait
                    }
                }
                Else {
                    Write-Error "Cannot find: $(Join-Path $folder $filename)"
                }
            }
        }
    }
    End {
        # Get the imported Visual C++ Redistributables applications to return on the pipeline
        $output = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | `
        Get-ItemProperty | Where-Object {$_.DisplayName -like "Microsoft Visual C*"} | Select-Object Publisher, DisplayName, DisplayVersion
        $output
    }
}
