require 'spec_helper'

describe Puppet::Type.type(:psrepository) do
  let(:resource) { described_class.new(name: 'psrepository') }
  subject { resource }

  let :params do
    [
      :name
    ]
  end

  let :properties do
    [
      :ensure,
      :source_location,
      :installation_policy
    ]
  end

  it 'should have expected properties' do
    expect(described_class.properties.map(&:name)).to include(*properties)
  end

  it 'should have expected parameters' do
    expect(described_class.parameters).to include(*params)
  end

  it 'should not have unexpected properties' do
    expect(properties).to include(*described_class.properties.map(&:name))
  end

  it 'should not have unexpected parameters' do
    expect(params + [:provider]).to include(*described_class.parameters)
  end

  describe 'parameter :name' do
    subject { resource.parameters[:name] }

    it { is_expected.to be_isnamevar }

    it 'should not allow nil' do
      expect {
        resource[:name] = nil
      }.to raise_error(Puppet::Error, /Got nil value for name/)
    end

    it 'should not allow empty' do
      expect {
        resource[:name] = ''
      }.to raise_error(Puppet::ResourceError, /A non-empty name must/)
    end

    ['value', 'value with spaces', 'UPPER CASE', '0123456789_-', 'With.Period'].each do |value|
      it "should accept '#{value}'" do
        expect { resource[:name] = value }.not_to raise_error
      end
    end

    ['*', '()', '[]', '!@'].each do |value|
      it "should reject '#{value}'" do
        expect { resource[:name] = value }.to raise_error(Puppet::ResourceError, /is not a valid name/)
      end
    end
  end

  describe 'parameter :source_location' do
    it 'should not allow nil' do
      expect {
        resource[:source_location] = nil
      }.to raise_error(Puppet::Error, /Got nil value for source_location/)
    end

    it 'should not allow empty' do
      expect {
        resource[:source_location] = ''
      }.to raise_error(Puppet::ResourceError, /A non-empty source_location must/)
    end

    it 'should accept valid string value' do
      resource[:source_location] = 'https://repo1.com'
      resource[:source_location] = 'https://repo2.com'
    end

    ['value', 'value with spaces', 'UPPER CASE', '0123456789_-', 'With.Period'].each do |value|
      it "should reject '#{value}'" do
        expect { resource[:source_location] = value }.to raise_error(Puppet::ResourceError, /should be a valid URI/)
      end
    end
  end

  context 'parameter :installation_policy' do
    it 'should not allow nil' do
      expect {
        resource[:installation_policy] = nil
      }.to raise_error(Puppet::Error, /Got nil value for installation_policy/)
    end

    it 'should not allow empty' do
      expect {
        resource[:installation_policy] = ''
      }.to raise_error(Puppet::ResourceError, /Invalid value "". Valid values are trusted, untrusted/)
    end

    it 'should accept valid string value' do
      resource[:installation_policy] = 'trusted'
      resource[:installation_policy] = 'untrusted'
    end

    it 'should not accept invalid string value' do
      expect {
        resource[:installation_policy] = 'woot'
      }.to raise_error(Puppet::ResourceError, %r{Invalid value "woot". Valid values are trusted, untrusted.})
    end
  end
end
