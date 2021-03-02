OUTPUT = echo
SSH_AGENT_CONFIG = "HOST *\n    AddKeysToAgent yes\n    IdentityFile ~/.ssh/id_ed25519\n    ControlMaster auto\n    ControlPath ~/.ssh/sockets/%r@%h-%p\n    ControlPersist 30m"
ST_PATH := $(HOME)/.config/sublime-text/Packages
FONT_DESTINATION := $(HOME)/.local/share/fonts

INCLUDED_CONFIG_OS = TRUE
.PHONY : pacman
.PHONY : update_packages
.PHONY : clean_packages

ifeq ($(wildcard $(PWD)/.nobrew),)
#############################################################
# Linux specific settings for homebrew compatible systems
#############################################################
PACKAGE_MANAGER = brew
PACKAGE_CMD := $(PACKAGE_MANAGER)
BREW_REQUIRED = yes
BREW_INSTALL = bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
HOMEBREW_ROOT = /home/linuxbrew/.linuxbrew

HOMEBREW_CMD := $(HOMEBREW_ROOT)/bin/brew
HOMEBREW_CELLAR := $(HOMEBREW_ROOT)/Cellar/
HOMEBREW_CASKROOM := $(HOMEBREW_ROOT)/Caskroom/
HOMEBREW_TAPROOM := $(HOMEBREW_ROOT)/Homebrew/Library/Taps/

HOMEBREW_TAP_FOLDER := $(addprefix $(HOMEBREW_TAPROOM), $(dir $(taps)))
HOMEBREW_TAP_NAME := $(addprefix homebrew-, $(notdir $(taps)))
HOMEBREW_TAPS := $(join $(HOMEBREW_TAP_FOLDER), $(HOMEBREW_TAP_NAME))
HOMEBREW_CASKS := $(addprefix $(HOMEBREW_CASKROOM), $(notdir $(casks)))
HOMEBREW_FORMULAS := $(addprefix $(HOMEBREW_CELLAR), $(notdir $(formulae)))

VIM_LOCATION := $(addprefix $(HOMEBREW_CELLAR),vim-custom)
VIM_OPTS = --with-gettext
VIM_PREREQ = $(HOMEBREW_TAPS)

FFMPEG_LOCATION := $(addprefix $(HOMEBREW_CELLAR),ffmpeg-custom)
FFMPEG_OPTS = --with-webp --with-speex --with-rav1e --with-srt --with-rist
FFMPEG_PREREQ = $(HOMEBREW_TAPS)

ZSH_LOCATION := $(HOMEBREW_CELLAR)zsh
ZSH_PREREQ = $(HOMEBREW_CMD)

BASH_LOCATION := $(HOMEBREW_CELLAR)bash
BASH_PREREQ = $(HOMEBREW_CMD)

NODE_LOCATION := $(HOMEBREW_CELLAR)node
NODE_LIBS := $(HOMEBREW_ROOT)/lib/node_modules
CSSLS_LOCATION = $(HOMEBREW_ROOT)/lib/node_modules/vscode-css-languageserver-bin
TSLS_LOCATION = $(HOMEBREW_ROOT)/lib/node_modules/typescript-language-server
NODE_PREREQ = $(HOMEBREW_CMD)

PYTHON_LOCATION := $(HOMEBREW_CELLAR)python
PYTHON_PREREQ = $(HOMEBREW_CMD)
PY_PACKAGE = python
PYLS_LOCATION = $(HOMEBREW_ROOT)/lib/node_modules/pyright

PHP_LOCATION := $(HOMEBREW_CELLAR)php
PHP_PREREQ = $(HOMEBREW_CMD)
PHPLS_LOCATION = $(HOMEBREW_ROOT)/lib/node_modules/intelephense-server

#############################################################
# Target: pacman (Homebrew)
# Installs required packages using Homebrew
#############################################################
INSTALL_FORMULAS =
INSTALL_TAPS =
pacman : | $(HOMEBREW_TAPS) $(HOMEBREW_CASKS) $(HOMEBREW_FORMULAS)
	@if [ "$(INSTALL_TAPS)" ]; then \
	$(OUTPUT) "\033[34m==> \033[37;1mTapping $(INSTALL_TAPS)...\033[0m"; \
	$(HOMEBREW_CMD) tap $(INSTALL_TAPS); \
	fi

	@if [ "$(INSTALL_FORMULAS)" ]; then \
	$(OUTPUT) "\033[34m==> \033[37;1mInstalling formula(s) $(INSTALL_FORMULAS)...\033[0m"; \
	$(HOMEBREW_CMD) install $(INSTALL_FORMULAS); \
	fi

$(HOMEBREW_CMD) :
	@sudo apt install curl
	@$(OUTPUT) "\033[32m==> \033[37;1mInstalling Homebrew...\033[0m"
	@$(BREW_INSTALL)
	@echo 'eval "$$($(HOMEBREW_ROOT)/bin/brew shellenv)"' >> ~/.bash_profile
	@echo 'eval "$$($(HOMEBREW_ROOT)/bin/brew shellenv)"' >> $(HOME)/.zprofile
	@eval "$$($(HOMEBREW_ROOT)/bin/brew shellenv)"
	@brew install gcc
	@brew vendor-install ruby

$(HOMEBREW_TAPS) : | $(HOMEBREW_CMD)
	$(eval INSTALL_TAPS := $(INSTALL_TAPS) $(patsubst $(HOMEBREW_TAPROOM)%,%,$(subst homebrew-,,$@)))

$(HOMEBREW_CASKS) : ;

$(addprefix $(HOMEBREW_CELLAR), git): | $(HOMEBREW_CMD)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling formulae $(notdir $@)...\033[0m"
	$(HOMEBREW_CMD) install $(notdir $@)
	@git config --global user.email "$(SSH_MAIL)"
	@git update-index --assume-unchanged $(PWD)/gitconfig $(PWD)/local/configs/ST/Preferences.sublime-settings

$(addprefix $(HOMEBREW_CELLAR), coreutils): | $(HOMEBREW_CMD)
$(addprefix $(HOMEBREW_CELLAR), findutils): | $(HOMEBREW_CMD)
$(addprefix $(HOMEBREW_CELLAR), gping): | $(HOMEBREW_CMD)

FILTERED_FORMULAS = $(addprefix $(HOMEBREW_CELLAR),$(notdir git coreutils findutils gping))
$(filter-out $(FILTERED_FORMULAS),$(HOMEBREW_FORMULAS)) : | $(HOMEBREW_CMD) $(HOMEBREW_TAPS)
	$(eval INSTALL_FORMULAS := $(INSTALL_FORMULAS) $(notdir $@))

ifneq ($(wildcard $(HOMEBREW_CMD)),)
update_packages : | pacman
	@$(OUTPUT) "\033[32m==> \033[37;1mUpdating $(PACKAGE_MANAGER) packages...\033[0m"
	@$(HOMEBREW_CMD) update && $(HOMEBREW_CMD) upgrade || true
	@$(PWD)/local/bin/check_custom_taps

clean_packages : | pacman
	@$(OUTPUT) "\033[32m==> \033[37;1mCleaning up $(PACKAGE_MANAGER) environment...\033[0m"
	@$(HOMEBREW_CMD) autoremove -q && $(HOMEBREW_CMD) cleanup || true
endif

else
#############################################################
# Linux specific settings for non-homebrew systems
#############################################################
PACKAGE_MANAGER = apt
PACKAGE_CMD := sudo $(PACKAGE_MANAGER)
BREW_REQUIRED = no
BREW_INSTALL =
APT_PREFIX = /usr/bin/
APT_FORMULAS := $(addprefix $(APT_PREFIX),$(notdir $(apt_packages)))
APT_REPOS := $(addprefix /etc/apt/sources.list.d/,$(addsuffix .list,$(notdir $(apt_repos))))

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
PYLS_LOCATION = /usr/local/lib/python3*/site-packages/python_language_server-*

PHP_LOCATION = /usr/bin/php
PHP_PREREQ =
PHPLS_LOCATION = /usr/local/lib/node_modules/intelephense-server
#############################################################
# Target: pacman (Apt)
# Installs required packages using apt
#############################################################
INSTALL_FORMULAS =
pacman : | $(APT_REPOS) $(APT_FORMULAS)
	@if [ "$(INSTALL_FORMULAS)" ]; then \
	$(OUTPUT) "\033[34m==> \033[37;1mInstalling APT package $(INSTALL_FORMULAS)...\033[0m"; \
	$(PACKAGE_CMD) install $(INSTALL_FORMULAS); \
	fi

/etc/apt/sources.list.d/rust-tools.list :
	$(OUTPUT) "\033[34m==> \033[37;1mAdding apt repository $(notdir $@)...\033[0m"; \
	curl -fsSL https://apt.cli.rs/pubkey.asc | sudo tee -a /usr/share/keyrings/rust-tools.asc
	curl -fsSL https://apt.cli.rs/rust-tools.list | sudo tee /etc/apt/sources.list.d/rust-tools.list
	sudo apt update

FILTERED_FORMULAS = $(addprefix /usr/bin/,$(notdir git delta btm diff-so-fancy duf curlie))
$(filter-out $(FILTERED_FORMULAS),$(APT_FORMULAS)) :
	$(eval INSTALL_FORMULAS := $(INSTALL_FORMULAS) $(notdir $@))

$(addprefix $(APT_PREFIX), git) :
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling APT package $(notdir $@)...\033[0m"
	$(PACKAGE_CMD) install $(notdir $@)
	@git config --global user.email "$(SSH_MAIL)"
	@git update-index --assume-unchanged $(PWD)/gitconfig

$(addprefix $(APT_PREFIX), delta) :
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling APT package $(notdir $@)...\033[0m"
	$(PACKAGE_CMD) install git-delta-musl

$(addprefix $(APT_PREFIX), btm) :
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling APT package $(notdir $@)...\033[0m"
	@curl -LO https://github.com/ClementTsang/bottom/releases/download/0.6.4/bottom_0.6.4_amd64.deb
	@sudo dpkg -i bottom_0.6.4_amd64.deb
	@rm bottom_0.6.4_amd64.deb

$(addprefix $(APT_PREFIX), duf) :
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling APT package $(notdir $@)...\033[0m"
	@curl -LO https://github.com/muesli/duf/releases/download/v0.6.2/duf_0.6.2_linux_amd64.deb
	@sudo dpkg -i duf_0.6.2_linux_amd64.deb
	@rm duf_0.6.2_linux_amd64.deb

$(addprefix $(APT_PREFIX), curlie) :
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling APT package $(notdir $@)...\033[0m"
	@curl -LO https://github.com/rs/curlie/releases/download/v1.6.0/curlie_1.6.0_linux_amd64.deb
	@sudo dpkg -i curlie_1.6.0_linux_amd64.deb
	@rm curlie_1.6.0_linux_amd64.deb

$(addprefix $(APT_PREFIX), diff-so-fancy) :
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling APT package $(notdir $@)...\033[0m"
	@sudo wget -q "https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy" -O $@
	@sudo chmod +x $@

update_packages : | pacman
	@$(OUTPUT) "\033[32m==> \033[37;1mUpdating $(PACKAGE_MANAGER) packages...\033[0m"
	@$(PACKAGE_CMD) update && $(PACKAGE_CMD) upgrade || true

clean_packages : | pacman
	@$(OUTPUT) "\033[32m==> \033[37;1mCleaning up $(PACKAGE_MANAGER) environment...\033[0m"
	@$(PACKAGE_CMD) autoclean && $(PACKAGE_CMD) autoremove || true
endif

.PHONY : zsh_postinstall
zsh_postinstall : | $(ZSH_LOCATION)
	$(eval TARGET_ZSH = $(shell which zsh))

	@$(OUTPUT) "\033[34m==> \033[37;1mAdding Homebrew zsh to allowed shells (will ask for password)...\033[0m"
	@cat /etc/shells | grep -q $(TARGET_ZSH) || echo '$(TARGET_ZSH)' | sudo tee -a /etc/shells
	@chsh -s $(TARGET_ZSH)

#############################################################
# Target: defaults
# Sets default OS settings
#############################################################
.PHONY : defaults
defaults : ;
