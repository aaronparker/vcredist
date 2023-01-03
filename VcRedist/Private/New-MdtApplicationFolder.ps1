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
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.Boolean])]
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
        [System.String] $Description = "Microsoft Visual C++ Redistributables imported with VcRedist https://vcredist.com/"
    )

    # Create a sub-folder below Applications to import the Redistributables into
    $MdtPath = [System.IO.Path]::Combine($Drive, "Applications", $Name)

    if (Test-Path -Path $MdtPath -ErrorAction "SilentlyContinue") {
        Write-Verbose "MDT folder exists: $MdtPath"
        Write-Output -InputObject $true
    }
    else {
        if ($PSCmdlet.ShouldProcess($MdtPath, "Create folder")) {
            try {
                # Create -AppFolder below Applications; Splat New-Item parameters
                $params = @{
                    Path        = $([System.IO.Path]::Combine($Drive, "Applications"))
                    Enable      = "True"
                    Name        = $Name
                    Comments    = $Description
                    ItemType    = "Folder"
                    ErrorAction = "Continue"
                }
                New-Item @params | Out-Null
            }
            catch [System.Exception] {
                throw $_
            }
            Write-Output -InputObject $true
        }
    }
}
