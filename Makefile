#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

export CI?=
export CI_SSH_DIR?=~/.ssh
export CI_SSH_PEM?=$(CI_SSH_DIR)/ci_id_rsa
export CI_SSH_KEY_PEM?=
export KITCHEN_OPTS=--log-level=info

.PHONY: all ci-prepare-env lint spec kitchen

all: lint spec kitchen

ci-prepare-env:
	@echo "CI: Preparing environment..."
	chef exec bundle install
	@mkdir -p $(CI_SSH_DIR)
	@if [ ! -f $(CI_SSH_PEM) ]; then \
	  echo "CI: Creating ssh keys..."; \
	  echo "$${CI_SSH_KEY_PEM}" > $(CI_SSH_PEM); \
	  chmod 600 $(CI_SSH_PEM); \
	else \
	  echo "CI: ssh keys are present, skipping creation"; \
	fi

lint:
	foodcritic -f any .
	rubocop

spec:
	chef exec rspec

kitchen:
	@if [ -n "$(CI)" ]; then \
	  export KITCHEN_OPTS="$(KITCHEN_OPTS) -c10 --destroy=always"; \
	fi; \
	kitchen test $$KITCHEN_OPTS
