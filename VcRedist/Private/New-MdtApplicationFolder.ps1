function New-MdtApplicationFolder {
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
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Drive,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [Alias('AppFolder')]
        [System.String] $Name,

        [Parameter(Mandatory = $False, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Description = "Microsoft Visual C++ Redistributables"
    )

    # Create a sub-folder below Applications to import the Redistributables into
    $target = "$($Drive):\Applications\$($Name)"

    if (Test-Path -Path $target -ErrorAction "SilentlyContinue") {
        Write-Verbose "$($MyInvocation.MyCommand): MDT folder exists: $target"
        Write-Output -InputObject $True
    }
    else {
        if ($PSCmdlet.ShouldProcess($target, "Create folder")) {
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
            catch [System.Exception] {
                Write-Warning -Message "$($MyInvocation.MyCommand): Failed to create MDT Applications folder: $Name"
                throw $_.Exception.Message
            }
            finally {
                Write-Output -InputObject $True
            }
        }
    }
}
