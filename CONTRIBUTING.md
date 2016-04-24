Contribution guide
==================

Contributions are accepted only via [gitlab.com](https://gitlab.com/artem-sidorenko/chef-rkt).

1. Fork the repository
2. Create a feature branch
3. Write [tests](#tests) and code
4. Ensure the [tests](#tests) do pass
5. If you have multiple commits, please [squash](https://git-scm.com/book/en/Git-Tools-Rewriting-History#Squashing-Commits) them to a small amount of logical separated commits
6. Rebase your changes on the last master branch of this repository
7. Submit a merge request to the master branch of this repository

Please write [good](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html) commit [messages](http://chris.beams.io/posts/git-commit/).

Tests
-----
This cookbook uses
 - [foodcritic](http://www.foodcritic.io/) and [rubocop](http://batsov.com/rubocop/) for linting
 - [chefspec](http://sethvargo.github.io/chefspec/) for unit tests
 - [inspec](https://github.com/chef/inspec) with [test-kitchen](http://kitchen.ci/) for integration tests

Its a good idea to install [ChefDK](https://downloads.chef.io/chef-dk/) and some gems:
```bash
# Example for Centos 7
$ yum -y install https://packages.chef.io/stable/el/7/chefdk-0.12.0-1.el7.x86_64.rpm
# Install required gems
$ chef exec bundle install
```

Check linting:
```bash
$ make lint
```

Run unit tests:
```bash
$ make spec
```

Run integration tests:
```bash
$ make kitchen
```

Run all tests:
```bash
$ make test
```

Please add/extend according tests together with code changes.

Linting and unit tests can be executed automatically within your fork by GitLab CI runners of gitlab.com.

Integration tests require VMs:
 - in case of local execution [vagrant](http://vagrantup.com/) with [virtualbox](http://virtualbox.org/) is used as provider. 
 - in case of CI execution [DigitalOcean](https://www.digitalocean.com/) is used as provider.

If you want to execute integration tests automatically via GitLab CI you should configure [secret variables](http://doc.gitlab.com/ee/ci/variables/README.html#user-defined-variables-secure-variables) in your fork:
 - `DIGITALOCEAN_ACCESS_TOKEN` - Your DigitalOcean [access token](https://www.digitalocean.com/community/tutorials/how-to-use-the-digitalocean-api-v2)
 - `DIGITALOCEAN_SSH_KEY_IDS` - DigitalOcean ID of ssh key which is used in order to access the VMs
 - `CI_SSH_KEY_PEM` - Private SSH key which is used in order to access the VMs
