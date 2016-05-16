#
# Cookbook Name:: rkt_test
# Recipe:: repositories
#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

# This recipe configures repositories for rkt installation
# Currently this are temporary repos with custom packages of rkt

case node['platform_family']
when 'rhel'
  yum_repository 'rkt' do
    description 'rkt repo'
    baseurl 'https://users.2realities.com/~artem/rkt/rpm/'
    gpgcheck false
    action :create
  end
when 'debian'
  package 'apt-transport-https'

  apt_repository 'rkt' do
    uri 'https://users.2realities.com/~artem/rkt/deb/'
    components ['/']
    distribution ''
    trusted true
  end
end
