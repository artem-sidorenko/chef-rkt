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

require_relative '../libraries/helpers'

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
      cmd_args = [image_url]
      cmd_args << '--no-store=true' if no_store
      cmd_args << '--trust-keys-from-https=true' if trust_keys_from_https
      rkt_run_cmd('fetch', cmd_args, 'create')
    end
  end
end

action :delete do
  image_id = rkt_image_name_to_id(image_url)
  if !image_id
    Chef::Log.info("#{new_resource} doesn't exists - nothing to do")
  else
    converge_by("#{new_resource} deleting image id #{image_id}") do
      rkt_run_cmd('image rm', [image_id], 'delete')
    end
  end
end
