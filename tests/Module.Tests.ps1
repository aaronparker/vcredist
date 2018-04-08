# AppVeyor Testing
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $ProjectRoot = 'env:APPVEYOR_BUILD_FOLDER'
}
Else {
    # Local Testing 
    $ProjectRoot = ((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName
}
$manifest = Join-Path (Join-Path $ProjectRoot "VcRedist") "VcRedist.psd1"
$module = Join-Path (Join-Path $ProjectRoot "VcRedist") "VcRedist.psm1"

Describe 'Module Metadata Validation' {      
    It 'Script fileinfo should be OK' {
        {Test-ModuleManifest $manifest -ErrorAction Stop} | Should Not Throw
    }
        
    It 'Import module should be OK' {
        {Import-Module $module -Force -ErrorAction Stop} | Should Not Throw
    }
}