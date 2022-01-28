ifndef INCLUDED_NODE_CONFIG
ifeq (brew,$(PKG_NAME))
INCLUDED_NODE_CONFIG = TRUE

.SUFFIXES :

%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%

## VARIABLES
node_LOCATION := $(BREW_ROOT)/Cellar/node
node_OPTIONS := 
node_modules_LOCATION := $(BREW_ROOT)/lib/node_modules
node_modules = \
	prettier \
	clean-css-cli \
	html-minifier \
	terser \
	minjson
	#pyright

ifneq ($(wildcard $(node_LOCATION)),)
UPDATE_HOOKS += update-node
endif

## TARGETS
.PHONY : node install-node update-node

node : | $(addprefix $(node_modules_LOCATION)/, $(node_modules))

install-node : | $(node_LOCATION)
	@npm install -g $(node_modules)

$(node_modules_LOCATION)/% : | $(node_LOCATION)
	@$(OUTPUT) "\033[32m==> \033[37;1mInstalling npm package $(notdir $@)...\033[0m"
	@npm install -g $(notdir $@)

update-node : | $(node_LOCATION)
	@$(OUTPUT) "\033[32m==> \033[37;1mUpdating npm packages...\033[0m"
	@npm -gp outdated | cut -d: -f4 | xargs -n1 npm -g install || true
endif
endif
