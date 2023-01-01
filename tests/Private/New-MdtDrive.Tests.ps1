<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
}

InModuleScope VcRedist {
    BeforeAll { Describe 'New-MdtDrive' {
            function Get-MdtPersistentDrive {}
            function New-PSDrive {}
            function Add-MDTPersistentDrive {}
        }

        Context "Creates a new MDT drive" {
            BeforeEach {
                Mock -CommandName Get-MdtPersistentDrive -MockWith {
                    $obj = [PSCustomObject]@{
                        Name        = "DS004"
                        Path        = "\\server\share"
                        Description = "MDT drive created by New-MdtDrive"
                    }
                    Write-Output $obj
                }
                Mock -CommandName New-PSDrive -MockWith {
                    $obj = [PSCustomObject]@{
                        Name     = "DS004"
                        Provider = "MDTProvider"
                        Root     = "\\server\share"
                    }
                    Write-Output $obj
                }
                Mock -CommandName Add-MdtPersistentDrive -MockWith {
                    $obj = [PSCustomObject]@{
                        Name     = "DS004"
                        Provider = "MDTProvider"
                        Root     = "\\server\share"
                    }
                    Write-Output $obj
                }
            }

            It "Successfully creates the MDT drive" {
                New-MdtDrive -Drive "DS004" -Path "\\server\share" | Should -Be "DS004"
            }
        }
    }
}
