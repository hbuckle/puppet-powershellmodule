require 'spec_helper'

provider_class = Puppet::Type.type(:psrepository).provider(:windowspowershell)

describe provider_class do
  before(:each) do
    type = Puppet::Type.type(:psrepository).new(
      name: :repo, source_location: 'http://source.com',
      installation_policy: :trusted
    )
    @provider_instance = provider_class.new(type)
    allow(provider_class).to receive(:invoke_ps_command).and_return(nil)
    allow(provider_class).to receive(:invoke_ps_command).with(
      provider_class.instances_command
    ).and_return(
      [
        '{"name":"Repo1","source_location":"https://repo1.com","installation_policy":"untrusted","provider":"windowspowershell"}',
        '{"name":"Repo2","source_location":"https://repo2.com","installation_policy":"trusted","provider":"windowspowershell"}'
      ]
    )
  end
  describe :instances do
    specify 'returns an array of :windowspowershell providers' do
      instances = provider_class.instances
      expect(instances.count).to eq(2)
      expect(instances).to all(be_instance_of(provider_class))
    end
    specify 'sets the property hash for each provider' do
      instances = provider_class.instances
      expect(instances[0].instance_variable_get('@property_hash')).to eq(
        name: 'Repo1', ensure: :present, source_location: 'https://repo1.com',
        installation_policy: 'untrusted', provider: 'windowspowershell'
      )
      expect(instances[1].instance_variable_get('@property_hash')).to eq(
        name: 'Repo2', ensure: :present, source_location: 'https://repo2.com',
        installation_policy: 'trusted', provider: 'windowspowershell'
      )
    end
  end
  describe :prefetch do
    specify 'sets the provider instance of the managed resource to a provider with the fetched state' do
      repo_resource1 = spy('psrepository', name: 'Repo1')
      repo_resource2 = spy('psrepository', name: 'Repo2')
      provider_class.prefetch(
        'Repo1' => repo_resource1,
        'Repo2' => repo_resource2
      )
      expect(repo_resource1).to have_received(:provider=).with(
        provider_class.instances[0]
      )
      expect(repo_resource2).to have_received(:provider=).with(
        provider_class.instances[1]
      )
    end
  end
  describe :exists? do
    specify 'returns true if the resource already exists' do
      existing_instance = provider_class.instances[0]
      expect(existing_instance.exists?).to be true
    end
    specify 'returns false if the resource does not exist' do
      expect(@provider_instance.exists?).to be false
    end
  end
  describe :flush do
    specify 'calls set-psrepository with updated parameters' do
      @provider_instance.source_location = 'http://newsource.com'
      @provider_instance.installation_policy = 'untrusted'
      @provider_instance.flush
      expect(provider_class).to have_received(:invoke_ps_command).with(
        "Set-PSRepository repo -sourcelocation 'http://newsource.com' -installationpolicy 'untrusted'"
      )
    end
  end
end
