#
# Cookbook Name:: rkt
# Recipe:: repository
#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

# This recipe configures repositories for rkt installation
# We use repositoriy from OBS as we don't have any other options for now
# https://build.opensuse.org/project/show/home:artem_sidorenko:rkt

repo_url = node['rkt']['install']['package']['repository_base_location']
unsupported_platform_message = "Unsupported platform #{node['platform']} with version #{node['platform_version']} and family #{node['platform_family']}" # rubocop:disable Metrics/LineLength

case node['platform_family']
when 'rhel'
  gpg_key_file = '/etc/pki/rpm-gpg/RPM-GPG-KEY-RKT'

  if node['platform'] == 'centos' && node['platform_version'] =~ /^7\..*$/ # rubocop:disable Style/GuardClause
    repo_url = "#{repo_url}/CentOS_7/"
  else
    raise unsupported_platform_message
  end

  cookbook_file gpg_key_file do
    source 'gpg-rkt-repository.key'
    mode '0644'
    owner 'root'
    group 'root'
  end
  yum_repository 'rkt' do
    description 'rkt repository'
    baseurl repo_url
    gpgkey 'file://' + gpg_key_file
  end
when 'debian'
  if node['platform'] == 'ubuntu' && node['platform_version'] == '16.04'
    repo_url = "#{repo_url}/Ubuntu_16.04/"
  elsif (node['platform'] == 'ubuntu' && node['platform_version'] == '14.04') ||
        (node['platform'] == 'linuxmint' && node['platform_version'] =~ /^17\.3.*$/)
    repo_url = "#{repo_url}/Ubuntu_14.04/"
  elsif node['platform'] == 'debian' && node['platform_version'] =~ /^8\..*$/
    repo_url = "#{repo_url}/Debian_8.0/"
  else
    raise unsupported_platform_message
  end

  apt_repository 'rkt' do
    uri repo_url
    components ['/']
    distribution ''
    key 'gpg-rkt-repository.key'
  end
else
  raise "Unsupported family #{node['platform_family']}"
end
