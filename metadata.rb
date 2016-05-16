name 'rkt'
maintainer 'Artem Sidorenko'
maintainer_email 'artem@posteo.de'
license 'Apache 2.0'
description 'This cookbook allows management of coreos rkt'
source_url 'https://gitlab.com/artem-sidorenko/chef-rkt'
issues_url 'https://gitlab.com/artem-sidorenko/chef-rkt/issues'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.0.1'

depends 'systemd'

supports 'centos', '>= 7.2'
supports 'scientific', '>= 7.2'
supports 'oracle', '>= 7.2'
supports 'redhat', '>= 7.2'
supports 'ubuntu', '>= 14.04'
