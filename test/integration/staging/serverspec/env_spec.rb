require 'serverspec'
set :backend, :exec

describe file '/home/vagrant/env' do
  it { should be_file }
  its(:content) { should match /WHAT: even/ }
  its(:content) { should match /KEY: staging-specific/ }
  its(:content) { should_not match /SOME_OTHER_KEY:/ }
end
