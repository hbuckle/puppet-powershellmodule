Puppet::Type.type(:psrepository).provide(:windows) do
  confine :operatingsystem => :windows
  confine :feature => :powershellget

  commands :powershell => 'powershell.exe'

  def exists?
    command = "$rp = Get-PSRepository #{@resource[:name]}; $rp.Name"
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    result.strip == resource[:name]
  end

  def destroy
    command = "Unregister-PSRepository #{@resource[:name]}"
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
  end

  def create
    command = "Register-PSRepository #{@resource[:name]} -SourceLocation #{@resource[:source_location]} -InstallationPolicy #{@resource[:installation_policy]}"
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
  end

  def source_location
    command = "$rp = Get-PSRepository #{@resource[:name]}; $rp.SourceLocation"
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    result.downcase.strip
  end

  def source_location=(value)
    command = "Set-PSRepository #{@resource[:name]} -SourceLocation #{value}"
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
  end

  def installation_policy
    command = "$rp = Get-PSRepository #{@resource[:name]}; $rp.InstallationPolicy"
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    result.downcase.strip
  end

  def installation_policy=(value)
    command = "Set-PSRepository #{@resource[:name]} -InstallationPolicy #{value}"
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
  end
end