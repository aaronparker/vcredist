Function Get-Bitness {
    <#
        .SYNOPSIS
            Tests the current operating system for 32-bit or 64-bit Windows. Uses '[System.IntPtr]::Size' for maximum compatibility

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .PARAMETER Architecture
            Specify a specific processor architecture to test for.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, HelpMessage = "Specify the processor architecture to test for.")]
        [ValidateSet('x86', 'x64')]
        [System.String[]] $Architecture
    )

    # Alternative methods for checking bitness
    # [System.Environment]::Is64BitOperatingSystem
    # (Get-CimInstance -ClassName win32_operatingsystem).OSArchitecture

    If ($PSBoundParameters.ContainsKey('Architecture')) {
        [System.Boolean] $output = $False
        Switch ($Architecture) {
            "x64" { If ([System.IntPtr]::Size -eq 8) { $output = $True } }
            "x86" { If ([System.IntPtr]::Size -eq 4) { $output = $True } }
        }
        Write-Output -InputObject $output
    }
    Else {
        [System.String] $output = "x64"
        Switch ([System.IntPtr]::Size) {
            8 { $output = "x64" }
            4 { $output = "x86" }
        }
        Write-Output -InputObject $output
    }
}
