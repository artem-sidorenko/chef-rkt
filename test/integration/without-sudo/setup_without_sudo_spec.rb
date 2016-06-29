#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

# Here we test if rkt setup without sudo was Ok

describe file('/usr/bin/rkt') do
  it { should be_symlink }
  it { should be_linked_to '/opt/rkt/rkt' }
end

describe file('/opt/rkt/rkt') do
  it { should be_executable }
  its('mode') { should eq 0700 }
end
