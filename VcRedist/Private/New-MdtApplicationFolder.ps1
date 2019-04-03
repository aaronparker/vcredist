Function New-MdtApplicationFolder {
    <#
        .SYNOPSIS
            Creates a new Application folder in an MDT deployment share.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .PARAMETER Drive
            A PS drive letter mapped to the MDT share.

        .PARAMETER Name
            A folder name to create below the MDT Applications folder.
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([String])]
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $Drive,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [Alias('AppFolder')]
        [string] $Name,

        [Parameter(Mandatory = $False, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string] $Description = "Microsoft Visual C++ Redistributables"
    )

    # Create a sub-folder below Applications to import the Redistributables into
    $target = "$($Drive):\Applications\$($Name)"

    If (Test-Path -Path $target) {
        Write-Verbose "MDT folder exists: $target"
        Write-Output $True
    }
    Else {
        If ($PSCmdlet.ShouldProcess($target, "Create folder")) {
            try {
                # Create -AppFolder below Applications; Splat New-Item parameters
                $newItemParams = @{
                    Path        = "$($Drive):\Applications"
                    Enable      = "True"
                    Name        = $Name
                    Comments    = $Description
                    ItemType    = "Folder"
                    ErrorAction = "SilentlyContinue"
                }
                New-Item @newItemParams
            }
            catch {
                Throw "Failed to create MDT Applications folder: $Name"
                Write-Output $false
                Break
            }
            finally {
                Write-Output $True
            }
        }
    }
}
