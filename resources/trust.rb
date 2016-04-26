#
# Cookbook Name:: rkt
# LWRP:: rkt_trust
#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

property :prefix, String
property :insecure_allow_http, [TrueClass, FalseClass], default: false
property :skip_fingerprint_review, [TrueClass, FalseClass], default: false
property :trust_keys_from_https, [TrueClass, FalseClass], default: false
property :root, [TrueClass, FalseClass], default: false
property :pubkey, String

default_action :create

action :create do
  raise 'Not implemented'
end

action :delete do
  raise 'Not implemented'
end
