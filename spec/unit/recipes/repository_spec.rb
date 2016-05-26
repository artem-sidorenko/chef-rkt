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

describe 'rkt::repository' do
  let(:platform_family) { 'rhel' }
  let(:platform) { 'centos' }
  let(:platform_version) { '7.2.1511' }
  let(:distro_url_postfix) { '' }

  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.automatic['platform_family'] = platform_family
      node.automatic['platform'] = platform
      node.automatic['platform_version'] = platform_version
      node.set['rkt']['install']['package']['repository_base_location'] = 'http://repo-url'
    end.converge(described_recipe)
  end

  before do
    @unsupported_platform_message = "Unsupported platform #{platform} with version #{platform_version} and family #{platform_family}" # rubocop:disable Metrics/LineLength
    @repository_url = "http://repo-url#{distro_url_postfix}"
  end

  context 'unsupported family' do
    let(:platform_family) { 'someunsupportedfamily' }

    it 'should raise an exception' do
      expect { chef_run }.to raise_error(RuntimeError, 'Unsupported family someunsupportedfamily')
    end
  end

  describe 'rhel family' do
    let(:platform_family) { 'rhel' }

    context 'centos 7.2 distribution' do
      let(:platform) { 'centos' }
      let(:platform_version) { '7.2.1511' }
      let(:distro_url_postfix) { '/CentOS_7/' }

      it 'should create repo gpg key' do
        expect(chef_run).to render_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-RKT')
      end

      it 'should create repository' do
        expect(chef_run).to create_yum_repository('rkt').with(baseurl: @repository_url)
      end
    end

    context 'unsupported centos version' do
      let(:platform) { 'centos' }
      let(:platform_version) { '6.7' }

      it 'should raise an exception' do
        expect { chef_run }.to raise_error(RuntimeError, @unsupported_platform_message)
      end
    end

    context 'unsupported distribution' do
      let(:platform) { 'someunsupporteddistro' }
      let(:platform_version) { '10.1.3' }

      it 'should raise an exception' do
        expect { chef_run }.to raise_error(RuntimeError, @unsupported_platform_message)
      end
    end
  end

  describe 'debian family' do
    let(:platform_family) { 'debian' }

    context 'ubuntu 16.04 distribution' do
      let(:platform) { 'ubuntu' }
      let(:platform_version) { '16.04' }
      let(:distro_url_postfix) { '/Ubuntu_16.04/' }

      it 'should create repository' do
        expect(chef_run).to add_apt_repository('rkt').with(uri: @repository_url)
      end
    end

    context 'ubuntu 14.04 distribution' do
      let(:platform) { 'ubuntu' }
      let(:platform_version) { '14.04' }
      let(:distro_url_postfix) { '/Ubuntu_14.04/' }

      it 'should create repository' do
        expect(chef_run).to add_apt_repository('rkt').with(uri: @repository_url)
      end
    end

    context 'mint 17 distribution' do
      let(:platform) { 'linuxmint' }
      let(:platform_version) { '17.3' }
      let(:distro_url_postfix) { '/Ubuntu_14.04/' }

      it 'should create repository' do
        expect(chef_run).to add_apt_repository('rkt').with(uri: @repository_url)
      end
    end

    context 'debian 8.4 distribution' do
      let(:platform) { 'debian' }
      let(:platform_version) { '8.4' }
      let(:distro_url_postfix) { '/Debian_8.0/' }

      it 'should create repository' do
        expect(chef_run).to add_apt_repository('rkt').with(uri: @repository_url)
      end
    end

    context 'unsupported distribution' do
      let(:platform) { 'someunsupporteddistro' }
      let(:platform_version) { '15.1.3' }

      it 'should raise an exception' do
        expect { chef_run }.to raise_error(RuntimeError, @unsupported_platform_message)
      end
    end
  end
end
