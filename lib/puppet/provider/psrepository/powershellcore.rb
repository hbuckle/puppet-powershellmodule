Puppet::Type.type(:psrepository).provide(:powershellcore) do
  initvars
  commands pwsh: 'pwsh'
  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.invoke_ps_command(command)
    result = pwsh(['-NoProfile', '-NonInteractive', '-NoLogo', '-Command', "$ProgressPreference = 'SilentlyContinue'; #{command}"])
    Puppet.debug result.exitstatus
    Puppet.debug result.lines
    result.lines
  end

  def self.instances
    result = invoke_ps_command instances_command
    result.each.collect do |line|
      repo = JSON.parse(line.strip, symbolize_names: true)
      repo[:ensure] = :present
      new(repo)
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

  def create
    self.class.invoke_ps_command create_command
    @property_hash[:ensure] = :present
  end

  def destroy
    self.class.invoke_ps_command destroy_command
    @property_hash.clear
  end

  def source_location=(value)
    @property_flush[:sourcelocation] = value
  end

  def installation_policy=(value)
    @property_flush[:installationpolicy] = value
  end

  def flush
    unless @property_flush.empty?
      flush_command = "Set-PSRepository #{@resource[:name]}"
      @property_flush.each do |key, value|
        flush_command << " -#{key} '#{value}'"
      end
      self.class.invoke_ps_command flush_command
    end
    @property_hash = @resource.to_hash
  end

  def self.instances_command
    <<-COMMAND
    @(Get-PSRepository).foreach({
      [ordered]@{
        'name' = $_.Name
        'source_location' = $_.SourceLocation
        'installation_policy' = $_.InstallationPolicy.ToLower()
      } | ConvertTo-Json -Depth 99 -Compress
    })
    COMMAND
  end

  def create_command
    <<-COMMAND
    $params = @{
      Name = '#{@resource[:name]}'
      SourceLocation = '#{@resource[:source_location]}'
      InstallationPolicy = '#{@resource[:installation_policy]}'
    }
    Register-PSRepository @params
    COMMAND
  end

  def destroy_command
    "Unregister-PSRepository #{@resource[:name]}"
  end
end
