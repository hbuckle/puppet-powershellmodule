Puppet::Type.type(:psrepository).provide(:windows) do
  confine :operatingsystem => :windows
  confine :feature => :powershellget

  commands :powershell =>
              if File.exists?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
              elsif File.exists?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
              else
                'powershell.exe'
              end
  
  mk_resource_methods

  def self.instances
    command = "@(Get-PSRepository).foreach({\"$($_.Name),$($_.SourceLocation),$($_.InstallationPolicy)\"})"
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    debug(result)
    result.lines.each_slice(3).collect do |repo|
      debug(repo)
      new(
        :name => repo[0].strip,
        :ensure => :present,
        :source_location => repo[1].downcase.strip,
        :installation_policy => repo[2].downcase.strip
      )
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    command = "Unregister-PSRepository #{@resource[:name]}"
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    @property_hash.clear
  end

  def create
    command = "Register-PSRepository #{@resource[:name]} -SourceLocation #{@resource[:source_location]} -InstallationPolicy #{@resource[:installation_policy]}"
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    @property_hash[:ensure] = :present
  end

  def source_location=(value)
    command = "Set-PSRepository #{@resource[:name]} -SourceLocation #{value}"
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    @property_hash[:source_location] = value
  end

  def installation_policy=(value)
    command = "Set-PSRepository #{@resource[:name]} -InstallationPolicy #{value}"
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    @property_hash[:installation_policy] = value
  end
end