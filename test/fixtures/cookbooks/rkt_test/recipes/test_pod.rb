#
# Cookbook Name:: rkt_test
# Recipe:: test_pod
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

# this will be checked by InSpec later
rkt_pod 'dnsmasq' do
  action :create
  image 'coreos.com/dnsmasq:v0.2.0'
end

# wait about 5 secs: pod spawning takes some time,
# and if we continue directly we might get false-positivies in our tests
ruby_block 'sleep-for-5-secs' do
  block do
    sleep(5)
  end
  action :run
end
