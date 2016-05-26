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
  let(:install_type) { 'tgz' }
  let(:systemd_system) { true }
  let(:ubuntu_platform) { true }
  let(:platform_family) { 'debian' }
  let(:platform_version) { '16.04' }
  let(:kernel_release) { '4.4.0-22-generic' }
  let(:kernel_parsed_release) { '4.4' }
  let(:kernel_check_enabled) { true }
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['rkt']['install']['type'] = install_type
      node.set['rkt']['install']['kernel_check'] = kernel_check_enabled
      node.automatic['packages']['systemd'] = systemd_system ? { version: '229-XYZ' } : nil
      node.automatic['platform'] = ubuntu_platform ? 'ubuntu' : 'someotherplatform'
      node.automatic['platform_family'] = platform_family
      node.automatic['platform_version'] = platform_version
      node.automatic['kernel']['release'] = kernel_release
    end.converge(described_recipe)
  end

  describe 'kernel version check' do
    before do
      @err_message = ''
      @err_message << "Unsupported kernel version #{kernel_parsed_release}:\n"
      @err_message << "\n"
      @err_message << "On kernel <3.18 you might face problems with overlayfs:\n"
      @err_message << " - https://github.com/coreos/rkt/blob/master/Documentation/dependencies.md#run-time-dependencies\n" # rubocop:disable Metrics/LineLength
      @err_message << " - https://github.com/coreos/rkt/issues/1922\n"
      @err_message << "\n"
      @err_message << "You can set node['rkt']['install']['kernel_check'] = false\n"
      @err_message << "to disable this check\n"
      if platform_family == 'rhel'
        @err_message << "\n"
        @err_message << "On RHEL family you can use the mainline kernel from ELRepo\n"
        @err_message << "You can use the recipe rkt::install_mainline_kernel in order to set it up\n"
      end
    end

    context 'kernel <3.18 on centos' do
      let(:kernel_release) { '3.10.0-229.14.1.el7.x86_64' }
      let(:kernel_parsed_release) { '3.10' }
      let(:platform_family) { 'rhel' }

      it 'should raise an exception' do
        expect { chef_run }.to raise_error(RuntimeError, @err_message)
      end

      context 'kernel check is disabled' do
        let(:kernel_check_enabled) { false }

        it 'should not raise an exception' do
          expect { chef_run }.not_to raise_error
        end
      end
    end

    context 'kernel <3.18 on debian 8.4' do
      let(:kernel_release) { '3.16.0-4-amd64' }
      let(:kernel_parsed_release) { '3.16' }
      let(:platform_family) { 'debian' }

      it 'should raise an exception' do
        expect { chef_run }.to raise_error(RuntimeError, @err_message)
      end

      context 'kernel check is disabled' do
        let(:kernel_check_enabled) { false }

        it 'should not raise an exception' do
          expect { chef_run }.not_to raise_error
        end
      end
    end

    context 'kernel >=3.18 on ubuntu 14.04' do
      let(:kernel_release) { '3.19.0-32-generic' }
      let(:kernel_parsed_release) { '3.19' }
      let(:platform_family) { 'debian' }

      it 'should not raise an exception' do
        expect { chef_run }.not_to raise_error
      end
    end

    context 'kernel >=3.18 on ubuntu 16.04' do
      let(:kernel_release) { '4.4.0-22-generic' }
      let(:kernel_parsed_release) { '4.4' }
      let(:platform_family) { 'debian' }

      it 'should not raise an exception' do
        expect { chef_run }.not_to raise_error
      end
    end
  end

  describe 'machinectl installation' do
    context 'ubuntu with systemd' do
      let(:systemd_system) { true }
      let(:ubuntu_platform) { true }

      it 'should install systemd-container' do
        expect(chef_run).to install_package('systemd-container')
      end
    end

    context 'non-ubuntu with systemd' do
      let(:systemd_system) { true }
      let(:ubuntu_platform) { false }

      it 'should not install systemd-container' do
        expect(chef_run).not_to install_package('systemd-container')
      end
    end

    context 'ubuntu without systemd' do
      let(:systemd_system) { false }
      let(:ubuntu_platform) { true }

      it 'should not install systemd-container' do
        expect(chef_run).not_to install_package('systemd-container')
      end
    end
  end

  describe 'invoke the installation recipe' do
    context 'unknown installation type' do
      let(:install_type) { 'none' }

      it 'should raise an exception' do
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
end
