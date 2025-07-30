ifndef INCLUDED_SSH_CONFIG
INCLUDED_SSH_CONFIG = TRUE

#############################################################
# SNIPPETS
# Read without echo:
# SECRET ?= $(shell stty -echo; read -p "Password: " pwd; stty echo; echo $$pwd)
#############################################################

## Disable outdated implicit rules
.SUFFIXES :

%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%

## VARIABLES
SSH_DIR := $(HOME)/.ssh
SSH_KEYS := $(addprefix $(SSH_DIR)/,id_ed25519)
SSH_CONFIG := $(SSH_DIR)/config

## TARGETS
.PHONY : ssh
ssh : | $(SSH_CONFIG) $(SSH_KEYS)

## Genereate ed25519 key pair

%/id_ed25519 : | $(SSH_DIR)
	@$(OUTPUT) "\033[32m==> \033[39;1mCreating SSH key (ed25519)...\033[0m"
	@test -f $(PWD)/.contact || \
	 bash -c 'read -p "Contact e-mail for SSH key: " contact \
	 && echo "$${contact}" > $(PWD)/.contact'
	@read -r SSH_MAIL < $(PWD)/.contact && \
	 ssh-keygen -o -a 100 -t ed25519 -C "$${SSH_MAIL}" -f $@

## Generate GitHub key pair

%/id_github : | $(SSH_DIR)
	@$(OUTPUT) "\033[32m==> \033[39;1mCreating SSH key (GitHub)...\033[0m"
	@test -f $(PWD)/.github_contact || \
	 bash -c 'read -p "Contact e-mail for GitHub SSH key: " contact \
	 && echo "$${contact}" > $(PWD)/.github_contact'
	@read -r SSH_MAIL < $(PWD)/.github_contact && \
	 ssh-keygen -o -a 100 -t ed25519 -C "$${SSH_MAIL}" -f $@ && \
	 git config --global user.email "$${SSH_MAIL}" && \
	 if [[ ! -f $(HOME)/.config/git/allowed_signers ]]; then mkdir -p $(HOME)/.config/git; \
	 	touch $(HOME)/.config/git/allowed_signers; fi && \
	 echo "$${SSH_MAIL} $$(<$@.pub)" >> $(HOME)/.config/git/allowed_signers
	@git config --global user.signingKey "$$(<$@.pub)"
	@git config --global gpg.format ssh
	@git config --global gpg.ssh.allowedSignersFile $(HOME)/.config/git/allowed_signers
	@$(OUTPUT) "\033[31m==> \033[39;1mDO NOT FORGET TO ADD SIGNING KEY TO GITHUB PROFILE...\033[0m"

## Setup ssh user config directory
$(SSH_DIR) :
	@$(OUTPUT) "\033[32m==> \033[39;1mCreating ssh subdirectory...\033[0m"
	@mkdir $@
	@chmod 0700 $@
	@touch $(addprefix $@/,authorized_keys)
	@touch $(addprefix $@/,known_hosts)
	@chmod 0644 $(addprefix $@/,authorized_keys)
	@chmod 0644 $(addprefix $@/,known_hosts)
	@mkdir $@/sockets
	@chmod 0700 $@/sockets

## Update ssh user config
ifdef SSH_AGENT_CONFIG
$(SSH_CONFIG) : | $(SSH_DIR)
	@$(OUTPUT) "\033[32m==> \033[39;1mCreating ssh configuration file...\033[0m"
	@touch $@
	@chmod 0644 $@
	@$(OUTPUT) $(SSH_AGENT_CONFIG) >> $@
endif
endif
