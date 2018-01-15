require 'puppet/provider/package'
require 'json'

Puppet::Type.type(:package).provide :powershellcore, parent: Puppet::Provider::Package do
  initvars
  has_feature :installable, :uninstallable, :upgradeable, :versionable
  commands pwsh: 'pwsh'

  def self.invoke_ps_command(command)
    result = pwsh(['-NoProfile', '-NonInteractive', '-NoLogo', '-Command', "$ProgressPreference = 'SilentlyContinue'; #{command}"])
    Puppet.debug result.exitstatus
    Puppet.debug result.lines
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
        'provider' = '#{name}'
      } | ConvertTo-Json -Depth 99 -Compress
    }
    COMMAND
  end

  def install_command
    command = "Install-Module #{@resource[:name]} -Scope AllUsers -Force"
    command << " -RequiredVersion #{@resource[:ensure]}" unless [:present, :latest].include? @resource[:ensure]
    command << " -Repository #{@resource[:source]}" if @resource[:source]
    command
  end

  def uninstall_command
    "Uninstall-Module #{@resource[:name]} -AllVersions -Scope AllUsers -Force"
  end

  def latest_command
    "$mod = Find-Module #{@resource[:name]}; $mod.Version.ToString()"
  end

  def update_command
    command = "Install-Module #{@resource[:name]} -Scope AllUsers -Force"
    command << " -Repository #{@resource[:source]}" if @resource[:source]
    command
  end
end
