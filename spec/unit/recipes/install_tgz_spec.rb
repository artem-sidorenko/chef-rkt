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

describe 'rkt::install_tgz' do
  let(:cache_path) { '/var/chef/cache/rkt' }
  let(:install_target_dir) { '/opt/rkt' }
  let(:rkt_version) { '1.6.0' }
  let(:setup_with_sudo) { false }

  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['rkt']['install']['tgz']['sudo'] = setup_with_sudo
      node.set['rkt']['install']['tgz']['version'] = rkt_version
    end.converge(described_recipe)
  end

  it 'should create the cache structure' do
    expect(chef_run).to create_directory(cache_path)
    expect(chef_run).to create_cookbook_file("#{cache_path}/coreos_app_sign.key")
  end

  it 'should download the rkt archive and signature' do
    expect(chef_run).to create_remote_file("#{cache_path}/rkt-v#{rkt_version}.tar.gz")
    expect(chef_run).to create_remote_file("#{cache_path}/rkt-v#{rkt_version}.tar.gz.sig")
  end

  it 'should check the signature if needed' do
    expect(chef_run.bash('check signature')).to do_nothing
    expect(chef_run.remote_file("#{cache_path}/rkt-v#{rkt_version}.tar.gz.sig"))
      .to notify('bash[check signature]').to(:run).immediately
  end

  it 'should unpack rkt to target install dir if needed' do
    expect(chef_run).to create_directory(install_target_dir)
    expect(chef_run.bash('unpack rkt')).to do_nothing
    expect(chef_run.bash('check signature'))
      .to notify('bash[unpack rkt]').to(:run).immediately
  end

  it 'should create rkt group' do
    expect(chef_run).to create_group('rkt')
  end

  it 'should create required folders for rkt' do
    expect(chef_run).to create_directory('/etc/rkt')
    expect(chef_run).to create_directory('/usr/lib/rkt')
    expect(chef_run).to create_directory('/var/lib/rkt')
  end

  it 'should create garbage collection cron job' do
    expect(chef_run).to create_cookbook_file('/etc/cron.hourly/1rkt-gc')
  end

  context 'setup with sudo' do
    let(:setup_with_sudo) { true }

    it 'should install sudo package' do
      expect(chef_run).to install_package('sudo')
    end

    it 'should create sudoers configuration' do
      expect(chef_run).to render_file('/etc/sudoers.d/rkt')
    end

    it 'should create rkt wrapper' do
      expect(chef_run).to create_cookbook_file('/usr/bin/rkt').with(source: 'sudo-rkt-wrapper')
    end
  end

  context 'setup without sudo' do
    let(:setup_with_sudo) { false }

    it 'should have restricted permission on rkt binary' do
      expect(chef_run).to create_file('/opt/rkt/rkt').with(mode: '0700')
    end

    it 'should create rkt symlink' do
      expect(chef_run).to create_link('/usr/bin/rkt').with(to: '/opt/rkt/rkt')
    end
  end
end
