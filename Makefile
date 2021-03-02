#############################################################
# Makefile inspired by Stephen Celis' DotFiles
#
# https://github.com/stephencelis/dotfiles
#
# Uses PHONY for targets that always need to be executed
# and order-only prerequisites to ignore directory changes.
#############################################################


#############################################################
# SNIPPETS
# Read without echo:
# SECRET ?= $(shell stty -echo; read -p "Password: " pwd; stty echo; echo $$pwd)
#############################################################

#############################################################
# Disable implicit rules to improve performance
#############################################################
.SUFFIXES :
Makefile : ;

%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%

#############################################################
# Dotfiles to be symlinked into home folder
#############################################################
symlinks = \
	dir_colors \
	gemrc \
	gitconfig \
	gitignore_global \
	vimrc \
	zimrc \
	zlogin \
	zlogout \
	zshrc \
	zshenv \
	bash_profile \
	bash_logout \
	bashrc \
	bash_extras \
	vim \
	config

#############################################################
# Brew taps
#############################################################
taps = \
	patthemav/custom \
	dawidd6/autoremove

#############################################################
# Brew formulae
#############################################################
formulae = \
	git \
	coreutils \
	grep \
	findutils \
	git-delta \
	sqlite \
	gibo \
	ripgrep \
	axel \
	bat \
	tealdeer \
	bottom \
	dust \
	duf \
	procs \
	curlie \
	dog \
	gping \
	xh \
	hexyl
# 	bchunk

#############################################################
# NPM modules
#############################################################
node_modules = \
	prettier \
	clean-css-cli \
	html-minifier \
	terser

#############################################################
# APT packages
#############################################################
apt_packages = git \
	delta \
	less \
	curl \
	make \
	man \
	mc \
	rg \
	bat \
 	btm \
 	duf \
 	curlie \
 	xh \
 	hexyl

apt_repos = rust-tools

#############################################################
# Brew casks
#############################################################
casks = \
	iina \
	forklift \
	sublime-text \
	sublime-merge

screensaver_casks = \
	aerial \
	brooklyn

webdev_casks = \
	tableplus \
	pgadmin4 \
	insomnia \
	imagealpha \
	imageoptim

system_casks = \
	xact \
	knockknock \
	taskexplorer \
	keepingyouawake \
	gemini \
	daisydisk \
	cyberduck

game_casks = \
	discord \
	openemu

OS_TYPE = $(shell uname -s | cut -d _ -f 1)
SSH_MAIL := $(shell cat $(PWD)/.contact 2>/dev/null)
OS_INCLUDE := $(OS_TYPE).mk

ifndef INCLUDED_CONFIG_OS
include $(OS_INCLUDE)
endif

#############################################################
# Target: default
# Default make target
#############################################################
.DEFAULT_GOAL := default
.PHONY : default
default : | update clean

#############################################################
# Target: install
# Installs package manager and required packages
# Links dotfiles and set OS defaults if necessary
#############################################################
.PHONY : install
install : | pacman ln ssh defaults vim

#############################################################
# Target: update
# Updates installed packages, npm modules, ruby gems and
# zsh environment.
#############################################################
.PHONY : update
update : | install update_self update_packages update_node update_zsh update_vim

.PHONY : update_self
update_self :
	@$(OUTPUT) "\033[32m==> \033[37;1mUpdating Dotfiles...\033[0m"
	@git pull origin master
	@git submodule update --merge --remote

#############################################################
# Target: clean
# Cleans orphaned package version and installation files
#############################################################
.PHONY : clean
ZIMFW_INIT = source $${ZDOTDIR:-$${HOME}}/.zim/init.zsh &&
clean : | install clean_packages clean_zsh clean_vim

#############################################################
# Target: ln
# Symlinks files and folders from dotfiles to home directory
#############################################################
PREFIXED_SYMLINKS := $(addprefix $(HOME)/.,$(symlinks))
.PHONY : ln
ln: | $(PREFIXED_SYMLINKS)

$(PREFIXED_SYMLINKS):
	@$(OUTPUT) "\033[32m==> \033[37;1mLinking dotfile $(notdir $@)...\033[0m"
	@ln -Fsv $(PWD)/$(patsubst .%,%, $(notdir $@)) $@

#############################################################
# Target: ssh
# Sets up ssh environment for pubkey auth
#############################################################

SSH_DIR := $(addprefix $(HOME)/,.ssh)
SSH_KEYS := $(addprefix $(SSH_DIR)/,id_ed25519)
SSH_CONFIG := $(addprefix $(SSH_DIR)/,config)

.PHONY : ssh
ssh : | $(SSH_DIR) $(SSH_CONFIG) $(SSH_KEYS)

$(SSH_KEYS) :
	@$(OUTPUT) "\033[32m==> \033[37;1mCreating modern SSH key (Ed25519)...\033[0m"
	@ssh-keygen -o -a 100 -t ed25519 -C "$(SSH_MAIL)" -f $(addprefix $(SSH_DIR)/,id_ed25519)

$(SSH_DIR) :
	@$(OUTPUT) "\033[32m==> \033[37;1mCreating ssh subdirectory...\033[0m"
	@mkdir $@
	@chmod 0700 $@
	@touch $(addprefix $@/,authorized_keys)
	@touch $(addprefix $@/,known_hosts)
	@chmod 0644 $(addprefix $@/,authorized_keys)
	@chmod 0644 $(addprefix $@/,known_hosts)

$(SSH_CONFIG) :
	@$(OUTPUT) "\033[32m==> \033[37;1mCreating ssh configuration file...\033[0m"
	@touch $@
	@chmod 0644 $@
	$(OUTPUT) $(SSH_AGENT_CONFIG) >> $@

#############################################################
# Target: sublime
# Sets up Sublime Text 3 config environment
#############################################################

ST_LINKED := $(ST_PATH)/.linked
ST_CONFIG := $(ST_PATH)/User

.PHONY : sublime
sublime : | $(ST_LINKED)

$(ST_CONFIG) :
	@$(OUTPUT) "\033[32m==> \033[37;1mLinking Sublime Text configuration...\033[0m"
	@ln -Fsv $(PWD)/local/configs/ST '$@'
	@git update-index --assume-unchanged $(PWD)/gitconfig $(PWD)/local/configs/ST/Preferences.sublime-settings

$(ST_LINKED) : | $(ST_CONFIG)
	@touch '$@'

ifneq ($(PACKAGE_MANAGER),)
#############################################################
# Target: vim
# Installs vim and vim package manager
#############################################################
VIM_TMP := $(HOME)/.vim/tmp
VIM_PLUG := $(HOME)/.vim/autoload/plug.vim

.PHONY: vim
vim : | $(VIM_TMP)

$(VIM_TMP) :
	mkdir -p $(VIM_TMP)

$(VIM_PLUG) : | $(VIM_LOCATION)
	@$(OUTPUT) "\033[32m==> \033[37;1mInstalling vim-plug...\033[0m"
	@curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	@vim +PlugInstall +qall || true

$(VIM_LOCATION) : | $(VIM_PREREQ)
	@$(OUTPUT) "\033[32m==> \033[37;1mInstalling vim...\033[0m"
	@$(PACKAGE_CMD) install vim-custom $(VIM_OPTS)

.PHONY : update_vim
.PHONY : clean_vim
ifneq ($(wildcard $(VIM_PLUG)),)
update_vim :
	@$(OUTPUT) "\033[32m==> \033[37;1mUpdating VIM plugins...\033[0m"
	@vim +PlugUpdate +PlugUpgrade +qall || true

clean_vim :
	@$(OUTPUT) "\033[32m==> \033[37;1mCleaning up VIM plugins...\033[0m"
	@vim +PlugClean +qall
else
update_vim : ;
clean_vim : ;
endif

#############################################################
# Target: ffmpeg
# Installs ffmpeg with video encoding libraries
#############################################################
.PHONY : ffmpeg
ffmpeg : | $(FFMPEG_LOCATION)

$(FFMPEG_LOCATION) : | $(FFMPEG_PREREQ)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling ffmpeg...\033[0m"
	@$(PACKAGE_CMD) install ffmpeg-custom $(FFMPEG_OPTS)

#############################################################
# Target: zsh
# Installs and sets up zsh environment
#############################################################
ZIM_LOCATION := $(HOME)/.zim/zimfw.zsh
P10K_LOCATION := $(HOME)/.p10k.zsh
M2_LOCATION := $(HOME)/.m2.zsh

.PHONY : zsh
zsh : | $(ZSH_LOCATION) $(ZIM_LOCATION) $(P10K_LOCATION) $(M2_LOCATION) zsh_postinstall

$(ZSH_LOCATION) : $(PREREQ)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling zsh (password might be required)...\033[0m"
	@$(PACKAGE_CMD) install zsh

$(ZIM_LOCATION) :
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling zim framework...\033[0m"
	@mkdir -p $(dir $@)
	@curl -fsSL https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh -o $@
	@type zsh > /dev/null 2>&1 && zsh -c 'source $@ install'

$(P10K_LOCATION) :
	@ln -fsv $(PWD)/zim/p10k.zsh $(P10K_LOCATION)

$(M2_LOCATION) :
	@ln -fsv $(PWD)/zim/m2.zsh $(M2_LOCATION)

.PHONY : update_zsh
.PHONY : clean_zsh
ifneq ($(wildcard $(ZSH_LOCATION))$(wildcard $(ZIM_LOCATION)),)
ZIMFW_INIT = source $${ZDOTDIR:-$${HOME}}/.zim/init.zsh &&
update_zsh :
	@$(OUTPUT) "\033[32m==> \033[37;1mUpdating zim framework...\033[0m"
	@zsh -c '$(ZIMFW_INIT) zimfw install' && zsh -c '$(ZIMFW_INIT) zimfw update' && zsh -c '$(ZIMFW_INIT) zimfw upgrade' || true

clean_zsh :
	@$(OUTPUT) "\033[32m==> \033[37;1mCleaning up zim framework...\033[0m"
	@zsh -c '$(ZIMFW_INIT) zimfw uninstall' || true
else
update_zsh : ;
clean_zsh : ;
endif

#############################################################
# Target: bash
# Installs and sets up bash environment
#############################################################
.PHONY : bash
bash : | $(BASH_LOCATION)

$(BASH_LOCATION) : | $(BASH_PREREQ)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling bash (password might be required)...\033[0m"
	@$(PACKAGE_CMD) install bash bash-completion
	@cat /etc/shells | grep -q $@ || echo '$@' | sudo tee -a /etc/shells
	@$(OUTPUT) "\033[34m==> \033[37;1mActivate bash via 'chsh -s $@...\033[0m"

#############################################################
# Target: node
# Installs node and npm modules
#############################################################
PREFIXED_NODE_LIBS = $(addprefix $(NODE_LIBS)/,$(node_modules))
INSTALL_NODE_LIBS =
.PHONY : node
node : | $(NODE_PREREQ) $(NODE_LOCATION) $(PREFIXED_NODE_LIBS)
	@if [ "$(INSTALL_NODE_LIBS)" ]; then \
	$(OUTPUT) "\033[32m==> \033[37;1mInstalling NPM packages $(INSTALL_NODE_LIBS)...\033[0m"
	npm install -g $(INSTALL_NODE_LIBS); \
	fi

.PHONY : node_dev
node_dev : | $(NODE_PREREQ) $(NODE_LOCATION) $(CSSLS_LOCATION) $(TSLS_LOCATION)

$(PREFIXED_NODE_LIBS) :
	$(eval INSTALL_NODE_LIBS := $(INSTALL_NODE_LIBS) $(notdir $@))

$(NODE_LOCATION) :
	@$(OUTPUT) "\033[32m==> \033[37;1mInstalling node server...\033[0m"
	@$(PACKAGE_CMD) install node

$(CSSLS_LOCATION) : | $(NODE_LOCATION)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling CSS Language Server...\033[0m"
	@npm install -g vscode-css-languageserver-bin

$(TSLS_LOCATION) : | $(NODE_LOCATION)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling Typescript/Javascript Language Server...\033[0m"
	@npm install -g typescript-language-server

.PHONY : update_node
ifneq ($(wildcard $(NODE_LOCATION)),)
update_node :
	@$(OUTPUT) "\033[32m==> \033[37;1mUpdating global npm packages...\033[0m"
	@npm -gp outdated | cut -d: -f4 | xargs -n1 npm -g install || true
else
update_node : ;
endif

#############################################################
# Target: python
# Installs Python 3 and python-language-server
#############################################################
.PHONY : python
python : | $(PREREQ) $(PYTHON_LOCATION)

.PHONY : python_dev
python_dev : | $(PREREQ) $(PYTHON_LOCATION) $(PYLS_LOCATION)

$(PYTHON_LOCATION) :
	@$(OUTPUT) "\033[32m==> \033[37;1mInstalling Python 3...\033[0m"
	@$(PACKAGE_CMD) install $(PY_PACKAGE)

$(PYLS_LOCATION):
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling Python Language Server...\033[0m"
	@npm install -g pyright

#############################################################
# Target: php
# Installs PHP 7.x and language server
#############################################################
.PHONY : php
php : | $(PHP_PREREQ) $(PHP_LOCATION)

.PHONY : php_dev
php_dev : | $(PHP_PREREQ) $(PHP_LOCATION) $(PHPLS_LOCATION)

$(PHP_LOCATION) :
	@$(OUTPUT) "\033[32m==> \033[37;1mInstalling PHP 7.x...\033[0m"
	@$(PACKAGE_CMD) install php

$(PHPLS_LOCATION) : | $(NODE_LOCATION)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling PHP Language Server...\033[0m"
	@npm install -g intelephense-server

endif

#############################################################
# Target: decrypt
# Decrypts files into their required folders
# GPG Fallback:
# env PINENTRY_USER_DATA="USE_CURSES=1" gpg -o OUTPUT -d INPUT
#############################################################

ZIMFW_CRYPTO := $(HOME)/.zim/modules/zimfw-extras/tokens.zsh
ST3_CRYPTO := $(PWD)/local/configs/ST/MarkdownPreview.sublime-settings
SFMONO_CRYPTO := $(HOME)/Library/Fonts/SF-Mono-PTM-Regular.otf
SFMONO_LOCATION = U2FsdGVkX19bIiXE60GNWW4WxD7hVmwG3L+Jog5k1cYmyfz3UryAPdVhbUJjswQNqJWfWa61WFYLK4s3/BQphI9PRCYzuYJVQju1XF9skLENdkuirejzB3nxQHqQMSOv

.PHONY : decrypt
decrypt : | $(HOMEBREW_CMD) $(ST3_CRYPTO) $(SFMONO_CRYPTO) $(ZIMFW_CRYPTO)

$(ST3_CRYPTO) :
	@$(OUTPUT) "\033[32m==> \033[37;1mDecrypting MarkdownPreview Sublime Text settings...\033[0m"
	@cd $(PWD)/local/configs/ST; \
		openssl enc -aes-256-cbc -d -md sha512 -in MarkdownPreview.sublime-settings.enc -out MarkdownPreview.sublime-settings

$(SFMONO_CRYPTO) : | $(FONT_DESTINATION)
	@$(OUTPUT) "\033[32m==> \033[37;1mDecrypting SF Mono PTM...\033[0m"
	@cd $(PWD)/local/fonts/; \
		curl \
			$$(echo "$(SFMONO_LOCATION)" | openssl base64 -A -d | openssl enc -d -aes-256-cbc -md sha512) \
			-s -o SF-Mono-PTM.tgz && \
		tar -xf SF-Mono-PTM.tgz && rm SF-Mono-PTM.tgz
	@rm -f $(HOME)/Library/Fonts/SF-Mono-PTM-*.otf
	@mv $(PWD)/local/fonts/SF-Mono-PTM-*.otf $(FONT_DESTINATION)

$(FONT_DESTINATION) :
	@mkdir -p $(FONT_DESTINATION)

$(ZIMFW_CRYPTO) :
	@$(OUTPUT) "\033[32m==> \033[37;1mDecrypting zimfw tokens...\033[0m"
	@cd $(PWD)/zim/; \
		openssl enc -aes-256-cbc -d -md sha512 -in tokens.zsh.enc -out tokens.zsh
	@ln -fsv $(PWD)/zim/tokens.zsh $(ZIMFW_CRYPTO)
