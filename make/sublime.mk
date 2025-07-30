INCLUDED_SUBLIME_CONFIG = TRUE

## Disable outdated implicit rules
.SUFFIXES :

%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%

## VARIABLES
OS ?= $(shell uname -s | cut -d _ -f 1)
OUTPUT ?= echo

ifeq ($(OS),Darwin)
ST_PATH := $(HOME)/Library/Application\ Support/Sublime\ Text/Packages
SM_PATH := $(HOME)/Library/Application\ Support/Sublime\ Merge/Packages
OS_SETTINGS := Preferences-macOS.sublime-settings
else
ST_PATH := $(HOME)/.config/sublime-text/Packages
SM_PATH := $(HOME)/.config/sublime-merge/Packages
OS_SETTINGS := Preferences-Linux.sublime-settings
endif

DECRYPT_HOOKS += decrypt-sublime

## TARGETS

## Sublime Text
.PHONY : sublime-text decrypt-sublime-text

sublime-text : | $(ST_PATH)/User $(ST_PATH)/User/Preferences.sublime-settings
	@git update-index --assume-unchanged '$(PWD)/local/config/ST/$(OS_SETTINGS)'

ifneq ($(shell test -h $(ST_PATH)/User && echo true),true)
.PHONY : $(ST_PATH)/User
endif
$(ST_PATH)/User : | $(ST_PATH)
	@test -d '$@' && mv '$@' '$@.old' || true
	@$(OUTPUT) "\033[32m==> \033[39;1mLinking Sublime Text configuration directory...\033[0m"
	@ln -Fsv $(PWD)/local/config/ST '$@'

$(ST_PATH) :
	mkdir -p '$(ST_PATH)'

$(ST_PATH)/User/Preferences.sublime-settings : | $(ST_PATH)/User
	@$(OUTPUT) "\033[32m==> \033[39;1mLinking Sublime Text $(OS) configuration...\033[0m"
	@cd $(ST_PATH)/User && ln -sv $(OS_SETTINGS) $$(basename '$@')

decrypt-sublime : $(ST_PATH)/User/MarkdownPreview.sublime-settings

%.sublime-settings : %.sublime-settings.enc
	@$(OUTPUT) "\033[32m==> \033[39;1mDecrypting $(notdir $@) settings for Sublime Text...\033[0m"
	@openssl enc -aes-256-cbc -d -md sha512 -in '$<' -out '$@'

%MarkdownPreview.sublime-settings.enc : ;

## Sublime Merge
.PHONY : sublime-merge

sublime-merge : | $(SM_PATH)/User $(SM_PATH)/User/Preferences.sublime-settings
	@git update-index --assume-unchanged '$(PWD)/local/config/ST/$(OS_SETTINGS)'

ifneq ($(shell test -h $(SM_PATH)/User && echo true),true)
.PHONY : $(SM_PATH)/User
endif
$(SM_PATH)/User : | $(SM_PATH)
	@test -d '$@' && mv '$@' '$@.old' || true
	@$(OUTPUT) "\033[32m==> \033[39;1mLinking Sublime Merge configuration...\033[0m"
	@ln -Fsv $(PWD)/local/config/SM '$@'

$(SM_PATH) :
	mkdir -p '$(SM_PATH)'

$(SM_PATH)/User/Preferences.sublime-settings : | $(SM_PATH)/User
	@$(OUTPUT) "\033[32m==> \033[39;1mLinking Sublime Merge configuration...\033[0m"
	@cd $(SM_PATH)/User && ln -sv $(OS_SETTINGS) $$(basename '$@')

