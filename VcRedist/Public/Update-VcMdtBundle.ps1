Function Update-VcMdtBundle {
    <#
        .SYNOPSIS
            Creates Visual C++ Redistributable applications in a Microsoft Deployment Toolkit share.

        .DESCRIPTION
            Creates an application in a Microsoft Deployment Toolkit share for each Visual C++ Redistributable and includes properties such as target Silent command line, Platform and Uninstall key.

            Use Get-VcList and Get-VcRedist to download the Redistributables and create the array for importing into MDT.

        .OUTPUTS
            System.Array

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://docs.stealthpuppy.com/docs/vcredist/usage/importing-into-mdt

        .PARAMETER MdtPath
            The local or network path to the MDT deployment share.

        .PARAMETER AppFolder
            Import the Visual C++ Redistributables into a sub-folder. Defaults to "VcRedists".

        .EXAMPLE
            Get-VcList | Save-VcRedist -Path C:\Temp\VcRedist | Import-VcMdtApp -Path C:\Temp\VcRedist -MdtPath \\server\deployment

            Description:
            Retrieves the list of Visual C++ Redistributables, downloads them to C:\Temp\VcRedist and imports each Redistributable into the MDT deployment share at \\server\deployment.

        .EXAMPLE
            $VcList = Get-VcList -ExportAll
            Save-VcRedist -VcList $VcList -Path C:\Temp\VcRedist
            Import-VcMdtApp -VcList $VcList -Path C:\Temp\VcRedist -MdtPath \\server\deployment -Bundle

            Description:
            Retrieves the list of supported and unsupported Visual C++ Redistributables in the variable $VcList, downloads them to C:\Temp\VcRedist, imports each Redistributable into the MDT deployment share at \\server\deployment and creates an application bundle.
    #>
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://docs.stealthpuppy.com/docs/vcredist/usage/importing-into-mdt")]
    [OutputType([System.Management.Automation.PSObject])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [System.String] $MdtPath,

        [Parameter(Mandatory = $False)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [ValidateNotNullOrEmpty()]
        [System.String] $AppFolder = "VcRedists",

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [System.String] $MdtDrive = "DS001",

        [Parameter(Mandatory = $False, Position = 2)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [System.String] $Publisher = "Microsoft",

        [Parameter(Mandatory = $False, Position = 3)]
        [ValidatePattern('^[a-zA-Z0-9\+ ]+$')]
        [System.String] $BundleName = "Visual C++ Redistributables",

        [Parameter(Mandatory = $False, Position = 4)]
        [ValidatePattern('^[a-zA-Z0-9-]+$')]
        [System.String] $Language = "en-US"
    )

    # If running on PowerShell Core, error and exit.
    If (Test-PSCore) {
        Write-Warning -Message "$($MyInvocation.MyCommand): PowerShell Core doesn't support PSSnapins. We can't load the MicrosoftDeploymentToolkit module."
        Throw [System.Management.Automation.InvalidPowerShellStateException]
        Exit
    }

    # Import the MDT module and create a PS drive to MdtPath
    If (Import-MdtModule) {
        If ($pscmdlet.ShouldProcess($Path, "Mapping")) {
            try {
                New-MdtDrive -Drive $MdtDrive -Path $MdtPath -ErrorAction SilentlyContinue | Out-Null
                Restore-MDTPersistentDrive -Force | Out-Null
            }
            catch [System.Exception] {
                Write-Warning -Message "$($MyInvocation.MyCommand): Failed to map drive to [$MdtPath]."
                Throw $_.Exception.Message
                Exit
            }
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to import the MDT PowerShell module. Please install the MDT Workbench and try again."
        Throw [System.Management.Automation.InvalidPowerShellStateException]
        Exit
    }

    $target = "$($MdtDrive):\Applications\$AppFolder"
    Write-Verbose -Message "$($MyInvocation.MyCommand): Update applications in: $target"

    If (Test-Path -Path $target -ErrorAction SilentlyContinue) {

        # Get properties from the existing bundle
        try {
            $gciParams = @{
                Path        = "$target\$($Publisher) $($BundleName)"
                ErrorAction = "SilentlyContinue"
            }
            $bundle = Get-ChildItem @gciParams
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to retreive the existing Visual C++ Redistributables bundle."
            Throw $_.Exception.Message
            Exit
        }

        # Grab the Visual C++ Redistributable application guids; Sort added VcRedists by version so they are ordered correctly
        $existingVcRedists = Get-ChildItem -Path $target | Where-Object { ($_.Name -like "*Visual C++*") -and ($_.guid -ne $bundle.guid) }
        $existingVcRedists = $existingVcRedists | Sort-Object -Property Version
        $dependencies = @(); ForEach ($app in $existingVcRedists) { $dependencies += $app.guid }

        If ($Null -ne $bundle) {
            If ($PSCmdlet.ShouldProcess($bundle.PSPath, "Update dependencies")) {
                try {
                    $sipParams = @{
                        Path        = "$target\$($Publisher) $($BundleName)"
                        Name        = "Dependency"
                        Value       = $dependencies
                        ErrorAction = "SilentlyContinue"
                    }
                    Set-ItemProperty @sipParams | Out-Null
                }
                catch [System.Exception] {
                    Write-Warning -Message "$($MyInvocation.MyCommand): Error updating VcRedist bundle dependencies."
                    Throw $_.Exception.Message
                    Continue
                }
                try {
                    $sipParams = @{
                        Path        = "$target\$($Publisher) $($BundleName)"
                        Name        = "Version"
                        Value       = (Get-Date -format "yyyy-MMM-dd")
                        ErrorAction = "SilentlyContinue"
                    }
                    Set-ItemProperty @sipParams | Out-Null
                }
                catch [System.Exception] {
                    Write-Warning -Message "$($MyInvocation.MyCommand): Error updating VcRedist bundle version."
                    Throw $_.Exception.Message
                    Continue
                }
            }
        }
    }
    Else {
        Write-Error -Message "$($MyInvocation.MyCommand): Failed to find path: [$target]."
    }

    If (Test-Path -Path $target -ErrorAction SilentlyContinue) {
        # Return list of apps to the pipeline
        Write-Output -InputObject (Get-ChildItem -Path "$target\$($Publisher) $($BundleName)" | Select-Object -Property * )
    }
    Else {
        Write-Error -Message "$($MyInvocation.MyCommand): Failed to find path: [$target]."
    }
}
