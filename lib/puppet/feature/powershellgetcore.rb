require 'puppet/util/feature'

Puppet.features.add(:powershellgetcore) do
  command = '"Import-Module powershellget; $mod = Get-Module powershellget; $mod.Name"'
  output = `pwsh -noprofile -executionpolicy bypass -command #{command}`
  output.downcase.strip == 'powershellget'
end
