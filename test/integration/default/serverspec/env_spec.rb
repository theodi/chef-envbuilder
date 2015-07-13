require 'serverspec'
set :backend, :exec

describe file '/home/vagrant/env' do
  it { should be_file }
  its(:content) { should match /DEFAULT: value/ }
end
