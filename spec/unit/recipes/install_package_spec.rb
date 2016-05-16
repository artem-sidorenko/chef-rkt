#
# Cookbook Name:: rkt
#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

require 'spec_helper'

describe 'rkt::install_package' do
  let(:chef_run) do
    ChefSpec::SoloRunner.converge(described_recipe)
  end

  it 'should install rkt package' do
    expect(chef_run).to install_package('rkt')
  end
end
