require 'spec_helper'
describe 'powershellmodule' do
  context 'with default values for all parameters' do
    it { should contain_class('powershellmodule') }
  end
end
