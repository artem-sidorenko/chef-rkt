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

describe 'rkt::install' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['rkt']['install']['type'] = install_type
    end.converge(described_recipe)
  end

  context 'unknown installation type' do
    let(:install_type) { 'none' }

    it 'should raise an exeption' do
      expect { chef_run }.to raise_error(RuntimeError, 'Unsupported installation type \'none\'')
    end
  end

  context 'install from tgz' do
    let(:install_type) { 'tgz' }

    it 'includes installation recipe from tgz' do
      expect(chef_run).to include_recipe 'rkt::install_tgz'
    end
  end

  context 'install from package' do
    let(:install_type) { 'package' }

    it 'includes installation recipe from package' do
      expect(chef_run).to include_recipe 'rkt::install_package'
    end
  end
end
