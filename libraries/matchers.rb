#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

# Matchers for ChefSpec unit tests

if defined?(ChefSpec)
  def create_rkt_trust(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:rkt_trust, :create, resource_name)
  end

  def delete_rkt_trust(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:rkt_trust, :delete, resource_name)
  end
end
