Function Import-VcMdtApp {
    <#
    .SYNOPSIS
        Creates Visual C++ Redistributable applications in a Microsoft Deployment Toolkit share.

    .DESCRIPTION
        Creates an application in a Microsoft Deployment Toolkit share for each Visual C++ Redistributable and includes setting `
        whether the Redistributable can run on 32-bit or 64-bit Windows and the Uninstall key for detecting whether the Redistributable is installed.

        Use Get-VcList and Get-VcRedist to download the Redistributable and create the array of Redistributables for importing into MDT.

    .NOTES
        Name: Import-VcMdtApp
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        https://stealthpuppy.com

    .PARAMETER VcList
        An array containing details of the Visual C++ Redistributables from Get-VcList.

    .PARAMETER Path
        A folder containing the downloaded Visual C++ Redistributables.

    .PARAMETER Release
        Specifies the release (or version) of the redistributables to download or install.

    .PARAMETER Architecture
        Specifies the processor architecture to download or install.

    .Parameter MDTShare
        The local or network path to the Microsoft Deployment Toolkit share.        

    .EXAMPLE
        Get-VcList | Get-VcRedist -Path C:\Temp\VcRedist | Import-VcMdtApp -MDTShare \\server\deployment

        Description:
        Retrieves the list of Visual C++ Redistributables, downloaded them C:\Temp\VcRedist and imports each Redistributable into the MDT dpeloyment share at \\server\deployment.
    #>
    # Parameter sets here means that Install, MDT and ConfigMgr actions are mutually exclusive
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $False, `
                HelpMessage = "An array containing details of the Visual C++ Redistributables from Get-VcList.")]
        [ValidateNotNull()]
        [array]$VcList,

        [Parameter(Mandatory = $True, Position = 1, HelpMessage = "A folder containing the downloaded Visual C++ Redistributables.")]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string]$Path,

        [Parameter(Mandatory = $False, HelpMessage = "Specify the version of the Redistributables to install.")]
        [ValidateSet('2005', '2008', '2010', '2012', '2013', '2015', '2017')]
        [string[]]$Release = @("2008", "2010", "2012", "2013", "2015", "2017"),

        [Parameter(Mandatory = $False, HelpMessage = "Specify the processor architecture/s to install.")]
        [ValidateSet('x86', 'x64')]
        [string[]]$Architecture = @("x86", "x64"),

        [Parameter(ParameterSetName = 'MDT', Mandatory = $True, HelpMessage = "The path to the MDT deployment share.")]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string]$MdtPath,

        [Parameter()]$MdtDrive = "DS001",
        [Parameter()]$Publisher = "Microsoft",
        [Parameter()]$Language = "en-US"
    )
    Begin {
        # If we can find the MDT PowerShell module, import it. Requires MDT console to be installed
        $mdtModule = "$((Get-ItemProperty "HKLM:SOFTWARE\Microsoft\Deployment 4" -ErrorAction SilentlyContinue).Install_Dir)bin\MicrosoftDeploymentToolkit.psd1"
        If (Test-Path -Path $mdtModule) {
            Try {            
                Import-Module -Name $mdtModule -ErrorAction SilentlyContinue
            }
            Catch {
                Throw "Could not load MDT PowerShell Module. Please make sure that the MDT console is installed correctly."
            }
        }
        Else {
            Throw "Cannot find the MDT PowerShell module. Is the MDT console installed?"
        }

        # Create the PSDrive for MDT
        If ($PSCmdlet.ShouldProcess("MDT deployment share $MDTPath", "Mapping")) {
            If (Test-Path -Path "$($MdtDrive):") {
                Write-Verbose "Found existing MDT drive $MdtDrive. Removing."
                Remove-PSDrive -Name $MdtDrive -Force
            }
            New-PSDrive -Name $MdtDrive -PSProvider MDTProvider -Root $MDTPath -ErrorAction SilentlyContinue
            If (!(Test-Path -Path "$($MdtDrive):")) {
                Throw "Failed to map MDT drive: $MdtDrive"
            }
        }
    }
    Process {
        # Filter release and architecture if specified
        If ($PSBoundParameters.ContainsKey('Release')) {
            Write-Verbose "Filtering releases for platform."
            $VcList = $VcList | Where-Object { $_.Release -eq $Release }
        }
        If ($PSBoundParameters.ContainsKey('Architecture')) {
            Write-Verbose "Filtering releases for architecture."
            $VcList = $VcList | Where-Object { $_.Architecture -eq $Architecture }
        }

        ForEach ($Vc in $VcList) {
            Write-Verbose "Importing app: [$($Vc.Name)][$($Vc.Release)][$($Vc.Architecture)]"

            # Import as an application into MDT
            If ($PSCmdlet.ShouldProcess("$($Vc.Name) in $MDTPath", "Import MDT app")) {

                # Configure parameters
                $Target = "$($(Get-Item -Path $Path).FullName)\$($Vc.Release)\$($Vc.Architecture)\$($Vc.ShortName)"
                $Filename = Split-Path -Path $Vc.Download -Leaf
                $Dir = "$Publisher VcRedist\$($Vc.Release) $($Vc.ShortName) $($Vc.Architecture)"
                $SupportedPlatform = If ($Vc.Architecture -eq "x86") { "All x86 Windows 7 and Newer" } `
                    Else { @("All x64 Windows 7 and Newer", "All x86 Windows 7 and Newer") }

                Import-MDTApplication -Path "$($MdtDrive):\Applications" `
                    -Name "$Publisher $($Vc.Name) $($Vc.Architecture)" `
                    -Enable $True `
                    -Reboot $False `
                    -Hide $False `
                    -Comments "" `
                    -ShortName "$($Vc.Name) $($Vc.Architecture)" `
                    -Version $Vc.Release `
                    -Publisher $Publisher `
                    -Language $Language `
                    -CommandLine ".\$FileName $($Vc.Install)" `
                    -WorkingDirectory ".\Applications\$Dir" `
                    -ApplicationSourcePath $Target `
                    -DestinationFolder $Dir `
                    -UninstallKey $Vc.ProductCode `
                    -SupportedPlatform $SupportedPlatform `
                    -Dependency ""
            }
        }
    }
    End {
        # Get the imported Visual C++ Redistributables applications to return on the pipeline
        $Output = Get-ChildItem -Path "$($MdtDrive):\Applications" | Where-Object { $_.Name -like "*Visual C++*" }
        $Output
    }
}