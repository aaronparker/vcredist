Function Import-VcConfigMgrApp {
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
            https://docs.stealthpuppy.com/vcredist/usage/importing-into-configmgr

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

        .PARAMETER Silent
            Add a completely silent command line install of the VcRedist with no UI. The default install is passive.

        .EXAMPLE
            $VcList = Get-VcList
            Save-VcRedist -VcList $VcList -Path "C:\Temp\VcRedist"
            Import-VcConfigMgrApp -VcList $VcList -Path "C:\Temp\VcRedist" -CMPath "\\server\share\VcRedist" -SMSSiteCode LAB

            Description:
            Download the supported Visual C++ Redistributables to "C:\Temp\VcRedist", copy them to "\\server\share\VcRedist" and import as applications into the ConfigMgr site LAB.
    #>
    [Alias('Import-VcCmApp')]
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI="https://docs.stealthpuppy.com/vcredist/usage/importing-into-configmgr")]
    [OutputType([Array])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [PSCustomObject] $VcList,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateScript( {If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string] $Path,

        [Parameter(Mandatory = $True)]
        [string] $CMPath,

        [Parameter(Mandatory = $True)]
        [ValidateScript( { If ($_ -match "^[a-zA-Z0-9]{3}$") { $True } Else { Throw "$_ is not a valid ConfigMgr site code." } })]
        [string] $SMSSiteCode,

        [Parameter(Mandatory = $False)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [string] $AppFolder = "VcRedists",

        [Parameter(Mandatory = $False)]
        [switch] $Silent,

        [Parameter()] $Publisher = "Microsoft",
        [Parameter()] $Language = "en-US",
        [Parameter()] $Keyword = "Visual C++ Redistributable"
    )

    Begin {
        # CMPath will be the network location for copying the Visual C++ Redistributables to
        $validPath = Get-ValidPath $Path
        Write-Verbose "Setting location to $validPath"
        Set-Location -Path $validPath

        If (!([bool]([System.Uri]$CMPath).IsUnc)) { Throw "$CMPath must be a valid UNC path." }
        
        If (Test-Path $CMPath) {
            # Copy VcRedists to the network location. Use robocopy for robustness
            If ($PSCmdlet.ShouldProcess("$($validPath) to $($CMPath)", "Copy")) {
                Robocopy.exe *.exe $validPath $CMPath /S /XJ /R:1 /W:1 /NP /NJH /NJS /NFL /NDL
            }
        }
        Else {
            Write-Warning "Unable to confirm $CMPath exists. Please check that $CMPath is valid."
        }
        
        # If the ConfigMgr console is installed, load the PowerShell module; Requires PowerShell module to be installed
        If (Test-Path $env:SMS_ADMIN_UI_PATH) {
            try {            
                # Import the ConfigurationManager.psd1 module
                Import-Module "$($env:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" | Out-Null
            }
            catch {
                Throw "Could not load ConfigMgr Module. Please make sure that the ConfigMgr Console is installed."
                Break
            }
        }
        Else {
            Throw "Cannot find environment variable SMS_ADMIN_UI_PATH. Is the ConfigMgr Console and PowerShell module installed?"
            Break
        }

        # Create the folder for importing the Redistributables into
        If ($AppFolder) {
            If ($PSCmdlet.ShouldProcess("$($SMSSiteCode):\Application\$($AppFolder)", "Creating")) {
                New-Item -Path "$($SMSSiteCode):\Application\$($AppFolder)" -ErrorAction SilentlyContinue
            }
        }
        If (Test-Path "$($SMSSiteCode):\Application\$($AppFolder)") {
            Write-Verbose "Importing into: $($SMSSiteCode):\Application\$($AppFolder)"
            $DestFolder = "$($SMSSiteCode):\Application\$($AppFolder)"
        }
        Else {
            Write-Verbose "Importing into: $($SMSSiteCode):\Application"
            $DestFolder = "$($SMSSiteCode):\Application"
        }

        # Output variable
        $output = @()
    }

    Process {
        ForEach ($Vc in $VcList) {
            Write-Verbose "Importing app: [$($Vc.Name)][$($Vc.Release)][$($Vc.Architecture)]"

            # Import as an application into ConfigMgr
            If ($PSCmdlet.ShouldProcess("$($Vc.Name) in $CMPath", "Import ConfigMgr app")) {
                
                # Create the ConfigMgr application with properties from the XML file
                If ((Get-Item -Path $DestFolder).PSDrive.Name -eq $SMSSiteCode) {
                    If ($pscmdlet.ShouldProcess($Vc.Name + " $($Vc.Architecture)", "Creating ConfigMgr application")) {

                            # Change to the SMS Application folder before importing the applications
                            Write-Verbose "Setting location to $($DestFolder)"
                            Set-Location $DestFolder -ErrorVariable ConnectionError
                                                
                        try {
                            # Splat New-CMApplication parameters and add the application
                            $cmAppParams = @{
                                Name            = "$($Vc.Name) $($Vc.Architecture)"
                                Description     = "$($Publisher) $($Vc.Name) $($Vc.Architecture) imported by $($MyInvocation.MyCommand)"
                                SoftwareVersion = "$($Vc.Release) $($Vc.Architecture)"
                                LinkText        = $Vc.URL
                                Publisher       = $Publisher
                                Keyword         = $Keyword
                                ErrorVariable   = "CMAppError"
                            }
                            $app = New-CMApplication @cmAppParams

                            # Move the new application to the -AppFolder path
                            $output += $app
                            $app | Move-CMObject -FolderPath $DestFolder -ErrorAction SilentlyContinue | Out-Null
                        }
                        catch {
                            Throw "Failed to create application $($Vc.Name) $($Vc.Architecture) with error: $CMAppError."
                        }
                        finally {
                            Write-Verbose "Setting location to $validPath"
                            Set-Location -Path $validPath
                        }
                    }

                    # Add a deployment type to the application
                    If ($pscmdlet.ShouldProcess($Vc.Name + " $($Vc.Architecture)", "Adding deployment type")) {

                        # Change to the SMS Application folder before importing the applications
                        Write-Verbose "Setting location to $($DestFolder)"
                        Set-Location $DestFolder -ErrorVariable ConnectionError

                        try {
                            # Splat Add-CMScriptDeploymentType parameters and add the application deployment type
                            $cmScriptParams = @{
                                InstallCommand              = "$(Split-Path -Path $Vc.Download -Leaf) $(If($Silent) { $vc.SilentInstall } Else { $vc.Install })"
                                ContentLocation             = "$($(Get-Item -Path $CMPath).FullName)\$($Vc.Release)\$($Vc.Architecture)\$($Vc.ShortName)"
                                ProductCode                 = $Vc.ProductCode
                                SourceUpdateProductCode     = $Vc.ProductCode
                                DeploymentTypeName          = ("SCRIPT_" + $Vc.Name)
                                UserInteractionMode         = "Hidden"
                                UninstallCommand            = "$env:SystemRoot\System32\msiexec.exe /x $($Vc.ProductCode) /qn-"
                                LogonRequirementType        = "WhetherOrNotUserLoggedOn"
                                InstallationBehaviorType    = "InstallForSystem"
                                Comment                     = "Generated by $($MyInvocation.MyCommand)"
                                ErrorVariable               = "CMDtError"
                            }
                            $app | Add-CMScriptDeploymentType @cmScriptParams | Out-Null
                        }
                        catch {
                            Throw "Failed to add script deployment type with error $CMDtError."
                        }
                        finally {
                            Write-Verbose "Setting location to $validPath"
                            Set-Location -Path $validPath
                        }
                    }
                }
            }
        }
    }
    
    End {
        Set-Location -Path $validPath

        # Output array of applications created in ConfigMgr
        Write-Output $output
    }
}
