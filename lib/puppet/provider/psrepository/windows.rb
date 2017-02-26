Puppet::Type.type(:psrepository).provide(:windows) do
  confine operatingsystem: :windows
  confine feature: :powershellget

  commands powershell:
              if File.exist?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
              elsif File.exist?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
              else
                'powershell.exe'
              end

  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.invoke_ps_command(command)
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    result.lines
  end

  def self.instances
    result = invoke_ps_command instances_command
    result.each.collect do |repo|
      new(
        name: repo.split(',')[0].strip,
        ensure: :present,
        source_location: repo.split(',')[1].downcase.strip,
        installation_policy: repo.split(',')[2].downcase.strip
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
    '@(Get-PSRepository).foreach({\"$($_.Name),$($_.SourceLocation),$($_.InstallationPolicy)\"})'
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
