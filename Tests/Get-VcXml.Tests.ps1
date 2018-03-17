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
        It "Given valid parameter -Xml, it returns Visual C++ Redistributables from an external manifest" {
            $Xml = "$($pwd)\Redists.xml"
            Export-VcXml -Path $Xml -Verbose
            $VcList = Get-VcList -Xml $Xml
            $VcList.Count | Should -Be 12
        }
    }
}