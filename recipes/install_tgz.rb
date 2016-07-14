#
# Cookbook Name:: rkt
# Recipe:: install_tgz
#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

cache_path = "#{Chef::Config[:file_cache_path]}/#{cookbook_name}"
version = node['rkt']['install']['tgz']['version']
install_target_dir = node['rkt']['install']['tgz']['target_dir']
install_target_bin = node['rkt']['install']['tgz']['target_bin']

directory cache_path do
  mode '0700'
  owner 'root'
  group 'root'
end

cookbook_file "#{cache_path}/coreos_app_sign.key" do
  source 'coreos_app_sign.key'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

remote_file "#{cache_path}/rkt-v#{version}.tar.gz" do
  source "https://github.com/coreos/rkt/releases/download/v#{version}/rkt-v#{version}.tar.gz"
  owner 'root'
  group 'root'
  mode '0600'
  action :create
end

remote_file "#{cache_path}/rkt-v#{version}.tar.gz.asc" do
  source "https://github.com/coreos/rkt/releases/download/v#{version}/rkt-v#{version}.tar.gz.asc"
  owner 'root'
  group 'root'
  mode '0600'
  action :create
  notifies :run, 'bash[check signature]', :immediately
end

bash 'check signature' do
  code <<-EOS
  rm -rf "#{cache_path}/gpghome"
  mkdir -p "#{cache_path}/gpghome"
  export GNUPGHOME="#{cache_path}/gpghome"
  gpg --import "#{cache_path}/coreos_app_sign.key"
  gpg --verify "#{cache_path}/rkt-v#{version}.tar.gz.asc"
  rm -rf "#{cache_path}/gpghome"
  EOS
  flags '-e'
  action :nothing
  notifies :create, "directory[#{install_target_dir}]", :immediately
  notifies :run, 'bash[unpack rkt]', :immediately
end

directory install_target_dir do
  mode '0755'
  owner 'root'
  group 'root'
  notifies :run, 'bash[unpack rkt]', :immediately
end

bash 'unpack rkt' do
  code <<-EOS
  rm -rf "#{cache_path}/unpacked"
  mkdir -p "#{cache_path}/unpacked"
  tar xfzC "#{cache_path}/rkt-v#{version}.tar.gz" "#{cache_path}/unpacked"
  cp "#{cache_path}/unpacked/rkt-v#{version}/rkt" "#{install_target_dir}/rkt"
  cp #{cache_path}/unpacked/rkt-v#{version}/*.aci "#{install_target_dir}/"
  rm -rf "#{cache_path}/unpacked"
  EOS
  flags '-e'
  action :nothing
end

group node['rkt']['install']['tgz']['group_name'] do
  system true
end

directory node['rkt']['install']['tgz']['etc_dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory node['rkt']['install']['tgz']['usr_dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory node['rkt']['install']['tgz']['var_dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file '/etc/cron.hourly/1rkt-gc' do
  source 'cron.hourly-rkt-gc'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

if node['rkt']['install']['tgz']['sudo']
  package 'sudo'

  template '/etc/sudoers.d/rkt' do
    mode '0600'
    owner 'root'
    group 'root'
    source 'sudoers-rkt.erb'
    variables(
      group: node['rkt']['install']['tgz']['group_name'],
      rkt_bin: "#{install_target_dir}/rkt"
    )
  end

  cookbook_file install_target_bin do
    mode '0750'
    owner 'root'
    group node['rkt']['install']['tgz']['group_name']
    source 'sudo-rkt-wrapper'
  end
else
  file "#{install_target_dir}/rkt" do
    mode '0700'
    owner 'root'
    group 'root'
  end

  link install_target_bin do
    to "#{install_target_dir}/rkt"
  end
end
