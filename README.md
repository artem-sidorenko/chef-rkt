chef-rkt
========

[![build status](https://gitlab.com/artem-sidorenko/chef-rkt/badges/master/build.svg)](https://gitlab.com/artem-sidorenko/chef-rkt/commits/master) [![cookbook version](https://img.shields.io/cookbook/v/rkt.svg)](https://supermarket.chef.io/cookbooks/rkt)

-----------------------------------------------------------

This cookbook has its home on [gitlab.com] and has a mirror
on [github.com]. Development is done on [gitlab.com] only.

-----------------------------------------------------------

[Chef] cookbook for management of [coreos rkt].

* [Requirements](#requirements)
* [Usage](#usage)
* [Recipes](#recipes)
* [Resources](#resources)
* [Issues](#issues)
* [Contributing](#contributing)
* [License and copyright](#license-and-copyright)

Requirements
------------

Supported distributions:

* EL 7 (CentOS, RHEL, ...) (with kernel >=3.18)
* Ubuntu >=14.04
* Debian 8 (with kernel >=3.18)

rkt [requires](https://github.com/coreos/rkt/blob/master/Documentation/dependencies.md#run-time-dependencies) kernel >=3.18.

Recipe [install_mainline_kernel](#install_mainline_kernel) can help with installation of [mainline kernel] on EL 7 systems.

Usage
-----

### Installation of rkt

* Usage in other cookbook
  * Add `depends 'rkt'` to `metadata.rb` of your cookbook
  * Include it in some recipe:

```ruby
include_recipe 'rkt'
```

* Usage in the run list of your node

```json
{
  "name":"examplenode",
  "run_list": [
    "recipe[rkt]"
  ]
}
```

### Use rkt resources

Fetch and start etcd:

```ruby
rkt_image 'coreos.com/etcd:v2.3.0' do
  trust_keys_from_https true
end

rkt_pod 'myetcd' do
  image 'coreos.com/etcd:v2.3.0'
end
```

and the same with one command:

```ruby
rkt_pod 'myetcd' do
  image 'coreos.com/etcd:v2.3.0'
  trust_keys_from_https true
end
```

remove and cleanup:

```ruby
rkt_pod 'myetcd' do
  action :delete
end

rkt_image 'coreos.com/etcd:v2.3.0' do
  action :delete
end

rkt_trust 'coreos.com/etcd' do
  action :delete
end
```

Recipes
-------

Recipes in this cookbook can help with installation of [coreos rkt]. Management of rkt resources is done via [custom resources], which are documented [below](#resources).

### default

The default recipe invokes the installation recipe `install` only.

### install

This recipe is responsible for rkt installation and includes some other recipes if needed.

Two different installation types of rkt are supported:

* from [release tarballs with compiled rkt] - recipe `install_tgz`
* from packages - recipe `install_package`

There is also a check of kernel version for possible known issues.

#### Attributes

| Key                                | Default | Description                                  |
|------------------------------------|---------|----------------------------------------------|
| ['rkt']['install']['type']         | `tgz`   | Installation type of rkt                     |
| ['rkt']['install']['kernel_check'] | `true`  | Check the kernel version for possible issues |

### install_package

This recipe installs rkt from packages. If needed, repository configuration recipe `repository` gets invoked.

Currently almost no distributions are providing rkt packages, see more information on this topic [below](#repository).

#### Attributes

| Key                                                | Default | Description                                      |
|----------------------------------------------------|---------|--------------------------------------------------|
| ['rkt']['install']['package']['name']              | `rkt`   | Package name of rkt                              |
| ['rkt']['install']['package']['manage_repository'] | `true`  | Controls if repository management should be done |

### install_tgz

This recipe installs rkt from [release tarballs with compiled rkt]. Installation includes:

* Automatic download of specified rkt release
* Constancy and integrity check
* Creation of needed directories
* Creation of garbage collection cronjob
* Creation of sudo configuration if needed

#### Attributes

| Key                                  | Default                     | Description                                      |
|--------------------------------------|-----------------------------|--------------------------------------------------|
| ['rkt']['install']['tgz']['version'] | see [attributes/default.rb] | Version of rkt which should be installed         |
| ['rkt']['install']['tgz']['sudo']    | `true`                      | Controls if sudo configuration should be done    |

### repository

This recipe is automatically invoked by `install_package` if repository configuration should be done.

Right now, almost no distributions are packaging rkt.
I maintain [rkt project on OpenBuild Service], where I'm building the packages from [release tarballs with compiled rkt] for some distributions.
I see this as intermediary solution (but probably for some years:D), so the quality claim of this packages isn't on the usual level of distributors (they just work, nothing more).

You can [use this repositories] without this cookbook too.

### install_mainline_kernel

This recipe needs to be invoked manually via runlist if needed.
This recipe configures needed repositories and installs a [mainline kernel] for EL7 systems.

EL7 distributions use an old kernel with some bugs in overlayfs, which is used by rkt.
By using the mainline kernel it's possible to avoid such problems.

Resources
---------

### rkt_image

Resource implementation of rkt commands for image handling:

* [rkt fetch]
* [rkt image rm]

#### Syntax

```ruby
rkt_image 'coreos.com/dnsmasq:v0.3.0' do
  action :create
  trust_keys_from_https true
end
```

The full syntax:

```ruby
rkt_image 'name' do
  image_url                String # defaults to 'name' if not specified
  no_store                 TrueClass, FalseClass
  trust_keys_from_https    TrueClass, FalseClass
  action                   Symbol # defaults to :create if not specified
end
```

#### Actions

* `:create` - Default. Fetch image
* `:delete` - Delete image

#### Properties

| Property                 | Default  | Description                                     |
|--------------------------|----------|-------------------------------------------------|
| image_url                | `[name]` | URL of image to fetch                           |
| no_store                 | `false`  | Ignore the local store by fetching              |
| trust_keys_from_https    | `false`  | Automatically trust keys fetched via HTTPS      |

### rkt_net

This resource creates a network, which can be used by rkt pods.

See [rkt networking documentation] for more information and details.

#### Syntax

```ruby
rkt_net 'podnet' do
  action :create
  type 'macvlan',
  options master: 'enp0s25',
          mode: 'private'
  ipam type: 'host-local',
       subnet: '192.168.0.0/24'
end
```

The full syntax:

```ruby
rkt_net 'name' do
  name                     String # defaults to 'name' if not specified
  type                     String
  action                   Symbol # defaults to :create if not specified
  options                  Hash
  ipam                     Hash
end
```

### rkt_pod

Run image in a pod.

This resource creates systemd container services (or upstart for Ubuntu 14.04) with `rkt-` prefix and starts them.

#### Syntax

```ruby
rkt_pod 'dnsmasq' do
  action :create
  image 'coreos.com/dnsmasq:v0.3.0'
  volumes data_volume: {
            kind: 'host',
            source: '/data'
          },
          log_volume: {
            kind: 'host',
            source: '/var/log/container'
          }
  net 'podnet'
end
```

The full syntax:

```ruby
rkt_pod 'name' do
  name                     String # defaults to 'name' if not specified
  image                    String
  trust_keys_from_https    TrueClass, FalseClass
  action                   Symbol # defaults to :create if not specified
  volumes                  Hash
  net                      String, Array, Hash
end
```

#### Actions

* `:create` - Default. Create a new pod and start it
* `:delete` - Delete pod

#### Properties

| Property                 | Default  | Description                                     |
|--------------------------|----------|-------------------------------------------------|
| name                     | `[name]` | Name of pod                                     |
| image                    |          | Image which should be run                       |
| trust_keys_from_https    | `false`  | Automatically trust keys fetched via HTTPS      |
| volumes                  |          | Volumes which should be mounted                 |
| net                      |          | Network options for the pod                     |

#### Advanced network options

You can specify multiple networks as Array in the `net` property:

```ruby
rkt_pod 'dnsmasq' do
  action :create
  image 'coreos.com/dnsmasq:v0.3.0'
  net ['podnet', 'internalnet']
end
```

If you use host-local IP provider for `pod-net` and `internal-net` and want to specify static IPs for the pod, you can pass a Hash in the net property:

```ruby
rkt_pod 'dnsmasq' do
  action :create
  image 'coreos.com/dnsmasq:v0.3.0'
  net podnet: '192.168.0.1',
      internalnet: '192.168.2.1'
end
```

### rkt_trust

Resource implementation of [rkt trust] command.

#### Syntax

```ruby
rkt_trust 'coreos.com/etcd' do
  action :create
  trust_keys_from_https true
end
```

The full syntax:

```ruby
rkt_trust 'name' do
  prefix                   String # defaults to 'name' if not specified
  insecure_allow_http      TrueClass, FalseClass
  skip_fingerprint_review  TrueClass, FalseClass
  trust_keys_from_https    TrueClass, FalseClass
  action                   Symbol # defaults to :create if not specified
end
```

#### Actions

* `:create` - Default. Create a trust for a key, which verifies images.
* `:delete` - Delete a trust for a key

#### Properties

| Property                 | Default  | Description                                     |
|--------------------------|----------|-------------------------------------------------|
| prefix                   | `[name]` | Prefix for the key                              |
| insecure_allow_http      | `false`  | Allow HTTP usage for key discovery              |
| skip_fingerprint_review  | `false`  | Accept the key without fingerprint verification |
| trust_keys_from_https    | `false`  | Automatically trust keys fetched via HTTPS      |

**Note:** fingerprint verification isn't supported yet.
You have to trust keys fetched via HTTPS or to skip fingerprint review.

Issues
------

You can find known issues [here](https://gitlab.com/artem-sidorenko/chef-rkt/issues). Feel free to open a new issue if needed.

Contributing
------------

Please see the [contribution guide](CONTRIBUTING.md).

License and copyright
---------------------

Copyright 2016 Artem Sidorenko and contributors.

Licensed under Apache 2.0

See the COPYRIGHT file at the top-level directory of this distribution
and at <https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT>

[coreos rkt]: https://github.com/coreos/rkt
[custom resources]: https://docs.chef.io/custom_resources.html
[release tarballs with compiled rkt]: https://github.com/coreos/rkt/releases
[attributes/default.rb]: ./attributes/default.rb
[use this repositories]: http://software.opensuse.org/download.html?project=home%3Aartem_sidorenko%3Arkt&package=rkt
[rkt project on OpenBuild Service]: https://build.opensuse.org/project/show/home:artem_sidorenko:rkt
[mainline kernel]: http://elrepo.org/tiki/kernel-ml
[gitlab.com]: https://gitlab.com/artem-sidorenko/chef-rkt
[github.com]: https://github.com/artem-sidorenko/chef-rkt
[rkt trust]: https://coreos.com/rkt/docs/latest/subcommands/trust.html
[rkt fetch]: https://coreos.com/rkt/docs/latest/subcommands/fetch.html
[rkt image rm]: https://coreos.com/rkt/docs/latest/subcommands/image.html#rkt-image-rm
[systemd container services]: https://github.com/coreos/rkt/blob/master/Documentation/using-rkt-with-systemd.md#systemd-run
[Chef]: https://www.chef.io/
[rkt networking documentation]: https://coreos.com/rkt/docs/latest/networking/overview.html#setting-up-additional-networks
