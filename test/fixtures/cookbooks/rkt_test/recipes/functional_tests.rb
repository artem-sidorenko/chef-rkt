#
# Cookbook Name:: rkt_test
# Recipe:: functional_tests
#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

# This recipe calls runs other recipes with
# tests for rkt cookbook

include_recipe "#{cookbook_name}::test_trust"
