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
export CI_SSH_KEY?=$(CI_SSH_DIR)/ci_id_rsa
export CI_SSH_KEY_PEM?=
export CI_DOWNLOAD_CACHE?=.cache
export CI_STOVE_DIR?=~/.stovedir
export CI_STOVE_KEY?=$(CI_STOVE_DIR)/supermarket.pem
export CI_STOVE_KEY_PEM?=
export CI_STOVE_USERNAME?=
export KITCHEN_OPTS?=--log-level=info
export KITCHEN_INSTANCE?=
export DEPLOY_USERNAME?=$(CI_STOVE_USERNAME)
export DEPLOY_KEY?=$(CI_STOVE_KEY)

.PHONY: all ci-prepare-env lint spec kitchen test

all: test
test: lint spec kitchen

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
	@if [ ! -f $(CI_SSH_KEY) ]; then \
	  echo "CI: Creating ssh keys..."; \
	  echo "$${CI_SSH_KEY_PEM}" > $(CI_SSH_KEY); \
	  chmod 600 $(CI_SSH_KEY); \
	else \
	  echo "CI: ssh keys are present, skipping creation"; \
	fi
	@mkdir -p $(CI_STOVE_DIR)
	@if [ ! -f $(CI_STOVE_KEY) ]; then \
	  echo "CI: Creating stove key..."; \
	  echo "$${CI_STOVE_KEY_PEM}" > $(CI_STOVE_KEY); \
	  chmod 600 $(CI_STOVE_KEY); \
	else \
	  echo "CI: stove key is present, skipping creation"; \
	fi

lint:
	foodcritic -f any .
	rubocop

spec:
	chef exec rspec

kitchen:
	@if [ -n "$(CI)" ]; then \
	  export KITCHEN_OPTS="$(KITCHEN_OPTS) -c2 --destroy=always"; \
	fi; \
	kitchen test $$KITCHEN_OPTS $(KITCHEN_INSTANCE)

deploy:
	@if [ -n "$(CI)" ]; then \
	  METADATA_VERSION=v$$(sed -n "s/[[:space:]]*version[[:space:]]*'\([[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*\)'.*/\1/p" metadata.rb); \
	  if [ -z "$$METADATA_VERSION" -o -z "$$CI_BUILD_TAG" ]; then \
	    echo "CI: can't determine either the CI version tag or the version from metadata.rb"; \
	    exit 1; \
	  fi; \
	  if [ "$$METADATA_VERSION" != "$$CI_BUILD_TAG" ]; then \
	    echo "CI: version mismatch between CI tag and version from metadata.rb:";\
	    echo "    metadata.rb: $${METADATA_VERSION}"; \
	    echo "    CI tag     : $${CI_BUILD_TAG}"; \
	    exit 1; \
	  fi; \
	fi
	@echo "Deploying to chef supermarket..."
	@chef exec stove --no-git --username "$(DEPLOY_USERNAME)" --key "$(DEPLOY_KEY)" --extended-metadata
