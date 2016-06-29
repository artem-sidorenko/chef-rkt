#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

# Here we test if rkt setup with sudo was Ok

describe file('/etc/sudoers.d/rkt') do
  it { should be_file }
  its('mode') { should eq 0600 }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
end

describe file('/usr/bin/rkt') do
  it { should be_executable }
  its('mode') { should eq 0750 }
  its('owner') { should eq 'root' }
  its('group') { should eq 'rkt' }
end
