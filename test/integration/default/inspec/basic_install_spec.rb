#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

# Here we test if rkt installation worked properly and as expected

describe file('/opt/rkt/rkt') do
  it { should be_executable }
end

describe file('/opt/rkt/stage1-coreos.aci') do
  it { should be_file }
end

describe group('rkt') do
  it { should exist }
end

describe file('/etc/rkt') do
  it { should be_directory }
  its('mode') { should eq 0755 }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
end

describe file('/usr/lib/rkt') do
  it { should be_directory }
  its('mode') { should eq 0755 }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
end

describe file('/var/lib/rkt') do
  it { should be_directory }
  its('mode') { should eq 0755 }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
end
