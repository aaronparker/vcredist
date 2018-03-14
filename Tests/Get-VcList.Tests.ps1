# Pester tests
Describe 'Get-VcList' {
    It "Given no parameters, it returns supported Visual C++ Redistributables" {
        $VcList = Get-VcList
        $VcList.Count | Should -Be 12
    }
    
    It "Given valid parameter -Export 'All', it returns supported Visual C++ Redistributables" {
        $VcList = Get-VcList -Export All
        $VcList.Count | Should -Be 32
    }
}