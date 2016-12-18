Puppet::Type.newtype(:powershellmodule) do
  @doc = 'Manage PowerShell modules'

  ensurable

  newparam(:name) do
    desc 'The name of the module'
    munge(&:downcase)
  end

  newproperty(:version) do
    desc 'The version to install'
  end

  newparam(:repository) do
    desc 'The repository to install from. Must be registered on the system'
  end
end
