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
    [OutputType([String])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string] $Path
    )
    
    # Resolve the path, trim any trailing backslash and return the string
    $resolvedPath = Resolve-Path -Path $Path -ErrorAction SilentlyContinue
    If ($resolvedPath) {
        $output = $resolvedPath.Path.TrimEnd("\")
        Write-Output $output
    }
}
