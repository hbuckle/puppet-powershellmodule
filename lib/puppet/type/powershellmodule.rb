Puppet::Type.newtype(:powershellmodule) do
  @doc = "Manage Windows PowerShell modules"

  ensurable

  newparam(:name) do
    desc "The name of the module"
    munge do |value|
      value.downcase
    end
  end

  newproperty(:version) do
    desc "The version to install"
  end

  newparam(:repository) do
    desc "The repository to install from. Must be registered on the system"
  end
end