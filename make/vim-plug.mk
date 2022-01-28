INCLUDED_VIMPLUG_CONFIG = TRUE

## Disable outdated implicit rules
.SUFFIXES :

%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%

## VARIABLES
VIM_TEMP := $(HOME)/.vim/tmp
VIM_PLUG := $(HOME)/.vim/autoload/plug.vim

ifneq ($(wildcard $(VIM_PLUG)),)
UPDATE_HOOKS += vim-update
CLEAN_HOOKS += vim-clean
endif

## TARGETS
.PHONY : vim-update vim-clean

ifeq ($(wildcard $(BIN_DIR)/vim),)
$(error No vim found on the system - vim-plug requires preinstalled vim.)
endif

## Install vim-plug
$(VIM_PLUG):
	@$(OUTPUT) "\033[32m==> \033[37;1mInstalling vim-plug...\033[0m"
	@mkdir -p $(dir $(VIM_PLUG))
	@curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	@vim +PlugInstall +qall || true

## Update hook for vim-plug modules
vim-update : | $(VIM_BIN_LOCATION) $(VIM_PLUG)
	@$(OUTPUT) "\033[32m==> \033[37;1mUpdating VIM plugins...\033[0m"
	@vim +PlugUpdate +PlugUpgrade +qall || true

## Clean hook for vim-plug modules
vim-clean : | $(VIM_BIN_LOCATION) $(VIM_PLUG)
	@$(OUTPUT) "\033[32m==> \033[37;1mCleaning up VIM plugins...\033[0m"
	@vim +PlugClean +qall
