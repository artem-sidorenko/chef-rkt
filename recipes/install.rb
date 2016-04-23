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

case node['rkt']['install']['type']
when 'tgz'
  include_recipe "#{cookbook_name}::install_tgz"
when 'package'
  include_recipe "#{cookbook_name}::install_package"
else
  raise "Unsupported installation type '#{node['rkt']['install']['type']}'"
end
