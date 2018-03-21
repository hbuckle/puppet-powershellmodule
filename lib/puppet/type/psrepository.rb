Puppet::Type.newtype(:psrepository) do
  @doc = 'Manage sources for PowerShell modules'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of the repository'
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty #{self.name.to_s} must be specified."
      end
      fail "#{self.name.to_s} should be a String" unless value.is_a? ::String
      fail("#{value} is not a valid #{self.name.to_s}") unless value =~ /^[a-zA-Z0-9\.\-\_\'\s]+$/
    end
  end

  newproperty(:source_location) do
    desc 'The source location'
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty #{self.name.to_s} must be specified."
      end
      fail "#{self.name.to_s} should be a String" unless value.is_a? ::String
      fail "#{self.name.to_s} should be a valid URI" unless value =~ URI::DEFAULT_PARSER.regexp[:ABS_URI]
      unless URI.parse(value).is_a?(URI::HTTP) ||
             URI.parse(value).is_a?(URI::HTTPS)
        fail "#{value} is not a valid URI"
      end
    end
    munge(&:downcase)
  end

  newproperty(:installation_policy) do
    desc 'Installation policy for this repository. Must be trusted or untrusted'
    defaultto :untrusted
    newvalues(:trusted, :untrusted)
  end
end
