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
# NOTE: Aqua's checksum forms the trust root for install dev tools local to this repository.
AQUA_CHECKSUM.Linux.x86_64 = 6908509aa0c985ea60ed4bfdc69a69f43059a6b539fb16111387e1a7a8d87a9f
AQUA_CHECKSUM ?= $(AQUA_CHECKSUM.$(uname_s).$(uname_m))
AQUA_URL = https://$(AQUA_REPO)/releases/download/v$(AQUA_VERSION)/aqua_$(kernel)_$(arch).tar.gz
AQUA_PROVENANCE_URL = https://$(AQUA_REPO)/releases/download/v$(AQUA_VERSION)/multiple.intoto.jsonl
AQUA_ROOT_DIR = .aqua

# NOTE: slsa-verifier establishes the trust root for installed CLI tools in the home directory.
SLSA_VERIFIER_VERSION ?= 2.7.0
SLSA_VERIFIER_CHECKSUM.Linux.x86_64 = 499befb675efcca9001afe6e5156891b91e71f9c07ab120a8943979f85cc82e6
SLSA_VERIFIER_CHECKSUM ?= $(SLSA_VERIFIER_CHECKSUM.$(uname_s).$(uname_m))
SLSA_VERIFIER_URL.Linux.x86_64 = https://github.com/slsa-framework/slsa-verifier/releases/download/v$(SLSA_VERIFIER_VERSION)/slsa-verifier-linux-amd64
SLSA_VERIFIER_URL ?= $(SLSA_VERIFIER_URL.$(uname_s).$(uname_m))

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
configure-all: configure-aqua configure-efm-langserver configure-nvim configure-bash configure-flake8 configure-markdownlint configure-git configure-tmux ## Configure all tools.

.PHONY: install-all
install-all: install-aqua install-flake8 install-black install-prettier install-yamllint install-sql-formatter install-vint ## Install all tools

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

$(HOME)/opt:
	@mkdir -p $(HOME)/opt

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
format: json-format lua-format md-format shfmt yaml-format ## Format all files

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

.PHONY: lua-format
lua-format: $(AQUA_ROOT_DIR)/.installed ## Format Lua files.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.lua' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		PATH="$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION):$(AQUA_ROOT_DIR)/bin:$${PATH}"; \
		AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)"; \
		stylua --config-path stylua.toml $${files}

.PHONY: md-format
md-format: node_modules/.installed ## Format Markdown files.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.md' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		npx prettier --write --no-error-on-unmatched-pattern $${files}

.PHONY: shfmt
shfmt: $(AQUA_ROOT_DIR)/.installed ## Format bash files.
	@# NOTE: We need to ignore config files used in tests.
	@set -euo pipefail;\
		files=$$(git ls-files | xargs file | grep -e ':.*shell' | cut -d':' -f1); \
		PATH="$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION):$(AQUA_ROOT_DIR)/bin:$${PATH}"; \
		AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)"; \
		shfmt --write --simplify --indent 4 $${files}

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

.PHONY: selene
selene: $(AQUA_ROOT_DIR)/.installed ## Runs the selene (Lua) linter.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.lua' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		PATH="$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION):$(AQUA_ROOT_DIR)/bin:$${PATH}"; \
		AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)"; \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			exit_code=0; \
			while IFS="" read -r p && [ -n "$$p" ]; do \
				level=$$(echo "$$p" | jq -c '.severity // empty' | tr -d '"'); \
				file=$$(echo "$$p" | jq -c '.primary_label.filename // empty' | tr -d '"'); \
				line=$$(echo "$$p" | jq -c '.primary_label.span.start_line // empty' | tr -d '"'); \
				endline=$$(echo "$$p" | jq -c '.primary_label.span.end_line // empty' | tr -d '"'); \
				col=$$(echo "$$p" | jq -c '.primary_label.span.start_column // empty' | tr -d '"'); \
				endcol=$$(echo "$$p" | jq -c '.primary_label.span.end_column // empty' | tr -d '"'); \
				message=$$(echo "$$p" | jq -c '((.code // empty) + " : " + (.message // empty))' | tr -d '"'); \
				exit_code=1; \
				case $$level in \
				"Warning") \
					echo "::warning file=$${file},line=$${line},endLine=$${endline},col=$${col},endColumn=$${endcol}::$${message}"; \
					;; \
				"Error") \
					echo "::error file=$${file},line=$${line},endLine=$${endline},col=$${col},endColumn=$${endcol}::$${message}"; \
					;; \
				esac; \
			done <<< "$$(selene --config selene.toml --display-style Json2 $${files})"; \
			if [ "$${exit_code}" != "0" ]; then \
				exit "$${exit_code}"; \
			fi; \
		else \
			selene --config selene.toml --no-summary $${files}; \
		fi

.PHONY: textlint
textlint: node_modules/.installed $(AQUA_ROOT_DIR)/.installed ## Runs the textlint linter.
	@set -euo pipefail; \
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
				'*.vim' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		.venv/bin/vint $${files}

## Base Tools
#####################################################################

$(HOME)/bin:
	@set -euo pipefail; \
		mkdir -p $(HOME)/bin; \
		ln -sf $(REPO_ROOT)/bin/all/* $(HOME)/bin/

$(HOME)/bin/%: $(HOME)/bin bin/all/%
	@ln -sf "$(REPO_ROOT)"/bin/all/* $(HOME)/bin/

BIN_SRCS := $(wildcard bin/all/*)
BIN_OBJS := $(subst bin/all,$(HOME)/bin,$(BIN_SRCS))

.PHONY: install-bin
install-bin: $(BIN_OBJS) ## Install binary scripts.

.PHONY: configure-bash
configure-bash: ## Configure bash.
	@set -euo pipefail; \
		rm -f ~/.inputrc ~/.profile ~/.bash_profile ~/.bashrc ~/.bash_aliases ~/.bash_aliases.kubectl ~/.bash_completion ~/.bash_logout ~/.dockerfunc ~/.ssh-find-agent; \
		ln -sf $(REPO_ROOT)/bash/_inputrc ~/.inputrc; \
		ln -sf $(REPO_ROOT)/bash/_profile ~/.profile; \
		ln -sf $(REPO_ROOT)/bash/_bash_profile ~/.bash_profile; \
		ln -sf $(REPO_ROOT)/bash/_bashrc ~/.bashrc; \
		ln -sf $(REPO_ROOT)/bash/_bash_aliases ~/.bash_aliases; \
		ln -sf $(REPO_ROOT)/bash/kubectl-aliases/.kubectl_aliases ~/.bash_aliases.kubectl; \
		ln -sf $(REPO_ROOT)/bash/_bash_completion ~/.bash_completion; \
		ln -sf $(REPO_ROOT)/bash/_bash_logout ~/.bash_logout; \
		ln -sf $(REPO_ROOT)/bash/lib/ssh-find-agent/ssh-find-agent.sh ~/.ssh-find-agent

$(HOME)/.aqua.yaml:
	@ln -sf $(REPO_ROOT)/aqua/aqua.yaml ~/.aqua.yaml

aqua/aqua-checksums.json: aqua/aqua.yaml .bin/aqua-$(AQUA_VERSION)/aqua
	@.bin/aqua-$(AQUA_VERSION)/aqua --config aqua/aqua.yaml update-checksum

$(HOME)/.aqua-checksums.json:
	@ln -sf $(REPO_ROOT)/aqua/aqua-checksums.json ~/.aqua-checksums.json

.PHONY: configure-aqua
configure-aqua: $(HOME)/.aqua.yaml $(HOME)/.aqua-checksums.json ## Configure aqua.

$(HOME)/.config/efm-langserver/config.yaml: efm-langserver/config.yaml
	@set -euo pipefail; \
		mkdir -p $$(dirname $@); \
		mkdir -p $(HOME)/.local/var/log; \
		envsubst < $< > $@

.PHONY: configure-efm-langserver
configure-efm-langserver: $(HOME)/.config/efm-langserver/config.yaml ## Configure efm-langserver.

.PHONY: configure-nvim
configure-nvim: ## Configure neovim.
	@set -euo pipefail; \
		rm -rf ~/.config/nvim; \
		ln -sf $(REPO_ROOT)/nvim ~/.config/nvim

.PHONY: configure-tmux
configure-tmux: ## Configure tmux.
	@set -euo pipefail; \
		rm -f ~/.tmux.conf ~/.tmux/plugins; \
		ln -sf $(REPO_ROOT)/tmux/_tmux.conf ~/.tmux.conf; \
		mkdir -p ~/.tmux; \
		ln -sf $(REPO_ROOT)/tmux/plugins ~/.tmux/plugins

.PHONY: configure-git
configure-git: ## Configure git.
	@set -euo pipefail; \
		rm -f ~/.gitconfig; \
		ln -sf "$(REPO_ROOT)/git/_gitconfig" ~/.gitconfig

## Install Tools
#####################################################################

.PHONY: install-slsa-verifier
install-slsa-verifier: $(HOME)/bin/slsa-verifier ## Install slsa-verifier

$(HOME)/opt/slsa-verifier-v$(SLSA_VERIFIER_VERSION)/slsa-verifier: $(HOME)/opt
	@set -euo pipefail; \
		tempfile=$$(mktemp --suffix=".tar.gz"); \
		curl -sSLo "$${tempfile}" "$(SLSA_VERIFIER_URL)"; \
		echo "$(SLSA_VERIFIER_CHECKSUM)  $${tempfile}" | sha256sum -c; \
	 	mkdir -p $(HOME)/opt/slsa-verifier-v$(SLSA_VERIFIER_VERSION); \
		mv "$${tempfile}" $(HOME)/opt/slsa-verifier-v$(SLSA_VERIFIER_VERSION)/slsa-verifier; \
		chmod +x $(HOME)/opt/slsa-verifier-v$(SLSA_VERIFIER_VERSION)/slsa-verifier

$(HOME)/bin/slsa-verifier: $(HOME)/opt/slsa-verifier-v$(SLSA_VERIFIER_VERSION)/slsa-verifier
	@set -euo pipefail; \
		ln -sf $(HOME)/opt/slsa-verifier-v$(SLSA_VERIFIER_VERSION)/slsa-verifier $@; \
		touch $(HOME)/opt/slsa-verifier-v$(SLSA_VERIFIER_VERSION)/slsa-verifier

.PHONY: install-aqua
install-aqua: $(HOME)/bin/aqua configure-aqua ## Install aqua and aqua-managed CLI tools
	@$(HOME)/bin/aqua --config $(HOME)/.aqua.yaml install

$(HOME)/opt/aqua-v$(AQUA_VERSION)/.installed: $(HOME)/opt $(HOME)/bin/slsa-verifier
	@set -euo pipefail; \
		tempfile=$$(mktemp --suffix=".aqua-v$(AQUA_VERSION).tar.gz"); \
		tempjsonl=$$(mktemp --suffix=".aqua-v$(AQUA_VERSION).intoto.jsonl"); \
		curl -sSLo "$${tempfile}" "$(AQUA_URL)"; \
		curl -sSLo "$${tempjsonl}" "$(AQUA_PROVENANCE_URL)"; \
		slsa-verifier verify-artifact \
			"$${tempfile}" \
			--provenance-path "$${tempjsonl}" \
			--source-uri "$(AQUA_REPO)" \
			--source-tag "v$(AQUA_VERSION)"; \
	 	mkdir -p $(HOME)/opt/aqua-v$(AQUA_VERSION); \
		tar -x -C $(HOME)/opt/aqua-v$(AQUA_VERSION) -f "$${tempfile}"; \
		touch $(HOME)/opt/aqua-v$(AQUA_VERSION)/.installed

$(HOME)/bin/aqua: $(HOME)/opt/aqua-v$(AQUA_VERSION)/.installed
	@set -euo pipefail; \
		touch $(HOME)/opt/aqua-v$(AQUA_VERSION)/aqua; \
		ln -sf $(HOME)/opt/aqua-v$(AQUA_VERSION)/aqua $@

## Linters
#####################################################################

# For Python (linting)
.PHONY: install-flake8
install-flake8: $(HOME)/.local/share/venv configure-flake8 ## User-install flake8 (Python) linter.
	@$</bin/pip3 install flake8

.PHONY: configure-flake8
configure-flake8: ## Configure flake8 (Python) linter.
	@rm -rf ~/.config/flake8
	@mkdir -p ~/.config
	@ln -sf "$(REPO_ROOT)/flake8/flake8.ini" ~/.config/flake8

.PHONY: install-vint
install-vint: $(HOME)/.local/share/venv ## User-install vint (VimScript) linter.
	@$</bin/pip3 install vim-vint

.PHONY: install-yamllint
install-yamllint: $(HOME)/.local/share/venv ## User-install yamllint linter.
	@$</bin/pip3 install yamllint

.PHONY: install-markdownlint
install-markdownlint: configure-markdownlint ## User-install markdownlint linter globally.
	@npm install -g markdownlint-cli

.PHONY: configure-markdownlint
configure-markdownlint: ## Configure markdownlint linter.
	@ln -sf "$(REPO_ROOT)/markdownlint/markdownlint.yaml" ~/.markdownlint.yaml

.PHONY: install-eslint
install-eslint: ## User-install eslint linter globally.
	@npm install -g eslint

## Formatters
#####################################################################

# For Python (formatting)
.PHONY: install-black
install-black: $(HOME)/.local/share/venv ## User-install black (Python) formatter.
	@$</bin/pip3 install black

# For Javascript, yaml, markdown (formatting)
.PHONY: install-prettier
install-prettier: ## User-install prettier formatter.
	@npm install -g prettier

# For SQL (formatting)
.PHONY: install-sql-formatter
install-sqlparse: ## User-install sqlparse formatter.
	@npm install -g sql-formatter

## Language Runtimes
#####################################################################

.PHONY: install-go
install-go: $(HOME)/opt ## Install the Go runtime.
	@set -e; \
		tempfile=$$(mktemp --suffix=".tar.gz"); \
		curl -sSLo "$${tempfile}" "$(GO_URL)"; \
		echo "$(GO_CHECKSUM)  $${tempfile}" | sha256sum -c; \
		cd $(HOME)/opt; \
		rm -rf go; \
		tar xf "$${tempfile}"; \
		mv go go-$(GO_VERSION); \
		ln -s go-$(GO_VERSION) go; \
		$(HOME)/opt/go/bin/go env -w GOTOOLCHAIN=go$(GO_VERSION)+auto

.PHONY: install-node
install-node: $(HOME)/opt ## Install the Node.js runtime.
	@set -e; \
		tempfile=$$(mktemp --suffix=".tar.gz"); \
		curl -sSLo "$${tempfile}" "$(NODE_URL)"; \
		echo "$(NODE_CHECKSUM)  $${tempfile}" | sha256sum -c; \
		cd $(HOME)/opt; \
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
