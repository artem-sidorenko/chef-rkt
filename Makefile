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
export CI_DOWNLOAD_CACHE?=.cache
export KITCHEN_OPTS=--log-level=info

.PHONY: all ci-prepare-env lint spec kitchen

all: lint spec kitchen

ci-prepare-env:
	@echo "CI: Preparing environment..."
	@if [ ! -f "$(CI_DOWNLOAD_CACHE)/$$CHEFDK_FILE" ]; then \
	  yum -y install wget && \
	  mkdir -p "$(CI_DOWNLOAD_CACHE)" && \
	  wget --progress=dot:giga -O $(CI_DOWNLOAD_CACHE)/$$CHEFDK_FILE "$$CHEFDK_URL"; \
	fi
	@echo "$$CHEFDK_SHA256 $(CI_DOWNLOAD_CACHE)/$$CHEFDK_FILE" > $(CI_DOWNLOAD_CACHE)/$$CHEFDK_FILE.sha256
	sha256sum -c $(CI_DOWNLOAD_CACHE)/$$CHEFDK_FILE.sha256
	yum -y install $(CI_DOWNLOAD_CACHE)/$$CHEFDK_FILE
	mkdir -p $(CI_DOWNLOAD_CACHE)/chefdk && \
	ln -s $(shell pwd)/$(CI_DOWNLOAD_CACHE)/chefdk ~/.chefdk
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
