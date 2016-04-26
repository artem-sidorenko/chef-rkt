#
# Cookbook Name:: rkt
# LWRP:: rkt_pod
#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

property :image, String
property :trust_keys_from_https, [TrueClass, FalseClass], default: false

default_action :create

action :create do
  raise 'Not implemented'
end

action :delete do
  raise 'Not implemented'
end
