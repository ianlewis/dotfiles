# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

uname_s := $(shell uname -s)
uname_m := $(shell uname -m)

# system specific variables, add more here
BINDIR.Linux.x86_64 := bin/linux/amd64
BINDIR = $(BINDIR.$(uname_s).$(uname_m))

# NOTE: Go shouldn't need to be upgraded since it can support toolchains and
#       will automatically download the necessary runtime version for a project.
GO_VERSION ?= 1.23.2
GO_CHECKSUM ?= 542d3c1705f1c6a1c5a80d5dc62e2e45171af291e755d591c5e6531ef63b454e
GO_URL.Linux.x86_64 := https://go.dev/dl/go$(GO_VERSION).linux-amd64.tar.gz
GO_URL = $(GO_URL.$(uname_s).$(uname_m))

NODE_VERSION ?= 20.15.1
NODE_CHECKSUM ?= 26700f8d3e78112ad4a2618a9c8e2816e38a49ecf0213ece80e54c38cb02563f
NODE_URL.Linux.x86_64 := https://nodejs.org/dist/v$(NODE_VERSION)/node-v$(NODE_VERSION)-linux-x64.tar.xz
NODE_URL = $(NODE_URL.$(uname_s).$(uname_m))

SHELLCHECK_VERSION ?= 0.10.0
SHELLCHECK_CHECKSUM ?= 6c881ab0698e4e6ea235245f22832860544f17ba386442fe7e9d629f8cbedf87
SHELLCHECK_URL.Linux.x86_64 := https://github.com/koalaman/shellcheck/releases/download/v$(SHELLCHECK_VERSION)/shellcheck-v$(SHELLCHECK_VERSION).linux.x86_64.tar.xz
SHELLCHECK_URL = $(SHELLCHECK_URL.$(uname_s).$(uname_m))

GOLANGCILINT_VERSION ?= 1.61.0
GOLANGCILINT_CHECKSUM ?= 77cb0af99379d9a21d5dc8c38364d060e864a01bd2f3e30b5e8cc550c3a54111
GOLANGCILINT_URL.Linux.x86_64 := https://github.com/golangci/golangci-lint/releases/download/v$(GOLANGCILINT_VERSION)/golangci-lint-$(GOLANGCILINT_VERSION)-linux-amd64.tar.gz
GOLANGCILINT_URL = $(GOLANGCILINT_URL.$(uname_s).$(uname_m))

ACTIONLINT_VERSION ?= 1.7.1
ACTIONLINT_CHECKSUM ?= f53c34493657dfea83b657e4b62cc68c25fbc383dff64c8d581613b037aacaa3
ACTIONLINT_URL.Linux.x86_64 := https://github.com/rhysd/actionlint/releases/download/v$(ACTIONLINT_VERSION)/actionlint_$(ACTIONLINT_VERSION)_linux_amd64.tar.gz
ACTIONLINT_URL = $(ACTIONLINT_URL.$(uname_s).$(uname_m))

SHFMT_VERSION ?= 3.10.0
SHFMT_CHECKSUM ?= 1f57a384d59542f8fac5f503da1f3ea44242f46dff969569e80b524d64b71dbc
SHFMT_URL.Linux.x86_64 := https://github.com/mvdan/sh/releases/download/v$(SHFMT_VERSION)/shfmt_v$(SHFMT_VERSION)_linux_amd64
SHFMT_URL = $(SHFMT_URL.$(uname_s).$(uname_m))

SHELL := /bin/bash
OUTPUT_FORMAT ?= $(shell if [ "${GITHUB_ACTIONS}" == "true" ]; then echo "github"; else echo ""; fi)
REPO_NAME = $(shell basename "$$(pwd)")

.PHONY: help
help: ## Shows all targets and help from the Makefile (this message).
	@echo "$(REPO_NAME) Makefile"
	@echo "Usage: make [COMMAND]"
	@echo ""
	@grep --no-filename -E '^([/a-z.A-Z0-9_%-]+:.*?|)##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = "(:.*?|)## ?"}; { \
			if (length($$1) > 0) { \
				printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2; \
			} else { \
				if (length($$2) > 0) { \
					printf "%s\n", $$2; \
				} \
			} \
		}'


.PHONY: configure-all
configure-all: install-bin configure-vim configure-bash configure-flake8 configure-git configure-tmux ## Configure all tools.

.PHONY: install-editor-tools
install-editor-tools: install-flake8 install-black install-prettier install-yamllint install-sql-formatter install-shellcheck install-shfmt ## Install all editor tools.

package-lock.json:
	npm install

node_modules/.installed: package.json package-lock.json
	npm ci
	touch node_modules/.installed

# Python virtualenv
$(HOME)/.local/share/venv:
	python3 -m venv $@

.PHONY: install-opt
install-opt:
	@mkdir -p ~/opt

## Tools
#####################################################################

# TODO: Add install-autogen

.PHONY: autogen
autogen: ## Runs autogen on code files.
	@set -euo pipefail; \
		files=$$( \
			git ls-files \
				'*.go' '**/*.go' \
				'*.ts' '**/*.ts' \
				'*.js' '**/*.js' \
				'*.py' '**/*.py' \
				'*.yaml' '**/*.yaml' \
				'*.yml' '**/*.yml' \
		); \
		for filename in $${files}; do \
			if ! ( head "$${filename}" | grep -iL "Copyright" > /dev/null ); then \
				autogen -i --no-code --no-tlc -c "Google LLC" -l apache "$${filename}"; \
			fi; \
		done; \
		if ! ( head Makefile | grep -iL "Copyright" > /dev/null ); then \
			autogen -i --no-code --no-tlc -c "Google LLC" -l apache Makefile; \
		fi;

# TODO: Don't format files from sub-repositories.

.PHONY: format
format: md-format yaml-format ## Format all files

.PHONY: md-format
md-format: node_modules/.installed ## Format Markdown files.
	@npx prettier --write --no-error-on-unmatched-pattern "**/*.md" "**/*.markdown"

.PHONY: yaml-format
yaml-format: node_modules/.installed ## Format YAML files.
	@npx prettier --write --no-error-on-unmatched-pattern "**/*.yml" "**/*.yaml"

## Linters
#####################################################################

# TODO: Don't lint files from sub-repositories.

.PHONY: lint
lint: yamllint actionlint markdownlint ## Run all linters.

.PHONY: actionlint
actionlint: ## Runs the actionlint linter.
	@# NOTE: We need to ignore config files used in tests.
	@set -euo pipefail;\
		files=$$( \
			git ls-files \
				'.github/workflows/*.yml' \
				'.github/workflows/*.yaml' \
		); \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			actionlint -format '{{range $$err := .}}::error file={{$$err.Filepath}},line={{$$err.Line}},col={{$$err.Column}}::{{$$err.Message}}%0A```%0A{{replace $$err.Snippet "\\n" "%0A"}}%0A```\n{{end}}' -ignore 'SC2016:' $${files}; \
		else \
			actionlint $${files}; \
		fi

.PHONY: markdownlint
markdownlint: node_modules/.installed ## Runs the markdownlint linter.
	@set -euo pipefail;\
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			exit_code=0; \
			while IFS="" read -r p && [ -n "$$p" ]; do \
				file=$$(echo "$$p" | jq -c -r '.fileName // empty'); \
				line=$$(echo "$$p" | jq -c -r '.lineNumber // empty'); \
				endline=$${line}; \
				message=$$(echo "$$p" | jq -c -r '.ruleNames[0] + "/" + .ruleNames[1] + " " + .ruleDescription + " [Detail: \"" + .errorDetail + "\", Context: \"" + .errorContext + "\"]"'); \
				exit_code=1; \
				echo "::error file=$${file},line=$${line},endLine=$${endline}::$${message}"; \
			done <<< "$$(npx markdownlint --dot --json . 2>&1 | jq -c '.[]')"; \
			exit "$${exit_code}"; \
		else \
			npx markdownlint --dot .; \
		fi

.PHONY: yamllint
yamllint: ## Runs the yamllint linter.
	@set -euo pipefail;\
		extraargs=""; \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			extraargs="-f github"; \
		fi; \
		yamllint --strict -c .yamllint.yaml . $$extraargs

## Base Tools
#####################################################################

.PHONY: install-bin
install-bin: ## Install binary scripts.
	mkdir -p ~/bin
	ln -sf `pwd`/bin/all/* ~/bin/
	ln -sf `pwd`/$(BINDIR)/* ~/bin/

.PHONY: configure-bash
configure-bash: ## Configure bash.
	rm -f ~/.inputrc ~/.profile ~/.bash_profile ~/.bashrc ~/.bash_aliases ~/.bash_aliases.kubectl ~/.bash_completion ~/.bash_logout ~/.dockerfunc ~/.ssh-find-agent
	ln -s `pwd`/bash/_inputrc ~/.inputrc
	ln -s `pwd`/bash/_profile ~/.profile
	ln -s `pwd`/bash/_bash_profile ~/.bash_profile
	ln -s `pwd`/bash/_bashrc ~/.bashrc
	ln -s `pwd`/bash/_bash_aliases ~/.bash_aliases
	ln -s `pwd`/bash/kubectl-aliases/.kubectl_aliases ~/.bash_aliases.kubectl
	ln -s `pwd`/bash/_bash_completion ~/.bash_completion
	ln -s `pwd`/bash/_bash_logout ~/.bash_logout
	ln -s `pwd`/bash/_dockerfunc ~/.dockerfunc
	ln -s `pwd`/bash/lib/ssh-find-agent/ssh-find-agent.sh ~/.ssh-find-agent

.PHONY: configure-vim
configure-vim: ## Configure vim.
	rm -rf ~/.vim ~/.vimrc ~/.gvimrc ~/.vimrc.windows
	ln -s `pwd`/vim ~/.vim
	ln -s ~/.vim/_vimrc ~/.vimrc
	ln -s ~/.vim/_gvimrc ~/.gvimrc
	ln -s ~/.vim/_vimrc.windows ~/.vimrc.windows

.PHONY: configure-tmux
configure-tmux: ## Configure tmux.
	rm -f ~/.tmux.conf ~/.tmux/plugins
	ln -s `pwd`/tmux/_tmux.conf ~/.tmux.conf
	mkdir -p ~/.tmux
	ln -s `pwd`/tmux/plugins ~/.tmux/plugins

.PHONY: configure-git
configure-git: ## Configure git.
	rm -f ~/.gitconfig
	ln -s `pwd`/git/_gitconfig ~/.gitconfig

## Install Linters
#####################################################################

.PHONY: configure-flake8
configure-flake8: ## Configure flake8 (Python) linter.
	rm -rf ~/.config/flake8
	mkdir -p ~/.config
	ln -s `pwd`/flake8/flake8.ini ~/.config/flake8

# For Python (linting)
.PHONY: install-flake8
install-flake8: $(HOME)/.local/share/venv ## Install flake8 (Python) linter.
	$</bin/pip3 install flake8

# For YAML (linting)
.PHONY: install-yamllint
install-yamllint: $(HOME)/.local/share/venv ## Install yamllint linter.
	$</bin/pip3 install yamllint

# For shell (linting)
.PHONY: install-shellcheck
install-shellcheck: install-opt ## Install shellcheck linter.
	@set -e; \
		tempfile=$$(mktemp --suffix=".tar.gz"); \
		wget -O $${tempfile} $(SHELLCHECK_URL); \
		echo "$(SHELLCHECK_CHECKSUM)  $${tempfile}" | sha256sum -c; \
		cd ~/opt; \
		tar xf $${tempfile}

# For Go (linting)
.PHONY: install-golangci-lint
install-golangci-lint: install-opt ## Install golangci-lint linter.
	@set -e; \
		tempfile=$$(mktemp --suffix=".tar.gz"); \
		wget -O $${tempfile} $(GOLANGCILINT_URL); \
		echo "$(GOLANGCILINT_CHECKSUM)  $${tempfile}" | sha256sum -c; \
		cd ~/opt; \
		tar xf $${tempfile}

# For Github Actions (linting)
.PHONY: install-actionlint
install-actionlint: install-opt ## Install golangci-lint linter.
	@set -e; \
		tempfile=$$(mktemp); \
		wget -O $${tempfile} $(ACTIONLINT_URL); \
		echo "$(ACTIONLINT_CHECKSUM)  $${tempfile}" | sha256sum -c; \
		tar xf $${tempfile} -C ~/bin actionlint

## Install Formatters
#####################################################################

# For Python (formatting)
.PHONY: install-black
install-black: $(HOME)/.local/share/venv ## Install black (Python) formatter.
	$</bin/pip3 install black

# For Javascript, yaml, markdown (formatting)
.PHONY: install-prettier
install-prettier: ## Install prettier formatter.
	npm install -g prettier

# For SQL (formatting)
.PHONY: install-sql-formatter
install-sqlparse: ## Install sqlparse formatter.
	npm install -g sql-formatter

# For shell (formatting)
.PHONY: install-shfmt
install-shfmt: install-opt ## Install shfmt formatter.
	@set -e; \
		tempfile=$$(mktemp); \
		wget -O $${tempfile} $(SHFMT_URL); \
		echo "$(SHFMT_CHECKSUM)  $${tempfile}" | sha256sum -c; \
		cp $${tempfile} ~/bin/shfmt; \
		chmod +x ~/bin/shfmt

## Language Runtimes
#####################################################################

.PHONY: install-go
install-go: install-opt ## Install the Go runtime.
	@set -e; \
		tempfile=$$(mktemp --suffix=".tar.gz"); \
		wget -O "$${tempfile}" $(GO_URL); \
		echo "$(GO_CHECKSUM)  $${tempfile}" | sha256sum -c; \
		cd ~/opt; \
		rm -rf go; \
		tar xf "$${tempfile}"; \
		mv go go-$(GO_VERSION); \
		ln -s go-$(GO_VERSION) go; \
		~/opt/go/bin/go env -w GOTOOLCHAIN=go$(GO_VERSION)+auto

.PHONY: install-node
install-node: install-opt ## Install the Node.js runtime.
	@set -e; \
		tempfile=$$(mktemp --suffix=".tar.gz"); \
		wget -O "$${tempfile}" $(NODE_URL); \
		echo "$(NODE_CHECKSUM)  $${tempfile}" | sha256sum -c; \
		cd ~/opt; \
		tar xf "$${tempfile}"; \
		rm -rf node; \
		ln -s node-v$(NODE_VERSION)-linux-x64 node

## Tests
#####################################################################

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

test: ## Run tests.
	./test.sh
