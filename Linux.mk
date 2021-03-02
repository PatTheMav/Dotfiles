OUTPUT = echo
SSH_AGENT_CONFIG =
ST_PATH := $(HOME)/.config/sublime-text/Packages
FONT_DESTINATION := $(HOME)/.local/share/fonts

INCLUDED_CONFIG_OS = TRUE
ifeq ($(wildcard $(PWD)/.nobrew),)
#############################################################
# Linux specific settings for homebrew compatible systems
#############################################################
PACKAGE_MANAGER = brew
PACKAGE_CMD := $(PACKAGE_MANAGER)
BREW_REQUIRED = yes
BREW_INSTALL = sh -c "$$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
HOMEBREW_ROOT = /home/linuxbrew/.linuxbrew

HOMEBREW_CMD := $(HOMEBREW_ROOT)/bin/brew
HOMEBREW_CELLAR := $(HOMEBREW_ROOT)/Cellar/
HOMEBREW_CASKROOM := $(HOMEBREW_ROOT)/Caskroom/
HOMEBREW_TAPROOM := $(HOMEBREW_ROOT)/Homebrew/Library/Taps/

HOMEBREW_TAP_FOLDER := $(addprefix $(HOMEBREW_TAPROOM), $(dir $(taps)))
HOMEBREW_TAP_NAME := $(addprefix homebrew-, $(notdir $(taps)))
HOMEBREW_TAPS := $(join $(HOMEBREW_TAP_FOLDER), $(HOMEBREW_TAP_NAME))
HOMEBREW_CASKS := $(addprefix $(HOMEBREW_CASKROOM), $(notdir $(casks)))
HOMEBREW_FORMULAE := $(addprefix $(HOMEBREW_CELLAR), $(notdir $(formulae)))

UPDATE_PACKAGES := @$(OUTPUT) "\033[32m==> \033[37;1mUpdating $(PACKAGE_MANAGER) packages...\033[0m"; type $(PACKAGE_MANAGER) > /dev/null 2>&1 && $(PACKAGE_CMD) update && $(PACKAGE_CMD) upgrade || true
UPDATE_PACKAGES := $(UPDATE_PACKAGES); $(PWD)/local/bin/check_custom_taps

CLEAN_PACKAGES = @$(OUTPUT) "\033[32m==> \033[37;1mCleaning up $(PACKAGE_MANAGER) environment...\033[0m"; type $(PACKAGE_MANAGER) > /dev/null 2>&1 && $(PACKAGE_CMD) autoremove -q && $(PACKAGE_CMD) cleanup || true

VIM_LOCATION := $(addprefix $(HOMEBREW_CELLAR),vim-custom)
VIM_OPTS = --with-gettext
VIM_PREREQ = $(HOMEBREW_TAPS)

FFMPEG_LOCATION := $(addprefix $(HOMEBREW_CELLAR),ffmpeg-custom)
FFMPEG_OPTS = --with-webp --with-speex --with-rav1e --with-rtmpdump --with-srt
FFMPEG_PREREQ = $(HOMEBREW_TAPS)

ZSH_LOCATION := $(HOMEBREW_CELLAR)/zsh
ZSH_PREREQ = $(HOMEBREW_CMD)

BASH_LOCATION := $(HOMEBREW_CELLAR)/bash
BASH_PREREQ = $(HOMEBREW_CMD)

NODE_LOCATION := $(HOMEBREW_CELLAR)node
NODE_LIBS := $(HOMEBREW_ROOT)/lib/node_modules
CSSLS_LOCATION = $(HOMEBREW_ROOT)/lib/node_modules/vscode-css-languageserver-bin
TSLS_LOCATION = $(HOMEBREW_ROOT)/lib/node_modules/typescript-language-server
NODE_PREREQ = $(HOMEBREW_CMD)

PYTHON_LOCATION := $(HOMEBREW_CELLAR)/python
PYTHON_PREREQ = $(HOMEBREW_CMD)
PY_PACKAGE = python

PHP_LOCATION := $(HOMEBREW_CELLAR)/php
PHP_PREREQ = $(HOMEBREW_CMD)
PHPLS_LOCATION = $(HOMEBREW_ROOT)/lib/node_modules/intelephense-server

#############################################################
# Target: pacman (Homebrew)
# Installs required packages using Homebrew
#############################################################
.PHONY : pacman
pacman : | $(HOMEBREW_TAPS) $(HOMEBREW_CASKS) $(HOMEBREW_FORMULAE)

$(HOMEBREW_CMD) :
	@sudo apt install curl
	@$(OUTPUT) "\033[32m==> \033[37;1mInstalling Homebrew...\033[0m"
	@$(BREW_INSTALL)
	@echo 'eval $$($(HOMEBREW_ROOT)/bin/brew shellenv)' >> ~/.profile
	@eval $$($(HOMEBREW_ROOT)/bin/brew shellenv)
	@brew install gcc
	@brew vendor-install ruby

$(HOMEBREW_TAPS) : | $(HOMEBREW_CMD)
	@$(OUTPUT) "\033[34m==> \033[37;1mTapping $(patsubst $(HOMEBREW_TAPROOM)%,%,$(subst homebrew-,,$@))...\033[0m"
	$(PACKAGE_CMD) tap $(patsubst $(HOMEBREW_TAPROOM)%,%,$(subst homebrew-,,$@))

$(HOMEBREW_CASKS) : | $(HOMEBREW_CMD)
	$(NOOP)

$(filter %git,$(HOMEBREW_FORMULAE)): | $(HOMEBREW_CMD)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling formulae $(notdir $@)...\033[0m"
	$(PACKAGE_CMD) install $(notdir $@)
	@git config --global user.email "$(SSH_MAIL)"
	@git update-index --assume-unchanged $(PWD)/gitconfig $(PWD)/local/configs/ST3/Preferences.sublime-settings

FILTERED_FORMULAE = $(addprefix $(HOMEBREW_CELLAR),$(notdir git coreutils findutils))
$(filter-out $(FILTERED_FORMULAE),$(HOMEBREW_FORMULAE)) : | $(HOMEBREW_CMD) $(HOMEBREW_TAPS)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling formulae $(notdir $@)...\033[0m"
	$(PACKAGE_CMD) install $(notdir $@)

else
#############################################################
# Linux specific settings for non-homebrew systems
#############################################################
PACKAGE_MANAGER = apt
PACKAGE_CMD := sudo $(PACKAGE_MANAGER)
BREW_REQUIRED = no
BREW_INSTALL =
APT_FORMULAE := $(addprefix /usr/bin/,$(notdir $(apt_packages)))

UPDATE_PACKAGES := @$(OUTPUT) "\033[32m==> \033[37;1mUpdating $(PACKAGE_MANAGER) packages...\033[0m"; type $(PACKAGE_MANAGER) > /dev/null 2>&1 && $(PACKAGE_CMD) update && $(PACKAGE_CMD) upgrade || true

CLEAN_PACKAGES = @$(OUTPUT) "\033[32m==> \033[37;1mCleaning up $(PACKAGE_MANAGER) packages...\033[0m"; type $(PACKAGE_MANAGER) > /dev/null 2>&1 && $(PACKAGE_CMD) autoclean && $(PACKAGE_CMD) autoremove || true

VIM_LOCATION = /usr/bin/vim
VIM_OPTS =
VIM_PREREQ =

FFMPEG_LOCATION = /usr/bin/ffmpeg
FFMPEG_OPTS =
FFMPEG_PREREQ =

ZSH_LOCATION = /usr/bin/zsh
ZSH_PREREQ =

BASH_LOCATION = /usr/bin/bash
BASH_PREREQ =

NODE_LOCATION = /usr/bin/node
NODE_LIBS = /usr/local/lib/node_modules
CSSLS_LOCATION = /usr/local/lib/node_modules/vscode-css-languageserver-bin
TSLS_LOCATION = /usr/local/lib/node_modules/typescript-language-server
NODE_PREREQ =

PYTHON_LOCATION = /usr/bin/python3
PY_PACKAGE = python3
PYTHON_PREREQ =

PHP_LOCATION = /usr/bin/php
PHP_PREREQ =
PHPLS_LOCATION = /usr/local/lib/node_modules/intelephense-server
#############################################################
# Target: pacman (Apt)
# Installs required packages using apt
#############################################################
pacman : | $(APT_FORMULAE)

FILTERED_FORMULAE = $(addprefix /usr/bin/,$(notdir git diff-so-fancy))
$(filter-out $(FILTERED_FORMULAE),$(APT_FORMULAE)) :
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling APT package $(notdir $@)...\033[0m"
	$(PACKAGE_CMD) install $(notdir $@)

$(filter %git, $(APT_FORMULAE)) :
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling APT package $(notdir $@)...\033[0m"
	$(PACKAGE_CMD) install $(notdir $@)
	@git config --global user.email "$(SSH_MAIL)"
	@git update-index --assume-unchanged $(PWD)/gitconfig

$(filter %diff-so-fancy, $(APT_FORMULAE)) :
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling APT package $(notdir $@)...\033[0m"
	@sudo wget -q "https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy" -O $@
	@sudo chmod +x $@

endif

#############################################################
# Target: defaults
# Sets default OS settings
#############################################################
.PHONY : defaults
defaults : ;
