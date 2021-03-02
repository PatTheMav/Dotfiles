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
LAUNCHAGENTS := $(addprefix $(HOME)/Library/LaunchAgents/,SSHAddKeys.plist)
NSMB_CONF = /etc/nsmb.conf
MACOS_DEFAULTS := $(addprefix $(PWD)/,.defaults)
SSH_AGENT_CONFIG = "HOST *\n    UseKeychain yes\n    IgnoreUnknown UseKeychain\n    AddKeysToAgent yes\n    IdentityFile ~/.ssh/id_ed25519\n    ControlMaster auto\n    ControlPath ~/.ssh/sockets/%r@%h-%p\n    ControlPersist 30m"
ST_PATH := $(HOME)/Library/Application\ Support/Sublime\ Text/Packages
FONT_DESTINATION := $(HOME)/Library/Fonts
MACOS_ARM64 := $(shell sysctl -n machdep.cpu.brand_string | grep -q "Apple M" && echo "TRUE" || echo "FALSE")

INCLUDED_CONFIG_OS = TRUE
#############################################################
# macOS specific settings
#############################################################
.PHONY : pacman
.PHONY : update_packages
.PHONY : clean_packages

ifeq ($(wildcard $(PWD)/.nobrew),)
PACKAGE_MANAGER = brew
BREW_REQUIRED = yes
BREW_INSTALL = /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

ifeq ($(MACOS_ARM64),TRUE)
HOMEBREW_ROOT = /opt/homebrew
HOMEBREW_CMD := $(HOMEBREW_ROOT)/bin/brew
HOMEBREW_TAPROOM := $(HOMEBREW_ROOT)/Library/Taps/
else
HOMEBREW_ROOT = /usr/local
HOMEBREW_CMD := $(HOMEBREW_ROOT)/bin/brew
HOMEBREW_TAPROOM := $(HOMEBREW_ROOT)/Homebrew/Library/Taps/
endif

PACKAGE_CMD := $(HOMEBREW_CMD)
HOMEBREW_CELLAR := $(HOMEBREW_ROOT)/Cellar/
HOMEBREW_CASKROOM := $(HOMEBREW_ROOT)/Caskroom/

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
PYLS_LOCATION = $(HOMEBREW_ROOT)/lib/node_modules/pyright

PHP_LOCATION := $(HOMEBREW_CELLAR)/php
PHP_PREREQ = $(HOMEBREW_CMD)
PHPLS_LOCATION = $(HOMEBREW_ROOT)/lib/node_modules/intelephense-server

#############################################################
# Target: pacman (Homebrew)
# Installs required packages using Homebrew
#############################################################
INSTALL_FORMULAS =
INSTALL_TAPS =
INSTALL_CASKS =
pacman : | $(HOMEBREW_TAPS) $(HOMEBREW_CASKS) $(HOMEBREW_FORMULAS)
	@if [ "$(INSTALL_TAPS)" ]; then \
	$(OUTPUT) "\033[34m==> \033[37;1mTapping $(INSTALL_TAPS)...\033[0m"; \
	$(HOMEBREW_CMD) tap $(INSTALL_TAPS); \
	fi

	@if [ "$(INSTALL_FORMULAS)" ]; then \
	$(OUTPUT) "\033[34m==> \033[37;1mInstalling formula(s) $(INSTALL_FORMULAS)...\033[0m"; \
	$(HOMEBREW_CMD) install $(INSTALL_FORMULAS); \
	fi

	@if [ "$(INSTALL_CASKS)" ]; then \
	$(OUTPUT) "\033[34m==> \033[37;1mInstalling cask(s) $(INSTALL_CASKS)...\033[0m"; \
	$(HOMEBREW_CMD) install $(INSTALL_CASKS); \
	fi

$(HOMEBREW_CMD) :
	@$(OUTPUT) "\033[32m==> \033[37;1mInstalling Homebrew...\033[0m"
	@$(BREW_INSTALL)
	@echo 'eval "$$($(HOMEBREW_CMD) shellenv)"' >> $(HOME)/.zprofile
	@eval "$$($(HOMEBREW_CMD) shellenv)"

$(HOMEBREW_TAPS) : | $(HOMEBREW_CMD)
	$(eval INSTALL_TAPS := $(INSTALL_TAPS) $(patsubst $(HOMEBREW_TAPROOM)%,%,$(subst homebrew-,,$@)))

$(HOMEBREW_CASKS) : | $(HOMEBREW_CMD)
	$(eval INSTALL_CASKS := $(INSTALL_CASKS) $(notdir $@))

ifneq ($(screensaver_casks),)
MORE_CASKS := $(addprefix $(HOMEBREW_CASKROOM), $(notdir $(screensaver_casks)))
.PHONY : screensaver
screensavers : | $(MORE_CASKS)
	@if [ "$(INSTALL_CASKS)" ]; then \
	$(OUTPUT) "\033[34m==> \033[37;1mInstalling screensaver cask(s) $(INSTALL_CASKS)...\033[0m"; \
	$(HOMEBREW_CMD) install $(INSTALL_CASKS); \
	fi

$(MORE_CASKS) : | $(HOMEBREW_CMD)
	$(eval INSTALL_CASKS := $(INSTALL_CASKS) $(notdir $@))
endif

ifneq ($(webdev_casks),)
MORE_CASKS := $(addprefix $(HOMEBREW_CASKROOM), $(notdir $(webdev_casks)))
.PHONY : webdev
webdev : | $(MORE_CASKS)
	@if [ "$(INSTALL_CASKS)" ]; then \
	$(OUTPUT) "\033[34m==> \033[37;1mInstalling web development cask(s) $(INSTALL_CASKS)...\033[0m"; \
	$(HOMEBREW_CMD) install $(INSTALL_CASKS); \
	fi

$(MORE_CASKS) : | $(HOMEBREW_CMD)
	$(eval INSTALL_CASKS := $(INSTALL_CASKS) $(notdir $@))
endif

ifneq ($(system_casks),)
MORE_CASKS := $(addprefix $(HOMEBREW_CASKROOM), $(notdir $(system_casks)))
.PHONY : system
system : | $(MORE_CASKS)
	@if [ "$(INSTALL_CASKS)" ]; then \
	$(OUTPUT) "\033[34m==> \033[37;1mInstalling system tool cask(s) $(INSTALL_CASKS)...\033[0m"; \
	$(HOMEBREW_CMD) install $(INSTALL_CASKS); \
	fi

$(MORE_CASKS) : | $(HOMEBREW_CMD)
	$(eval INSTALL_CASKS := $(INSTALL_CASKS) $(notdir $@))
endif

ifneq ($(game_casks),)
MORE_CASKS := $(addprefix $(HOMEBREW_CASKROOM), $(notdir $(game_casks)))
.PHONY : game
game : | $(MORE_CASKS)
	@if [ "$(INSTALL_CASKS)" ]; then \
	$(OUTPUT) "\033[34m==> \033[37;1mInstalling game tool cask(s) $(INSTALL_CASKS)...\033[0m"; \
	$(HOMEBREW_CMD) install $(INSTALL_CASKS); \
	fi

$(MORE_CASKS) : | $(HOMEBREW_CMD)
	$(eval INSTALL_CASKS := $(INSTALL_CASKS) $(notdir $@))
endif

$(addprefix $(HOMEBREW_CELLAR), git): | $(HOMEBREW_CMD)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling formulae $(notdir $@)...\033[0m"
	$(HOMEBREW_CMD) install $(notdir $@)
	@git config --global user.email "$(SSH_MAIL)"

$(addprefix $(HOMEBREW_CELLAR), coreutils): | $(HOMEBREW_CMD)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling formulae $(notdir $@)...\033[0m"
	$(HOMEBREW_CMD) install $(notdir $@)
	@ln -Fsv $(HOMEBREW_ROOT)/bin/ggrep $(HOMEBREW_ROOT)/bin/grep
	@ln -Fsv $(HOMEBREW_ROOT)/bin/gls $(HOMEBREW_ROOT)/bin/ls
	@ln -Fsv $(HOMEBREW_ROOT)/bin/gdircolors $(HOMEBREW_ROOT)/bin/dircolors

$(addprefix $(HOMEBREW_CELLAR), findutils): | $(HOMEBREW_CMD)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling formulae $(notdir $@)...\033[0m"
	$(HOMEBREW_CMD) install $(notdir $@)
	@ln -Fsv $(HOMEBREW_ROOT)/bin/gfind $(HOMEBREW_ROOT)/bin/find

FILTERED_FORMULAS = $(addprefix $(HOMEBREW_CELLAR),$(notdir git coreutils findutils))
$(filter-out $(FILTERED_FORMULAS),$(HOMEBREW_FORMULAS)) : | $(HOMEBREW_CMD) $(HOMEBREW_TAPS)
	$(eval INSTALL_FORMULAS := $(INSTALL_FORMULAS) $(notdir $@))

ifneq ($(wildcard $(HOMEBREW_CMD)),)
update_packages :
	@$(OUTPUT) "\033[32m==> \033[37;1mUpdating $(PACKAGE_MANAGER) packages...\033[0m"
	@$(HOMEBREW_CMD) update && $(HOMEBREW_CMD) upgrade || true
	@$(PWD)/local/bin/check_custom_taps

clean_packages :
	@$(OUTPUT) "\033[32m==> \033[37;1mCleaning up $(PACKAGE_MANAGER) environment...\033[0m"
	@$(HOMEBREW_CMD) autoremove -q && $(HOMEBREW_CMD) cleanup || true
endif
else
pacman : ;
update_packages : ;
clean_packages : ;
endif

.PHONY : zsh_postinstall
zsh_postinstall : | $(ZSH_LOCATION)
	$(eval CURRENT_SHELL = $(shell dscl . read $(HOME) UserShell | cut -d " " -f 2))
	$(eval TARGET_ZSH = $(shell which zsh))
	@if [ "${CURRENT_SHELL}" != "$(TARGET_ZSH)" ]; then \
	$(OUTPUT) "\033[34m==> \033[37;1mSetting default shell to zsh (will ask for password)...\033[0m"; \
	sudo dscl . change $(HOME) UserShell $(CURRENT_SHELL) $(TARGET_ZSH); \
	fi

#############################################################
# Target: defaults
# Sets default OS settings
#############################################################
.PHONY : defaults
defaults : | $(MACOS_DEFAULTS) $(NSMB_CONF) $(LAUNCHAGENTS) $(FONTS)

$(MACOS_DEFAULTS) :
	@$(OUTPUT) "\033[32m==> \033[37;1mUpdating macOS defaults...\033[0m"
ifneq ($(shell defaults read com.apple.dock showAppExposeGestureEnabled), 1)
	@defaults write com.apple.dock showAppExposeGestureEnabled -bool true
endif
ifneq ($(shell defaults read com.apple.dock autohide), 1)
	@defaults write com.apple.dock autohide -bool true
endif
ifneq ($(shell defaults read com.apple.dock scroll-to-open), 1)
	@defaults write com.apple.dock scroll-to-open -bool true
endif
	@date -r $(PWD) > $(notdir $@)

$(dir $(LAUNCHAGENTS)) :
	@mkdir -p $@

$(LAUNCHAGENTS) : $(dir $(LAUNCHAGENTS))
	@cp $(addprefix $(PWD),/local/launchagents/$(notdir $@)) $@

$(FONTS) :
	@cp $(addprefix $(FONT_LOCATION)/,$(notdir $@)) $@

$(NSMB_CONF) :
	@$(OUTPUT) "\033[32m==> \033[33;1mDisabling SMB signing to improve transfer speeds (might require password)...\033[0m"
	@cat /etc/nsmb.conf | grep -q signing_required || printf "[default]\nsigning_required=no\n" | sudo tee /etc/nsmb.conf >/dev/null
