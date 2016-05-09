#
# Cookbook Name:: rkt
# LWRP:: rkt_image
#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

property :image_url, String, name_property: true
property :no_store, [TrueClass, FalseClass], default: false
property :trust_keys_from_https, [TrueClass, FalseClass], default: false

default_action :create

def whyrun_supported?
  true
end

action :create do
  if rkt_image_name_to_id(image_url) && !no_store
    Chef::Log.info("#{new_resource} already exists - nothing to do")
  else
    converge_by("#{new_resource} fetching image #{image_url}") do
      cmd = "rkt fetch #{image_url}"
      cmd += ' --no-store=true' if no_store
      cmd += ' --trust-keys-from-https=true' if trust_keys_from_https
      run_cmd = Mixlib::ShellOut.new(cmd).run_command
      if run_cmd.error?
        raise "#{new_resource} action create failed, following command line was called: #{cmd}
              stdout:
              #{run_cmd.stdout}
              stderr:
              #{run_cmd.stderr}
              "
      end
    end
  end
end

action :delete do
  image_id = rkt_image_name_to_id(image_url)
  if !image_id
    Chef::Log.info("#{new_resource} doesn't exists - nothing to do")
  else
    converge_by("#{new_resource} deleting image id #{image_id}") do
      cmd = "rkt image rm #{image_id}"
      run_cmd = Mixlib::ShellOut.new(cmd).run_command
      if run_cmd.error?
        raise "#{new_resource} action delete failed, following command line was called: #{cmd}
              stdout:
              #{run_cmd.stdout}
              stderr:
              #{run_cmd.stderr}
              "
      end
    end
  end
end

def rkt_image_name_to_id(image_name)
  cmd = 'rkt image list'
  cmd += ' --no-legend=true --fields=id,name'
  run_cmd = Mixlib::ShellOut.new(cmd).run_command
  raise "#{new_resource} image check failed, following command line was called: #{cmd}" if run_cmd.error?
  images = {}
  run_cmd.stdout.split("\n").each do |line|
    values = line.split
    images[values[1]] = values[0]
  end
  images[image_name]
end
