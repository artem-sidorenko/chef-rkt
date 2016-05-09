#
# Cookbook Name:: rkt_test
# Recipe:: test_trust
#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

# This recipe creates some different resources with rkt_trust LWRP
# and triggers different actions

rkt_trust 'coreos.com/etcd-trust-create' do
  prefix 'coreos.com/etcd'
  action :create
  trust_keys_from_https true
end

rkt_trust 'coreos.com/etcd-trust-delete' do
  prefix 'coreos.com/etcd'
  action :delete
end

# this will be checked by InSpec later
rkt_trust 'coreos.com/dnsmasq' do
  action :create
  trust_keys_from_https true
end
