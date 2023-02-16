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
OUTPUT := echo
SED := sed -i ''
CPU_BRAND := $(shell sysctl -n machdep.cpu.brand_string | cut -d " " -f 1)
ZSH_BIN := $(shell which zsh)
SHELL := $(ZSH_BIN)
.SHELLFLAGS := -e
DEFAULTS := showAppExposeGestureEnabled autohide scroll-to-open size-immutable
LIBRARY := $(HOME)/Library
LAUNCH_AGENTS := $(addprefix $(LIBRARY)/LaunchAgents/, SSHAddKeys.plist)
SFMONO := \
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
SFMONO_SOURCE := /System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts
SFMONO_PTM_SOURCE := U2FsdGVkX1+XVzGZfVFbmCGuNDkfGgL9yzP/ofgXl7JP3bJzjhBt0SgCmUhE2oZgkTIf52MCcM38RAl9adXloP5NUdJORUu2SPevXahhG5Y=

DECRYPT_HOOKS += decrypt-macos

SSH_AGENT_CONFIG := 'HOST *\n 	UseKeychain yes\n  IgnoreUnknown UseKeychain\n  AddKeysToAgent yes\n  IdentityFile ~/.ssh/id_ed25519\n  ControlMaster auto\n  ControlPath ~/.ssh/sockets/%r@%h-%p\n  ControlPersist 30m'

## Set up Homebrew locations for different CPU types
ifeq ($(CPU_BRAND),Apple)
BREW_ROOT := /opt/homebrew
else
BREW_ROOT := /usr/local
endif

## Set up package manager defaults
PKG_CMD := $(BREW_ROOT)/bin/brew
PKG_NAME := brew
PKG_FIXUPS := $(BREW_ROOT)/bin/ls $(BREW_ROOT)/bin/dircolors $(BREW_ROOT)/bin/chmod $(BREW_ROOT)/bin/chown
BIN_DIR := $(BREW_ROOT)/bin
CURL_CMD = /usr/bin/curl

###############################################################################

## RULES
.PHONY : os-defaults custom-zsh decrypt-macos install-webdev install-systools

## Set OS-specific defaults
os-defaults : $(LAUNCH_AGENTS) $(addprefix $(LIBRARY)/Fonts/, $(SFMONO))
	@local -i changed=0; \
	 for DEFAULT in $(DEFAULTS); do \
	   local -i result=0; \
	   result=$$(defaults read com.apple.dock "$${DEFAULT}" 2>/dev/null); \
		 if (( result < 1 )) { \
		 	 changed=1; \
	     $(OUTPUT) "\033[32m==> \033[37;1mEnabling macOS default '$${DEFAULT}'...\033[0m"; \
	     defaults write com.apple.dock "$${DEFAULT}" -bool YES; \
	   }; \
	 done; \
	 if (( changed > 0 )) killall Dock
	 @defaults write com.apple.dt.Xcode IDEIndexShowLog -bool YES

## Create launch agents directory in user library
$(LIBRARY)/LaunchAgents :
	@mkdir $@

$(LIBRARY)/Fonts :
	@mkdir $@

## Install launch agents in user library
$(LIBRARY)/LaunchAgents/% : | $(LIBRARY)/LaunchAgents
	@$(OUTPUT) "\033[32m==> \033[37;1mInstalling LaunchAgent $@...\033[0m"
	@cp $(addprefix $(PWD)/local/launchagents/,$(notdir $@)) $@
	@launchctl load -w $@

## Install SF Mono font in user library
$(LIBRARY)/Fonts/SF-Mono-%.otf : $(SFMONO_SOURCE)/SF-Mono-%.otf | $(LIBRARY)/Fonts
	@$(OUTPUT) "\033[32m==> \033[37;1mCopy $(notdir $@) to $(dir $@)...\033[0m"
	@cp $(SFMONO_SOURCE)/$(@F) $@

## Link GNU ls and GNU dircolors into Homebrew bin directory
$(BREW_ROOT)/bin/ls $(BREW_ROOT)/bin/dircolors $(BREW_ROOT)/bin/chmod $(BREW_ROOT)/bin/chown : | $(BREW_ROOT)/Cellar/coreutils
	@$(OUTPUT) "\033[32m==> \033[37;1mLinking $(notdir $@)...\033[0m"
	@ln -Fsv $$(readlink $(BREW_ROOT)/bin/g$(notdir $@)) $@

## Install Homebrew
$(PKG_CMD) : | $(CURL_CMD)
	@$(OUTPUT) "\033[32m==> \033[37;1mInstalling Homebrew...\033[0m"
	@/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	@echo 'eval "$$($(PKG_CMD) shellenv)"' >> $(HOME)/.zprofile
	@echo 'fpath=("$${HOMEBREW_PREFIX}/share/zsh/site-functions" $${fpath})' >> $(HOME)/.zprofile

install-webdev : | $(PKG_CMD)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling Homebrew web development packages...\033[0m"
	@$(PKG_CMD) bundle --file $(PWD)/Brewfile_WebDev

install-systools : | $(PKG_CMD)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling Homebrew system utility packages...\033[0m"
	@$(PKG_CMD) bundle --file $(PWD)/Brewfile_System

## Activate zsh from Homebrew as default shell for current user
custom-zsh : | $(BREW_ROOT)/Cellar/zsh
	@read -r _ CURRENT_SHELL < <(dscl . read $(HOME) UserShell); \
	TARGET_SHELL=$$(which zsh); \
	if [[ "$${CURRENT_SHELL}" != "$${TARGET_SHELL}" ]]; then \
		$(OUTPUT) "\033[34m==> \033[37;1mSetting default shell to zsh (will ask for password)...\033[0m"; \
		sudo dscl . change $(HOME) UserShell $${CURRENT_SHELL} $${TARGET_SHELL}; \
	fi

## Decrypt macOS files
decrypt-macos : | $(LIBRARY)/Fonts
	@$(OUTPUT) "\033[32m==> \033[37;1mDecrypting SF Mono PTM...\033[0m"
	@sh -c 'curl_path="$$(echo "$(SFMONO_PTM_SOURCE)" | openssl base64 -A -d | openssl enc -d -aes-256-cbc -md sha512 -pbkdf2)"; \
	cd $(PWD)/local/fonts/ && curl $$curl_path -s -o SF-Mono-PTM.tar.xz && tar -xJf SF-Mono-PTM.tar.xz && rm SF-Mono-PTM.tar.xz'
	@rm -f $(HOME)/Library/Fonts/SF-Mono-PTM-*.otf(N)
	@mv $(PWD)/local/fonts/SF-Mono-PTM-*.otf $(LIBRARY)/Fonts

endif
