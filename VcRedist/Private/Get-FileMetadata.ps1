Function Get-FileMetadata {
    <#
        .SYNOPSIS
            Get file metadata from files in a target folder.
        
        .DESCRIPTION
            Retreives file metadata from files in a target path, or file paths, to display information on the target files.
            Useful for understanding application files and identifying metadata stored in them. Enables the administrator to view metadata for application control scenarios.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .OUTPUTS
            [System.Array]

        .PARAMETER Path
            A target path in which to scan files for metadata.

        .PARAMETER Include
            Gets only the specified items.

        .EXAMPLE
            Get-FileMetadata -Path "C:\Users\aaron\AppData\Local\GitHubDesktop"

            Description:
            Scans the folder specified in the Path variable and returns the metadata for each file.
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    [OutputType([Array])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, `
                HelpMessage = 'Specify a target path, paths or a list of files to scan for metadata.')]
        [ValidateNotNull()]
        [Alias('FullName', 'PSPath')]
        [System.String[]] $Path,

        [Parameter(Mandatory = $False, Position = 1, HelpMessage = 'Gets only the specified items.')]
        [Alias('Filter')]
        [System.String[]] $Include = @('*.exe', '*.dll', '*.ocx', '*.msi', '*.ps1', '*.vbs', '*.js', '*.cmd', '*.bat')
    )
    Begin {

        # RegEx to grab CN from certificates
        $FindCN = "(?:.*CN=)(.*?)(?:,\ O.*)"
        Write-Verbose -Message "$($MyInvocation.MyCommand): Beginning metadata trawling."
    }
    Process {

        # For each path in $Path, check that the path exists
        ForEach ($folder in $Path) {

            If (Test-Path -Path $folder -IsValid) {

                # Get the item to determine whether it's a file or folder
                If ((Get-Item -Path $folder).PSIsContainer) {

                    # Target is a folder, so trawl the folder for .exe and .dll files in the target and sub-folders
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Getting metadata for files in folder: [$folder]."
                    try {
                        $items = Get-ChildItem -Path $folder -Recurse -Include $Include -ErrorAction SilentlyContinue
                    }
                    catch [System.Exception] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to retrieve files in: [$folder]."
                        Throw $_.Exception.Message
                        Continue
                    }
                }
                Else {
                    # Target is a file, so just get metadata for the file
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Getting metadata for file: [$folder]."
                    try {
                        $items = Get-Item -Path $folder -ErrorAction SilentlyContinue
                    }
                    catch [System.Exception] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to retrieve files in: [$folder]."
                        Throw $_.Exception.Message
                        Continue
                    }
                }

                # Create an array from what was returned for specific data and sort on file path
                $Files = $items | Select-Object @{Name = "Path"; Expression = { $_.FullName } }, `
                @{Name = "Owner"; Expression = { (Get-Acl -Path $_.FullName).Owner } }, `
                @{Name = "Vendor"; Expression = { $(((Get-DigitalSignature -Path $_ -ErrorAction SilentlyContinue).Subject -replace $FindCN, '$1') -replace '"', "") } }, `
                @{Name = "Company"; Expression = { $_.VersionInfo.CompanyName } }, `
                @{Name = "Description"; Expression = { $_.VersionInfo.FileDescription } }, `
                @{Name = "Product"; Expression = { $_.VersionInfo.ProductName } }, `
                @{Name = "ProductVersion"; Expression = { $_.VersionInfo.ProductVersion } }, `
                @{Name = "FileVersion"; Expression = { $_.VersionInfo.FileVersion } }

                If ($Files) {
                    Write-Output -InputObject $Files
                }
            }
            Else {
                Write-Warning -Message "$($MyInvocation.MyCommand): Path does not exist: $folder"
            }
        }
    }
    End {
        # Return the array of file paths and metadata
        $StopWatch.Stop()
        Write-Verbose "$($MyInvocation.MyCommand): Metadata trawling complete."
    }
}
