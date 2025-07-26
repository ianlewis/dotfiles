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

SHELL := /usr/bin/env bash

uname_s := $(shell uname -s)
uname_m := $(shell uname -m)
arch.x86_64 := amd64
arch = $(arch.$(uname_m))
kernel.Linux := linux
kernel = $(kernel.$(uname_s))

XDG_CONFIG_HOME ?= $(HOME)/.config
XDG_BIN_HOME ?= $(HOME)/.local/bin
XDG_DATA_HOME ?= $(HOME)/.local/share
XDG_STATE_HOME ?= $(HOME)/.local/state

OUTPUT_FORMAT ?= $(shell if [ "${GITHUB_ACTIONS}" == "true" ]; then echo "github"; else echo ""; fi)
REPO_ROOT = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
REPO_NAME = $(shell basename "$(REPO_ROOT)")

# renovate: datasource=github-releases depName=aquaproj/aqua versioning=loose
AQUA_VERSION ?= v2.53.3
AQUA_REPO ?= github.com/aquaproj/aqua
AQUA_CHECKSUM.Linux.x86_64 = 2450bcf687c93e91ec892d49e5787b5b856796d38eb7283f52a351d82a8e31ee
AQUA_CHECKSUM ?= $(AQUA_CHECKSUM.$(uname_s).$(uname_m))
AQUA_URL = https://$(AQUA_REPO)/releases/download/$(AQUA_VERSION)/aqua_$(kernel)_$(arch).tar.gz
AQUA_ROOT_DIR = $(REPO_ROOT)/.aqua
AQUA_PROVENANCE_URL = https://$(AQUA_REPO)/releases/download/$(AQUA_VERSION)/multiple.intoto.jsonl

# renovate: datasource=github-releases depName=slsa-framework/slsa-verifier versioning=loose
SLSA_VERIFIER_VERSION ?= 2.7.1
# NOTE: slsa-verifier establishes the trust root for installed CLI tools in the home directory.
SLSA_VERIFIER_CHECKSUM.Linux.x86_64 = 946dbec729094195e88ef78e1734324a27869f03e2c6bd2f61cbc06bd5350339
SLSA_VERIFIER_CHECKSUM ?= $(SLSA_VERIFIER_CHECKSUM.$(uname_s).$(uname_m))
SLSA_VERIFIER_URL.Linux.x86_64 = https://github.com/slsa-framework/slsa-verifier/releases/download/v$(SLSA_VERIFIER_VERSION)/slsa-verifier-linux-amd64
SLSA_VERIFIER_URL ?= $(SLSA_VERIFIER_URL.$(uname_s).$(uname_m))

# NOTE: Go shouldn't necessarily need to be upgraded since it can support
#       toolchains and will automatically download the necessary runtime
#       version for a project.
# renovate: datasource=golang-version
GO_VERSION ?= 1.24.3
GO_CHECKSUM ?= 3333f6ea53afa971e9078895eaa4ac7204a8c6b5c68c10e6bc9a33e8e391bdd8
GO_URL.Linux.x86_64 := https://go.dev/dl/go$(GO_VERSION).linux-amd64.tar.gz
GO_URL = $(GO_URL.$(uname_s).$(uname_m))

# renovate: datasource=node-version
NODE_VERSION ?= 22.13.1
NODE_CHECKSUM ?= 0d2a5af33c7deab5555c8309cd3f373446fe1526c1b95833935ab3f019733b3b
NODE_URL.Linux.x86_64 := https://nodejs.org/dist/v$(NODE_VERSION)/node-v$(NODE_VERSION)-linux-x64.tar.xz
NODE_URL = $(NODE_URL.$(uname_s).$(uname_m))

# renovate: datasource=github-releases depName=pyenv/pyenv versioning=loose
PYENV_INSTALL_VERSION ?= v2.6.3
# NOTE: PYENV_INSTALL_SHA is used to validate the pyenv installation.
PYENV_INSTALL_SHA ?= f1c5371752c6dccecac612d5bac840203f72e5d8
# NOTE: pyenv plugins do not make releases and pyenv-installer installs them at
# the 'master' branch. We validate the SHA here but it may be updated from time
# to time and cause validation errors.
PYENV_DOCTOR_SHA ?= bad83e51e1409665de6cb37537cfc1e02e154bec
PYENV_UPDATE_SHA ?= 39b088e56c0b176a50a700bfcfe91fa6428ee8b9
PYENV_VIRTUALENV_SHA ?= 4b3f5f8468c6c7e2b2e55ba8d1bd192f03489d3a
PYENV_ROOT ?= $(XDG_DATA_HOME)/pyenv

# renovate: datasource=github-releases depName=nodenv/nodenv versioning=loose
NODENV_INSTALL_VERSION ?= master
NODENV_INSTALL_SHA ?= e9f84ae35a3c1646dc2eb007e33decd35ad53b54
NODENV_ROOT ?= $(XDG_DATA_HOME)/nodenv
# renovate: datasource=github-releases depName=nodenv/node-build versioning=loose
NODENV_BUILD_VERSION ?= v5.4.5
NODENV_BUILD_SHA ?= 73a5315be96e41d33a26b14281a557679300e50f

# renovate: datasource=github-releases depName=rbenv/rbenv versioning=loose
RBENV_INSTALL_VERSION ?= v1.3.2
RBENV_INSTALL_SHA ?= 10e96bfc473c7459a447fbbda12164745a72fd37
RBENV_ROOT ?= $(XDG_DATA_HOME)/rbenv
RBENV_BUILD_VERSION ?= v20250610
RBENV_BUILD_SHA ?= 1195268593b80a0a1bcd518e11efb4b4de115984

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
	@set -euo pipefail; \
		normal=""; \
		cyan=""; \
		if [ -t 1 ]; then \
			normal=$$(tput sgr0); \
			cyan=$$(tput setaf 6); \
		fi; \
		grep --no-filename -E '^([/a-z.A-Z0-9_%-]+:.*?|)##' $(MAKEFILE_LIST) | \
			awk \
				--assign=normal="$${normal}" \
				--assign=cyan="$${cyan}" \
				'BEGIN {FS = "(:.*?|)## ?"}; { \
					if (length($$1) > 0) { \
						printf("  " cyan "%-25s" normal " %s\n", $$1, $$2); \
					} else { \
						if (length($$2) > 0) { \
							printf("%s\n", $$2); \
						} \
					} \
				}'

.PHONY: all
all: install-all configure-all ## Install and configure everything.

.PHONY: configure-all
configure-all: configure-aqua configure-efm-langserver configure-nix configure-nvim configure-bash configure-git configure-tmux ## Configure all tools.

.PHONY: install-all
install-all: install-tools install-runtimes ## Install all CLI tools and runtimes.

.PHONY: install-tools
install-tools: install-bin install-aqua ## Install all CLI tools.

install-runtimes: install-go install-node install-python install-ruby ## Install all runtimes.

package-lock.json: package.json $(NODENV_ROOT)/.installed
	@set -euo pipefail; \
		eval "$(NODENV_ROOT=$(NODENV_ROOT) $(NODENV_ROOT)/bin/nodenv init - bash)"; \
		npm install \
			--package-lock-only \
			--no-audit \
			--no-fund

node_modules/.installed: package-lock.json
	@set -euo pipefail; \
		eval "$(NODENV_ROOT=$(NODENV_ROOT) $(NODENV_ROOT)/bin/nodenv init - bash)"; \
		npm clean-install; \
		npm audit signatures; \
		touch $@

.venv/bin/activate: $(PYENV_ROOT)/.installed
	@set -euo pipefail; \
		eval "$(PYENV_ROOT=$(PYENV_ROOT) $(PYENV_ROOT)/bin/pyenv init - bash)"; \
		python -m venv .venv

.venv/.installed: requirements-dev.txt .venv/bin/activate
	@set -euo pipefail; \
		$(REPO_ROOT)/.venv/bin/pip install -r $< --require-hashes; \
		touch $@

.bin/aqua-$(AQUA_VERSION)/aqua:
	@set -euo pipefail; \
		mkdir -p .bin/aqua-$(AQUA_VERSION); \
		tempfile=$$(mktemp --suffix=".aqua-$(AQUA_VERSION).tar.gz"); \
		curl -sSLo "$${tempfile}" "$(AQUA_URL)"; \
		echo "$(AQUA_CHECKSUM)  $${tempfile}" | sha256sum -c; \
		tar -x -C .bin/aqua-$(AQUA_VERSION) -f "$${tempfile}"

$(AQUA_ROOT_DIR)/.installed: .aqua.yaml .bin/aqua-$(AQUA_VERSION)/aqua
	@AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)" ./.bin/aqua-$(AQUA_VERSION)/aqua \
		--config .aqua.yaml \
		install; \
	@touch $@

$(HOME)/opt:
	@mkdir -p $(HOME)/opt

## Tools
#####################################################################

.PHONY: license-headers
license-headers: ## Update license headers.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.c' \
				'*.cpp' \
				'*.go' \
				'*.h' \
				'*.hpp' \
				'*.ts' \
				'*.js' \
				'*.lua' \
				'*.py' \
				'*.rb' \
				'*.rs' \
				'*.toml' \
				'*.vim' \
				'*.yaml' \
				'*.yml' \
				'Makefile' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
		); \
		name=$$(git config user.name); \
		if [ "$${name}" == "" ]; then \
			>&2 echo "git user.name is required."; \
			>&2 echo "Set it up using:"; \
			>&2 echo "git config user.name \"John Doe\""; \
		fi; \
		for filename in $${files}; do \
			if ! ( head "$${filename}" | grep -iL "Copyright" > /dev/null ); then \
				./third_party/mbrukman/autogen/autogen.sh \
					--in-place \
					--no-code \
					--no-tlc \
					--copyright "$${name}" \
					--license apache \
					"$${filename}"; \
			fi; \
		done

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
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
		); \
		if [ "$${files}" == "" ]; then \
			exit 0; \
		fi; \
		./node_modules/.bin/prettier \
			--no-error-on-unmatched-pattern \
			--write \
			$${files}

.PHONY: lua-format
lua-format: $(AQUA_ROOT_DIR)/.installed ## Format Lua files.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.lua' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
		); \
		PATH="$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION):$(AQUA_ROOT_DIR)/bin:$${PATH}"; \
		AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)"; \
		stylua --config-path stylua.toml $${files}

.PHONY: md-format
md-format: node_modules/.installed ## Format Markdown files.
	@#NOTE: tab-width of 4 is recommended for Markdown files.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.md' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
		); \
		if [ "$${files}" == "" ]; then \
			exit 0; \
		fi; \
		# NOTE: prettier uses .editorconfig for tab-width. \
		./node_modules/.bin/prettier \
			--no-error-on-unmatched-pattern \
			--write \
			$${files}

.PHONY: shfmt
shfmt: $(AQUA_ROOT_DIR)/.installed ## Format bash files.
	@# NOTE: We need to ignore config files used in tests.
	@set -euo pipefail;\
		files=$$(git ls-files | xargs file | grep -e ':.*shell' | cut -d':' -f1); \
		if [ "$${files}" == "" ]; then \
			exit 0; \
		fi; \
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
		if [ "$${files}" == "" ]; then \
			exit 0; \
		fi; \
		./node_modules/.bin/prettier \
			--no-error-on-unmatched-pattern \
			--write \
			$${files}

## Linting
#####################################################################

.PHONY: lint
lint: actionlint commitlint fixme markdownlint renovate-config-validator selene shellcheck textlint yamllint zizmor ## Run all linters.

.PHONY: actionlint
actionlint: $(AQUA_ROOT_DIR)/.installed ## Runs the actionlint linter.
	@# NOTE: We need to ignore config files used in tests.
	@set -euo pipefail;\
		files=$$( \
			git ls-files --deduplicate \
				'.github/workflows/*.yml' \
				'.github/workflows/*.yaml' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
		); \
		if [ "$${files}" == "" ]; then \
			exit 0; \
		fi; \
		PATH="$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION):$(AQUA_ROOT_DIR)/bin:$${PATH}"; \
		AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)"; \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			actionlint \
				-format '{{range $$err := .}}::error file={{$$err.Filepath}},line={{$$err.Line}},col={{$$err.Column}}::{{$$err.Message}}%0A```%0A{{replace $$err.Snippet "\\n" "%0A"}}%0A```\n{{end}}' \
				-ignore 'SC2016:' \
				$${files}; \
		else \
			actionlint $${files}; \
		fi

.PHONY: commitlint
commitlint: node_modules/.installed ## Run commitlint linter.
	@set -euo pipefail;\
		commitlint_from=$(COMMITLINT_FROM_REF); \
		commitlint_to=$(COMMITLINT_TO_REF); \
		if [ "$${commitlint_from}" == "" ]; then \
			commitlint_from=$$(git remote show origin | grep 'HEAD branch' | awk '{print $$NF}'); \
		fi; \
		if [ "$${commitlint_to}" == "" ]; then \
			# if head is on the commitlint_from branch, then we will lint the \
			# last commit by default. \
			current_branch=$$(git rev-parse --abbrev-ref HEAD); \
			if [ "$${commitlint_from}" == "$${current_branch}" ]; then \
				commintlint_from="HEAD~1"; \
			fi; \
			commitlint_to="HEAD"; \
		fi; \
		./node_modules/.bin/commitlint \
			--config commitlint.config.mjs \
			--from "$${commitlint_from}" \
			--to "$${commitlint_to}" \
			--verbose \
			--strict

.PHONY: fixme
fixme: $(AQUA_ROOT_DIR)/.installed ## Check for outstanding FIXMEs.
	@set -euo pipefail;\
		PATH="$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION):$(AQUA_ROOT_DIR)/bin:$${PATH}"; \
		AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)"; \
		output="default"; \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			output="github"; \
		fi; \
		# NOTE: todos does not use `git ls-files` because many files might be \
		# 		unsupported and generate an error if passed directly on the \
		# 		command line. \
		todos \
			--output "$${output}" \
			--todo-types="FIXME,Fixme,fixme,BUG,Bug,bug,XXX,COMBAK"

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
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
		); \
		if [ "$${files}" == "" ]; then \
			exit 0; \
		fi; \
		PATH="$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION):$(AQUA_ROOT_DIR)/bin:$${PATH}"; \
		AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)"; \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			exit_code=0; \
			while IFS="" read -r p && [ -n "$$p" ]; do \
				file=$$(echo "$$p" | jq -cr '.fileName // empty'); \
				line=$$(echo "$$p" | jq -cr '.lineNumber // empty'); \
				endline=$${line}; \
				message=$$(echo "$$p" | jq -cr '.ruleNames[0] + "/" + .ruleNames[1] + " " + .ruleDescription + " [Detail: \"" + .errorDetail + "\", Context: \"" + .errorContext + "\"]"'); \
				exit_code=1; \
				echo "::error file=$${file},line=$${line},endLine=$${endline}::$${message}"; \
			done <<< "$$(./node_modules/.bin/markdownlint --config .markdownlint.yaml --dot --json $${files} 2>&1 | jq -c '.[]')"; \
			if [ "$${exit_code}" != "0" ]; then \
				exit "$${exit_code}"; \
			fi; \
		else \
			./node_modules/.bin/markdownlint \
				--config .markdownlint.yaml \
				--dot \
				$${files}; \
		fi; \
		files=$$( \
			git ls-files --deduplicate \
				'.github/pull_request_template.md' \
				'.github/ISSUE_TEMPLATE/*.md' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
		); \
		if [ "$${files}" == "" ]; then \
			exit 0; \
		fi; \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			exit_code=0; \
			while IFS="" read -r p && [ -n "$$p" ]; do \
				file=$$(echo "$$p" | jq -cr '.fileName // empty'); \
				line=$$(echo "$$p" | jq -cr '.lineNumber // empty'); \
				endline=$${line}; \
				message=$$(echo "$$p" | jq -cr '.ruleNames[0] + "/" + .ruleNames[1] + " " + .ruleDescription + " [Detail: \"" + .errorDetail + "\", Context: \"" + .errorContext + "\"]"'); \
				exit_code=1; \
				echo "::error file=$${file},line=$${line},endLine=$${endline}::$${message}"; \
			done <<< "$$(./node_modules/.bin/markdownlint --config .github/template.markdownlint.yaml --dot --json $${files} 2>&1 | jq -c '.[]')"; \
			if [ "$${exit_code}" != "0" ]; then \
				exit "$${exit_code}"; \
			fi; \
		else \
			./node_modules/.bin/markdownlint \
				--config .github/template.markdownlint.yaml \
				--dot \
				$${files}; \
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
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
		); \
		if [ "$${files}" == "" ]; then \
			exit 0; \
		fi; \
		PATH="$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION):$(AQUA_ROOT_DIR)/bin:$${PATH}"; \
		AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)"; \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			exit_code=0; \
			while IFS="" read -r p && [ -n "$$p" ]; do \
				type=$$(echo "$${p}" | jq -c '.type // empty' | tr -d '"'); \
				if [ "$${type}" != "Diagnostic" ]; then \
					continue; \
				fi; \
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
			selene \
				--config selene.toml \
				--no-summary \
				$${files}; \
		fi

SHELLCHECK_ARGS = --severity=style --external-sources

.PHONY: shellcheck
shellcheck: $(AQUA_ROOT_DIR)/.installed ## Runs the shellcheck linter.
	@set -e;\
		files=$$(git ls-files | xargs file | grep -e ':.*shell' | cut -d':' -f1); \
		if [ "$${files}" == "" ]; then \
			exit 0; \
		fi; \
		PATH="$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION):$(AQUA_ROOT_DIR)/bin:$${PATH}"; \
		AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)"; \
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

.PHONY: textlint
textlint: node_modules/.installed $(AQUA_ROOT_DIR)/.installed ## Runs the textlint linter.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.md' \
				'*.txt' \
				':!:requirements*.txt' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
		); \
		if [ "$${files}" == "" ]; then \
			exit 0; \
		fi; \
		PATH="$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION):$(AQUA_ROOT_DIR)/bin:$${PATH}"; \
		AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)"; \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			exit_code=0; \
			while IFS="" read -r p && [ -n "$$p" ]; do \
				filePath=$$(echo "$$p" | jq -cr '.filePath // empty'); \
				file=$$(realpath --relative-to="." "$${filePath}"); \
				while IFS="" read -r m && [ -n "$$m" ]; do \
					line=$$(echo "$$m" | jq -cr '.loc.start.line // empty'); \
					endline=$$(echo "$$m" | jq -cr '.loc.end.line // empty'); \
					col=$$(echo "$${m}" | jq -cr '.loc.start.column // empty'); \
					endcol=$$(echo "$${m}" | jq -cr '.loc.end.column // empty'); \
					message=$$(echo "$$m" | jq -cr '.message // empty'); \
					exit_code=1; \
					echo "::error file=$${file},line=$${line},endLine=$${endline},col=$${col},endColumn=$${endcol}::$${message}"; \
				done <<<"$$(echo "$$p" | jq -cr '.messages[] // empty')"; \
			done <<< "$$(./node_modules/.bin/textlint -c .textlintrc.yaml --format json $${files} 2>&1 | jq -c '.[]')"; \
			exit "$${exit_code}"; \
		else \
			./node_modules/.bin/textlint \
				--config .textlintrc.yaml \
				$${files}; \
		fi

.PHONY: yamllint
yamllint: .venv/.installed ## Runs the yamllint linter.
	@set -euo pipefail;\
		files=$$( \
			git ls-files --deduplicate \
				'*.yml' \
				'*.yaml' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
		); \
		if [ "$${files}" == "" ]; then \
			exit 0; \
		fi; \
		format="standard"; \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			format="github"; \
		fi; \
		.venv/bin/yamllint \
			--strict \
			--config-file .yamllint.yaml \
			--format "$${format}" \
			$${files}

.PHONY: zizmor
zizmor: .venv/.installed ## Runs the zizmor linter.
	@# NOTE: On GitHub actions this outputs SARIF format to zizmor.sarif.json
	@#       in addition to outputting errors to the terminal.
	@set -euo pipefail;\
		files=$$( \
			git ls-files --deduplicate \
				'.github/workflows/*.yml' \
				'.github/workflows/*.yaml' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
		); \
		if [ "$${files}" == "" ]; then \
			exit 0; \
		fi; \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			.venv/bin/zizmor \
				--config .zizmor.yml \
				--quiet \
				--pedantic \
				--format sarif \
				$${files} > zizmor.sarif.json; \
		fi; \
		.venv/bin/zizmor \
			--config .zizmor.yml \
			--quiet \
			--pedantic \
			--format plain \
			$${files}

## Base Tools
#####################################################################

$(XDG_BIN_HOME):
	@set -euo pipefail; \
		mkdir -p $(XDG_BIN_HOME); \
		ln -sf $(REPO_ROOT)/bin/all/* $(XDG_BIN_HOME)/

$(XDG_BIN_HOME)/%: $(XDG_BIN_HOME) bin/all/%
	@ln -sf "$(REPO_ROOT)"/bin/all/* $(XDG_BIN_HOME)/

BIN_SRCS := $(wildcard bin/all/*)
BIN_OBJS := $(subst bin/all,$(XDG_BIN_HOME),$(BIN_SRCS))

.PHONY: install-bin
install-bin: $(BIN_OBJS) ## Install binary scripts.

.PHONY: configure-bash
configure-bash: ## Configure bash.
	@set -euo pipefail; \
		rm -f \
			$(HOME)/.inputrc \
			$(HOME)/.profile \
			$(HOME)/.bash_profile \
			$(HOME)/.bashrc \
			$(HOME)/.bash_aliases \
			$(HOME)/.bash_completion \
			$(HOME)/.bash_logout \
			$(HOME)/.dockerfunc \
			$(HOME)/.local/share/bash/lib \
			$(XDG_CONFIG_HOME)/sbp; \
		mkdir -p $(HOME)/.local/share/bash; \
		ln -sf $(REPO_ROOT)/bash/lib $(HOME)/.local/share/bash/lib; \
		ln -sf $(REPO_ROOT)/bash/_inputrc $(HOME)/.inputrc; \
		ln -sf $(REPO_ROOT)/bash/_profile $(HOME)/.profile; \
		ln -sf $(REPO_ROOT)/bash/_bash_profile $(HOME)/.bash_profile; \
		ln -sf $(REPO_ROOT)/bash/_bashrc $(HOME)/.bashrc; \
		ln -sf $(REPO_ROOT)/bash/_bash_aliases $(HOME)/.bash_aliases; \
		ln -sf $(REPO_ROOT)/bash/_bash_completion $(HOME)/.bash_completion; \
		ln -sf $(REPO_ROOT)/bash/_bash_logout $(HOME)/.bash_logout; \
		ln -sf $(REPO_ROOT)/bash/sbp $(XDG_CONFIG_HOME)/sbp

$(HOME)/.aqua.yaml:
	@ln -sf $(REPO_ROOT)/aqua/aqua.yaml $(HOME)/.aqua.yaml

aqua/aqua-checksums.json: aqua/aqua.yaml .bin/aqua-$(AQUA_VERSION)/aqua
	@.bin/aqua-$(AQUA_VERSION)/aqua --config aqua/aqua.yaml update-checksum

$(HOME)/.aqua-checksums.json:
	@ln -sf $(REPO_ROOT)/aqua/aqua-checksums.json $(HOME)/.aqua-checksums.json

.PHONY: configure-aqua
configure-aqua: $(HOME)/.aqua.yaml $(HOME)/.aqua-checksums.json ## Configure aqua.

$(XDG_CONFIG_HOME)/efm-langserver/config.yaml: efm-langserver/config.yaml
	@set -euo pipefail; \
		mkdir -p $$(dirname $@); \
		mkdir -p $(XDG_STATE_HOME)/efm-langserver; \
		sed 's|$${XDG_STATE_HOME}|'$(XDG_STATE_HOME)'|'< $< > $@

.PHONY: configure-efm-langserver
configure-efm-langserver: $(XDG_CONFIG_HOME)/efm-langserver/config.yaml ## Configure efm-langserver.

.PHONY: configure-nix
configure-nix: ## Configure nix.
	@set -euo pipefail; \
		mkdir -p $(XDG_CONFIG_HOME)/nix; \
		ln -sf $(REPO_ROOT)/nix/nix.conf $(XDG_CONFIG_HOME)/nix/nix.conf

.PHONY: configure-nvim
configure-nvim: ## Configure neovim.
	@set -euo pipefail; \
		rm -rf $(XDG_CONFIG_HOME)/nvim; \
		ln -sf $(REPO_ROOT)/nvim $(XDG_CONFIG_HOME)/nvim

.PHONY: configure-tmux
configure-tmux: ## Configure tmux.
	@set -euo pipefail; \
		rm -f $(HOME)/.tmux.conf $(HOME)/.tmux; \
		ln -sf $(REPO_ROOT)/tmux/_tmux.conf $(HOME)/.tmux.conf; \
		ln -sf $(REPO_ROOT)/tmux/_tmux $(HOME)/.tmux

.PHONY: configure-git
configure-git: ## Configure git.
	@set -euo pipefail; \
		rm -f $(HOME)/.gitconfig; \
		ln -sf "$(REPO_ROOT)/git/_gitconfig" $(HOME)/.gitconfig

## Install Tools
#####################################################################

.PHONY: install-slsa-verifier
install-slsa-verifier: $(XDG_BIN_HOME)/slsa-verifier ## Install slsa-verifier

$(HOME)/opt/slsa-verifier-v$(SLSA_VERIFIER_VERSION)/slsa-verifier: $(HOME)/opt
	@set -euo pipefail; \
		tempfile=$$(mktemp --suffix=".tar.gz"); \
		curl -sSLo "$${tempfile}" "$(SLSA_VERIFIER_URL)"; \
		echo "$(SLSA_VERIFIER_CHECKSUM)  $${tempfile}" | sha256sum -c; \
	 	mkdir -p $(HOME)/opt/slsa-verifier-v$(SLSA_VERIFIER_VERSION); \
		mv "$${tempfile}" $(HOME)/opt/slsa-verifier-v$(SLSA_VERIFIER_VERSION)/slsa-verifier; \
		chmod +x $(HOME)/opt/slsa-verifier-v$(SLSA_VERIFIER_VERSION)/slsa-verifier

$(XDG_BIN_HOME)/slsa-verifier: $(XDG_BIN_HOME) $(HOME)/opt/slsa-verifier-v$(SLSA_VERIFIER_VERSION)/slsa-verifier
	@set -euo pipefail; \
		ln -sf $(HOME)/opt/slsa-verifier-v$(SLSA_VERIFIER_VERSION)/slsa-verifier $@; \
		touch $(HOME)/opt/slsa-verifier-v$(SLSA_VERIFIER_VERSION)/slsa-verifier

.PHONY: install-aqua
install-aqua: $(XDG_BIN_HOME)/aqua configure-aqua ## Install aqua and aqua-managed CLI tools
	@$(XDG_BIN_HOME)/aqua --config $(HOME)/.aqua.yaml install

$(HOME)/opt/aqua-$(AQUA_VERSION)/.installed: $(HOME)/opt $(XDG_BIN_HOME)/slsa-verifier
	@set -euo pipefail; \
		tempfile=$$(mktemp --suffix=".aqua-$(AQUA_VERSION).tar.gz"); \
		tempjsonl=$$(mktemp --suffix=".aqua-$(AQUA_VERSION).intoto.jsonl"); \
		curl -sSLo "$${tempfile}" "$(AQUA_URL)"; \
		curl -sSLo "$${tempjsonl}" "$(AQUA_PROVENANCE_URL)"; \
		$(XDG_BIN_HOME)/slsa-verifier verify-artifact \
			"$${tempfile}" \
			--provenance-path "$${tempjsonl}" \
			--source-uri "$(AQUA_REPO)" \
			--source-tag "$(AQUA_VERSION)"; \
		mkdir -p $(HOME)/opt/aqua-$(AQUA_VERSION); \
		tar -x -C $(HOME)/opt/aqua-$(AQUA_VERSION) -f "$${tempfile}"; \
		touch $(HOME)/opt/aqua-$(AQUA_VERSION)/.installed

$(XDG_BIN_HOME)/aqua: $(HOME)/opt/aqua-$(AQUA_VERSION)/.installed
	@set -euo pipefail; \
		touch $(HOME)/opt/aqua-$(AQUA_VERSION)/aqua; \
		ln -sf $(HOME)/opt/aqua-$(AQUA_VERSION)/aqua $@

## Language Runtimes
#####################################################################

.PHONY: install-go
install-go: $(HOME)/opt ## Install the Go runtime.
	@set -euo pipefail; \
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
install-node: $(XDG_DATA_HOME)/node_modules/.installed ## Install the Node.js environment.

# Installs nodeenv and Node.js
$(NODENV_ROOT)/.installed:
	@set -euo pipefail; \
		# Install the nodenv. \
		git clone --branch "$(NODENV_INSTALL_VERSION)" https://github.com/nodenv/nodenv.git $(NODENV_ROOT); \
		if [ "$(NODENV_INSTALL_VERSION)" == "master" ]; then \
			git -C $(NODENV_ROOT) checkout "$(NODENV_INSTALL_SHA)"; \
		fi; \
		nodenv_sha=$$(git -C $(NODENV_ROOT) rev-parse HEAD); \
		if [ "$${nodenv_sha}" != "$(NODENV_INSTALL_SHA)" ]; then \
			echo "Invalid nodenv: '$${nodenv_sha}' != '$(NODENV_INSTALL_SHA)'"; \
			rm -rf $(NODENV_ROOT); \
			exit 1; \
		fi; \
		# Install the nodenv plugins. \
		git clone --branch "$(NODENV_BUILD_VERSION)" https://github.com/nodenv/node-build.git "$(NODENV_ROOT)"/plugins/node-build; \
		nodenv_build_sha=$$(git -C $(NODENV_ROOT)/plugins/node-build rev-parse HEAD); \
		if [ "$${nodenv_build_sha}" != "$(NODENV_BUILD_SHA)" ]; then \
			echo "Invalid node-build: '$${nodenv_build_sha}' != '$(NODENV_BUILD_SHA)'"; \
			rm -rf $(NODENV_ROOT); \
			exit 1; \
		fi; \
		NODENV_ROOT=$(NODENV_ROOT) $(NODENV_ROOT)/bin/nodenv install --skip-existing; \
		ln -sf $(REPO_ROOT)/.node-version $(HOME)/.node-version; \
		touch $@

nodenv/package-lock.json: nodenv/package.json
	@set -euo pipefail; \
		cd $(REPO_ROOT)/nodenv; \
		NODENV_ROOT=$(NODENV_ROOT) $(NODENV_ROOT)/shims/npm \
			install \
			--package-lock-only \
			--no-audit \
			--no-fund

# Installs tools in the user node_modules.
$(XDG_DATA_HOME)/node_modules/.installed: nodenv/package-lock.json $(NODENV_ROOT)/.installed
	@set -euo pipefail; \
		cd $(REPO_ROOT)/nodenv; \
		NODENV_ROOT=$(NODENV_ROOT) $(NODENV_ROOT)/shims/npm clean-install; \
		NODENV_ROOT=$(NODENV_ROOT) $(NODENV_ROOT)/shims/npm audit signatures; \
		ln -sf $(REPO_ROOT)/nodenv/node_modules $(XDG_DATA_HOME)/node_modules; \
		touch $@

.PHONY: install-python
install-python: $(PYENV_ROOT)/versions/$(USER)/.installed ## Install the Python environment.

# Installs the requirements in the Python virtualenv.
$(PYENV_ROOT)/versions/$(USER)/.installed: requirements.txt $(PYENV_ROOT)/versions/$(USER)/bin/activate
	@set -euo pipefail; \
		export PYENV_ROOT=$(PYENV_ROOT); \
		$(PYENV_ROOT)/versions/$(USER)/bin/pip install -r $< --require-hashes; \
		touch $@

# Creates a Python virtualenv using pyenv.
$(PYENV_ROOT)/versions/$(USER)/bin/activate: $(PYENV_ROOT)/.installed
	@set -euo pipefail; \
		export PYENV_ROOT=$(PYENV_ROOT); \
		# NOTE: We unset the `PYENV_VERSION` environment variable to \
		# 		ensure that we don't depend on a virtualenv that is not \
		# 		yet installed. \
		PYENV_VERSION= $(PYENV_ROOT)/bin/pyenv virtualenv $(USER)

$(PYENV_ROOT)/.installed:
	@set -euo pipefail; \
		export PYENV_ROOT=$(PYENV_ROOT) \
		export PYENV_GIT_TAG=$(PYENV_INSTALL_VERSION); \
		$(REPO_ROOT)/pyenv/pyenv-installer/bin/pyenv-installer; \
		# Validate the pyenv installation. \
		pyenv_sha=$$(git -C $(PYENV_ROOT) rev-parse HEAD); \
		if [ "$${pyenv_sha}" != "$(PYENV_INSTALL_SHA)" ]; then \
			echo "Invalid pyenv: '$${pyenv_sha}' != '$(PYENV_INSTALL_SHA)'"; \
			rm -rf $(PYENV_ROOT); \
			exit 1; \
		fi; \
		pyenv_doctor_sha=$$(git -C $(PYENV_ROOT)/plugins/pyenv-doctor rev-parse HEAD); \
		if [ "$${pyenv_doctor_sha}" != "$(PYENV_DOCTOR_SHA)" ]; then \
			echo "Invalid pyenv_doctor: '$${pyenv_doctor_sha}' != '$(PYENV_DOCTOR_SHA)'"; \
			rm -rf $(PYENV_ROOT); \
			exit 1; \
		fi; \
		pyenv_update_sha=$$(git -C $(PYENV_ROOT)/plugins/pyenv-update rev-parse HEAD); \
		if [ "$${pyenv_update_sha}" != "$(PYENV_UPDATE_SHA)" ]; then \
			echo "Invalid pyenv_update: '$${pyenv_update_sha}' != '$(PYENV_UPDATE_SHA)'"; \
			rm -rf $(PYENV_ROOT); \
			exit 1; \
		fi; \
		pyenv_virtualenv_sha=$$(git -C $(PYENV_ROOT)/plugins/pyenv-virtualenv rev-parse HEAD); \
		if [ "$${pyenv_virtualenv_sha}" != "$(PYENV_VIRTUALENV_SHA)" ]; then \
			echo "Invalid pyenv_virtualenv: '$${pyenv_virtualenv_sha}' != '$(PYENV_VIRTUALENV_SHA)'"; \
			rm -rf $(PYENV_ROOT); \
			exit 1; \
		fi; \
		$(PYENV_ROOT)/bin/pyenv install --skip-existing; \
		ln -sf $(REPO_ROOT)/.python-version $(HOME)/.python-version; \
		touch $@

.PHONY: install-ruby
install-ruby: $(RBENV_ROOT)/.installed ## Install the Ruby environment.

$(RBENV_ROOT)/.installed:
	@set -euo pipefail; \
		export RBENV_ROOT=$(RBENV_ROOT) \
		export RBENV_GIT_TAG=$(RBENV_INSTALL_VERSION); \
		git clone --branch "$(RBENV_INSTALL_VERSION)" https://github.com/rbenv/rbenv.git $(RBENV_ROOT); \
		# Validate the rbenv installation. \
		rbenv_sha=$$(git -C $(RBENV_ROOT) rev-parse HEAD); \
		if [ "$${rbenv_sha}" != "$(RBENV_INSTALL_SHA)" ]; then \
			echo "Invalid rbenv: '$${rbenv_sha}' != '$(RBENV_INSTALL_SHA)'"; \
			rm -rf $(RBENV_ROOT); \
			exit 1; \
		fi; \
		# Install the nodenv plugins. \
		git clone --branch "$(RBENV_BUILD_VERSION)" https://github.com/rbenv/ruby-build.git "$(RBENV_ROOT)"/plugins/ruby-build; \
		rbenv_build_sha=$$(git -C $(RBENV_ROOT)/plugins/ruby-build rev-parse HEAD); \
		if [ "$${rbenv_build_sha}" != "$(RBENV_BUILD_SHA)" ]; then \
			echo "Invalid ruby-build: '$${rbenv_build_sha}' != '$(RBENV_BUILD_SHA)'"; \
			rm -rf $(RBENV_ROOT); \
			exit 1; \
		fi; \
		$(RBENV_ROOT)/bin/rbenv install --skip-existing; \
		ln -sf $(REPO_ROOT)/.ruby-version $(HOME)/.ruby-version; \
		touch $@

## Maintenance
#####################################################################

.PHONY: todos
todos: $(AQUA_ROOT_DIR)/.installed ## Print outstanding TODOs.
	@set -euo pipefail;\
		PATH="$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION):$(AQUA_ROOT_DIR)/bin:$${PATH}"; \
		AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)"; \
		output="default"; \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			output="github"; \
		fi; \
		# NOTE: todos does not use `git ls-files` because many files might be \
		# 		unsupported and generate an error if passed directly on the \
		# 		command line. \
		todos \
			--output "$${output}" \
			--todo-types="TODO,Todo,todo,FIXME,Fixme,fixme,BUG,Bug,bug,XXX,COMBAK"

.PHONY: clean
clean: ## Delete temporary files.
	@rm -rf \
		.bin \
		$(AQUA_ROOT_DIR) \
		.venv \
		node_modules \
		*.sarif.json
