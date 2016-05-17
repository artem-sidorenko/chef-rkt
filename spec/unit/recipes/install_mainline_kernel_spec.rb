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

describe 'rkt::install_mainline_kernel' do
  let(:platform_family) { 'rhel' }
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.automatic['platform_family'] = platform_family
    end.converge(described_recipe)
  end

  context 'run on the non RHEL family' do
    let(:platform_family) { 'debian' }

    it 'should raise an exception' do
      expect { chef_run }.to raise_error(RuntimeError, 'This recipe supports only RHEL family')
    end
  end

  context 'run on the RHEL family' do
    let(:platform_family) { 'rhel' }

    it 'should not raise an exception' do
      expect { chef_run }.not_to raise_error
    end

    it 'creates the RPM GPG key of elrepo' do
      expect(chef_run).to render_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org')
    end

    it 'creates the yum repository elrepo-kernel' do
      expect(chef_run).to create_yum_repository('elrepo-kernel')
      expect(chef_run).to create_yum_repository('elrepo-kernel').with(enabled: false)
    end

    it 'installs mainline kernel from elrepo-kernel' do
      expect(chef_run).to install_package('kernel-ml')
      expect(chef_run).to install_package('kernel-ml').with(options: '--enablerepo=elrepo-kernel')
    end
  end
end
