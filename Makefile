#############################################################
# Makefile inspired by Stephen Celis' DotFiles
#
# https://github.com/stephencelis/dotfiles
#############################################################

## Disable outdated implicit rules
.SUFFIXES :

%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%

## VARIABLES
INSTALL_HOOKS =
UPDATE_HOOKS =
CLEAN_HOOKS =
DECRYPT_HOOKS =
PKG_FIXUPS =

ifndef INCLUDED_OS_CONFIG
include make/host.mk
endif

OUTPUT ?= echo

## Include additional modules
include make/symlinks.mk
include make/ssh.mk
include make/sublime.mk
# include make/vim-plug.mk
include make/zimfw.mk
include make/ffmpeg.mk
include make/node.mk

## TARGETS

## Specify default goal for Makefile run without target
.DEFAULT_GOAL := default
.PHONY : default install packages update update-self clean Makefile

## Makefile self-update (only if local file is unchanged)
Makefile : | /usr/bin/git
	@git fetch --quiet
	@git update-index --assume-unchanged $(PWD)/gitconfig
	@if ! git diff --quiet --exit-code HEAD $@; then \
		$(OUTPUT) "\033[31m==> \033[37;1mUnable to update $@ - local changes detected.\033[0m"; \
		return 0; \
	fi
	@if ! git diff --quiet --exit-code HEAD origin/master $@; then \
		$(OUTPUT) "\033[32m==> \033[37;1mUpdating $@...\033[0m"; \
		git checkout origin/master -- $@; \
	fi

make/%.mk : | /usr/bin/git
	@git fetch --quiet
	@if ! git diff --quiet --exit-code HEAD make/$@; then \
		$(OUTPUT) "\033[31m==> \033[37;1mUnable to update $@ - local changes detected.\033[0m"; \
		return 0; \
	fi
	@if ! git diff --quiet --exit-code HEAD origin/master make/$@; then \
		$(OUTPUT) "\033[32m==> \033[37;1mUpdating $@...\033[0m"; \
		git checkout origin/master -- make/$@; \
	fi

## default target
default : | install update clean

## install environment and initial values
install : | os-defaults ln ssh packages
	@if [[ -z "$$(git config --global init.templatedir)" ]]; then \
		git config --global init.templatedir $(PWD)/local/git-templates; \
	fi

## Install package manager and software packages
packages : | install-packages $(PKG_FIXUPS)

## Update installed packages and modules
update : | update-self update-packages $(UPDATE_HOOKS) $(PKG_FIXUPS)

## Update Dotfiles
update-self :
	@$(OUTPUT) "\033[32m==> \033[37;1mUpdating Dotfiles...\033[0m"
	@git pull origin master
	@git submodule update --remote

## Cleanup after package updates
clean : | clean-packages $(CLEAN_HOOKS)

## Decrypt configuration files
decrypt : | $(DECRYPT_HOOKS)
