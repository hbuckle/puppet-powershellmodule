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
    result.each.map do |line|
      repo = JSON.parse(line.strip, symbolize_names: true)
      repo[:ensure] = :present
      new(repo)
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      resource = resources[prov.name]
      resource.provider = prov if resource
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

  # The source location for existing psrepos
  # You cannot define this for the default psgallery repo
  def source_location=(value)
    @property_flush[:sourcelocation] = value
  end

  # The installation policy for existing psrepos
  def installation_policy=(value)
    @property_flush[:installationpolicy] = value
  end

  # Sets any pre-existing psrepo to have the proper attributes. Source location, install policy, etc.
  def flush
    # If any psrepos existed on the system...
    unless @property_flush.empty?
      # Base block of the command which will be used to true-up psrepos
      flush_command = "Set-PSRepository #{@resource[:name]}"
      # For each attribute on the psrepos..
      @property_flush.each do |key, value|
        # If the repo we is powershell gallery, then DROP the source_location key
        # If you specify source_location for the PSGallery default repo, it will fail
        next if @resource[:name].casecmp?('psgallery') && key == :sourcelocation

        # Append that attribute to the true-up command
        flush_command << " -#{key} '#{value}'"
      end
      # launch pwsh to true-up any pre-existing repo with proper settings
      self.class.invoke_ps_command flush_command
    end
    @property_hash = @resource.to_hash
  end

  # Expected return example when an actual repo is registered:
  # {"name":"PSGallery","source_location":"https://www.powershellgallery.com/api/v2","installation_policy":"trusted"}
  # When no ps repos are registered it returns:
  # WARNING: Unable to find module repositories
  # The try, catch here gets around the issue of having no repos
  def self.instances_command
    <<-COMMAND
    try {
        @(Get-PSRepository -ErrorAction Stop -WarningAction Stop 3>$null).foreach({
            [ordered]@{
            'name' = $_.Name
            'source_location' = $_.SourceLocation
            'installation_policy' = $_.InstallationPolicy.ToLower()
            } | ConvertTo-Json -Depth 99 -Compress
        })
    } catch {
      # If no repos were registered
      exit 0
    }
    COMMAND
  end

  def create_command
    <<-COMMAND
    $params = @{
      Name = '#{@resource[:name]}'
      SourceLocation = '#{@resource[:source_location]}'
      InstallationPolicy = '#{@resource[:installation_policy]}'
    }

    # Detecting if this is Powershell Gallery repo or not
    if ($params.Name -eq 'PSGallery' -or $params.SourceLocation -match 'powershellgallery') {
      # Trim these params or the splatting will fail
      $params.Remove('Name')
      $params.Remove('SourceLocation')
      Register-PSRepository -Default @params
    } else {
      # For all non-PSGallery repos..
      Register-PSRepository @params
    }
    COMMAND
  end

  def destroy_command
    "Unregister-PSRepository #{@resource[:name]}"
  end
end
