function Test-PSCore {
    <#
        .SYNOPSIS
            Returns True is running on PowerShell Core.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .PARAMETER Version
            The version of PowerShell Core. Optionally specified where value needs to be something other than 6.0.0.
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Position = 0)]
        [System.String] $Version = "6.0.0"
    )

    # Check whether current PowerShell environment matches or is higher than $Version
    if (($PSVersionTable.PSVersion -ge [System.Version]::Parse($Version)) -and ($PSVersionTable.PSEdition -eq "Core")) {
        Write-Output -InputObject $true
    }
    else {
        Write-Output -InputObject $false
    }
}
