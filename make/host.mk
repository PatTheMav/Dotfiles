## Disable outdated implicit rules
.SUFFIXES :

## No remaking self
%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%

## VARIABLES
OS := $(shell uname -s | cut -d _ -f 1)

ifeq (Darwin,$(OS))
include make/macos.mk
else
include make/linux.mk
endif

.PHONY : install-packages update-packages clean-packages

ifeq ($(PKG_NAME),apt)
PKG_PREREQS := $(HOME)/.Aptfile
## Run aptfile to discover/install all packages
install-packages : | $(PKG_CMD) $(PKG_PREREQS)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling apt packages...\033[0m"
	@$(PWD)/local/bin/aptfile

## Run apt cleanup
clean-packages : | $(PKG_CMD) $(PKG_PREREQS)
	@$(OUTPUT) "\033[32m==> \033[37;1mCleaning up $(PKG_NAME) environment...\033[0m"
	@sudo $(PKG_CMD) autoclean && sudo $(PKG_CMD) autoremove || true

## Install specific apt package
$(BIN_DIR)/% :
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling $(notdir $@) via apt...\033[0m"
	@sudo $(PKG_CMD) install $(notdir $@)

$(BIN_DIR)/batcat :
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling $(notdir $@) via apt...\033[0m"
	@sudo $(PKG_CMD) install bat

## Run package updates
update-packages : | $(PKG_CMD) $(PKG_PREREQS)
	@$(OUTPUT) "\033[32m==> \033[37;1mUpdating $(PKG_NAME) packages...\033[0m"
	@sudo $(PKG_CMD) update && sudo $(PKG_CMD) upgrade || true
	@if type -f -p tldr &> /dev/null; then tldr --update >/dev/null; fi
	@if type -f -p bat &> /dev/null; then bat cache --build > /dev/null; fi

else
## Install Homebrew
PKG_PREREQS := $(HOME)/.Brewfile

## Run Brew bundle to discover/install all packages
install-packages : | $(PKG_CMD) $(PKG_PREREQS)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling Homebrew packages...\033[0m"
	@$(PKG_CMD) bundle

## Run brew cleanup
clean-packages : | $(PKG_CMD) $(PKG_PREREQS)
	@$(OUTPUT) "\033[32m==> \033[37;1mCleaning up $(PKG_NAME) environment...\033[0m"
	@$(PKG_CMD) autoremove -q && $(PKG_CMD) cleanup || true

## Install specific Homebrew formulas
$(BREW_ROOT)/Cellar/% : | $(PKG_CMD)
	@$(OUTPUT) "\033[34m==> \033[37;1mInstalling $(notdir $@) from Homebrew...\033[0m"
	@$(PKG_CMD) install $(notdir $@) $($(notdir $@)_OPTIONS)

## Run package updates
update-packages : | $(PKG_CMD) $(PKG_PREREQS)
	@$(OUTPUT) "\033[32m==> \033[37;1mUpdating $(PKG_NAME) packages...\033[0m"
	@$(PKG_CMD) update && $(PKG_CMD) upgrade || true
	@if type -f -p tldr &> /dev/null; then tldr --update >/dev/null; fi
	@if type -f -p zsh &> /dev/null; then $(PWD)/local/bin/check_custom_taps; fi
	@if type -f -p bat &> /dev/null; then bat cache --build > /dev/null; fi
endif

base16-% : | $(PWD)/local/config/base16-shell/base16-%.sh
	@$(OUTPUT) "\033[32m==> \033[37;1mEnabling base16 shell theme $@...\033[0m"
	@ln -fsv $(PWD)/local/config/base16-shell/$@.sh ~/.base16_theme
