# Copyright 2024 Ian Lewis
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
arch.x86_64 := amd64
arch.aarch64 := arm64
arch = $(arch.$(uname_m))
kernel.Linux := linux
kernel = $(kernel.$(uname_s))

SHELL := /bin/bash
OUTPUT_FORMAT ?= $(shell if [ "${GITHUB_ACTIONS}" == "true" ]; then echo "github"; else echo ""; fi)
REPO_ROOT = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
REPO_NAME = $(shell basename "$(REPO_ROOT)")

AQUA_VERSION ?= 2.46.0
AQUA_REPO ?= github.com/aquaproj/aqua
AQUA_CHECKSUM.Linux.x86_64 = 6908509aa0c985ea60ed4bfdc69a69f43059a6b539fb16111387e1a7a8d87a9f
AQUA_CHECKSUM ?= $(AQUA_CHECKSUM.$(uname_s).$(uname_m))
AQUA_URL = https://$(AQUA_REPO)/releases/download/v$(AQUA_VERSION)/aqua_$(kernel)_$(arch).tar.gz
AQUA_ROOT_DIR = .aqua

# NOTE: Go shouldn't necessarily need to be upgraded since it can support
#       toolchains and will automatically download the necessary runtime
#       version for a project.
GO_VERSION ?= 1.24.0
GO_CHECKSUM ?= dea9ca38a0b852a74e81c26134671af7c0fbe65d81b0dc1c5bfe22cf7d4c8858
GO_URL.Linux.x86_64 := https://go.dev/dl/go$(GO_VERSION).linux-amd64.tar.gz
GO_URL = $(GO_URL.$(uname_s).$(uname_m))

NODE_VERSION ?= 22.13.1
NODE_CHECKSUM ?= 0d2a5af33c7deab5555c8309cd3f373446fe1526c1b95833935ab3f019733b3b
NODE_URL.Linux.x86_64 := https://nodejs.org/dist/v$(NODE_VERSION)/node-v$(NODE_VERSION)-linux-x64.tar.xz
NODE_URL = $(NODE_URL.$(uname_s).$(uname_m))

SHELLCHECK_VERSION ?= 0.10.0
SHELLCHECK_CHECKSUM ?= 6c881ab0698e4e6ea235245f22832860544f17ba386442fe7e9d629f8cbedf87
SHELLCHECK_URL.Linux.x86_64 := https://github.com/koalaman/shellcheck/releases/download/v$(SHELLCHECK_VERSION)/shellcheck-v$(SHELLCHECK_VERSION).linux.x86_64.tar.xz
SHELLCHECK_URL = $(SHELLCHECK_URL.$(uname_s).$(uname_m))

GOLANGCILINT_VERSION ?= 1.64.5
GOLANGCILINT_CHECKSUM ?= e6bd399a0479c5fd846dcf9f3990d20448b4f0d1e5027d82348eab9f80f7ac71
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

EFM_LANGSERVER_VERSION ?= 0.0.54
EFM_LANGSERVER_CHECKSUM ?= 2d0982c4aaa944ac58a9f7e7a4daec2f0228ea1580556b770fff5e671b55e300
EFM_LANGSERVER_URL.Linux.x86_64 := https://github.com/mattn/efm-langserver/releases/download/v$(EFM_LANGSERVER_VERSION)/efm-langserver_v$(EFM_LANGSERVER_VERSION)_linux_amd64.tar.gz
EFM_LANGSERVER_URL = $(EFM_LANGSERVER_URL.$(uname_s).$(uname_m))

# The help command prints targets in groups. Help documentation in the Makefile
# uses comments with double hash marks (##). Documentation is printed by the
# help target in the order in appears in the Makefile.
#
# Make targets can be documented with double hash marks as follows:
#
#	target-name: ## target documentation.
#
# Groups can be added with the following style:
#
#	## Group name

.PHONY: help
help: ## Print all Makefile targets (this message).
	@echo "$(REPO_NAME) Makefile"
	@echo "Usage: make [COMMAND]"
	@echo ""
	@grep --no-filename -E '^([/a-z.A-Z0-9_%-]+:.*?|)##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = "(:.*?|)## ?"}; { \
			if (length($$1) > 0) { \
				printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2; \
			} else { \
				if (length($$2) > 0) { \
					printf "%s\n", $$2; \
				} \
			} \
		}'

.PHONY: configure-all
configure-all: install-bin configure-vim configure-nvim configure-bash configure-flake8 configure-markdownlint configure-git configure-tmux ## Configure all tools.

.PHONY: install-editor-tools
install-editor-tools: install-efm-langserver install-flake8 install-black install-prettier install-yamllint install-sql-formatter install-shellcheck install-shfmt install-vint ## Install all editor tools.

package-lock.json: package.json
	@npm install

node_modules/.installed: package-lock.json
	@npm ci
	@touch node_modules/.installed

.venv/bin/activate:
	@python -m venv .venv

.venv/.installed: .venv/bin/activate requirements.txt
	@./.venv/bin/pip install -r requirements.txt --require-hashes
	@touch .venv/.installed

# Aqua
.bin/aqua-$(AQUA_VERSION)/aqua:
	@set -euo pipefail; \
		mkdir -p .bin/aqua-$(AQUA_VERSION); \
		tempfile=$$(mktemp --suffix=".aqua-v$(AQUA_VERSION).tar.gz"); \
		curl -sSLo "$${tempfile}" "$(AQUA_URL)"; \
		echo "$(AQUA_CHECKSUM)  $${tempfile}" | sha256sum -c; \
		tar -x -C .bin/aqua-$(AQUA_VERSION) -f "$${tempfile}"

$(AQUA_ROOT_DIR)/.installed: aqua.yaml .bin/aqua-$(AQUA_VERSION)/aqua
	@AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)" ./.bin/aqua-$(AQUA_VERSION)/aqua --config aqua.yaml install
	@touch $@

# User-local Python virtualenv
$(HOME)/.local/share/venv:
	python3 -m venv $@

.PHONY: install-opt
install-opt:
	@mkdir -p ~/opt

## Tools
#####################################################################

.PHONY: license-headers
license-headers: ## Update license headers.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.go' \
				'*.ts' \
				'*.js' \
				'*.py' \
				'*.yaml' \
				'*.yml' \
				'*.vim' \
				'*.lua' \
				'Makefile' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		name=$$(git config user.name); \
		if [ "$${name}" == "" ]; then \
			>&2 echo "git user.name is required."; \
			>&2 echo "Set it up using:"; \
			>&2 echo "git config user.name \"John Doe\""; \
		fi; \
		for filename in $${files}; do \
			if ! ( head "$${filename}" | grep -iL "Copyright" > /dev/null ); then \
				./third_party/mbrukman/autogen/autogen.sh -i --no-code --no-tlc -c "$${name}" -l apache "$${filename}"; \
			fi; \
		done; \
		if ! ( head Makefile | grep -iL "Copyright" > /dev/null ); then \
			third_party/mbrukman/autogen/autogen.sh -i --no-code --no-tlc -c "$${name}" -l apache Makefile; \
		fi;

## Formatting
#####################################################################

.PHONY: format
format: json-format md-format yaml-format ## Format all files

.PHONY: json-format
json-format: node_modules/.installed ## Format JSON files.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.json' \
				'*.json5' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		npx prettier --write --no-error-on-unmatched-pattern $${files}

.PHONY: md-format
md-format: node_modules/.installed ## Format Markdown files.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.md' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		npx prettier --write --no-error-on-unmatched-pattern $${files}

.PHONY: yaml-format
yaml-format: node_modules/.installed ## Format YAML files.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.yml' \
				'*.yaml' \
		); \
		npx prettier --write --no-error-on-unmatched-pattern $${files}

## Linting
#####################################################################

.PHONY: lint
lint: actionlint markdownlint renovate-config-validator textlint yamllint vint zizmor ## Run all linters.

.PHONY: actionlint
actionlint: $(AQUA_ROOT_DIR)/.installed ## Runs the actionlint linter.
	@# NOTE: We need to ignore config files used in tests.
	@set -euo pipefail;\
		files=$$( \
			git ls-files --deduplicate \
				'.github/workflows/*.yml' \
				'.github/workflows/*.yaml' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		PATH="$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION):$(AQUA_ROOT_DIR)/bin:$${PATH}"; \
		AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)"; \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			actionlint -format '{{range $$err := .}}::error file={{$$err.Filepath}},line={{$$err.Line}},col={{$$err.Column}}::{{$$err.Message}}%0A```%0A{{replace $$err.Snippet "\\n" "%0A"}}%0A```\n{{end}}' -ignore 'SC2016:' $${files}; \
		else \
			actionlint $${files}; \
		fi

.PHONY: zizmor
zizmor: .venv/.installed ## Runs the zizmor linter.
	@# NOTE: On GitHub actions this outputs SARIF format to zizmor.sarif.json
	@#       in addition to outputting errors to the terminal.
	@set -euo pipefail;\
		files=$$( \
			git ls-files --deduplicate \
				'.github/workflows/*.yml' \
				'.github/workflows/*.yaml' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			.venv/bin/zizmor --quiet --pedantic --format sarif $${files} > zizmor.sarif.json || true; \
		fi; \
		.venv/bin/zizmor --quiet --pedantic --format plain $${files}

.PHONY: markdownlint
markdownlint: node_modules/.installed $(AQUA_ROOT_DIR)/.installed ## Runs the markdownlint linter.
	@# NOTE: Issue and PR templates are handled specially so we can disable
	@# MD041/first-line-heading/first-line-h1 without adding an ugly html comment
	@# at the top of the file.
	@set -euo pipefail;\
		files=$$( \
			git ls-files --deduplicate \
				'*.md' \
				':!:.github/pull_request_template.md' \
				':!:.github/ISSUE_TEMPLATE/*.md' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		PATH="$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION):$(AQUA_ROOT_DIR)/bin:$${PATH}"; \
		AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)"; \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			exit_code=0; \
			while IFS="" read -r p && [ -n "$$p" ]; do \
				file=$$(echo "$$p" | jq -c -r '.fileName // empty'); \
				line=$$(echo "$$p" | jq -c -r '.lineNumber // empty'); \
				endline=$${line}; \
				message=$$(echo "$$p" | jq -c -r '.ruleNames[0] + "/" + .ruleNames[1] + " " + .ruleDescription + " [Detail: \"" + .errorDetail + "\", Context: \"" + .errorContext + "\"]"'); \
				exit_code=1; \
				echo "::error file=$${file},line=$${line},endLine=$${endline}::$${message}"; \
			done <<< "$$(npx markdownlint --config .markdownlint.yaml --dot --json $${files} 2>&1 | jq -c '.[]')"; \
			if [ "$${exit_code}" != "0" ]; then \
				exit "$${exit_code}"; \
			fi; \
		else \
			npx markdownlint --config .markdownlint.yaml --dot $${files}; \
		fi; \
		files=$$( \
			git ls-files --deduplicate \
				'.github/pull_request_template.md' \
				'.github/ISSUE_TEMPLATE/*.md' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			exit_code=0; \
			while IFS="" read -r p && [ -n "$$p" ]; do \
				file=$$(echo "$$p" | jq -c -r '.fileName // empty'); \
				line=$$(echo "$$p" | jq -c -r '.lineNumber // empty'); \
				endline=$${line}; \
				message=$$(echo "$$p" | jq -c -r '.ruleNames[0] + "/" + .ruleNames[1] + " " + .ruleDescription + " [Detail: \"" + .errorDetail + "\", Context: \"" + .errorContext + "\"]"'); \
				exit_code=1; \
				echo "::error file=$${file},line=$${line},endLine=$${endline}::$${message}"; \
			done <<< "$$(npx markdownlint --config .github/template.markdownlint.yaml --dot --json $${files} 2>&1 | jq -c '.[]')"; \
			if [ "$${exit_code}" != "0" ]; then \
				exit "$${exit_code}"; \
			fi; \
		else \
			npx markdownlint  --config .github/template.markdownlint.yaml --dot $${files}; \
		fi

.PHONY: renovate-config-validator
renovate-config-validator: node_modules/.installed ## Validate Renovate configuration.
	@./node_modules/.bin/renovate-config-validator --strict

.PHONY: textlint
textlint: node_modules/.installed $(AQUA_ROOT_DIR)/.installed ## Runs the textlint linter.
	@set -e;\
		files=$$( \
			git ls-files --deduplicate \
				'*.md' \
				'*.txt' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			exit_code=0; \
			while IFS="" read -r p && [ -n "$$p" ]; do \
				filePath=$$(echo "$$p" | jq -c -r '.filePath // empty'); \
				file=$$(realpath --relative-to="." "$${filePath}"); \
				while IFS="" read -r m && [ -n "$$m" ]; do \
					line=$$(echo "$$m" | jq -c -r '.loc.start.line'); \
					endline=$$(echo "$$m" | jq -c -r '.loc.end.line'); \
					message=$$(echo "$$m" | jq -c -r '.message'); \
					echo "::error file=$${file},line=$${line},endLine=$${endline}::$${message}"; \
				done <<<"$$(echo "$$p" | jq -c -r '.messages[] // empty')"; \
			done <<< "$$(./node_modules/.bin/textlint -c .textlintrc.json --format json $${files} 2>&1 | jq -c '.[]')"; \
			exit "$${exit_code}"; \
		else \
			./node_modules/.bin/textlint -c .textlintrc.json $${files}; \
		fi

.PHONY: yamllint
yamllint: .venv/.installed ## Runs the yamllint linter.
	@set -euo pipefail;\
		extraargs=""; \
		files=$$( \
			git ls-files --deduplicate \
				'*.yml' \
				'*.yaml' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			extraargs="-f github"; \
		fi; \
		.venv/bin/yamllint --strict -c .yamllint.yaml $${extraargs} $${files}

SHELLCHECK_ARGS = --severity=style --external-sources

.PHONY: shellcheck
shellcheck: ## Runs the shellcheck linter.
	@set -e;\
		files=$$(git ls-files | xargs file | grep -e ':.*shell' | cut -d':' -f1); \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			exit_code=0; \
			while IFS="" read -r p && [ -n "$$p" ]; do \
				level=$$(echo "$$p" | jq -c '.level // empty' | tr -d '"'); \
				file=$$(echo "$$p" | jq -c '.file // empty' | tr -d '"'); \
				line=$$(echo "$$p" | jq -c '.line // empty' | tr -d '"'); \
				endline=$$(echo "$$p" | jq -c '.endLine // empty' | tr -d '"'); \
				col=$$(echo "$$p" | jq -c '.column // empty' | tr -d '"'); \
				endcol=$$(echo "$$p" | jq -c '.endColumn // empty' | tr -d '"'); \
				message=$$(echo "$$p" | jq -c '.message // empty' | tr -d '"'); \
				exit_code=1; \
				case $$level in \
				"info") \
					echo "::notice file=$${file},line=$${line},endLine=$${endline},col=$${col},endColumn=$${endcol}::$${message}"; \
					;; \
				"warning") \
					echo "::warning file=$${file},line=$${line},endLine=$${endline},col=$${col},endColumn=$${endcol}::$${message}"; \
					;; \
				"error") \
					echo "::error file=$${file},line=$${line},endLine=$${endline},col=$${col},endColumn=$${endcol}::$${message}"; \
					;; \
				esac; \
			done <<< "$$(echo -n "$$files" | xargs shellcheck -f json $(SHELLCHECK_ARGS) | jq -c '.[]')"; \
			exit "$${exit_code}"; \
		else \
			echo -n "$$files" | xargs shellcheck $(SHELLCHECK_ARGS); \
		fi

.PHONY: vint
vint: .venv/.installed ## Runs the vint linter.
	@set -euo pipefail;\
		extraargs=""; \
		files=$$( \
			git ls-files \
				'*.vim' '**/*.vim' \
		); \
		.venv/bin/vint $${files}

## Base Tools
#####################################################################

.PHONY: install-bin
install-bin: ## Install binary scripts.
	mkdir -p ~/bin
	ln -sf $$(pwd)/bin/all/* ~/bin/

.PHONY: configure-bash
configure-bash: ## Configure bash.
	rm -f ~/.inputrc ~/.profile ~/.bash_profile ~/.bashrc ~/.bash_aliases ~/.bash_aliases.kubectl ~/.bash_completion ~/.bash_logout ~/.dockerfunc ~/.ssh-find-agent
	ln -sf $$(pwd)/bash/_inputrc ~/.inputrc
	ln -sf $$(pwd)/bash/_profile ~/.profile
	ln -sf $$(pwd)/bash/_bash_profile ~/.bash_profile
	ln -sf $$(pwd)/bash/_bashrc ~/.bashrc
	ln -sf $$(pwd)/bash/_bash_aliases ~/.bash_aliases
	ln -sf $$(pwd)/bash/kubectl-aliases/.kubectl_aliases ~/.bash_aliases.kubectl
	ln -sf $$(pwd)/bash/_bash_completion ~/.bash_completion
	ln -sf $$(pwd)/bash/_bash_logout ~/.bash_logout
	ln -sf $$(pwd)/bash/lib/ssh-find-agent/ssh-find-agent.sh ~/.ssh-find-agent

.PHONY: configure-vim
configure-vim: ## Configure vim.
	rm -rf ~/.vim ~/.vimrc ~/.gvimrc ~/.vimrc.windows
	ln -sf $$(pwd)/vim ~/.vim
	ln -sf ~/.vim/_vimrc.vim ~/.vimrc

.PHONY: configure-nvim
configure-nvim: ## Configure neovim.
	rm -rf ~/.config/nvim
	ln -sf $$(pwd)/nvim ~/.config/nvim

.PHONY: configure-tmux
configure-tmux: ## Configure tmux.
	rm -f ~/.tmux.conf ~/.tmux/plugins
	ln -sf $$(pwd)/tmux/_tmux.conf ~/.tmux.conf
	mkdir -p ~/.tmux
	ln -sf $$(pwd)/tmux/plugins ~/.tmux/plugins

.PHONY: configure-git
configure-git: ## Configure git.
	rm -f ~/.gitconfig
	ln -sf "$$(pwd)/git/_gitconfig" ~/.gitconfig

## Install Tools
#####################################################################

.PHONY: install-efm-langserver
install-efm-langserver: install-bin install-opt ## Install efm-langserver
	 @set -e; \
		tempfile=$$(mktemp --suffix=".tar.gz"); \
		curl -sSLo "$${tempfile}" "$(EFM_LANGSERVER_URL)"; \
		echo "$(EFM_LANGSERVER_CHECKSUM)  $${tempfile}" | sha256sum -c; \
		cd ~/opt; \
		tar xf "$${tempfile}"; \
		ln -sf ~/opt/efm-langserver_v$(EFM_LANGSERVER_VERSION)_$$(echo "$(uname_s)" | tr A-Z a-z)_$(arch)/efm-langserver ~/bin/efm-langserver

## Install Linters
#####################################################################

# For Python (linting)
.PHONY: install-flake8
install-flake8: $(HOME)/.local/share/venv ## User-install flake8 (Python) linter.
	$</bin/pip3 install flake8

.PHONY: configure-flake8
configure-flake8: ## Configure flake8 (Python) linter.
	rm -rf ~/.config/flake8
	mkdir -p ~/.config
	ln -sf "$$(pwd)/flake8/flake8.ini" ~/.config/flake8

.PHONY: install-vint
install-vint: $(HOME)/.local/share/venv ## User-install vint (VimScript) linter.
	$</bin/pip3 install vim-vint

.PHONY: install-yamllint
install-yamllint: $(HOME)/.local/share/venv ## User-install yamllint linter.
	$</bin/pip3 install yamllint

.PHONY: install-markdownlint
install-markdownlint: ## User-install markdownlint linter globally.
	npm install -g markdownlint-cli

.PHONY: configure-markdownlint
configure-markdownlint: ## Configure markdownlint linter.
	mkdir -p ~/.config
	ln -sf "$$(pwd)/markdownlint/markdownlint.yaml" ~/.config/markdownlint.yaml

.PHONY: install-eslint
install-eslint: ## User-install eslint linter globally.
	npm install -g eslint

# For shell (linting)
.PHONY: install-shellcheck
install-shellcheck: install-bin install-opt ## User-install shellcheck linter.
	@set -e; \
		tempfile=$$(mktemp --suffix=".tar.gz"); \
		curl -sSLo "$${tempfile}" "$(SHELLCHECK_URL)"; \
		echo "$(SHELLCHECK_CHECKSUM)  $${tempfile}" | sha256sum -c; \
		cd ~/opt; \
		tar xf "$${tempfile}"; \
		ln -sf ~/opt/shellcheck-v$(SHELLCHECK_VERSION)/shellcheck ~/bin/shellcheck

# For Go (linting)
.PHONY: install-golangci-lint
install-golangci-lint: install-opt ## User-install golangci-lint linter.
	@set -e; \
		tempfile=$$(mktemp --suffix=".tar.gz"); \
		curl -sSLo "$${tempfile}" "$(GOLANGCILINT_URL)"; \
		echo "$(GOLANGCILINT_CHECKSUM)  $${tempfile}" | sha256sum -c; \
		cd ~/opt; \
		tar xf "$${tempfile}"

# For Github Actions (linting)
.PHONY: install-actionlint
install-actionlint: ## User-install actionlint linter.
	@set -e; \
		tempfile=$$(mktemp); \
		curl -sSLo "$${tempfile}" "$(ACTIONLINT_URL)"; \
		echo "$(ACTIONLINT_CHECKSUM)  $${tempfile}" | sha256sum -c; \
		tar xf "$${tempfile}" -C ~/bin actionlint

## Install Formatters
#####################################################################

# For Python (formatting)
.PHONY: install-black
install-black: $(HOME)/.local/share/venv ## User-install black (Python) formatter.
	$</bin/pip3 install black

# For Javascript, yaml, markdown (formatting)
.PHONY: install-prettier
install-prettier: ## User-install prettier formatter.
	npm install -g prettier

# For SQL (formatting)
.PHONY: install-sql-formatter
install-sqlparse: ## User-install sqlparse formatter.
	npm install -g sql-formatter

# For shell (formatting)
.PHONY: install-shfmt
install-shfmt: install-bin install-opt ## User-install shfmt formatter.
	@set -e; \
		tempfile=$$(mktemp); \
		curl -sSLo "$${tempfile}" "$(SHFMT_URL)"; \
		echo "$(SHFMT_CHECKSUM)  $${tempfile}" | sha256sum -c; \
		cp "$${tempfile}" ~/bin/shfmt; \
		chmod +x ~/bin/shfmt

## Language Runtimes
#####################################################################

.PHONY: install-go
install-go: install-opt ## Install the Go runtime.
	@set -e; \
		tempfile=$$(mktemp --suffix=".tar.gz"); \
		curl -sSLo "$${tempfile}" "$(GO_URL)"; \
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
		curl -sSLo "$${tempfile}" "$(NODE_URL)"; \
		echo "$(NODE_CHECKSUM)  $${tempfile}" | sha256sum -c; \
		cd ~/opt; \
		rm -rf node; \
		tar xf "$${tempfile}"; \
		ln -sf node-v$(NODE_VERSION)-linux-x64 node

## Maintenance
#####################################################################

.PHONY: clean
clean: ## Delete temporary files.
	@rm -rf \
		.bin \
		$(AQUA_ROOT_DIR) \
		.venv \
		node_modules \
		*.sarif.json
