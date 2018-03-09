Function New-VcMdtApp {
    <#
    .SYNOPSIS
        

    .DESCRIPTION


    .NOTES
        Name: New-VcMdtApp
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        https://stealthpuppy.com

    .PARAMETER VcList
        The XML file that contains the details about the Visual C++ Redistributables. This must be in the expected format.


    .PARAMETER Path
        Specify a target folder to download the Redistributables to, otherwise use the current folder.


    .PARAMETER Release
        Specifies the release (or version) of the redistributables to download or install.


    .PARAMETER Architecture
        Specifies the processor architecture to download or install.


    .Parameter MDTShare
        

    .EXAMPLE
        

        Description:

    #>
    # Parameter sets here means that Install, MDT and ConfigMgr actions are mutually exclusive
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $False, `
                HelpMessage = "An array containing details of the Visual C++ Redistributables from Get-VcList.")]
        [ValidateNotNull()]
        [string]$VcList,

        [Parameter(Mandatory = $True, HelpMessage = "A folder containing the downloaded Visual C++ Redistributables.")]
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
        [string]$MDTPath
    )
    Begin {
        $MdtDrive = "DS001"
        $Publisher = "Microsoft"

        # If we can find the MDT PowerShell module, import it. Requires MDT console to be installed
        $mdtModule = "$((Get-ItemProperty "HKLM:SOFTWARE\Microsoft\Deployment 4").Install_Dir)bin\MicrosoftDeploymentToolkit.psd1"
        If (Test-Path -Path $mdtModule) {
            Try {            
                Import-Module -Name $mdtModule
            }
            Catch {
                Throw "Could not load MDT PowerShell Module. Please make sure that the MDT console is installed correctly."
            }
        }
        Else {
            Throw "Cannot find the MDT PowerShell module. Is the MDT console installed?"
        }

        # Create the PSDrive for MDT
        If ($pscmdlet.ShouldProcess("MDT deployment share $MDTPath", "Mapping")) {
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

            Write-Verbose "Installing: [$($Vc.Name)][$($Vc.Release)][$($Vc.Architecture)]"
            $Target = "$($(Get-Item -Path $Path).FullName)\$($Vc.Release)\$($Vc.Architecture)\$($Vc.ShortName)"
            $Filename = Split-Path -Path $Vc.Download -Leaf -PathType Leaf

            # Import as an application into MDT
            If ($pscmdlet.ShouldProcess("$($Vc.Name) in $MDTPath", "Import MDT app")) {
                Import-MDTApplication -Path "$($MdtDrive):\Applications" -enable "True" `
                    -Name "$Publisher $Vc.Name $Vc.Release" `
                    -ShortName $Vc.Name `
                    -Version $Vc.Release -Publisher $Publisher -Language "en-US" `
                    -CommandLine $(".\$FileName $Vc.Install") `
                    -WorkingDirectory ".\Applications\$Publisher $ShortName" `
                    -ApplicationSourcePath $Target
                -DestinationFolder "$Publisher VcRedist\$($Vc.Release) $($Vc.ShortName) $($Vc.Architecture)"
            }

            If ($pscmdlet.ShouldProcess("$($Vc.Name) in $MDTPath", "Set properties")) {
                Get-Item -Path "$($MdtDrive):\Applications\$Publisher $Vc.Name $Vc.Release" | Set-ItemProperty -Name UninstallKey -Value $Vc.ProductCode
            
                $Platforms = Get-ItemProperty -Path "Microsoft Visual C++ Redistributables" -Name SupportedPlatform
                $Platforms.SupportedPlatform = "All x86 Windows 7 and Newer"
                Set-ItemProperty -Path "Microsoft Visual C++ Redistributables" -Name SupportedPlatform -Value $Platforms
            }
        }
    }
    End {

    }
}