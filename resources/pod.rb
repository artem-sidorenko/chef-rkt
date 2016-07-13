#
# Cookbook Name:: rkt
# LWRP:: rkt_pod
#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

property :name, String, name_property: true
property :image, String, required: true
property :trust_keys_from_https, [TrueClass, FalseClass], default: false
property :volumes, Hash, default: {}
property :net, [String, Array, Hash]

default_action :create

action :create do
  service_name = "rkt-#{name}"
  cmd_args = []
  cmd_args << '--trust-keys-from-https=true' if trust_keys_from_https

  volumes.each do |volume, options|
    options[:kind] ||= 'host'
    raise "source option isn't configured for volume #{volume} in resource #{new_resource}" unless options[:source]

    cmd_args << "--volume=#{volume},kind=#{options[:kind]},source=#{options[:source]}"
  end

  case net.class.to_s
  when 'String'
    cmd_args << "--net=#{net}"
  when 'Array'
    cmd_string = net.join(',')
    cmd_args << "--net=#{cmd_string}"
  when 'Hash'
    net_values = []
    net.each do |net, ip|
      net_values << "#{net}:IP=#{ip}"
    end
    cmd_string = net_values.join(',')
    cmd_args << "--net=#{cmd_string}"
  end

  args = cmd_args.join(' ')
  exec_cmd = "/usr/bin/rkt run #{args} #{image}"

  if node['packages']['upstart']
    template "/etc/init/#{service_name}.conf" do
      source 'ubuntu/upstart/rkt-pod.conf.erb'
      mode 0644
      cookbook 'rkt'
      variables(
        pod_name: name,
        service_name: service_name,
        cmd: exec_cmd
      )
      notifies :restart, "service[#{service_name}]"
    end
  elsif node['packages']['systemd']
    systemd_service service_name do
      description name
      slice 'machine.slice'
      service do
        exec_start exec_cmd
        kill_mode 'mixed'
        restart 'always'
      end
      install do
        wanted_by 'multi-user.target'
      end
      notifies :restart, "service[#{service_name}]"
    end
  else
    raise "#{new_resource} action :create failed,
           Can't find one of supported init systems:
            - systemd
            - upstart
          "
  end

  service service_name do
    action [:enable, :start]
  end
end

action :delete do
  service_name = "rkt-#{name}"

  service service_name do
    action [:stop, :disable]
  end
  if node['packages']['upstart']
    file "/etc/init/#{service_name}.conf" do
      action :delete
    end
  elsif node['packages']['systemd']
    systemd_service service_name do
      action :delete
    end
  else
    raise "#{new_resource} action :delete failed,
           Can't find one of supported init systems:
            - systemd
            - upstart
          "
  end
end
