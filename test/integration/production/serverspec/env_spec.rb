require 'serverspec'
set :backend, :exec

describe file '/home/vagrant/env' do
  it { should be_file }
  its(:content) { should match /DEFAULT: overridden/ }
  its(:content) { should match /JUST_CANNOT: even/ }
  its(:content) { should match /KEY: from_master_list/ }
end
