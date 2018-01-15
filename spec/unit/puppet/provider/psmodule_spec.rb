require 'spec_helper'

provider_class = Puppet::Type.type(:package).provider(:windowspowershell)

describe provider_class do
  before(:each) do
    type = Puppet::Type.type(:package).new(
      name: 'module', source: 'http://source.com'
    )
    @provider_instance = provider_class.new(type)
    allow(provider_class).to receive(:invoke_ps_command).with(
      provider_class.instances_command).and_return(
        [
          '{"name":"PackageManagement","ensure":["1.1.6.0","1.1.7.0"],"provider":"windowspowershell"}',
          '{"name":"Pester","ensure":["4.0.8"],"provider":"windowspowershell"}',
          '{"name":"PowerShellGet","ensure":["1.5.0.0"],"provider":"windowspowershell"}'
        ]
      )
  end
  describe :instances do
    specify 'returns an array of :windowspowershell providers' do
      instances = provider_class.instances
      expect(instances.count).to eq(3)
      expect(instances).to all(be_instance_of(provider_class))
    end
  end
end
