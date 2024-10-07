## Disable outdated implicit rules
.SUFFIXES :

## No remaking self
%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%

ifndef INCLUDED_OS_CONFIG
INCLUDED_OS_CONFIG := TRUE

## VARIABLES
OUTPUT := echo -e
SED := sed -i''
BASH_BIN := $(shell which bash)
SHELL := $(BASH_BIN)
.SHELLFLAGS := -ec

SSH_AGENT_CONFIG := 'HOST *\n    AddKeysToAgent yes\n    IdentityFile ~/.ssh/id_ed25519\n    ControlMaster auto\n    ControlPath ~/.ssh/sockets/%r@%h-%p\n    ControlPersist 30m'

ifeq (,$(wildcard $(PWD)/.nobrew))
ifneq (aarch64,$(shell uname -m))
CURL_CMD := $(shell which curl)
ifeq (,$(CURL_CMD))
CURL_CMD = /usr/bin/curl
endif
BREW_ROOT := /home/linuxbrew/.linuxbrew
PKG_CMD := $(BREW_ROOT)/bin/brew
PKG_NAME := brew
BIN_DIR := $(BREW_ROOT)/bin

$(CURL_CMD) :
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling curl to fetch Homebrew installer...\033[0m"; \
	@sudo apt install curl

endif
else
PKG_CMD := /usr/bin/apt
PKG_NAME := apt
DISTRO_NAME := $(shell lsb_release -i -s)
DISTRO_VERSION := $(shell lsb_release -r -s | cut -d "." -f 1)
ifeq (true,$(shell test $(DISTRO_NAME) = "Ubuntu" -a $(DISTRO_VERSION) -ge 22 && echo 'true'))
PKG_FIXUPS :=
else
ifeq (true,$(shell test $(DISTRO_NAME) = "Debian" -a $(DISTRO_VERSION) -ge 10 && echo 'true'))
PKG_FIXUPS :=
else
PKG_FIXUPS := /usr/local/bin/bat
endif
endif
BIN_DIR := /usr/bin
endif

.PHONY : os-defaults custom-zsh

os-defaults : ;

## Activate zsh from Homebrew as default shell for current user
custom-zsh : | $(BIN_DIR)/zsh
	@TARGET_SHELL=$$(which zsh); \
	cat /etc/shells | grep -q "$${TARGET_SHELL}" || \
	$(OUTPUT) "\033[34m==> \033[37;1mSetting default shell to zsh (will ask for password)...\033[0m"; \
	echo "$${TARGET_SHELL}" | sudo tee -a /etc/shells && \
	chsh -s "$${TARGET_SHELL}"
endif

## Install Homebrew
$(PKG_CMD) : | $(CURL_CMD)
	@$(OUTPUT) "\033[32m==> \033[37;1mInstalling Homebrew...\033[0m"
	@/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	@echo 'eval "$$($(PKG_CMD) shellenv)"' >> $(HOME)/.zshrc
	@echo 'eval "$$($(PKG_CMD) shellenv)"' >> $(HOME)/.bashrc
	@echo 'fpath=("$${HOMEBREW_PREFIX}/share/zsh/site-functions" $${fpath})' >> $(HOME)/.zshrc
	@echo 'fpath=("$${HOMEBREW_PREFIX}/share/zsh/site-functions" $${fpath})' >> $(HOME)/.bashrc

## Link batcat to bat in user binary directory
/usr/local/bin/bat : | /usr/bin/batcat
	@$(OUTPUT) "\033[32m==> \033[37;1mLinking $(notdir $@)...\033[0m"
	@sudo ln -fsv /usr/bin/batcat /usr/local/bin/bat
