require 'spec_helper'

provider_class = Puppet::Type.type(:package).provider(:psmodule)

describe provider_class do
  before(:each) do
    type = Puppet::Type.type(:package).new(
      name: 'module', source: 'http://source.com'
    )
    @provider_instance = provider_class.new(type)
    allow(provider_class).to receive(:invoke_ps_command).with(
      provider_class.instances_command).and_return(
        ['PackageManagement', '1.1.1.0', 'Pester', '4.0.2', 'Posh-SSH',
         '1.7.7', 'PowerShellGet', '1.1.2.0', 'PSDeployTools', '1.0.6',
         'PSExcel', '1.0,1.0.2']
      )
  end
  describe :instances do
    specify 'returns an array of :psmodule providers' do
      instances = provider_class.instances
      expect(instances.count).to eq(6)
      expect(instances).to all(be_instance_of(provider_class))
    end
  end
end
