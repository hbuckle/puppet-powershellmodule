require 'spec_helper'

provider_class = Puppet::Type.type(:package).provider(:windowspowershell)

describe provider_class do
  let(:type) do
    Puppet::Type.type(:package).new(
      name: 'module', source: 'http://source.com', ensure: :present,
    )
  end

  let(:provider_instance) { provider_class.new(type) }

  before(:each) do
    allow(provider_class).to receive(:invoke_ps_command).with(
      provider_class.instances_command,
    ).and_return(
      [
        '{"name":"PackageManagement","ensure":["1.1.6.0","1.1.7.0"],"provider":"windowspowershell"}',
        '{"name":"Pester","ensure":["4.0.8"],"provider":"windowspowershell"}',
        '{"name":"PowerShellGet","ensure":["1.5.0.0"],"provider":"windowspowershell"}',
      ],
    )
  end

  describe 'instances' do
    specify 'returns an array of :windowspowershell providers' do
      instances = provider_class.instances
      expect(instances.count).to eq(3)
      expect(instances).to all(be_instance_of(provider_class))
    end
  end

  describe 'install_options' do
    specify 'flattens an array of options to a command string' do
      input = ['-foo', '-bar']
      output = provider_instance.install_options input
      expect(output).to eq('-foo -bar')
    end
    specify 'flattens a mixed array of options to a command string' do
      input = ['-foobar', { '-foo' => 'bar' }]
      output = provider_instance.install_options input
      expect(output).to eq('-foobar -foo bar')
    end
  end

  describe 'install_command' do
    specify 'with name and source' do
      output = provider_instance.install_command
      expect(output).to eq(
        'Install-Module module -Scope AllUsers -Force -Repository http://source.com',
      )
    end
    specify 'with name, version and source' do
      type = Puppet::Type.type(:package).new(
        name: 'module', ensure: '1.0.0', source: 'http://source.com',
      )
      provider_instance = provider_class.new(type)
      output = provider_instance.install_command
      expect(output).to eq(
        'Install-Module module -Scope AllUsers -Force -RequiredVersion 1.0.0 -Repository http://source.com',
      )
    end
    specify 'with name, version, source and install_options' do
      type = Puppet::Type.type(:package).new(
        name: 'module', ensure: '1.0.0', source: 'http://source.com',
        install_options: ['-foobar', { '-foo' => 'bar' }]
      )
      provider_instance = provider_class.new(type)
      output = provider_instance.install_command
      expect(output).to eq(
        'Install-Module module -Scope AllUsers -Force -RequiredVersion 1.0.0 -Repository http://source.com -foobar -foo bar',
      )
    end
  end
end
