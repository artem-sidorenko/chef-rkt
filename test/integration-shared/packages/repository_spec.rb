#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

# Here we test if rkt repository configuration was Ok

if os['family'] == 'centos'
  describe file('/etc/pki/rpm-gpg/RPM-GPG-KEY-RKT') do
    it { should be_file }
  end

  describe file('/etc/yum.repos.d/rkt.repo') do
    it { should be_file }
  end
elsif os['family'] == 'ubuntu' || os['family'] == 'debian'
  describe file('/etc/apt/sources.list.d/rkt.list') do
    it { should be_file }
  end
else
  raise "Unsupported platform family #{os['family']}"
end
