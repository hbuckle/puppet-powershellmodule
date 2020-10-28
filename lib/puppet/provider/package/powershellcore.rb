require 'puppet/provider/package'
require 'json'

Puppet::Type.type(:package).provide :powershellcore, parent: Puppet::Provider::Package do
  initvars
  has_feature :installable, :uninstallable, :upgradeable, :versionable, :install_options
  commands pwsh: 'pwsh'

  def self.invoke_ps_command(command)
    # override_locale is necessary otherwise the Install-Module commands silently fails on Linux
    result = Puppet::Util::Execution.execute(['pwsh', '-NoProfile', '-NonInteractive', '-NoLogo', '-Command',
                                              "$ProgressPreference = 'SilentlyContinue'; $ErrorActionPreference = 'Stop'; #{command}"],
                                             override_locale: false)
    result.lines
  end

  def self.instances
    result = invoke_ps_command instances_command
    result.each.map do |line|
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
    result = self.class.invoke_ps_command(latest_command)
    result[0].strip
  end

  def update
    self.class.invoke_ps_command(update_command)
  end

  # Turns a array of install_options into flags to be passed to a command.
  # The options can be passed as a string or hash. Note that passing a hash
  # should only be used in case "-foo bar" must be passed,
  # Regular flags like '-foobar' must be passed as a string.
  # which can be accomplished with:
  #     install_options => [ '-foobar',{ '-foo' => 'bar' } ]
  # This will result in the following being passed as arguments to the command:
  #     -foobar -foo bar
  # @param options [Array]
  # @return Concatenated list of options
  # @api private
  def install_options(options)
    return unless options

    opts = options.map do |val|
      case val
      when Hash
        val.keys.sort.map do |k|
          "#{k} #{val[k]}"
        end
      else
        val
      end
    end
    opts.flatten.join(' ')
  end

  def self.instances_command
    # Get-Package is way faster than Get-InstalledModule
    <<-COMMAND
    Get-Package -AllVersions -ProviderName PowerShellGet -Scope AllUsers -Type Module -WarningAction 'SilentlyContinue' |
    Group-Object -Property Name | % {
      [ordered]@{
        'name' = $_.Name
        'ensure' = @(($_.Group).Version)
        'provider' = '#{name}'
      } | ConvertTo-Json -Depth 99 -Compress
    }
    COMMAND
  end

  # Command used to install powershell modules
  def install_command
    command = "Install-Module #{@resource[:name]} -Scope AllUsers -Force"
    command << " -RequiredVersion #{@resource[:ensure]}" unless [:present, :latest].include? @resource[:ensure]
    command << " -Repository #{@resource[:source]}" if @resource[:source]
    command << " #{install_options(@resource[:install_options])}" if @resource[:install_options]
    command
  end

  # Command to unisntall powershell modules
  def uninstall_command
    "Uninstall-Module #{@resource[:name]} -AllVersions -Force"
  end

  # Command to fetch latest version of powershell modules
  def latest_command
    command = "$mod = Find-Module #{@resource[:name]}"
    command << " -Repository #{@resource[:source]}" if @resource[:source]
    command << '; $mod.Version.ToString()'
    command
  end

  # Command to update powershell modules
  def update_command
    # The -AllowClobber here is needed because this command will fail with an error like:
    # "This cmdlet exists on the system and could cause a conflict, use -allowclobber to install"
    # I believe this is due to a cmdlet moving from one module to another, seen in powercli modules
    command = "Install-Module #{@resource[:name]} -Scope AllUsers -Force -AllowClobber"
    command << " -Repository #{@resource[:source]}" if @resource[:source]
    command << " #{install_options(@resource[:install_options])}" if @resource[:install_options]
    command
  end
end
