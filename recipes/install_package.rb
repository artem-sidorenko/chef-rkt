#
# Cookbook Name:: rkt
# Recipe:: install_package
#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

if node['rkt']['install']['package']['manage_repository']
  include_recipe "#{cookbook_name}::repository"
end

package node['rkt']['install']['package']['name']
