Function Compare-VersionNumber {
    <#
        .SYNOPSIS
            Compares two version numbers to determine whether one is greater than the other.

        .DESCRIPTION
            Compares two version numbers to determine whether one is greater than the other.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .PARAMETER LowVersion
            The lower version number to compare.

        .PARAMETER HighVersion
            The higher version number to compare.
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNull()]
        [System.String] $LowVersion,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateNotNull()]
        [System.String] $HighVersion,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $MatchMinor
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
        Write-Output -InputObject $result
    }
}
