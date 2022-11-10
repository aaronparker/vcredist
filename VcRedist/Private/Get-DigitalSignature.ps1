function Get-DigitalSignature {
    <#
        .SYNOPSIS
            Get digital signatures from files in a target folder.

        .DESCRIPTION
            Gets digital signatures from .exe and .dll files from a specified path and sub-folders.
            Retreives the certificate thumbprint, certificate name, certificate expiry, certificate validity and file path and outputs the results.
            Output includes files that are not signed.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://github.com/Insentra/ApplicationControl

        .OUTPUTS
            [System.Array]

        .PARAMETER Path
            A target path in which to scan files for digital signatures.

        .PARAMETER Include
            Gets only the specified items.

        .PARAMETER Unique
            By default the script will return all files and their certificate details. Use -Unique to return the first listing for each unique certificate.

        .EXAMPLE
            Get-AcDigitalSignatures -Path "C:\Users\aaron\AppData\Local\GitHubDesktop"

            Description:
            Scans the folder specified in the Path variable and returns the digital signatures for each file.

        .EXAMPLE
            Get-DigitalSignatures -Path "C:\Users\aaron\AppData\Local\GitHubDesktop" -Unique

            Description:
            Scans the folder specified in the Path variable and returns the digital signatures for only the first file with a unique certificate.
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    [OutputType([Array])]
    param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, `
                HelpMessage = 'Specify a target path in which to scan files for digital signatures.')]
        [Alias('FullName', 'PSPath')]
        [System.String[]] $Path,

        [Parameter(Mandatory = $False, Position = 1, ValueFromPipeline = $False, `
                HelpMessage = 'Gets only the specified items.')]
        [Alias('Filter')]
        [System.String[]] $Include = @('*.exe', '*.dll', '*.ocx', '*.msi', '*.ps1', '*.vbs', '*.js'),

        [Parameter(ParameterSetName = 'Base', Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Unique
    )
    begin {
        # Initialise $Signatures as an array
        $Signatures = @()
    }
    process {
        # For each path in $Path, check that the path exists
        foreach ($Loc in $Path) {
            if (Test-Path -Path $Loc -IsValid -ErrorAction "SilentlyContinue") {

                # Get the item to determine whether it's a file or folder
                if ((Get-Item -Path $Loc -Force).PSIsContainer) {

                    # Target is a folder, so trawl the folder for .exe and .dll files in the target and sub-folders
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Scanning files in folder: $Loc"
                    $items = Get-ChildItem -Path $Loc -Recurse -File -Include $Include
                }
                else {

                    # Target is a file, so just get metadata for the file
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Scanning file: $Loc"
                    $items = Get-Item -Path $Loc
                }

                # Get Exe and Dll files from the target path (inc. subfolders), find signatures and return certain properties in a grid view
                Write-Verbose -Message "$($MyInvocation.MyCommand): Getting digital signatures for: $Loc"
                $Signatures += $items | Get-AuthenticodeSignature | `
                    Select-Object @{Name = "Thumbprint"; Expression = { $_.SignerCertificate.Thumbprint } }, `
                @{Name = "Subject"; Expression = { $_.SignerCertificate.Subject } }, `
                @{Name = "Expiry"; Expression = { $_.SignerCertificate.NotAfter } }, `
                    Status, `
                    Path
            }
            else {
                Write-Error "Path does not exist: $Loc"
            }
        }
    }
    end {
        # If -Unique is specified, filter the signatures list and return the first item of each unique certificate
        # If -Export is specified, we also only want unique certificate files
        if ($Export -or $Unique) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Filtering for unique signatures."
            $Signatures = $Signatures | Where-Object { $_.Status -eq "Valid" -or $_.Status -eq "UnknownError" } | `
                Group-Object -Property Thumbprint | `
                ForEach-Object { $_.Group | Select-Object -First 1 }
            Write-Verbose -Message "$($MyInvocation.MyCommand): $($Signatures.Count) unique signature/s found in $Path"
        }

        # Return output
        Write-Verbose -Message "$($MyInvocation.MyCommand): Digital signature trawling complete."
        Write-Object -InputObject $Signatures
    }
}
