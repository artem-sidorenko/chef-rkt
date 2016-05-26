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
  let(:platform_family) { 'rhel' }
  let(:platform) { 'centos' }
  let(:platform_version) { '7.2.1511' }
  let(:manage_repository) { true }
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.automatic['platform_family'] = platform_family
      node.automatic['platform'] = platform
      node.automatic['platform_version'] = platform_version
      node.set['rkt']['install']['package']['manage_repository'] = manage_repository
    end.converge(described_recipe)
  end

  context 'repository management is enabled' do
    let(:manage_repository) { true }

    it 'should include repository management recipe' do
      expect(chef_run).to include_recipe 'rkt::repository'
    end
  end

  context 'repository management is disabled' do
    let(:manage_repository) { false }

    it 'should include repository management recipe' do
      expect(chef_run).not_to include_recipe 'rkt::repository'
    end
  end

  it 'should install rkt package' do
    expect(chef_run).to install_package('rkt')
  end
end
