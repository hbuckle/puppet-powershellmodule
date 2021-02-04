require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'encore', 'powershellmodule', 'helper.rb'))

Puppet::Type.type(:pspackageprovider).provide(:windowspowershell, parent: :powershellcore) do
  confine operatingsystem: :windows
  commands powershell: 'powershell'

  def self.invoke_ps_command(command)
    PuppetX::PowerShellModule::Helper.instance.powershell(command)
  end
end
