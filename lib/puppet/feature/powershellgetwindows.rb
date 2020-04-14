require 'puppet/util/feature'

Puppet.features.add(:powershellgetwindows) do
  command = '"try { Import-Module powershellget -ErrorAction Stop; $mod = Get-Module powershellget; $mod.Name; } catch {}"'
  output = `powershell.exe -noprofile -executionpolicy bypass -command #{command}`
  output.downcase.strip == 'powershellget'
end
