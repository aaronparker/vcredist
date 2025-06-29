function New-IntuneWin32AppDetectionRule {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification = "Accepted for Intune detection objects.")]
    [OutputType([System.Collections.ArrayList])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline,
            HelpMessage = "Pass a VcList object from Save-VcRedist.")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(
            Mandatory = $true,
            Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $IntuneManifest
    )

    begin {
        $DetectionRules = New-Object -TypeName "System.Collections.ArrayList"
    }

    process {
        foreach ($VcRedist in $VcList) {
            foreach ($DetectionRuleItem in $IntuneManifest.DetectionRule) {
                switch ($DetectionRuleItem.Type) {
                    "MSI" {
                        # Create a MSI installation based detection rule
                        $DetectionRuleArgs = @{
                            "ProductCode"            = $DetectionRuleItem.ProductCode
                            "ProductVersionOperator" = $DetectionRuleItem.ProductVersionOperator
                        }
                        if (-not([System.String]::IsNullOrEmpty($DetectionRuleItem.ProductVersion))) {
                            $DetectionRuleArgs.Add("ProductVersion", $DetectionRuleItem.ProductVersion)
                        }

                        # Create MSI based detection rule
                        $DetectionRule = New-IntuneWin32AppDetectionRuleMSI @DetectionRuleArgs
                    }
                    "Script" {
                        # Create a PowerShell script based detection rule
                        $DetectionRuleArgs = @{
                            "ScriptFile"            = (Join-Path -Path $AppSourceFolder -ChildPath $DetectionRuleItem.ScriptFile)
                            "EnforceSignatureCheck" = [System.Convert]::ToBoolean($DetectionRuleItem.EnforceSignatureCheck)
                            "RunAs32Bit"            = [System.Convert]::ToBoolean($DetectionRuleItem.RunAs32Bit)
                        }

                        # Create script based detection rule
                        $DetectionRule = New-IntuneWin32AppDetectionRuleScript @DetectionRuleArgs
                    }
                    "Registry" {
                        if ($VcRedist.UninstallKey -eq "32") { $Check32BitOn64System = $true } else { $Check32BitOn64System = $false }
                        switch ($DetectionRuleItem.DetectionMethod) {
                            "Existence" {
                                # Construct registry existence detection rule parameters
                                $DetectionRuleArgs = @{
                                    "Existence"            = $true
                                    "KeyPath"              = $DetectionRuleItem.KeyPath -replace "{guid}", $VcRedist.ProductCode
                                    "DetectionType"        = $DetectionRuleItem.DetectionType
                                    "Check32BitOn64System" = $Check32BitOn64System
                                }
                                if (-not([System.String]::IsNullOrEmpty($DetectionRuleItem.ValueName))) {
                                    $DetectionRuleArgs.Add("ValueName", $DetectionRuleItem.ValueName)
                                }
                            }
                            "VersionComparison" {
                                # Construct registry version comparison detection rule parameters
                                $DetectionRuleArgs = @{
                                    "VersionComparison"         = $true
                                    "KeyPath"                   = $DetectionRuleItem.KeyPath
                                    "ValueName"                 = $DetectionRuleItem.ValueName
                                    "VersionComparisonOperator" = $DetectionRuleItem.Operator
                                    "VersionComparisonValue"    = $DetectionRuleItem.Value
                                    "Check32BitOn64System"      = $Check32BitOn64System
                                }
                            }
                            "StringComparison" {
                                # Construct registry string comparison detection rule parameters
                                $DetectionRuleArgs = @{
                                    "StringComparison"         = $true
                                    "KeyPath"                  = $DetectionRuleItem.KeyPath
                                    "ValueName"                = $DetectionRuleItem.ValueName
                                    "StringComparisonOperator" = $DetectionRuleItem.Operator
                                    "StringComparisonValue"    = $DetectionRuleItem.Value
                                    "Check32BitOn64System"     = $Check32BitOn64System
                                }
                            }
                            "IntegerComparison" {
                                # Construct registry integer comparison detection rule parameters
                                $DetectionRuleArgs = @{
                                    "IntegerComparison"         = $true
                                    "KeyPath"                   = $DetectionRuleItem.KeyPath
                                    "ValueName"                 = $DetectionRuleItem.ValueName
                                    "IntegerComparisonOperator" = $DetectionRuleItem.Operator
                                    "IntegerComparisonValue"    = $DetectionRuleItem.Value
                                    "Check32BitOn64System"      = $Check32BitOn64System
                                }
                            }
                        }

                        # Create registry based detection rule
                        $DetectionRule = New-IntuneWin32AppDetectionRuleRegistry @DetectionRuleArgs
                    }
                    "File" {
                        if ($VcRedist.Architecture -eq "x86") { $Check32BitOn64System = $true } else { $Check32BitOn64System = $false }
                        switch ($DetectionRuleItem.DetectionMethod) {
                            "Existence" {
                                # Create a custom file based requirement rule
                                $DetectionRuleArgs = @{
                                    "Existence"            = $true
                                    "Path"                 = $DetectionRuleItem.Path
                                    "FileOrFolder"         = $DetectionRuleItem.FileOrFolder
                                    "DetectionType"        = $DetectionRuleItem.DetectionType
                                    "Check32BitOn64System" = $Check32BitOn64System
                                }
                            }
                            "DateModified" {
                                # Create a custom file based requirement rule
                                $DetectionRuleArgs = @{
                                    "DateModified"         = $true
                                    "Path"                 = $DetectionRuleItem.Path
                                    "FileOrFolder"         = $DetectionRuleItem.FileOrFolder
                                    "Operator"             = $DetectionRuleItem.Operator
                                    "DateTimeValue"        = $DetectionRuleItem.DateTimeValue
                                    "Check32BitOn64System" = $Check32BitOn64System
                                }
                            }
                            "DateCreated" {
                                # Create a custom file based requirement rule
                                $DetectionRuleArgs = @{
                                    "DateCreated"          = $true
                                    "Path"                 = $DetectionRuleItem.Path
                                    "FileOrFolder"         = $DetectionRuleItem.FileOrFolder
                                    "Operator"             = $DetectionRuleItem.Operator
                                    "DateTimeValue"        = $DetectionRuleItem.DateTimeValue
                                    "Check32BitOn64System" = $Check32BitOn64System
                                }
                            }
                            "Version" {
                                # Create a custom file based requirement rule
                                $DetectionRuleArgs = @{
                                    "Version"              = $true
                                    "Path"                 = $(Split-Path -Path $VcRedist.DetectionFile)
                                    "FileOrFolder"         = $(Split-Path -Path $VcRedist.DetectionFile -Leaf)
                                    "Operator"             = $DetectionRuleItem.Operator
                                    "VersionValue"         = $VcRedist.Version
                                    "Check32BitOn64System" = $Check32BitOn64System
                                }
                            }
                            "Size" {
                                # Create a custom file based requirement rule
                                $DetectionRuleArgs = @{
                                    "Size"                 = $true
                                    "Path"                 = $DetectionRuleItem.Path
                                    "FileOrFolder"         = $DetectionRuleItem.FileOrFolder
                                    "Operator"             = $DetectionRuleItem.Operator
                                    "SizeInMBValue"        = $DetectionRuleItem.SizeInMBValue
                                    "Check32BitOn64System" = $Check32BitOn64System
                                }
                            }
                        }

                        # Create file based detection rule
                        $DetectionRule = New-IntuneWin32AppDetectionRuleFile @DetectionRuleArgs
                    }
                }

                # Add detection rule to list
                $DetectionRules.Add($DetectionRule) | Out-Null
            }
        }
    }

    end {
        # Return the collection of detection rules
        return $DetectionRules
    }
}
