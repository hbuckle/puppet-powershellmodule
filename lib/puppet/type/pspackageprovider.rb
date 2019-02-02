Puppet::Type.newtype(:pspackageprovider) do
  @doc = 'Manage PowerShell Package providers for PowerShell modules'

  newproperty(:ensure) do
    newvalue(:present) do
      provider.create
    end
  end

  newparam(:name, namevar: true) do
    desc 'The name of the package provider'
    validate do |value|
      raise ArgumentError, "A non-empty #{self.name} must be specified." if value.nil? || value.empty?
      raise "#{self.name} should be a String" unless value.is_a? ::String
      raise "#{value} is not a valid #{self.name}" unless value =~ /^[a-zA-Z0-9\.\-\_\'\s]+$/
    end
    munge(&:downcase)
  end

  newproperty(:version) do
    desc 'The version for a PowerShell Package Provider'
    validate do |value|
      raise ArgumentError, "A non-empty #{self.name} must be specified." if value.nil? || value.empty?
      raise "#{self.name} should be a String" unless value.is_a? ::String
    end
  end
end
