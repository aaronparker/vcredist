function Get-Bitness {
    <#
        .SYNOPSIS
            Tests the current operating system for 32-bit or 64-bit Windows. Uses '[System.IntPtr]::Size' for maximum compatibility

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .PARAMETER Architecture
            Specify a specific processor architecture to test for.
    #>
    [CmdletBinding(SupportsShouldProcess = $false)]
    param ()

    # Alternative methods for checking bitness
    # [System.Environment]::Is64BitOperatingSystem
    # (Get-CimInstance -ClassName win32_operatingsystem).OSArchitecture

    [System.String] $output = "x64"
    switch ([System.IntPtr]::Size) {
        8 { $output = "x64" }
        4 { $output = "x86" }
    }
    Write-Output -InputObject $output
}
