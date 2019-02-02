Puppet::Type.newtype(:psrepository) do
  @doc = 'Manage sources for PowerShell modules'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the repository'
    validate do |value|
      raise ArgumentError, "A non-empty #{self.name} must be specified." if value.nil? || value.empty?
      raise "#{self.name} should be a String" unless value.is_a? ::String
      raise "#{value} is not a valid #{self.name}" unless value =~ /^[a-zA-Z0-9\.\-\_\'\s]+$/
    end
  end

  newproperty(:source_location) do
    desc 'The source location'
    validate do |value|
      raise ArgumentError, "A non-empty #{self.name} must be specified." if value.nil? || value.empty?
      raise "#{self.name} should be a String" unless value.is_a? ::String
      raise "#{self.name} should be a valid URI" unless value =~ URI::DEFAULT_PARSER.regexp[:ABS_URI]
      unless URI.parse(value).is_a?(URI::HTTP) ||
             URI.parse(value).is_a?(URI::HTTPS)
        raise "#{value} is not a valid URI"
      end
    end
  end

  newproperty(:installation_policy) do
    desc 'Installation policy for this repository. Must be trusted or untrusted'
    defaultto :untrusted
    newvalues(:trusted, :untrusted)
  end
end
