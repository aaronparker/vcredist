<#
    .SYNOPSIS
        Private Pester function tests.
#>
[CmdletBinding()]
param ()

InModuleScope VcRedist {
    BeforeAll { Describe 'New-MdtDrive' {
            Function Get-MdtPersistentDrive {}
            Function New-PSDrive {}
            Function Add-MDTPersistentDrive {}
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

    Describe 'New-MdtApplicationFolder' {
        Context "Application folder exists" {
            BeforeEach {
                Mock Test-Path { $True }
            }
            It "Returns True if the Application folder exists" {
                New-MdtApplicationFolder -Drive "DS001" -Name "VcRedists" | Should -BeTrue
            }
        }
        Context "Creates a new Packages folder" {
            BeforeEach {
                Function New-Item {}
                Mock Test-Path { $False }
                Mock New-Item { $obj = [PSCustomObject]@{Name = "VcRedists" } }
            }
            It "Successfully creates a Application folder" {
                New-MdtApplicationFolder -Drive "DS001" -Name "VcRedists" | Should -BeTrue
            }
        }
    }


    Describe 'Test-PSCore' {
        BeforeEach {
            $Version = '6.0.0'
        }
        Context "Tests whether we are running on PowerShell Core" {
            It "Imports the MDT PowerShell module and returns True" {
                If (($PSVersionTable.PSVersion -ge [version]::Parse($Version)) -and ($PSVersionTable.PSEdition -eq "Core")) {
                    Test-PSCore | Should -BeTrue
                }
            }
        }
        Context "Tests whether we are running on Windows PowerShell" {
            It "Returns False if running Windows PowerShell" {
                If (($PSVersionTable.PSVersion -lt [version]::Parse($Version)) -and ($PSVersionTable.PSEdition -eq "Desktop")) {
                    Test-PSCore | Should -BeFalse
                }
            }
        }
    }
}
