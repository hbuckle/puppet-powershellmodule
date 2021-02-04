require 'json'
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'encore', 'powershellmodule', 'helper.rb'))

Puppet::Type.type(:pspackageprovider).provide :powershellcore do
  confine operatingsystem: :windows
  commands pwsh: 'pwsh'

  mk_resource_methods

  def self.invoke_ps_command(command)
    # override_locale is necessary otherwise the Install-Module commands silently fails on Linux
    # TODO is this still necessary with ruby-pwsh
    PuppetX::PowerShellModule::Helper.instance.pwsh(command)
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.prefetch(resources)
    instances.each do |prov|
      resource = resources[prov.name]
      resource.provider = prov if resource
    end
  end

  def self.instances
    result = invoke_ps_command instances_command
    result.each.map do |line|
      p = JSON.parse(line.strip, symbolize_names: true)
      p[:ensure] = :present
      new(p)
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    self.class.invoke_ps_command install_command
    @property_hash[:ensure] = :present
  end

  def flush
    unless @property_flush.empty?
      flush_command = "PackageManagement\\Install-PackageProvider -Name #{@resource[:name]}"
      @property_flush.each do |key, value|
        flush_command << if @property_flush[:version]
                           " -RequiredVersion '#{value}'"
                         else
                           " -#{key} '#{value}'"
                         end
      end
      flush_command << ' -Force'
      self.class.invoke_ps_command flush_command
    end
    @property_hash = @resource.to_hash
  end

  def self.instances_command
    <<-COMMAND
    @(Get-PackageProvider).foreach({
      [ordered]@{
        'name' = $_.Name.ToLower()
        'version' = $_.Version.ToString()
      } | ConvertTo-Json -Depth 99 -Compress
    })
    COMMAND
  end

  def install_command
    command = []
    command << "PackageManagement\\Install-PackageProvider -Name #{@resource[:name]}"
    command << ' -Force'
    command.join
  end
end
