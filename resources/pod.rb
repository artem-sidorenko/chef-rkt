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
property :image, String
property :trust_keys_from_https, [TrueClass, FalseClass], default: false

default_action :create

action :create do
  cmd_args = []
  cmd_args << '--trust-keys-from-https=true' if trust_keys_from_https
  args = cmd_args.join(' ')
  service_name = "rkt-#{name}"
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
  raise 'Not implemented'
end
