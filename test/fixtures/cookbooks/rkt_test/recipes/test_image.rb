#
# Cookbook Name:: rkt_test
# Recipe:: test_image
#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

# This recipe creates some different resources with rkt_image LWRP
# and triggers different actions

# Create trusts for etcd, fetch it, remove it
rkt_trust 'coreos.com/etcd-image-trust-create' do
  prefix 'coreos.com/etcd'
  action :create
  trust_keys_from_https true
end

rkt_image 'coreos.com/etcd:v2.3.0-image-create' do
  image_url 'coreos.com/etcd:v2.3.0'
  action :create
end

rkt_image 'coreos.com/etcd:v2.3.0-image-delete' do
  image_url 'coreos.com/etcd:v2.3.0'
  action :delete
end

rkt_trust 'coreos.com/etcd-image-trust-delete' do
  prefix 'coreos.com/etcd'
  action :delete
end

# this will be checked by InSpec later
rkt_image 'coreos.com/dnsmasq:v0.2.0' do
  action :create
  trust_keys_from_https true
end
