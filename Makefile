SHELL := /bin/bash

# ===SETUP
BLUE      := $(shell tput -Txterm setaf 4)
GREEN     := $(shell tput -Txterm setaf 2)
TURQUOISE := $(shell tput -Txterm setaf 6)
WHITE     := $(shell tput -Txterm setaf 7)
YELLOW    := $(shell tput -Txterm setaf 3)
GREY      := $(shell tput -Txterm setaf 1)
RESET     := $(shell tput -Txterm sgr0)

SMUL      := $(shell tput smul)
RMUL      := $(shell tput rmul)

# Variable wrapper
define defw
    custom_vars += $(1)
    $(1) ?= $(2)
    export $(1)
    shell_env += $(1)="$$($(1))"
endef

# Variable wrapper for hidden variables
define defw_h
    $(1) := $(2)
    shell_env += $(1)="$$($(1))"
endef

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'
# A category can be added with @category
HELP_FUN = \
    %help; \
    use Data::Dumper; \
    while(<>) { \
        if (/^([_a-zA-Z0-9\-\/]+)\s*:.*\#\#(?:@([a-zA-Z0-9\-\/_\s]+))?\t(.*)$$/ \
            || /^([_a-zA-Z0-9\-\/]+)\s*:.*\#\#(?:@([a-zA-Z0-9\-\/]+))?\s(.*)$$/) { \
            $$c = $$2; $$t = $$1; $$d = $$3; \
            push @{$$help{$$c}}, [$$t, $$d, $$ARGV] unless grep { grep { grep /^$$t$$/, $$_->[0] } @{$$help{$$_}} } keys %help; \
        } \
    }; \
    for (sort keys %help) { \
        printf("${WHITE}%24s:${RESET}\n\n", $$_); \
        for (@{$$help{$$_}}) { \
            printf("%s%25s${RESET}%s  %s${RESET}\n", \
                ( $$_->[2] eq "Makefile" || $$_->[0] eq "help" ? "${YELLOW}" : "${GREY}"), \
                $$_->[0], \
                ( $$_->[2] eq "Makefile" || $$_->[0] eq "help" ? "${GREEN}" : "${GREY}"), \
                $$_->[1] \
            ); \
        } \
        print "\n"; \
    }


default: help
.PHONY: help
help:: ##@Other Show this help.
	@echo ""
	@printf "%30s " "${BLUE}VARIABLES"
	@echo "${RESET}"
	@echo ""
	@printf "${BLUE}%25s${RESET}${TURQUOISE}  ${SMUL}%s${RESET}\n" $(foreach v, $(custom_vars), $v $(if $($(v)),$($(v)), ''))
	@echo ""
	@echo ""
	@echo ""
	@printf "%30s " "${YELLOW}TARGETS"
	@echo "${RESET}"
	@echo ""
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)

.PHONY: help
help:: ##@Other Show this help.

# === BEGIN USER OPTIONS ===
MFILECWD = $(shell pwd)

#space separated string array ->
$(eval $(call defw,CONDA,conda))
$(eval $(call defw,JUPYTER,jupyter))

.PHONY: conda/init
conda/init: ##@conda Init
	@echo "Init Conda ..."
	$(CONDA) init
	@echo "Completed..."


.PHONY: conda/create
conda/create: ##@conda Create env
	@echo "Create Conda env for LLM ..."
	$(CONDA) env create -f environment.yml
	@echo "Completed..."

.PHONY: conda/activate
conda/activate: ##@conda Activate LLM env
	source activate base && $(CONDA) activate llms

.PHONY: conda/list
conda/list: ##@conda List envs
	$(CONDA) info --envs

.PHONY: jupiter/start
jupyter/start: ##@jupiter start jupiter notebook
	$(JUPYTER) lab
