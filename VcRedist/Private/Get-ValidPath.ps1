Function Get-ValidPath {
    <#
        .SYNOPSIS
            Test a file system path and return correct path string.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .PARAMETER Path
            A directory path that the function will validate and return.
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [System.String] $Path
    )
    
    Process {
        # Resolve the path, trim any trailing backslash and return the string
        try {
            $resolvedPath = Resolve-Path -Path $Path -ErrorAction "SilentlyContinue"
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to resolve: [$Path]."
            Throw $_.Exception.Message
        }
        finally {
            If ($resolvedPath) {
                Write-Output -InputObject ($resolvedPath.Path.TrimEnd("\"))
            }
        }
    }
}
