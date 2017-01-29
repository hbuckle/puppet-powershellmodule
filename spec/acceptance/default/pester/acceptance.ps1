Describe "puppet-powershellmodule" {
    It "Installs PowerShell modules" {
        $mod = Get-InstalledModule "Posh-SSH"
        $mod.Name | Should Be "Posh-SSH"
    }
}