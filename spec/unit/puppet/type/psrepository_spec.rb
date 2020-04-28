require 'spec_helper'

describe Puppet::Type.type(:psrepository) do
  subject { resource }

  let(:resource) { described_class.new(name: 'psrepository') }
  let :params do
    [
      :name,
    ]
  end

  let :properties do
    [
      :ensure,
      :source_location,
      :installation_policy,
    ]
  end

  it 'has expected properties' do
    expect(described_class.properties.map(&:name)).to include(*properties)
  end

  it 'has expected parameters' do
    expect(described_class.parameters).to include(*params)
  end

  it 'does not have unexpected properties' do
    expect(properties).to include(*described_class.properties.map(&:name))
  end

  it 'does not have unexpected parameters' do
    expect(params + [:provider]).to include(*described_class.parameters)
  end

  describe 'parameter :name' do
    subject { resource.parameters[:name] }

    it { is_expected.to be_isnamevar }

    it 'does not allow nil' do
      expect {
        resource[:name] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for name})
    end

    it 'does not allow empty' do
      expect {
        resource[:name] = ''
      }.to raise_error(Puppet::ResourceError, %r{A non-empty name must})
    end

    ['value', 'value with spaces', 'UPPER CASE', '0123456789_-', 'With.Period'].each do |value|
      it "should accept '#{value}'" do
        expect { resource[:name] = value }.not_to raise_error
      end
    end

    ['*', '()', '[]', '!@'].each do |value|
      it "should reject '#{value}'" do
        expect { resource[:name] = value }.to raise_error(Puppet::ResourceError, %r{is not a valid name})
      end
    end
  end

  describe 'parameter :source_location' do
    it 'does not allow nil' do
      expect {
        resource[:source_location] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for source_location})
    end

    it 'does not allow empty' do
      expect {
        resource[:source_location] = ''
      }.to raise_error(Puppet::ResourceError, %r{A non-empty source_location must})
    end

    it 'accepts valid string value' do
      resource[:source_location] = 'https://repo1.com'
      resource[:source_location] = 'https://repo2.com'
    end

    ['value', 'value with spaces', 'UPPER CASE', '0123456789_-', 'With.Period'].each do |value|
      it "should reject '#{value}'" do
        expect { resource[:source_location] = value }.to raise_error(Puppet::ResourceError, %r{should be a valid URI})
      end
    end
  end

  context 'parameter :installation_policy' do
    it 'does not allow nil' do
      expect {
        resource[:installation_policy] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for installation_policy})
    end

    it 'does not allow empty' do
      expect {
        resource[:installation_policy] = ''
      }.to raise_error(Puppet::ResourceError, %r{Invalid value "". Valid values are trusted, untrusted})
    end

    it 'accepts valid string value' do
      resource[:installation_policy] = 'trusted'
      resource[:installation_policy] = 'untrusted'
    end

    it 'does not accept invalid string value' do
      expect {
        resource[:installation_policy] = 'woot'
      }.to raise_error(Puppet::ResourceError, %r{Invalid value "woot". Valid values are trusted, untrusted.})
    end
  end
end
