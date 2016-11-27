Puppet::Type.newtype(:powershellmodule) do
  @doc = "Manage Windows PowerShell modules"

  ensurable

  newparam(:name) do
    desc "The name of the module"
  end

  newproperty(:version) do
    desc "The version to install"
  end
end