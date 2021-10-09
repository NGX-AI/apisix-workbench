# Makefile basic env setting
.DEFAULT_GOAL := help
## add pipefail support for default shell
# SHELL := $(SHELL) -o pipefail


# Project basic setting
project_name           ?= apisix-workbench
project_version        ?= 1.0.1
project_compose        ?= ci/pod/docker-compose.yml
project_launch_utc     ?= $(shell date +%Y%m%d%H%M%S)
project_release_folder ?= release
project_release_name   ?= $(project_release_folder)/$(project_name)_release.v$(project_version).$(project_launch_utc).tar.gz


# Hyperconverged Infrastructure
ENV_OS_NAME            ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
ENV_VAGRANT            ?= vagrant
ENV_DOCKER             ?= docker
ENV_DOCKER_COMPOSE     ?= docker-compose --project-directory $(CURDIR) -p $(project_name) -f $(project_compose)


# OSX archive `._` cache file
ifeq ($(ENV_OS_NAME),darwin)
	ENV_TAR ?= COPYFILE_DISABLE=1 tar
else
	ENV_TAR ?= tar
endif


# Makefile basic extension function
_color_red    =\E[1;31m
_color_green  =\E[1;32m
_color_yellow =\E[1;33m
_color_blue   =\E[1;34m
_color_wipe   =\E[0m


define func_echo_status
	printf "[%b info %b] %s\n" "$(_color_blue)" "$(_color_wipe)" $(1)
endef


define func_echo_warn_status
	printf "[%b info %b] %s\n" "$(_color_yellow)" "$(_color_wipe)" $(1)
endef


define func_echo_success_status
	printf "[%b info %b] %s\n" "$(_color_green)" "$(_color_wipe)" $(1)
endef


define func_check_folder
	if [[ ! -d $(1) ]]; then \
		mkdir -p $(1); \
		$(call func_echo_status, 'folder check -> create `$(1)`'); \
	else \
		$(call func_echo_success_status, 'folder check -> found `$(1)`'); \
	fi
endef


# Makefile target
### help : Show Makefile rules
.PHONY: help
help:
	@$(call func_echo_success_status, "Makefile rules:")
	@echo
	@if [ '$(ENV_OS_NAME)' = 'darwin' ]; then \
		awk '{ if(match($$0, /^#{3}([^:]+):(.*)$$/)){ split($$0, res, ":"); gsub(/^#{3}[ ]*/, "", res[1]); _desc=$$0; gsub(/^#{3}([^:]+):[ \t]*/, "", _desc); printf("    make %-15s : %-10s\n", res[1], _desc) } }' Makefile; \
	else \
		awk '{ if(match($$0, /^\s*#{3}\s*([^:]+)\s*:\s*(.*)$$/, res)){ printf("    make %-15s : %-10s\n", res[1], res[2]) } }' Makefile; \
	fi
	@echo


### vm-up : vagrant up
.PHONY: vm-up
vm-up:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_VAGRANT) up
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### vm-reload : vagrant reload without provision
.PHONY: vm-reload
vm-reload:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_VAGRANT) reload --no-provision
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### vm-provision : vagrant provision
.PHONY: vm-provision
vm-provision:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_VAGRANT) provision
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### ssh : vagrant ssh
.PHONY: ssh
ssh:
	@$(call func_echo_status, "$@ -> [ Start ]")
	-$(ENV_VAGRANT) ssh
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### sync : vagrant rsync
.PHONY: sync
sync:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_VAGRANT) rsync
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### vm-down : vagrant destroy
.PHONY: vm-down
vm-down:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_VAGRANT) destroy -f
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### container
### ci-env-up : launch ci env
.PHONY: ci-env-up
ci-env-up:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER_COMPOSE) up -d
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### ci-env-ps : ci env ps
.PHONY: ci-env-ps
ci-env-ps:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER_COMPOSE) ps
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### ci-env-rebuild : ci env image rebuild
.PHONY: ci-env-rebuild
ci-env-rebuild:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER_COMPOSE) build
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### ci-env-down : destroy ci env
.PHONY: ci-env-down
ci-env-down:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER_COMPOSE) down
	@$(call func_echo_success_status, "$@ -> [ Done ]")
