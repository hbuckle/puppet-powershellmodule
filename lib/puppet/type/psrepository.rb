Puppet::Type.newtype(:psrepository) do
  @doc = 'Manage sources for PowerShell modules'

  ensurable

  newparam(:name) do
    desc 'The name of the repository'
  end

  newproperty(:source_location) do
    desc 'The source location'
    validate do |value|
      unless URI.parse(value).is_a?(URI::HTTP) ||
             URI.parse(value).is_a?(URI::HTTPS)
        raise Puppet::ResourceError "#{value} is not a valid URI"
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
