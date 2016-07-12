#
# Cookbook Name:: rkt_test
# Recipe:: test_net
#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

# This recipe creates some different networks with rkt_net LWRP,
# then creates some pods with rkt_pod LWRP

rkt_net 'netdeleted' do
  type 'ptp'
  ipam type: 'host-local',
       subnet: '192.168.10.0/24'
end

rkt_net 'netdeleted' do
  action :delete
end

# This will be checked by InSpec
rkt_net 'testnet' do
  type 'ptp'
  ipam type: 'host-local',
       subnet: '192.168.0.0/24'
end

rkt_pod 'dnsmasq-with-2nd-net' do
  action :create
  image 'coreos.com/dnsmasq:v0.3.0'
  net testnet: '192.168.0.10'
end
