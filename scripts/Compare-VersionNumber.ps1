function Compare-VersionNumber {
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
    [CmdletBinding(SupportsShouldProcess = $false)]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [System.String] $LowVersion,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [System.String] $HighVersion,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $MatchMinor
    )
    begin {
        # Convert parameters to version numbers
        $low = New-Object -TypeName "System.Version" -ArgumentList $LowVersion
        $high = New-Object -TypeName "System.Version" -ArgumentList $HighVersion
    }

    process {
        # Compare versions
        if ($MatchMinor) {
            if ($high.Major -eq $low.Major) {
                $result = $high.Minor -gt $low.Minor
            }
            else {
                # If major version numbers don't match return false
                $result = $false
            }
        }
        else {
            $result = $high -gt $low
        }
    }

    end {
        # Return result
        Write-Output -InputObject $result
    }
}
