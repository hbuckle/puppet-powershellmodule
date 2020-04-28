require 'spec_helper'

provider_class = Puppet::Type.type(:pspackageprovider).provider(:windowspowershell)

describe provider_class do
  let(:type) do
    Puppet::Type.type(:pspackageprovider).new(name: 'repo')
  end

  let(:provider_instance) { provider_class.new(type) }

  before(:each) do
    allow(provider_class).to receive(:invoke_ps_command).and_return(nil)
    allow(provider_class).to receive(:invoke_ps_command).with(
      provider_class.instances_command,
    ).and_return(
      [
        '{"name":"Repo1"}',
        '{"name":"Repo2"}',
      ],
    )
  end

  describe 'instances' do
    specify 'returns an array of :windowspowershell providers' do
      instances = provider_class.instances
      expect(instances.count).to eq(2)
      expect(instances).to all(be_instance_of(provider_class))
    end
    specify 'sets the property hash for each provider' do
      instances = provider_class.instances
      expect(instances[0].instance_variable_get('@property_hash')).to eq(
        name: 'Repo1', ensure: :present,
      )
      expect(instances[1].instance_variable_get('@property_hash')).to eq(
        name: 'Repo2', ensure: :present,
      )
    end
  end

  describe 'prefetch' do
    specify 'sets the provider instance of the managed resource to a provider with the fetched state' do
      repo_resource1 = instance_double('pspackageprovider', name: 'Repo1')
      repo_resource2 = instance_double('pspackageprovider', name: 'Repo2')
      expect(repo_resource1).to receive(:provider=).with(
        provider_class.instances[0],
      )
      expect(repo_resource2).to receive(:provider=).with(
        provider_class.instances[1],
      )
      provider_class.prefetch(
        'Repo1' => repo_resource1,
        'Repo2' => repo_resource2,
      )
    end
  end

  describe 'exists?' do
    specify 'returns true if the resource already exists' do
      existing_instance = provider_class.instances[0]
      expect(existing_instance.exists?).to be true
    end
    specify 'returns false if the resource does not exist' do
      expect(provider_instance.exists?).to be false
    end
  end

  describe 'create' do
    specify 'calls install-packageprovider with parameters' do
      expect(provider_class).to receive(:invoke_ps_command).with(
        'PackageManagement\\Install-PackageProvider -Name repo -Force',
      )
      provider_instance.create
    end
  end
end
