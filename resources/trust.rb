#
# Cookbook Name:: rkt
# LWRP:: rkt_trust
#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

require_relative '../libraries/helpers'

require 'fileutils'

property :prefix, String, name_property: true
property :insecure_allow_http, [TrueClass, FalseClass], default: false
property :skip_fingerprint_review, [TrueClass, FalseClass], default: false
property :trust_keys_from_https, [TrueClass, FalseClass], default: false
property :pubkey, String

default_action :create

def whyrun_supported?
  true
end

trustedkeys_prefix_path = '/etc/rkt/trustedkeys/prefix.d'

action :create do
  # We do not support fingerprint verification by now, so lets fail
  # if we have no way to handle the fingerprint verification
  if !skip_fingerprint_review && !trust_keys_from_https
    raise "#{new_resource} - skip_fingerprint_review or trust_keys_from_https should be allowed"
  end
  if Dir.exist?("#{trustedkeys_prefix_path}/#{prefix}")
    Chef::Log.info("#{new_resource} already exists - nothing to do")
  else
    converge_by("#{new_resource} creating trust for prefix #{prefix}") do
      cmd_args = ["--prefix=#{prefix}"]
      cmd_args << '--skip-fingerprint-review=true' if skip_fingerprint_review
      cmd_args << '--insecure-allow-http=true' if insecure_allow_http
      cmd_args << '--trust-keys-from-https=true' if trust_keys_from_https
      rkt_run_cmd('trust', cmd_args, 'create')
    end
  end
end

action :delete do
  prefix_path = "#{trustedkeys_prefix_path}/#{prefix}"
  if !Dir.exist?(prefix_path)
    Chef::Log.info("#{new_resource} doesn't exists - nothing to do")
  else
    converge_by("#{new_resource} deleting trust for prefix #{prefix}") do
      FileUtils.remove_dir(prefix_path)
    end
  end
end
