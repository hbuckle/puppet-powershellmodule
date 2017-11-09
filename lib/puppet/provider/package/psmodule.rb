require 'puppet/provider/package'
require 'json'

Puppet::Type.type(:package).provide :psmodule, parent: Puppet::Provider::Package do
  confine operatingsystem: :windows
  confine feature: :powershellget

  has_feature :installable
  has_feature :uninstallable
  has_feature :upgradeable
  has_feature :versionable

  commands powershell:
              if File.exist?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
              elsif File.exist?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
              else
                'powershell.exe'
              end

  def self.invoke_ps_command(command)
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    result.lines
  end

  def self.instances
    result = invoke_ps_command instances_command
    result.each.collect do |line|
      new(JSON.parse(line.strip, symbolize_names: true))
    end
  end

  # This is called by the base provider class. Seems to be used to
  # set the property_hash, but we already have that, so just return it
  def query
    @property_hash
  end

  def install
    self.class.invoke_ps_command install_command
  end

  def uninstall
    self.class.invoke_ps_command uninstall_command
  end

  def latest
    result = self.class.invoke_ps_command latest_command
    result[0].strip
  end

  def update
    self.class.invoke_ps_command update_command
  end

  def self.instances_command
    # Get-Package is way faster than Get-InstalledModule
    <<-COMMAND
    Get-Package -AllVersions -ProviderName PowerShellGet -Scope AllUsers -Type Module |
    Group-Object -Property Name | % {
      [ordered]@{
        'name' = $_.Name
        'ensure' = @(($_.Group).Version)
        'provider' = 'psmodule'
      } | ConvertTo-Json -Depth 99 -Compress
    }
    COMMAND
  end

  def install_command
    command = "Install-Module #{@resource[:name]} -Force"
    command << " -RequiredVersion #{@resource[:ensure]}" unless [:present, :latest].include? @resource[:ensure]
    command << " -Repository #{@resource[:source]}" if @resource[:source]
    command
  end

  def uninstall_command
    "Uninstall-Module #{@resource[:name]} -AllVersions -Force"
  end

  def latest_command
    "$mod = Find-Module #{@resource[:name]}; $mod.Version.ToString()"
  end

  def update_command
    command = "Install-Module #{@resource[:name]} -Force"
    command << " -Repository #{@resource[:source]}" if @resource[:source]
    command
  end
end
