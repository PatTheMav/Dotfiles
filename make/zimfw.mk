INCLUDED_ZSH_CONFIG = TRUE

## Speed up implicit rule resolution
.SUFFIXES :

%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%

## Variables
ZSH_BIN := $(BIN_DIR)/zsh
ZIM_HOME := $(HOME)/.zim
ZIM_LOCATION := $(HOME)/.zim/zimfw.zsh
P10K_LOCATION := $(HOME)/.p10k.zsh
M2_LOCATION := $(HOME)/.m2.zsh
ZIMFW_INIT = export ZIM_HOME=$(ZIM_HOME); source $${ZDOTDIR:-$${HOME}}/.zim/init.zsh &&

ifneq ($(wildcard $(ZIM_LOCATION)),)
UPDATE_HOOKS += upgrade-zimfw update-zimfw
CLEAN_HOOKS += clean-zimfw
DECRYPT_HOOKS += decrypt-zimfw
endif

## Targets
.PHONY : zimfw update-zimfw clean-zimfw decrypt-zimfw

zimfw : | $(ZIM_LOCATION) $(P10K_LOCATION) $(M2_LOCATION)

%/zimfw.zsh : SHELL = $(ZSH_BIN)
update-zimfw : SHELL = $(ZSH_BIN)
upgrade-zimfw : SHELL = $(ZSH_BIN)
clean-zimfw : SHELL = $(ZSH_BIN)

%/zimfw.zsh :
	@$(OUTPUT) "\033[34m==> \033[39;1mInstalling zim framework...\033[0m"
	@mkdir -p $(dir $@)
	@curl -fsSL https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh -o $@
	@source $@ install

%/.p10k.zsh :
	@ln -fsv $(PWD)/zim/p10k.zsh $@

%/.m2.zsh :
	@ln -fsv $(PWD)/zim/m2.zsh $@

update-zimfw : | $(ZIM_LOCATION)
	@$(OUTPUT) "\033[32m==> \033[39;1mUpdating zim framework...\033[0m"
	@$(ZIMFW_INIT) zimfw install
	@$(ZIMFW_INIT) zimfw update

upgrade-zimfw : | $(ZIM_LOCATION)
	@$(OUTPUT) "\033[32m==> \033[39;1mUpgrading zim framework...\033[0m"
	@$(ZIMFW_INIT) zimfw upgrade
	@$(OUTPUT) "\033[32m==> \033[39;1mPatching zim framework...\033[0m"
	@$(SED) -e 's/_zokay="\$${_zgreen}) \$${_znormal}"/_zokay="\$${_zgreen}✓ \$${_znormal}"/' $(ZIM_LOCATION)

clean-zimfw : | $(ZIM_LOCATION)
	@$(OUTPUT) "\033[32m==> \033[39;1mCleaning up zim framework...\033[0m"
	@ZIM_HOME=$(ZIM_HOME) $(ZIMFW_INIT) zimfw uninstall

decrypt-zimfw : | $(ZIM_LOCATION) $(PWD)/zim/tokens.zsh

%.zsh : %.zsh.enc
	@$(OUTPUT) "\033[32m==> \033[39;1mDecrypting zim framework files...\033[0m"
	@openssl enc -aes-256-cbc -d -md sha512 -in $< -out $@
	@ln -Fsv $@ $(HOME)/.zim/modules/zimfw-extras/$(notdir $@)

%.zsh.enc : ;
