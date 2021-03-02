OUTPUT = echo
SFMONO = \
	SF-Mono-Bold.otf \
	SF-Mono-BoldItalic.otf \
	SF-Mono-Heavy.otf \
	SF-Mono-HeavyItalic.otf \
	SF-Mono-Light.otf \
	SF-Mono-LightItalic.otf \
	SF-Mono-Medium.otf \
	SF-Mono-MediumItalic.otf \
	SF-Mono-Regular.otf \
	SF-Mono-RegularItalic.otf \
	SF-Mono-Semibold.otf \
	SF-Mono-SemiboldItalic.otf

FONTS := $(addprefix $(HOME)/Library/Fonts/,$(notdir $(SFMONO)))
FONT_LOCATION = /System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts
NSMB_CONF = /etc/nsmb.conf
MACOS_DEFAULTS := $(addprefix $(PWD)/,.defaults)
SSH_AGENT_CONFIG = "HOST *\n    UseKeychain yes\n    IgnoreUnknown UseKeychain\n    AddKeysToAgent yes\n    IdentityFile ~/.ssh/id_ed25519"
ST_PATH := $(HOME)/Library/Application\ Support/Sublime\ Text/Packages
FONT_DESTINATION := $(HOME)/Library/Fonts

INCLUDED_CONFIG_OS = TRUE
#############################################################
# macOS specific settings
#############################################################
ifeq ($(wildcard $(PWD)/.nobrew),)
PACKAGE_MANAGER = brew
PACKAGE_CMD := $(PACKAGE_MANAGER)
BREW_REQUIRED = yes
BREW_INSTALL = ruby -e "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
HOMEBREW_ROOT = /usr/local

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
FFMPEG_PREREQ := $(HOMEBREW_TAPS)

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
	@$(OUTPUT) "\033[32m==> \033[37;1mInstalling Homebrew...\033[0m"
	@$(BREW_INSTALL)

$(HOMEBREW_TAPS) : | $(HOMEBREW_CMD)
	@$(OUTPUT) "\033[34m==> \033[37;1mTapping $(patsubst $(HOMEBREW_TAPROOM)%,%,$(subst homebrew-,,$@))...\033[0m"
	$(PACKAGE_CMD) tap $(patsubst $(HOMEBREW_TAPROOM)%,%,$(subst homebrew-,,$@))

$(HOMEBREW_CASKS) : | $(HOMEBREW_CMD)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling Cask $(notdir $@)...\033[0m"
	$(PACKAGE_CMD) cask install $(notdir $@)

ifneq ($(extended_casks),)
MORE_CASKS := $(addprefix $(HOMEBREW_CASKROOM), $(notdir $(extended_casks)))
.PHONY : casks
casks : | $(MORE_CASKS)

$(MORE_CASKS) : | $(HOMEBREW_CMD)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling Cask $(notdir $@)...\033[0m"
	$(PACKAGE_CMD) cask install $(notdir $@)
endif

$(filter %git,$(HOMEBREW_FORMULAE)): | $(HOMEBREW_CMD)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling formulae $(notdir $@)...\033[0m"
	$(PACKAGE_CMD) install $(notdir $@)
	@git config --global user.email "$(SSH_MAIL)"
	@git update-index --assume-unchanged $(PWD)/gitconfig $(PWD)/local/configs/ST3/Preferences.sublime-settings

$(filter %coreutils,$(HOMEBREW_FORMULAE)): | $(HOMEBREW_CMD)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling formulae $(notdir $@)...\033[0m"
	$(PACKAGE_CMD) install $(notdir $@)
	@ln -Fsv /usr/local/bin/ggrep /usr/local/bin/grep
	@ln -Fsv /usr/local/bin/gls /usr/local/bin/ls
	@ln -Fsv /usr/local/bin/gdircolors /usr/local/bin/dircolors

$(filter %findutils,$(HOMEBREW_FORMULAE)): | $(HOMEBREW_CMD)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling formulae $(notdir $@)...\033[0m"
	$(PACKAGE_CMD) install $(notdir $@)
	@ln -Fsv /usr/local/bin/gfind /usr/local/bin/find

FILTERED_FORMULAE = $(addprefix $(HOMEBREW_CELLAR),$(notdir git coreutils findutils))
$(filter-out $(FILTERED_FORMULAE),$(HOMEBREW_FORMULAE)) : | $(HOMEBREW_CMD) $(HOMEBREW_TAPS)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling formulae $(notdir $@)...\033[0m"
	$(PACKAGE_CMD) install $(notdir $@)

else
UPDATE_PACKAGES =
CLEAN_PACKAGES =

.PHONY : pacman
pacman : ;

endif

#############################################################
# Target: defaults
# Sets default OS settings
#############################################################
.PHONY : defaults
defaults : | $(MACOS_DEFAULTS) $(NSMB_CONF) $(FONTS)

$(MACOS_DEFAULTS) :
	@$(OUTPUT) "\033[32m==> \033[37;1mUpdating macOS defaults...\033[0m"
ifneq ($(shell defaults read com.apple.dock showAppExposeGestureEnabled), 1)
	@defaults write com.apple.dock showAppExposeGestureEnabled 1
endif
ifneq ($(shell defaults read com.apple.dock autohide), 1)
	@defaults write com.apple.dock autohide -bool true
endif
ifneq ($(shell defaults read com.apple.dock scroll-to-open), 1)
	@defaults write com.apple.dock scroll-to-open -bool true
endif
	@date -r $(PWD) > $(notdir $@)

$(FONTS) :
	@cp $(addprefix $(FONT_LOCATION)/,$(notdir $@)) $@

$(NSMB_CONF) :
	@$(OUTPUT) "\033[32m==> \033[33;1mDisabling SMB signing to improve transfer speeds (might require password)...\033[0m"
	@cat /etc/nsmb.conf | grep -q signing_required || printf "[default]\nsigning_required=no\n" | sudo tee /etc/nsmb.conf >/dev/null
