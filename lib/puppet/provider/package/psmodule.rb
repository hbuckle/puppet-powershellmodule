require 'puppet/provider/package'

Puppet::Type.type(:package).provide :psmodule, parent: Puppet::Provider::Package do
  confine operatingsystem: :windows
  confine feature: :powershellget

  has_feature :installable
  has_feature :uninstallable
  has_feature :upgradeable
  has_feature :versionable

  commands :powershell =>
              if File.exists?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
              elsif File.exists?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
              else
                'powershell.exe'
              end

  def self.invoke_ps_command(command)
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    Puppet.debug result
    result
  end

  def invoke_ps_command(command)
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    Puppet.debug result
    result
  end

  def self.instances
    command = <<-COMMAND
    Get-Package -AllVersions -ProviderName PowerShellGet -Scope AllUsers -Type Module |
      Group-Object -Property Name | % {
        $_.Name
        ($_.Group).Version -join ','
    }
    COMMAND
    result = invoke_ps_command command
    result.lines.each_slice(3).collect do |mod|
      Puppet.debug mod
      new(
        name: mod[0].strip,
        ensure: mod[1].strip.split(','),
        provider: 'psmodule'
      )
    end
  end

  def query
    self.class.instances.each do |mod|
      return mod.properties if @resource[:name].casecmp(mod.name)
    end
    nil
  end

  def install
    command = "Install-Module #{@resource[:name]} -RequiredVersion #{@resource[:ensure]} -Force"
    command << " -Source #{@resource[:source]}" if @resource[:source]
    invoke_ps_command command
  end

  def uninstall
    command = "Uninstall-Module #{@resource[:name]} -AllVersions -Force"
    invoke_ps_command command
  end

  def latest
    command = "$mod = Find-Module #{@resource[:name]}; $mod.Version.ToString()"
    result = invoke_ps_command command
    result.strip
  end

  def update
    command = "Install-Module #{@resource[:name]} -Force"
    command << " -Source #{@resource[:source]}" if @resource[:source]
    invoke_ps_command command
  end
end
