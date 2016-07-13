#
# Cookbook Name:: rkt
# LWRP:: rkt_net
#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

require 'json'

property :name, String, name_property: true
property :type, String, required: true
property :options, Hash, default: {}
property :ipam, Hash, default: {}

default_action :create

action :create do
  rkt_net_file = ::File.join(node['rkt']['conf']['net_conf_dir'], "#{name}.conf")

  net_struct = {
    name: name,
    type: type,
    ipam: ipam
  }

  net_struct.merge!(options)

  file rkt_net_file do
    owner 'root'
    group 'root'
    mode '0640'
    content JSON.pretty_generate(net_struct)
  end
end

action :delete do
  rkt_net_file = ::File.join(node['rkt']['conf']['net_conf_dir'], "#{name}.conf")

  file rkt_net_file do
    action :delete
  end
end
