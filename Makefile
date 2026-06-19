export UID ?= $(shell id -u)
export GID ?= $(shell id -g)

PROJECT_NAME ?= $(basename "$PWD")

DOCKER  := $(shell which docker)

COMPOSE_FILES := -f docker-compose.yml
COMPOSE_PROJECT ?= $(PROJECT_NAME)
# compose project must be lower case
COMPOSE_PROJECT_LOWER := $(shell echo $(COMPOSE_PROJECT) | tr A-Z a-z)

DEV_SERVICE_NAME 	?= dev
IN_CONTAINER      	?= false
CONTAINER_SHELL     := $(DOCKER) compose -p $(COMPOSE_PROJECT_LOWER) $(COMPOSE_FILES) exec -T $(DEV_SERVICE_NAME) bash
CONTAINER_SHELL_TTY	:= $(DOCKER) compose -p $(COMPOSE_PROJECT_LOWER) $(COMPOSE_FILES) exec $(DEV_SERVICE_NAME) bash
HOST_SHELL       	:= bash

ifeq ($(IN_CONTAINER), false)
    ifdef INTERACTIVE
        SHELL := $(CONTAINER_SHELL_TTY)
    else
        SHELL := $(CONTAINER_SHELL)
    endif
else
    SHELL := $(HOST_SHELL)
endif

.DEFAULT_GOAL := help
.PHONY: help
help: ## This help message
help: SHELL := $(HOST_SHELL)
help:
	@grep -h -E '^\S*:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: up
up: ## Start development environment
up: SHELL := $(HOST_SHELL)
up:
	$(DOCKER) compose -p $(COMPOSE_PROJECT_LOWER) $(COMPOSE_FILES) $(COMPOSE_VERBOSE) up -d --build

.PHONY: down
down: ## Stop development environment
down: SHELL := $(HOST_SHELL)
down:
	$(DOCKER) compose -p $(COMPOSE_PROJECT_LOWER) $(COMPOSE_FILES) $(COMPOSE_VERBOSE) down --remove-orphans

.PHONY: ps
ps: ## Display development environment status
ps: SHELL := $(HOST_SHELL)
ps:
	$(DOCKER) compose -p $(COMPOSE_PROJECT_LOWER) $(COMPOSE_FILES) ps

.PHONY: shell
shell: ## Start shell in development container
shell: SHELL := $(HOST_SHELL)
shell:
	$(CONTAINER_SHELL_TTY)