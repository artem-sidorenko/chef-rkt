#
# Cookbook Name:: rkt
# Recipe:: install_mainline_kernel
#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

# This recipe configures ELRepo repository
# and installs the mainline linux kernel

raise 'This recipe supports only RHEL family' unless node['platform_family'] == 'rhel'

cookbook_file '/etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org' do
  source 'rpm-gpg-elrepo.key'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

yum_repository 'elrepo-kernel' do
  description 'ELRepo.org Community Enterprise Linux Kernel Repository - el7'
  baseurl 'http://elrepo.org/linux/kernel/el7/$basearch/
           http://mirrors.coreix.net/elrepo/kernel/el7/$basearch/
           http://jur-linux.org/download/elrepo/kernel/el7/$basearch/
           http://repos.lax-noc.com/elrepo/kernel/el7/$basearch/
           http://mirror.ventraip.net.au/elrepo/kernel/el7/$basearch/'
  mirrorlist 'http://mirrors.elrepo.org/mirrors-elrepo-kernel.el7'
  enabled false
  gpgcheck true
  gpgkey 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org'
  action :create
end

package 'kernel-ml' do
  action :install
  options '--enablerepo=elrepo-kernel'
end
