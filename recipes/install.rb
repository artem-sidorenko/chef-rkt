#
# Cookbook Name:: rkt
# Recipe:: install
#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

# check the kernel version
if node['rkt']['install']['kernel_check']
  kernel_release = node['kernel']['release'].match(/^(\d*\.\d*)\./)[1]
  if Gem::Version.new(kernel_release) < Gem::Version.new('3.18')
    err_message = ''
    err_message << "Unsupported kernel version #{kernel_release}:\n"
    err_message << "\n"
    err_message << "On kernel <3.18 you might face problems with overlayfs:\n"
    err_message << " - https://github.com/coreos/rkt/blob/master/Documentation/dependencies.md#run-time-dependencies\n"
    err_message << " - https://github.com/coreos/rkt/issues/1922\n"
    err_message << "\n"
    err_message << "You can set node['rkt']['install']['kernel_check'] = false\n"
    err_message << "to disable this check\n"
    if node['platform_family'] == 'rhel'
      err_message << "\n"
      err_message << "On RHEL family you can use the mainline kernel from ELRepo\n"
      err_message << "You can use the recipe rkt::install_mainline_kernel in order to set it up\n"
    end
    raise err_message
  end
end

# install machinectl on ubuntu
package 'systemd-container' if node['packages']['systemd'] && node['platform'] == 'ubuntu'

case node['rkt']['install']['type']
when 'tgz'
  include_recipe "#{cookbook_name}::install_tgz"
when 'package'
  include_recipe "#{cookbook_name}::install_package"
else
  raise "Unsupported installation type '#{node['rkt']['install']['type']}'"
end

# create conf directory for networks
directory node['rkt']['conf']['net_conf_dir'] do
  owner 'root'
  group 'root'
  mode '0750'
end
