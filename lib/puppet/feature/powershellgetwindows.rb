require 'puppet/util/feature'

Puppet.features.add(:powershellgetwindows) do
  command = '"Import-Module powershellget; $mod = Get-Module powershellget; $mod.Name"'
  output = `powershell.exe -noprofile -executionpolicy bypass -command #{command}`
  output.downcase.strip == 'powershellget'
end
