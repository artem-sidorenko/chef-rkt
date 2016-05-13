#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

# Here we verify the test resources created in rkt_test cookbook

# recipe: test_trust
describe file('/etc/rkt/trustedkeys/prefix.d/coreos.com/dnsmasq') do
  it { should be_directory }
end

describe file('/etc/rkt/trustedkeys/prefix.d/coreos.com/dnsmasq/18ad5014c99ef7e3ba5f6ce950bdd3e0fc8a365e') do
  it { should be_file }
end

# recipe: test_image
describe command('rkt image list --no-legend=true --fields=name') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match 'coreos.com/dnsmasq:v0.2.0' }
end

# recipe: test_pod
describe command('rkt list --no-legend=true') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match '.*dnsmasq.*coreos.com/dnsmasq:v0.2.0.*running.*' }
end

describe service('rkt-dnsmasq') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
