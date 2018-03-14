# Pester tests
Describe 'Get-VcList' {
    Context "Return built-in manifest" {
        It "Given no parameters, it returns supported Visual C++ Redistributables" {
            $VcList = Get-VcList
            $VcList.Count | Should -Be 12
        }
        It "Given valid parameter -Export 'All', it returns all Visual C++ Redistributables" {
            $VcList = Get-VcList -Export All
            $VcList.Count | Should -Be 32
        }
    }
    Context "Return external manifest" {
        It "Given valid parameter -Xml 'All', it returns supported Visual C++ Redistributables" {
            $VcList = Get-VcList -Xml "C:\projects\install-visualcredistributables\VcRedist\VisualCRedistributablesSupported.xml"
            $VcList.Count | Should -Be 12
        }
    }
}