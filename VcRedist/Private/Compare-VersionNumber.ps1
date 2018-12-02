Set-StrictMode -Version Latest
Function Compare-VersionNumber {
    <#
        .SYNOPSIS
            Compares two version numbers to determine whether one is greater than the other.

        .DESCRIPTION
            Compares two version numbers to determine whether one is greater than the other.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://github.com/aaronparker/Install-VisualCRedistributables

        .PARAMETER LowVersion
            The lower version number to compare.

        .PARAMETER HighVersion
            The higher version number to compare.
    #>
    [CmdletBinding()]
    [OutputType([Bool])]
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNull()]
        [string] $LowVersion,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateNotNull()]
        [string] $HighVersion,

        [Parameter(Mandatory = $False)]
        [switch] $MatchMinor
    )
    Begin {
        # Convert parameters to version numbers
        $low = New-Object -TypeName System.Version -ArgumentList $LowVersion
        $high = New-Object -TypeName System.Version -ArgumentList $HighVersion
    }
    Process {
        # Compare versions
        If ($MatchMinor) {
            If ($high.Major -eq $low.Major) {
                $result = $high.Minor -gt $low.Minor
            }
            Else {
                # If major version numbers don't match return false
                $result = $False
            }
        }
        Else {
            $result = $high -gt $low
        }
    }
    End {
        # Return result
        Write-Output $result
    }
}
