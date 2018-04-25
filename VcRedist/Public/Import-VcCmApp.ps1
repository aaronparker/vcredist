Function Import-VcCmApp {
    <#
    .SYNOPSIS
        Creates Visual C++ Redistributable applications in a ConfigMgr site.

    .DESCRIPTION
        Creates an application in a Configuration Manager site for each Visual C++ Redistributable and includes setting whether the Redistributable can run on 32-bit or 64-bit Windows and the Uninstall key for detecting whether the Redistributable is installed.

        Use Get-VcList and Get-VcRedist to download the Redistributable and create the array of Redistributables for importing into ConfigMgr.

    .OUTPUTS
         System.Array
    
    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        https://github.com/aaronparker/Install-VisualCRedistributables

    .PARAMETER VcList
        An array containing details of the Visual C++ Redistributables from Get-VcList.

    .PARAMETER Path
        A folder containing the downloaded Visual C++ Redistributables.

    .PARAMETER CMPath
        Specify a UNC path where the Visual C++ Redistributables will be distributed from

    .PARAMETER SMSSiteCode
        Specify the Site Code for ConfigMgr app creation.

    .PARAMETER AppFolder
        Import the Visual C++ Redistributables into a sub-folder. Defaults to "VcRedists".

    .PARAMETER Release
        Specifies the release (or version) of the redistributables to download or install.

    .PARAMETER Architecture
        Specifies the processor architecture to download or install.

    .EXAMPLE
        $VcList = Get-VcList | Get-VcRedist -Path "C:\Temp\VcRedist"
        Import-VcCmApp -VcList $VcList -Path "C:\Temp\VcRedist" -CMPath "\\server\share\VcRedist" -SMSSiteCode LAB

        Description:
        Download the supportee Visual C++ Redistributables to "C:\Temp\VcRedist", copy them to "\\server\share\VcRedist" and import as applications into the ConfigMgr site LAB.
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([Array])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $False, `
                HelpMessage = "An array containing details of the Visual C++ Redistributables from Get-VcList.")]
        [ValidateNotNull()]
        [array] $VcList,

        [Parameter(Mandatory = $True, Position = 1, HelpMessage = "A folder containing the downloaded Visual C++ Redistributables.")]
        [ValidateScript( {If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string] $Path,

        [Parameter(Mandatory = $True, HelpMessage = "Specify a distribution UNC path to copy the Redistributables to.")]
        [string] $CMPath,

        [Parameter(Mandatory = $True, HelpMessage = "Specify ConfigMgr Site Code.")]
        [ValidateScript( { If ($_ -match "^[a-zA-Z0-9]{3}$") { $True } Else { Throw "$_ is not a valid ConfigMgr site code." } })]
        [string] $SMSSiteCode,

        [Parameter(Mandatory = $False, HelpMessage = "Specify Applications folder to import the VC Redistributables into.")]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [string] $AppFolder = "VcRedists",

        [Parameter(Mandatory = $False, HelpMessage = "Specify the version of the Redistributables to install.")]
        [ValidateSet('2005', '2008', '2010', '2012', '2013', '2015', '2017')]
        [string[]] $Release = @("2008", "2010", "2012", "2013", "2015", "2017"),

        [Parameter(Mandatory = $False, HelpMessage = "Specify the processor architecture/s to install.")]
        [ValidateSet('x86', 'x64')]
        [string[]] $Architecture = @("x86", "x64"),

        [Parameter()] $Publisher = "Microsoft",
        [Parameter()] $Language = "en-US",
        [Parameter()] $Keyword = "Visual C++ Redistributable"
    )
    Begin {        
        # CMPath will be the network location for copying the Visual C++ Redistributables to
        Set-Location -Path $Path
        If ( !([bool]([System.Uri]$CMPath).IsUnc) ) { Throw "$CMPath must be a valid UNC path." }
        If ( Test-Path $CMPath ) {
            # Copy VcRedists to the network location. Use robocopy for robustness
            If ($PSCmdlet.ShouldProcess("$($Path) to $($CMPath)", "Copy")) {
                Robocopy.exe *.exe $Path $CMPath /S /XJ /R:1 /W:1 /NP /NJH /NJS /NFL /NDL
            }
        }
        Else {
            Write-Warning "Unable to confirm $CMPath exists. Please check that $CMPath is valid."
        }
        
        # If the ConfigMgr console is installed, load the PowerShell module; Requires PowerShell module to be installed
        If ( Test-Path $env:SMS_ADMIN_UI_PATH ) {
            Try {            
                # Import the ConfigurationManager.psd1 module
                Import-Module "$($env:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" | Out-Null
            }
            Catch {
                Throw "Could not load ConfigMgr Module. Please make sure that the ConfigMgr Console is installed."
                Break
            }
        }
        Else {
            Throw "Cannot find environment variable SMS_ADMIN_UI_PATH. Is the ConfigMgr Console and PowerShell module installed?"
            Break
        }

        # Create the folder for importing the Redistributables into
        If ( $AppFolder ) {
            If ($PSCmdlet.ShouldProcess("$($SMSSiteCode):\Application\$($AppFolder)", "Creating")) {
                New-Item -Path "$($SMSSiteCode):\Application\$($AppFolder)" -ErrorAction SilentlyContinue
            }
        }
        If ( Test-Path "$($SMSSiteCode):\Application\$($AppFolder)" ) {
            Write-Verbose "Importing into: $($SMSSiteCode):\Application\$($AppFolder)"
            $DestFolder = "$($SMSSiteCode):\Application\$($AppFolder)"
        }
        Else {
            Write-Verbose "Importing into: $($SMSSiteCode):\Application"
            $DestFolder = "$($SMSSiteCode):\Application"
        }

        # Output variable
        $Output = @()
    }
    Process {
        # Filter release and architecture if specified
        If ( $PSBoundParameters.ContainsKey('Release') ) {
            Write-Verbose "Filtering releases for platform."
            $VcList = $VcList | Where-Object { $_.Release -eq $Release }
        }
        If ( $PSBoundParameters.ContainsKey('Architecture') ) {
            Write-Verbose "Filtering releases for architecture."
            $VcList = $VcList | Where-Object { $_.Architecture -eq $Architecture }
        }

        ForEach ( $Vc in $VcList ) {
            Write-Verbose "Importing app: [$($Vc.Name)][$($Vc.Release)][$($Vc.Architecture)]"

            # Import as an application into ConfigMgr
            If ($PSCmdlet.ShouldProcess("$($Vc.Name) in $CMPath", "Import ConfigMgr app")) {

                # Configure parameters and change to the SMS Site drive
                Write-Verbose "Setting location to $($Path)"
                Set-Location -Path $Path
                $Target = "$($(Get-Item -Path $CMPath).FullName)\$($Vc.Release)\$($Vc.Architecture)\$($Vc.ShortName)"
                $Filename = Split-Path -Path $Vc.Download -Leaf
                
                # Change to the SMS Application folder before importing the applications
                Write-Verbose "Setting location to $($DestFolder)"
                Set-Location $DestFolder -ErrorVariable ConnectionError

                # Create the ConfigMgr application with properties from the XML file
                If ( (Get-Item -Path $DestFolder).PSDrive.Name -eq $SMSSiteCode ) {
                    If ( $pscmdlet.ShouldProcess($Vc.Name + " $($Vc.Architecture)", "Creating ConfigMgr application") ) {
                        $App = New-CMApplication -Name "$($Vc.Name) $($Vc.Architecture)" `
                            -Description "$($Publisher) $($Vc.Name) $($Vc.Architecture) imported by $($MyInvocation.MyCommand)" `
                            -SoftwareVersion "$($Vc.Release) $($Vc.Architecture)" `
                            -LinkText $Vc.URL `
                            -Publisher $Publisher `
                            -Keyword $Keyword `
                            -ErrorVariable CMAppError
                        $Output += $App
                        $App | Move-CMObject -FolderPath $DestFolder -ErrorAction SilentlyContinue | Out-Null
                    }

                    # Add a deployment type to the application
                    If ( $pscmdlet.ShouldProcess($Vc.Name + " $($Vc.Architecture)", "Adding deployment type") ) {
                        $App | Add-CMScriptDeploymentType `
                            -InstallCommand "$Filename $($Vc.Install)" `
                            -ContentLocation $Target `
                            -ProductCode $Vc.ProductCode `
                            -SourceUpdateProductCode $Vc.ProductCode `
                            -DeploymentTypeName ("SCRIPT_" + $Vc.Name) `
                            -UserInteractionMode Hidden `
                            -UninstallCommand "msiexec /x $($Vc.ProductCode) /qn-" `
                            -LogonRequirementType WhetherOrNotUserLoggedOn `
                            -InstallationBehaviorType InstallForSystem `
                            -Comment "Generated by $($MyInvocation.MyCommand)" `
                            -ErrorVariable CMDtError | Out-Null
                    }
                }
                Else {
                    Write-Error "Unable to change to ConfigMgr drive location $($DestFolder). Cannot import VcRedist."
                }
            }
        }
    }
    End {
        Set-Location -Path $Path

        # Output array of applications created in ConfigMgr
        Write-Output $Output
    }
}
