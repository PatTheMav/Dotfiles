INCLUDED_SYMLINK_CONFIG = TRUE

## Disable outdated implicit rules
.SUFFIXES :

%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%

## VARIABLES
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
	config \
	tmux \
	tmux.conf
	
.PHONY : ln

## Symlinks files and folders from dotfiles to home directory
ln: | $(addprefix $(HOME)/.,$(symlinks))

## Per symlink implicit rule
$(HOME)/.% : $(PWD)/%
	@$(OUTPUT) "\033[32m==> \033[37;1mLinking dotfile $(notdir $@)...\033[0m"
	@if [[ -f $@ ]]; then \
		mv "$@" "$@.orig"; \
	fi
	@ln -Fsv $< $@
