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

# Set the initial shell so we can determine extra options.
SHELL := /usr/bin/env bash -ueo pipefail
DEBUG_LOGGING ?= $(shell if [[ "$(GITHUB_ACTIONS)" == "true" ]] && [[ -n "$(RUNNER_DEBUG)" || "$(ACTIONS_RUNNER_DEBUG)" == "true" || "$(ACTIONS_STEP_DEBUG)" == "true" ]]; then echo "true"; else echo ""; fi)
BASH_OPTIONS := $(shell if [ "$(DEBUG_LOGGING)" == "true" ]; then echo "-x"; else echo ""; fi)

# Add extra options for debugging.
SHELL := /usr/bin/env bash -ueo pipefail $(BASH_OPTIONS)

include versions.mk

uname_s := $(shell uname -s)
uname_m := $(shell uname -m)
arch.x86_64 := amd64
arch.aarch64 := arm64
arch.arm64 := arm64
arch := $(arch.$(uname_m))
kernel.Linux := linux
kernel.Darwin := darwin
kernel := $(kernel.$(uname_s))

XDG_CONFIG_HOME ?= $(HOME)/.config
XDG_BIN_HOME ?= $(HOME)/.local/bin
XDG_DATA_HOME ?= $(HOME)/.local/share
XDG_STATE_HOME ?= $(HOME)/.local/state

OUTPUT_FORMAT ?= $(shell if [ "${GITHUB_ACTIONS}" == "true" ]; then echo "github"; else echo ""; fi)
REPO_ROOT := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
REPO_NAME := $(shell basename "$(REPO_ROOT)")

# TODO(github.com/aquaproj/aqua/issues/3951): workaround for flaky aqua install
SLSA_VERIFIER_REPO := github.com/slsa-framework/slsa-verifier
SLSA_VERIFIER_CHECKSUM ?= $(SLSA_VERIFIER_CHECKSUM.$(kernel).$(arch))
SLSA_VERIFIER_URL := https://$(SLSA_VERIFIER_REPO)/releases/download/$(SLSA_VERIFIER_VERSION)/slsa-verifier-$(kernel)-$(arch)

# TODO(github.com/aquaproj/aqua/issues/3951): workaround for flaky aqua install
COSIGN_REPO := github.com/sigstore/cosign
COSIGN_CHECKSUM ?= $(COSIGN_CHECKSUM.$(kernel).$(arch))
COSIGN_URL := https://$(COSIGN_REPO)/releases/download/$(COSIGN_VERSION)/cosign-$(kernel)-$(arch)

AQUA_REPO := github.com/aquaproj/aqua
AQUA_CHECKSUM ?= $(AQUA_CHECKSUM.$(kernel).$(arch))
AQUA_INSTALLER_URL := https://raw.githubusercontent.com/aquaproj/aqua-installer/$(AQUA_INSTALLER_VERSION)/aqua-installer
export AQUA_ROOT_DIR := $(REPO_ROOT)/.aqua

# Ensure that aqua and aqua installed tools are in the PATH.
export PATH := $(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION):$(AQUA_ROOT_DIR)/bin:$(PATH)

# We want GNU versions of tools so prefer them if present.
GREP := $(shell command -v ggrep 2>/dev/null || command -v grep 2>/dev/null)
AWK := $(shell command -v gawk 2>/dev/null || command -v awk 2>/dev/null)
MKTEMP := $(shell command -v gmktemp 2>/dev/null || command -v mktemp 2>/dev/null)

# NOTE: Go shouldn't necessarily need to be upgraded since it can support
#       toolchains and will automatically download the necessary runtime
#       version for a project.
GO_CHECKSUM ?= $(GO_CHECKSUM.$(kernel).$(arch))
GO_URL := https://go.dev/dl/go$(GO_VERSION).$(kernel)-$(arch).tar.gz

export PYENV_ROOT ?= $(XDG_DATA_HOME)/pyenv
export NODENV_ROOT ?= $(XDG_DATA_HOME)/nodenv
export RBENV_ROOT ?= $(XDG_DATA_HOME)/rbenv

E2E_HOME ?= $(shell $(MKTEMP) --directory)
export E2E_HOME := $(E2E_HOME)

# The current language runtime versions
NODE_VERSION := $(shell cat .node-version)
PYTHON_VERSION := $(shell cat .python-version)
RUBY_VERSION := $(shell cat .ruby-version)

# Macro for creating necessary directories.
# NOTE: needed for targets that require a directory to be created without
#       triggering rebuilds when anything inside changes.
$(HOME)/%/.created:
	@# bash \
	mkdir -p $(dir $@); \
	touch $@

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
	@# bash \
	echo "$(REPO_NAME) Makefile"; \
	echo "Usage: $(MAKE) [COMMAND]"; \
	echo ""; \
	normal=""; \
	cyan=""; \
	if command -v tput >/dev/null 2>&1; then \
		if [ -t 1 ]; then \
			normal=$$(tput sgr0); \
			cyan=$$(tput setaf 6); \
		fi; \
	fi; \
	$(GREP) --no-filename -E '^([/a-z.A-Z0-9_%-]+:.*?|)##' $(MAKEFILE_LIST) | \
		$(AWK) \
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

# Node.js setup
#####################################################################

package-lock.json: package.json $(AQUA_ROOT_DIR)/.installed $(NODENV_ROOT)/versions/$(NODE_VERSION)/.installed
	@# bash \
	loglevel="notice"; \
	if [ -n "$(DEBUG_LOGGING)" ]; then \
		loglevel="verbose"; \
	fi; \
	# NOTE: npm install will happily ignore the fact that integrity hashes are \
	# missing in the package-lock.json. We need to check for missing integrity \
	# fields ourselves. If any are missing, then we need to regenerate the \
	# package-lock.json from scratch. \
	nointegrity=""; \
	noresolved=""; \
	if [ -f "$@" ]; then \
		nointegrity=$$(jq '.packages | del(."") | .[] | select(has("integrity") | not)' < $@); \
		noresolved=$$(jq '.packages | del(."") | .[] | select(has("resolved") | not)' < $@); \
	fi; \
	if [ ! -f "$@" ] || [ -n "$${nointegrity}" ] || [ -n "$${noresolved}" ]; then \
		# NOTE: package-lock.json is removed to ensure that npm includes the \
		# integrity field. npm install will not restore this field if \
		# missing in an existing package-lock.json file. \
		rm -f $@; \
		# NOTE: We clean the node_modules directory to ensure that npm install \
		#       will not desync between the package.json, package-lock.json \
		#       and the node_modules directory. \
		$(MAKE) clean-node-modules; \
		$(NODENV_ROOT)/shims/npm --loglevel="$${loglevel}" install \
			--no-audit \
			--no-fund; \
	else \
		$(NODENV_ROOT)/shims/npm --loglevel="$${loglevel}" install \
			--package-lock-only \
			--no-audit \
			--no-fund; \
	fi

node_modules/.installed: package.json $(NODENV_ROOT)/versions/$(NODE_VERSION)/.installed
	@# bash \
	loglevel="silent"; \
	if [ -n "$(DEBUG_LOGGING)" ]; then \
		loglevel="verbose"; \
	fi; \
	$(NODENV_ROOT)/shims/npm --loglevel="$${loglevel}" clean-install; \
	$(NODENV_ROOT)/shims/npm --loglevel="$${loglevel}" audit signatures; \
	touch $@

# Python setup
#####################################################################

.uv/venv/bin/activate: $(PYENV_ROOT)/versions/$(PYTHON_VERSION)/.python-installed
	@# bash \
	mkdir -p .uv; \
	$(PYENV_ROOT)/shims/python -m venv .uv/venv; \
	touch $@

.uv/.installed: requirements-dev.txt .uv/venv/bin/activate
	@# bash \
	./.uv/venv/bin/pip install -r $< --require-hashes; \
	touch $@

uv.lock: pyproject.toml .uv/.installed
	@# bash \
	./.uv/venv/bin/uv lock; \
	touch $@

.venv/.installed: pyproject.toml .uv/.installed
	@# bash \
	./.uv/venv/bin/uv sync --locked; \
	touch $@

# Aqua setup
#####################################################################

# NOTE: aqua-installer itself is treated as a lockfile.
.PHONY: aqua-installer
aqua-installer:
	curl -sSfL -o .aqua-installer $(AQUA_INSTALLER_URL); \
	chmod +x .aqua-installer

$(AQUA_ROOT_DIR)/bin/aqua:
	@# bash \
	./.aqua-installer -v "$(AQUA_VERSION)"

.aqua-checksums.json: .aqua.yaml $(AQUA_ROOT_DIR)/bin/aqua
	@# bash \
	loglevel="info"; \
	if [ -n "$(DEBUG_LOGGING)" ]; then \
		loglevel="debug"; \
	fi; \
	$(AQUA_ROOT_DIR)/bin/aqua \
		--config ".aqua.yaml" \
		--log-level "$${loglevel}" \
		update-checksum --prune

$(AQUA_ROOT_DIR)/.installed: $(AQUA_ROOT_DIR)/bin/aqua .aqua.yaml
	@# bash \
	loglevel="info"; \
	if [ -n "$(DEBUG_LOGGING)" ]; then \
		loglevel="debug"; \
	fi; \
	$(AQUA_ROOT_DIR)/bin/aqua \
		--config ".aqua.yaml" \
		--log-level "$${loglevel}" \
		install; \
	touch $@

## Installation
#####################################################################

.PHONY: all
all: test install ## Run all tests, install and configure everything.

.PHONY: install
install: install-tools install-runtimes configure ## Install and configure everything.

.PHONY: configure
configure: configure-aqua configure-bash configure-bat configure-crictl configure-crontab configure-efm-langserver configure-ghostty configure-git configure-k9s configure-nix configure-node configure-nvim configure-ssh configure-tmux configure-yamlfmt configure-yamllint

.PHONY: install-tools
install-tools: install-bin install-slsa-verifier install-cosign install-aqua

.PHONY: install-runtimes
install-runtimes: install-go install-node install-python install-ruby

## Testing
#####################################################################

.PHONY: test
test: lint unit-test e2e-test ## Run all tests.

.PHONY: unit-test
unit-test: bats-unit ## Run unit tests.

.PHONY: bats
bats-unit: ## Run Bats unit tests.
	@# bash \
	formatter="pretty"; \
	if [[ "$(OUTPUT_FORMAT)" == "github" ]]; then \
		formatter="tap"; \
	fi; \
	./bash/test/bats/bin/bats \
		--formatter "$${formatter}" \
		--recursive \
		bash/test/unit

$(E2E_HOME)/.installed:
	@# bash \
	echo "Using temporary directory: $${E2E_HOME}"; \
	HOME="$${E2E_HOME}" \
		XDG_BIN_HOME="$${E2E_HOME}/.local/bin" \
		XDG_CONFIG_HOME="$${E2E_HOME}/.config" \
		XDG_DATA_HOME="$${E2E_HOME}/.local/share" \
		XDG_STATE_HOME="$${E2E_HOME}/.local/state" \
		NODENV_ROOT="$${E2E_HOME}/.local/share/nodenv" \
		PYENV_ROOT="$${E2E_HOME}/.local/share/pyenv" \
		RBENV_ROOT="$${E2E_HOME}/.local/share/rbenv" \
			$(MAKE) install; \
	touch $@

.PHONY: e2e-test
e2e-test: bats-e2e tmux-e2e nvim-checkhealth ## Run all end-to-end tests.

.PHONY: bats-e2e
bats-e2e: $(E2E_HOME)/.installed ## Run bats end-to-end tests.
	@# bash \
	formatter="pretty"; \
	if [[ "$(OUTPUT_FORMAT)" == "github" ]]; then \
		formatter="tap"; \
	fi; \
	AQUA_VERSION=$(AQUA_VERSION) \
		./bash/test/bats/bin/bats \
			--formatter "$${formatter}" \
			bash/test/e2e

.PHONY: tmux-e2e
tmux-e2e: $(E2E_HOME)/.installed ## Test tmux config for parsing errors (e2e).
	@# bash \
	# Check tmux config for parsing errors. This needs to be an e2e test \
	# since it relies on the home directory paths. \
	HOME="$(E2E_HOME)" \
		tmux start-server \; source-file -n "$(E2E_HOME)/.tmux.conf"

.PHONY: nvim-checkhealth
nvim-checkhealth: $(E2E_HOME)/.installed ## Run Neovim checkhealth (e2e).
	@# bash \
	# Ensure the environment (PATH etc.) is set up properly and isn't polluted \
	# by current PATH. \
	env -i \
		HOME="$${E2E_HOME}" \
		XDG_BIN_HOME="$${E2E_HOME}/.local/bin" \
		XDG_CONFIG_HOME="$${E2E_HOME}/.config" \
		XDG_DATA_HOME="$${E2E_HOME}/.local/share" \
		XDG_STATE_HOME="$${E2E_HOME}/.local/state" \
		NODENV_ROOT="$${E2E_HOME}/.local/share/nodenv" \
		PYENV_ROOT="$${E2E_HOME}/.local/share/pyenv" \
		RBENV_ROOT="$${E2E_HOME}/.local/share/rbenv" \
		TERM="$${TERM:-"xterm-256color"}" \
		LANG="$${LANG:-"en_US.UTF-8"}" \
		LC_ALL="$${LC_ALL:-"en_US.UTF-8"}" \
			bash --login _nvim_checkhealth.sh; \
	cat nvim-checkhealth.log; \
	if [[ "$(arch)" == "arm64" && "$(kernel)" == "linux" ]]; then \
		# TODO(#607): Remove exception when selene has proper ARM64 support. \
		num_errors=$$(( \
			cat nvim-checkhealth.log | \
			$(GREP) -v 'ERROR "selene": No global executable found' | \
			$(GREP) -ic 'error') || true); \
	else \
		num_errors=$$($(GREP) -ic 'error' nvim-checkhealth.log || true); \
	fi; \
	num_warnings=$$($(GREP) -ic 'warning' nvim-checkhealth.log || true); \
	>&2 echo "nvim checkhealth found $${num_errors} errors, $${num_warnings} warnings."; \
	if [ "$${num_errors}" -gt 0 ]; then \
		exit 1; \
	fi


## Formatting
#####################################################################

.PHONY: format
format: json-format license-headers lua-format md-format shfmt yaml-format ## Format all files

.PHONY: json-format
json-format: node_modules/.installed ## Format JSON files.
	@# bash \
	loglevel="log"; \
	if [ -n "$(DEBUG_LOGGING)" ]; then \
		loglevel="debug"; \
	fi; \
	files=$$( \
		git ls-files --deduplicate \
			'*.json' \
			'*.json5' \
			':!:third_party' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	); \
	if [ "$${files}" == "" ]; then \
		exit 0; \
	fi; \
	./node_modules/.bin/prettier \
		--log-level "$${loglevel}" \
		--no-error-on-unmatched-pattern \
		--write \
		$${files}

.PHONY: license-headers
license-headers: ## Update license headers.
	@# bash \
	files=$$( \
		git ls-files --deduplicate \
			'*.c' \
			'*.cpp' \
			'*.go' \
			'*.h' \
			'*.hpp' \
			'*.js' \
			'*.lua' \
			'*.py' \
			'*.rb' \
			'*.rs' \
			'*.yaml' \
			'*.yml' \
			'Makefile' \
			':!:third_party' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	); \
	name=$$(git config user.name); \
	if [ "$${name}" == "" ]; then \
		>&2 echo "git user.name is required."; \
		>&2 echo "Set it up using:"; \
		>&2 echo "git config user.name \"John Doe\""; \
		exit 1; \
	fi; \
	for filename in $${files}; do \
		if ! ( head "$${filename}" | $(GREP) -iL "Copyright" > /dev/null ); then \
			./third_party/mbrukman/autogen/autogen.sh \
				--in-place \
				--no-code \
				--no-tlc \
				--copyright "$${name}" \
				--license apache \
				"$${filename}"; \
		fi; \
	done

.PHONY: lua-format
lua-format: $(AQUA_ROOT_DIR)/.installed ## Format Lua files.
	@# bash \
	files=$$( \
		git ls-files --deduplicate \
			'*.lua' \
			':!:third_party' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	); \
	if [ "$${files}" == "" ]; then \
		exit 0; \
	fi; \
	stylua $${files}

.PHONY: md-format
md-format: node_modules/.installed ## Format Markdown files.
	@# bash \
	loglevel="log"; \
	if [ -n "$(DEBUG_LOGGING)" ]; then \
		loglevel="debug"; \
	fi; \
	files=$$( \
		git ls-files --deduplicate \
			'*.md' \
			':!:third_party' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	); \
	if [ "$${files}" == "" ]; then \
		exit 0; \
	fi; \
	# NOTE: prettier uses .editorconfig for tab-width. \
	./node_modules/.bin/prettier \
		--log-level "$${loglevel}" \
		--no-error-on-unmatched-pattern \
		--write \
		$${files}

.PHONY: shfmt
shfmt: $(AQUA_ROOT_DIR)/.installed ## Format bash files.
	@# bash \
	files=$$(git ls-files ':!:third_party' | xargs file | $(GREP) -e ':.*shell' | cut -d':' -f1); \
	if [ "$${files}" == "" ]; then \
		exit 0; \
	fi; \
	shfmt --write --simplify --indent 4 $${files}

.PHONY: yaml-format
yaml-format: node_modules/.installed ## Format YAML files.
	@# bash \
	loglevel="log"; \
	if [ -n "$(DEBUG_LOGGING)" ]; then \
		loglevel="debug"; \
	fi; \
	files=$$( \
		git ls-files --deduplicate \
			'*.yml' \
			'*.yaml' \
			':!:third_party' \
	); \
	if [ "$${files}" == "" ]; then \
		exit 0; \
	fi; \
	./node_modules/.bin/prettier \
		--log-level "$${loglevel}" \
		--no-error-on-unmatched-pattern \
		--write \
		$${files}

## Linting
#####################################################################

.PHONY: lint
lint: actionlint checkmake commitlint fixme format-check markdownlint renovate-config-validator selene shellcheck textlint yamllint zizmor ## Run all linters.

.PHONY: actionlint
actionlint: $(AQUA_ROOT_DIR)/.installed ## Runs the actionlint linter.
	@# bash \
	# NOTE: We need to ignore config files used in tests. \
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
		actionlint \
			-format '{{range $$err := .}}::error file={{$$err.Filepath}},line={{$$err.Line}},col={{$$err.Column}}::{{$$err.Message}}%0A```%0A{{replace $$err.Snippet "\\n" "%0A"}}%0A```\n{{end}}' \
			-ignore 'SC2016:' \
			$${files}; \
	else \
		actionlint \
			-ignore 'SC2016:' \
			$${files}; \
	fi

.PHONY: checkmake
checkmake: $(AQUA_ROOT_DIR)/.installed ## Runs the checkmake linter.
	@# bash \
	# NOTE: We need to ignore config files used in tests. \
	files=$$( \
		git ls-files --deduplicate \
			'Makefile' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	); \
	if [ "$${files}" == "" ]; then \
		exit 0; \
	fi; \
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		# TODO: Remove newline from the format string after updating checkmake. \
		checkmake \
			--format '::error file={{.FileName}},line={{.LineNumber}}::{{.Rule}}: {{.Violation}}'$$'\n' \
			$${files}; \
	else \
		checkmake $${files}; \
	fi

.PHONY: commitlint
commitlint: node_modules/.installed ## Run commitlint linter.
	@# bash \
	commitlint_from=$(COMMITLINT_FROM_REF); \
	commitlint_to=$(COMMITLINT_TO_REF); \
	if [ "$${commitlint_from}" == "" ]; then \
		# Try to get the default branch without hitting the remote server \
		if git symbolic-ref --short refs/remotes/origin/HEAD >/dev/null 2>&1; then \
			commitlint_from=$$(git symbolic-ref --short refs/remotes/origin/HEAD); \
		elif git show-ref refs/remotes/origin/master >/dev/null 2>&1; then \
			commitlint_from="origin/master"; \
		else \
			commitlint_from="origin/main"; \
		fi; \
	fi; \
	if [ "$${commitlint_to}" == "" ]; then \
		# if head is on the commitlint_from branch, then we will lint the \
		# last commit by default. \
		current_branch=$$(git rev-parse --abbrev-ref HEAD); \
		if [ "$${commitlint_from}" == "$${current_branch}" ]; then \
			commitlint_from="HEAD~1"; \
		fi; \
		commitlint_to="HEAD"; \
	fi; \
	./node_modules/.bin/commitlint \
		--from "$${commitlint_from}" \
		--to "$${commitlint_to}" \
		--verbose \
		--strict

.PHONY: fixme
fixme: $(AQUA_ROOT_DIR)/.installed ## Check for outstanding FIXMEs.
	@# bash \
	output="default"; \
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		output="github"; \
	fi; \
	# NOTE: todos does not use `git ls-files` because many files might be \
	# 		unsupported and generate an error if passed directly on the \
	# 		command line. \
	todos \
		--output "$${output}" \
		--todo-types="FIXME,Fixme,fixme,BUG,Bug,bug,XXX,COMBAK" \
		--exclude-dir "third_party"

.PHONY: format-check
format-check: ## Check that files are properly formatted.
	@# bash \
	if [ -n "$$(git diff)" ]; then \
		>&2 echo "The working directory is dirty. Please commit, stage, or stash changes and try again."; \
		exit 1; \
	fi; \
	$(MAKE) format; \
	exit_code=0; \
	if [ -n "$$(git diff)" ]; then \
		>&2 echo "Some files need to be formatted. Please run '$(MAKE) format' and try again."; \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			echo "::group::git diff"; \
		fi; \
		git --no-pager diff; \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			echo "::endgroup::"; \
		fi; \
		exit_code=1; \
	fi; \
	git restore .; \
	exit "$${exit_code}"

.PHONY: markdownlint
markdownlint: node_modules/.installed $(AQUA_ROOT_DIR)/.installed ## Runs the markdownlint linter.
	@# bash \
	# NOTE: Issue and PR templates are handled specially so we can disable \
	# MD041/first-line-heading/first-line-h1 without adding an ugly html comment \
	# at the top of the file. \
	files=$$( \
		git ls-files --deduplicate \
			'*.md' \
			':!:third_party' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	); \
	if [ "$${files}" == "" ]; then \
		exit 0; \
	fi; \
	./node_modules/.bin/markdownlint-cli2 $${files}

.PHONY: renovate-config-validator
renovate-config-validator: node_modules/.installed ## Validate Renovate configuration.
	@# bash \
	./node_modules/.bin/renovate-config-validator \
		--strict

.PHONY: selene
selene: $(AQUA_ROOT_DIR)/.installed ## Runs the selene (Lua) linter.
	@# bash \
	files=$$( \
		git ls-files --deduplicate \
			'*.lua' \
			':!:third_party' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	); \
	if [ "$${files}" == "" ]; then \
		exit 0; \
	fi; \
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		exit_code=0; \
		selene_out="$$(selene --display-style Json2 $${files} || exit_code=\"$$?\")"; \
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
		done <<< "$${selene_out}"; \
		exit "$${exit_code}"; \
	else \
		selene \
			--no-summary \
			$${files}; \
	fi

SHELLCHECK_ARGS = --severity=style --external-sources

.PHONY: shellcheck
shellcheck: $(AQUA_ROOT_DIR)/.installed ## Runs the shellcheck linter.
	@# bash \
	files=$$(git ls-files ':!:third_party' | xargs file | $(GREP) -e ':.*shell' | cut -d':' -f1); \
	if [ "$${files}" == "" ]; then \
		exit 0; \
	fi; \
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
	@# bash \
	files=$$( \
		git ls-files --deduplicate \
			'*.md' \
			'*.txt' \
			':!:requirements*.txt' \
			':!:third_party' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	); \
	if [ "$${files}" == "" ]; then \
		exit 0; \
	fi; \
	./node_modules/.bin/textlint $${files}

.PHONY: yamllint
yamllint: .venv/.installed ## Runs the yamllint linter.
	@# bash \
	files=$$( \
		git ls-files --deduplicate \
			'*.yml' \
			'*.yaml' \
			':!:third_party' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	); \
	if [ "$${files}" == "" ]; then \
		exit 0; \
	fi; \
	format="standard"; \
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		format="github"; \
	fi; \
	./.venv/bin/yamllint \
		--strict \
		--format "$${format}" \
		$${files}

.PHONY: zizmor
zizmor: .venv/.installed ## Runs the zizmor linter.
	@# bash \
	# NOTE: On GitHub actions this outputs SARIF format to zizmor.sarif.json \
	#       in addition to outputting errors to the terminal. \
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
		./.venv/bin/zizmor \
			--quiet \
			--pedantic \
			--format sarif \
			$${files} > zizmor.sarif.json; \
	fi; \
	./.venv/bin/zizmor \
		--quiet \
		--pedantic \
		--format plain \
		$${files}

## Base Tools
#####################################################################

.PHONY: install-bin
install-bin: $(XDG_BIN_HOME)/.created $(XDG_CONFIG_HOME)/.created ## Install binary scripts.
	@# bash \
	ln -sf $(REPO_ROOT)/bin/all/clone.bash $(XDG_BIN_HOME)/clone; \
	ln -sf $(REPO_ROOT)/bin/all/delete_old_downloads.sh $(XDG_BIN_HOME)/delete_old_downloads.sh; \
	ln -sf $(REPO_ROOT)/bin/all/docker_prune.sh $(XDG_BIN_HOME)/docker_prune.sh; \
	ln -sf $(REPO_ROOT)/bin/all/project-windowizer $(XDG_BIN_HOME)/project-windowizer; \
	ln -sf $(REPO_ROOT)/bin/all/tmux-sessionizer $(XDG_BIN_HOME)/tmux-sessionizer; \
	ln -sf $(REPO_ROOT)/bin/all/ts $(XDG_BIN_HOME)/ts; \
	ln -sf $(REPO_ROOT)/bin/all/randstr.bash $(XDG_BIN_HOME)/randstr; \
	ln -sf $(REPO_ROOT)/bin/all/update_authorized_keys.sh $(XDG_BIN_HOME)/update_authorized_keys.sh; \
	ln -sf $(REPO_ROOT)/bin/all/withpass.sh $(XDG_BIN_HOME)/withpass; \
	mkdir -p $(XDG_CONFIG_HOME)/coding-assistant-docker-images; \
	$(MAKE) \
		-C third_party/ianlewis/coding-assistant-docker-images \
		install

aqua/aqua-checksums.json: aqua/aqua.yaml $(AQUA_ROOT_DIR)/bin/aqua
	@# bash \
	loglevel="info"; \
	if [ -n "$(DEBUG_LOGGING)" ]; then \
		loglevel="debug"; \
	fi; \
	cd aqua; \
	./.bin/aqua-$(AQUA_VERSION)/aqua \
		--config aqua.yaml \
		--log-level "$${loglevel}" \
		update-checksum

$(HOME)/.aqua.yaml:
	@# bash \
	ln -sf $(REPO_ROOT)/aqua/aqua.yaml $(HOME)/.aqua.yaml

$(HOME)/.aqua-checksums.json:
	@# bash \
	ln -sf $(REPO_ROOT)/aqua/aqua-checksums.json $(HOME)/.aqua-checksums.json

.PHONY: configure-aqua
configure-aqua: $(HOME)/.aqua.yaml $(HOME)/.aqua-checksums.json ## Configure aqua.

.PHONY: configure-bash
configure-bash: $(XDG_CONFIG_HOME)/.created $(XDG_DATA_HOME)/.created ## Configure bash.
	@# bash \
	$(MAKE) -C bash/lib/ble.sh build; \
	$(RM) -f \
		$(HOME)/.inputrc \
		$(HOME)/.profile \
		$(HOME)/.bash_profile \
		$(HOME)/.bashrc \
		$(HOME)/.bash_aliases \
		$(HOME)/.bash_completion \
		$(HOME)/.bash_logout \
		$(XDG_DATA_HOME)/bash/lib \
		$(XDG_CONFIG_HOME)/sbp \
		$(XDG_CONFIG_HOME)/blesh; \
	mkdir -p $(XDG_DATA_HOME)/bash; \
	ln -sf $(REPO_ROOT)/bash/lib $(XDG_DATA_HOME)/bash/lib; \
	ln -sf $(REPO_ROOT)/bash/_inputrc $(HOME)/.inputrc; \
	ln -sf $(REPO_ROOT)/bash/_profile $(HOME)/.profile; \
	ln -sf $(REPO_ROOT)/bash/_bash_profile $(HOME)/.bash_profile; \
	ln -sf $(REPO_ROOT)/bash/_bashrc $(HOME)/.bashrc; \
	ln -sf $(REPO_ROOT)/bash/_bash_aliases $(HOME)/.bash_aliases; \
	ln -sf $(REPO_ROOT)/bash/_bash_completion $(HOME)/.bash_completion; \
	ln -sf $(REPO_ROOT)/bash/_bash_logout $(HOME)/.bash_logout; \
	ln -sf $(REPO_ROOT)/bash/sbp $(XDG_CONFIG_HOME)/sbp; \
	ln -sf $(REPO_ROOT)/bash/blesh $(XDG_CONFIG_HOME)/blesh

.PHONY: configure-bat
configure-bat: $(XDG_CONFIG_HOME)/.created install-aqua ## Configure bat.
	@# bash \
	# NOTE: bat must be installed via aqua before running this so that it can \
	#       be used to build the cache. \
	# NOTE: this may run before aqua tools are available on the $PATH so we \
	#       need to refer to bat via the aqua root dir. \
	aqua_dir=$$(AQUA_ROOT_DIR= $(XDG_BIN_HOME)/aqua --config "$(HOME)/.aqua.yaml" root-dir); \
	mkdir -p "$$($${aqua_dir}/bin/bat --config-dir)/themes"; \
	ln -sf \
		$(REPO_ROOT)/nvim/pack/nvim/start/tokyonight.nvim/extras/sublime/tokyonight_moon.tmTheme \
		"$$($${aqua_dir}/bin/bat --config-dir)/themes/tokyonight_moon.tmTheme"; \
	"$${aqua_dir}/bin/bat" cache --build

.PHONY: configure-crictl
configure-crictl: $(XDG_CONFIG_HOME)/.created ## Configure crictl.
	@# bash \
	mkdir -p $(XDG_CONFIG_HOME)/crictl; \
	ln -sf $(REPO_ROOT)/crictl/crictl.yaml $(XDG_CONFIG_HOME)/crictl/crictl.yaml

.PHONY: configure-crontab
configure-crontab: install-bin ## Configure crontab.
	@# bash \
	( \
		echo '######################## MANAGED BY dotfiles; DO NOT EDIT ######################'; \
		echo "SHELL=$$(which bash)"; \
		echo ""; \
		cat cron/crontab; \
		echo ""; \
		for filename in ${HOME}/.config/dotfiles/cron.d/*; do \
			if [[ -r "$${filename}" ]]; then \
				echo "###### BEGIN FILE: $${filename} ######"; \
				echo ""; \
				cat "$${filename}"; \
				echo ""; \
				echo "###### END FILE: $${filename} ######"; \
				echo ""; \
			fi; \
		done; \
		echo '############################## END MANAGED SECTION #############################'; \
	) | crontab -

$(XDG_CONFIG_HOME)/efm-langserver/config.yaml: efm-langserver/config.yaml $(XDG_CONFIG_HOME)/.created
	@# bash \
	mkdir -p $(XDG_CONFIG_HOME)/efm-langserver; \
	sed 's|$${XDG_STATE_HOME}|'$(XDG_STATE_HOME)'|'< $< > $@

$(XDG_STATE_HOME)/efm-langserver/.created:
	@# bash \
	mkdir -p $(XDG_STATE_HOME)/efm-langserver; \
	touch $@

.PHONY: configure-efm-langserver
configure-efm-langserver: $(XDG_CONFIG_HOME)/efm-langserver/config.yaml $(XDG_STATE_HOME)/efm-langserver/.created ## Configure efm-langserver.

.PHONY: configure-git
configure-git: ## Configure git.
	@# bash \
	$(RM) -f $(HOME)/.gitconfig; \
	ln -sf "$(REPO_ROOT)/git/_gitconfig" $(HOME)/.gitconfig

.PHONY: configure-ghostty
configure-ghostty: $(XDG_CONFIG_HOME)/.created ## Configure Ghostty.
	@# bash \
	config_dir="$(XDG_CONFIG_HOME)/ghostty"; \
	if [ "$(kernel)" == "darwin" ]; then \
		config_dir="$(HOME)/Library/Application Support/com.mitchellh.ghostty"; \
		fonts_dir="$(HOME)/Library/Fonts"; \
		mkdir -p "$${fonts_dir}"; \
		cp third_party/fonts.google.com/RobotoMono/*.ttf "$${fonts_dir}/"; \
		cp third_party/fonts.google.com/Noto_Sans_JP/*.ttf "$${fonts_dir}/"; \
	fi; \
	mkdir -p "$${config_dir}"; \
	ln -sf $(REPO_ROOT)/ghostty/config "$${config_dir}/config"

.PHONY: configure-k9s
configure-k9s: $(XDG_CONFIG_HOME)/.created ## Configure k9s.
	@# bash \
	mkdir -p $(XDG_CONFIG_HOME)/k9s; \
	ln -sf $(REPO_ROOT)/k9s/config.yaml $(XDG_CONFIG_HOME)/k9s/config.yaml

.PHONY: configure-nix
configure-nix: $(XDG_CONFIG_HOME)/.created ## Configure nix.
	@# bash \
	mkdir -p $(XDG_CONFIG_HOME)/nix; \
	ln -sf $(REPO_ROOT)/nix/nix.conf $(XDG_CONFIG_HOME)/nix/nix.conf

.PHONY: configure-node
configure-node: ## Configure Node.js and npm.
	@# bash \
	ln -sf $(REPO_ROOT)/npm/_npmrc $(HOME)/.npmrc; \
	ln -sf $(REPO_ROOT)/.node-version $(HOME)/.node-version

# NOTE: nvim-treesitter install_dir must exist for it to be added to the Neovim
# runtimepath.
.PHONY: configure-nvim
configure-nvim: $(XDG_CONFIG_HOME)/.created $(XDG_DATA_HOME)/nvim/treesitter/.created ## Configure neovim.
	@# bash \
	$(RM) -rf $(XDG_CONFIG_HOME)/nvim; \
	ln -sf $(REPO_ROOT)/nvim $(XDG_CONFIG_HOME)/nvim

.PHONY: configure-python
configure-python: ## Configure Python.
	ln -sf "$(REPO_ROOT)/.python-version" "$(HOME)/.python-version"

.PHONY: configure-ruby
configure-ruby: ## Configure Ruby.
	ln -sf "$(REPO_ROOT)/.ruby-version" "$(HOME)/.ruby-version"

.PHONY: configure-ssh
configure-ssh: ## Configure ssh.
	@# bash \
	mkdir -p $(HOME)/.ssh/conf.d; \
 	chmod 0700 $(HOME)/.ssh $(HOME)/.ssh/conf.d; \
	ln -sf $(REPO_ROOT)/ssh/config $(HOME)/.ssh/config

.PHONY: configure-tmux
configure-tmux: ## Configure tmux.
	@# bash \
	$(RM) -f $(HOME)/.tmux.conf $(HOME)/.tmux; \
	ln -sf $(REPO_ROOT)/tmux/_tmux.conf $(HOME)/.tmux.conf; \
	ln -sf $(REPO_ROOT)/tmux/_tmux $(HOME)/.tmux

$(XDG_CONFIG_HOME)/yamllint/.created: $(XDG_CONFIG_HOME)/.created
	@# bash \
	mkdir -p $(XDG_CONFIG_HOME)/yamllint; \
	touch $@

$(XDG_CONFIG_HOME)/yamllint/config: yamllint/_config.yaml $(XDG_CONFIG_HOME)/yamllint/.created
	@# bash \
	ln -sf $(REPO_ROOT)/yamllint/_config.yaml $(XDG_CONFIG_HOME)/yamllint/config

$(XDG_CONFIG_HOME)/yamllint/config.kubernetes.yaml: yamllint/_config.kubernetes.yaml $(XDG_CONFIG_HOME)/yamllint/.created
	@# bash \
	sed 's|$${XDG_CONFIG_HOME}|'$(XDG_CONFIG_HOME)'|'< $< > $@

.PHONY: configure-yamllint
configure-yamllint: $(XDG_CONFIG_HOME)/yamllint/config $(XDG_CONFIG_HOME)/yamllint/config.kubernetes.yaml ## Configure yamllint.

$(XDG_CONFIG_HOME)/yamlfmt/.created: $(XDG_CONFIG_HOME)/.created
	@# bash \
	mkdir -p $(XDG_CONFIG_HOME)/yamlfmt; \
	touch $@

$(XDG_CONFIG_HOME)/yamlfmt/.yamlfmt.kubernetes.yaml: yamlfmt/_yamlfmt.kubernetes.yaml $(XDG_CONFIG_HOME)/yamlfmt/.created
	@# bash \
	ln -sf $(REPO_ROOT)/yamlfmt/_yamlfmt.kubernetes.yaml $(XDG_CONFIG_HOME)/yamlfmt/.yamlfmt.kubernetes.yaml

.PHONY: configure-yamlfmt
configure-yamlfmt: $(XDG_CONFIG_HOME)/yamlfmt/.yamlfmt.kubernetes.yaml ## Configure yamlfmt.

## Install Tools
#####################################################################

$(XDG_BIN_HOME)/slsa-verifier: $(XDG_BIN_HOME)/.created .
	@# bash \
	tempfile=$$($(MKTEMP) --suffix=".slsa-verifier-$(SLSA_VERIFIER_VERSION)"); \
	curl -sSLo "$${tempfile}" "$(SLSA_VERIFIER_URL)"; \
	echo "$(SLSA_VERIFIER_CHECKSUM)  $${tempfile}" | shasum -a 256 -c; \
	chmod +x "$${tempfile}"; \
	mv "$${tempfile}" $@

.PHONY: install-slsa-verifier
install-slsa-verifier: $(XDG_BIN_HOME)/slsa-verifier ## Install slsa-verifier

$(XDG_BIN_HOME)/cosign: $(XDG_BIN_HOME)/.created .
	@# bash \
	tempfile=$$($(MKTEMP) --suffix=".cosign-$(COSIGN_VERSION)"); \
	curl -sSLo "$${tempfile}" "$(COSIGN_URL)"; \
	echo "$(COSIGN_CHECKSUM)  $${tempfile}" | shasum -a 256 -c; \
	chmod +x "$${tempfile}"; \
	mv "$${tempfile}" $@

.PHONY: install-cosign
install-cosign: $(XDG_BIN_HOME)/cosign ## Install cosign

# NOTE: The go runtime is required to install some tools on some platforms.
.PHONY: install-aqua
install-aqua: $(XDG_DATA_HOME)/aquaproj-aqua/bin/aqua configure-aqua install-go ## Install aqua and aqua-managed CLI tools
	@# bash \
	# Unset AQUA_ROOT_DIR so it installs to the default global root dir. \
	PATH=$(HOME)/opt/go/bin:$(PATH) \
	AQUA_ROOT_DIR= \
		$(XDG_DATA_HOME)/aquaproj-aqua/bin/aqua \
			--config "$(HOME)/.aqua.yaml" \
			install

$(XDG_DATA_HOME)/aquaproj-aqua/bin/aqua: $(XDG_DATA_HOME)/.created
	@# bash \
	# Remove old aqua installations to avoid conflicts. \
	# $(RM) -rf $(HOME)/opt/aqua-*; \
	$(RM) -f $(XDG_BIN_HOME)/aqua
	# Explicitly set AQUA_ROOT_DIR to the default global root dir. \
	AQUA_ROOT_DIR="$(XDG_DATA_HOME)/aquaproj-aqua" \
		./.aqua-installer -v "$(AQUA_VERSION)"

## Language Runtimes
#####################################################################

.PHONY: install-go
install-go: $(HOME)/opt/go-$(GO_VERSION)/.installed ## Install the Go runtime.

$(HOME)/opt/go-$(GO_VERSION)/.installed: $(HOME)/opt/.created
	@# bash \
	tempfile=$$($(MKTEMP) --suffix=".tar.gz"); \
	curl -sSLo "$${tempfile}" "$(GO_URL)"; \
	echo "$(GO_CHECKSUM)  $${tempfile}" | sha256sum -c -; \
	cd $(HOME)/opt; \
	$(RM) -rf go; \
	tar xf "$${tempfile}"; \
	mv go go-$(GO_VERSION); \
	ln -s go-$(GO_VERSION) go; \
	$(HOME)/opt/go/bin/go env -w GOTOOLCHAIN=go$(GO_VERSION)+auto; \
	touch $@

.PHONY: install-node
install-node: $(XDG_DATA_HOME)/node_modules/.installed ## Install the Node.js environment.

# Installs nodenv
$(NODENV_ROOT)/.installed: versions.mk $(XDG_DATA_HOME)/.created
	@# bash \
	# TODO(#609): Update dependency on configure-node. \
	# Run this here rather than as a dependency to avoid unnecessary rebuilds. \
	$(MAKE) configure-node; \
	# Install nodenv. \
	if [[ -d $(NODENV_ROOT) ]]; then \
		git -C $(NODENV_ROOT) fetch origin "$(NODENV_INSTALL_SHA)"; \
		git -C $(NODENV_ROOT) checkout "$(NODENV_INSTALL_SHA)"; \
	else \
		git clone --branch "$(NODENV_INSTALL_VERSION)" https://github.com/nodenv/nodenv.git $(NODENV_ROOT); \
	fi; \
	nodenv_sha=$$(git -C $(NODENV_ROOT) rev-parse HEAD); \
	if [ "$${nodenv_sha}" != "$(NODENV_INSTALL_SHA)" ]; then \
		echo "Invalid nodenv: '$${nodenv_sha}' != '$(NODENV_INSTALL_SHA)'"; \
		$(RM) -rf $(NODENV_ROOT); \
		exit 1; \
	fi; \
	touch $@

# Installs node-build plugin for nodenv
$(NODENV_ROOT)/plugins/node-build/.installed: $(NODENV_ROOT)/.installed versions.mk
	@# bash \
	node_build_path="$(NODENV_ROOT)/plugins/node-build"; \
	if [[ -d "$${node_build_path}" ]]; then \
		git -C "$${node_build_path}" fetch origin "$(NODENV_BUILD_SHA)"; \
		git -C "$${node_build_path}" checkout "$(NODENV_BUILD_SHA)"; \
	else \
		git clone --branch "$(NODENV_BUILD_VERSION)" https://github.com/nodenv/node-build.git "$${node_build_path}"; \
	fi; \
	nodenv_build_sha=$$(git -C "$${node_build_path}" rev-parse HEAD); \
	if [ "$${nodenv_build_sha}" != "$(NODENV_BUILD_SHA)" ]; then \
		echo "Invalid node-build: '$${nodenv_build_sha}' != '$(NODENV_BUILD_SHA)'"; \
		$(RM) -rf "$${node_build_path}"; \
		exit 1; \
	fi; \
	touch $@

# Installs Node.js
$(NODENV_ROOT)/versions/$(NODE_VERSION)/.installed: .node-version $(NODENV_ROOT)/plugins/node-build/.installed
	@# bash \
	$(NODENV_ROOT)/bin/nodenv install --skip-existing; \
	touch $@

nodenv/package-lock.json: nodenv/package.json $(AQUA_ROOT_DIR)/.installed $(NODENV_ROOT)/versions/$(NODE_VERSION)/.installed
	@# bash \
	loglevel="notice"; \
	if [ -n "$(DEBUG_LOGGING)" ]; then \
		loglevel="verbose"; \
	fi; \
	# NOTE: npm install will happily ignore the fact that integrity hashes are \
	# missing in the package-lock.json. We need to check for missing integrity \
	# fields ourselves. If any are missing, then we need to regenerate the \
	# package-lock.json from scratch. \
	nointegrity=""; \
	noresolved=""; \
	if [ -f "$@" ]; then \
		nointegrity=$$(jq '.packages | del(."") | .[] | select(has("integrity") | not)' < $@); \
		noresolved=$$(jq '.packages | del(."") | .[] | select(has("resolved") | not)' < $@); \
	fi; \
	if [ ! -f "$@" ] || [ -n "$${nointegrity}" ] || [ -n "$${noresolved}" ]; then \
		# NOTE: package-lock.json is removed to ensure that npm includes the \
		# integrity field. npm install will not restore this field if \
		# missing in an existing package-lock.json file. \
		$(RM) -f $@; \
		# NOTE: We clean the node_modules directory to ensure that npm install \
		#       will not desync between the package.json, package-lock.json \
		#       and the node_modules directory. \
		$(RM) -rf nodenv/node_modules; \
		$(NODENV_ROOT)/shims/npm --loglevel="$${loglevel}" install \
			--prefix ./nodenv \
			--no-audit \
			--no-fund; \
	else \
		$(NODENV_ROOT)/shims/npm --loglevel="$${loglevel}" install \
			--prefix ./nodenv \
			--package-lock-only \
			--no-audit \
			--no-fund; \
	fi

# Installs tools in the user node_modules.
$(XDG_DATA_HOME)/node_modules/.installed: $(NODENV_ROOT)/versions/$(NODE_VERSION)/.installed $(XDG_DATA_HOME)/.created | nodenv/package-lock.json
	@# bash \
	loglevel="silent"; \
	if [ -n "$(DEBUG_LOGGING)" ]; then \
		loglevel="verbose"; \
	fi; \
	cd $(REPO_ROOT)/nodenv; \
	$(NODENV_ROOT)/shims/npm --loglevel="$${loglevel}" clean-install; \
	$(NODENV_ROOT)/shims/npm --loglevel="$${loglevel}" audit signatures; \
	$(RM) -f $(XDG_DATA_HOME)/node_modules; \
	ln -sf $(REPO_ROOT)/nodenv/node_modules $(XDG_DATA_HOME)/node_modules; \
	touch $@

.PHONY: install-python
install-python: $(PYENV_ROOT)/versions/$(PYTHON_VERSION)/.installed ## Install the Python environment.

# Installs pyenv
$(PYENV_ROOT)/.installed: versions.mk $(XDG_DATA_HOME)/.created
	@# bash \
	# TODO(#609): Update dependency on configure-python. \
	# Run this here rather than as a dependency to avoid unnecessary rebuilds. \
	$(MAKE) configure-python; \
	# Install pyenv. \
	if [[ -d $(PYENV_ROOT) ]]; then \
		git -C $(PYENV_ROOT) fetch origin "$(PYENV_INSTALL_SHA)"; \
		git -C $(PYENV_ROOT) checkout "$(PYENV_INSTALL_SHA)"; \
	else \
		git clone --branch "$(PYENV_INSTALL_VERSION)" https://github.com/pyenv/pyenv.git $(PYENV_ROOT); \
	fi; \
	pyenv_sha=$$(git -C $(PYENV_ROOT) rev-parse HEAD); \
	if [ "$${pyenv_sha}" != "$(PYENV_INSTALL_SHA)" ]; then \
		echo "Invalid pyenv: '$${pyenv_sha}' != '$(PYENV_INSTALL_SHA)'"; \
		$(RM) -rf $(PYENV_ROOT); \
		exit 1; \
	fi; \
	touch $@

# Installs pyenv-virtualenv plugin for pyenv
$(PYENV_ROOT)/plugins/pyenv-virtualenv/.installed: $(PYENV_ROOT)/.installed versions.mk
	@# bash \
	pyenv_virtualenv_path="$(PYENV_ROOT)/plugins/pyenv-virtualenv"; \
	if [[ -d "$${pyenv_virtualenv_path}" ]]; then \
		git -C "$${pyenv_virtualenv_path}" fetch origin "$(PYENV_VIRTUALENV_SHA)"; \
		git -C "$${pyenv_virtualenv_path}" checkout "$(PYENV_VIRTUALENV_SHA)"; \
	else \
		git clone --branch "$(PYENV_VIRTUALENV_VERSION)" https://github.com/pyenv/pyenv-virtualenv.git "$${pyenv_virtualenv_path}"; \
	fi; \
	pyenv_virtualenv_sha=$$(git -C "$${pyenv_virtualenv_path}" rev-parse HEAD); \
	if [ "$${pyenv_virtualenv_sha}" != "$(PYENV_VIRTUALENV_SHA)" ]; then \
		echo "Invalid pyenv-virtualenv: '$${pyenv_virtualenv_sha}' != '$(PYENV_VIRTUALENV_SHA)'"; \
		$(RM) -rf "$${pyenv_virtualenv_path}"; \
		exit 1; \
	fi; \
	touch $@

# Installs Python
$(PYENV_ROOT)/versions/$(PYTHON_VERSION)/.python-installed: .python-version $(PYENV_ROOT)/plugins/pyenv-virtualenv/.installed
	@# bash \
	$(PYENV_ROOT)/bin/pyenv install --skip-existing; \
	touch $@

# Installs Python tools in the pyenv virtualenv for the current version.
$(PYENV_ROOT)/versions/$(PYTHON_VERSION)/.installed: requirements-dev.txt $(PYENV_ROOT)/versions/$(PYTHON_VERSION)/.python-installed
	@# bash \
	# Install uv \
	$(PYENV_ROOT)/versions/$(PYTHON_VERSION)/bin/pip install -r $< --require-hashes; \
	# Install other packages \
	$(PYENV_ROOT)/versions/$(PYTHON_VERSION)/bin/uv pip install --python "$(PYENV_ROOT)/versions/$(PYTHON_VERSION)/" .; \
	$(PYENV_ROOT)/bin/pyenv rehash; \
	touch $@

# Installs Ruby
.PHONY: install-ruby
install-ruby: $(RBENV_ROOT)/versions/$(RUBY_VERSION)/.installed ## Install the Ruby environment.

# Installs rbenv
$(RBENV_ROOT)/.installed: versions.mk $(XDG_DATA_HOME)/.created
	@# bash \
	# TODO(#609): Update dependency on configure-ruby. \
	# Run this here rather than as a dependency to avoid unnecessary rebuilds. \
	$(MAKE) configure-ruby; \
	# Install rbenv. \
	if [[ -d $(RBENV_ROOT) ]]; then \
		git -C $(RBENV_ROOT) fetch origin "$(RBENV_INSTALL_SHA)"; \
		git -C $(RBENV_ROOT) checkout "$(RBENV_INSTALL_SHA)"; \
	else \
		git clone --branch "$(RBENV_INSTALL_VERSION)" https://github.com/rbenv/rbenv.git $(RBENV_ROOT); \
	fi; \
	rbenv_sha=$$(git -C $(RBENV_ROOT) rev-parse HEAD); \
	if [ "$${rbenv_sha}" != "$(RBENV_INSTALL_SHA)" ]; then \
		echo "Invalid rbenv: '$${rbenv_sha}' != '$(RBENV_INSTALL_SHA)'"; \
		$(RM) -rf $(RBENV_ROOT); \
		exit 1; \
	fi; \
	touch $@

# Installs ruby-build plugin for rbenv
$(RBENV_ROOT)/plugins/ruby-build/.installed: $(RBENV_ROOT)/.installed versions.mk
	@# bash \
	ruby_build_path="$(RBENV_ROOT)/plugins/ruby-build"; \
	if [[ -d "$${ruby_build_path}" ]]; then \
		git -C "$${ruby_build_path}" fetch origin "$(RBENV_BUILD_SHA)"; \
		git -C "$${ruby_build_path}" checkout "$(RBENV_BUILD_SHA)"; \
	else \
		git clone --branch "$(RBENV_BUILD_VERSION)" https://github.com/rbenv/ruby-build.git "$${ruby_build_path}"; \
	fi; \
	rbenv_build_sha=$$(git -C "$${ruby_build_path}" rev-parse HEAD); \
	if [ "$${rbenv_build_sha}" != "$(RBENV_BUILD_SHA)" ]; then \
		echo "Invalid ruby-build: '$${rbenv_build_sha}' != '$(RBENV_BUILD_SHA)'"; \
		$(RM) -rf "$${ruby_build_path}"; \
		exit 1; \
	fi; \
	touch $@

# Installs Ruby
$(RBENV_ROOT)/versions/$(RUBY_VERSION)/.installed: .ruby-version $(RBENV_ROOT)/plugins/ruby-build/.installed
	@# bash \
	$(RBENV_ROOT)/bin/rbenv install --skip-existing; \
	touch $@

## Maintenance
#####################################################################

.PHONY: update-lockfiles
update-lockfiles: .aqua-checksums.json package-lock.json uv.lock aqua-installer aqua/aqua-checksums.json nodenv/package-lock.json ## Update lockfiles.

.PHONY: todos
todos: $(AQUA_ROOT_DIR)/.installed ## Print outstanding TODOs.
	@# bash \
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

.PHONY: clean-node-modules
clean-node-modules:
	@$(RM) -r node_modules

.PHONY: clean
clean: clean-node-modules ## Delete temporary files.
	@$(RM) -r .bin
	@$(RM) -r $(AQUA_ROOT_DIR)
	@$(RM) -r .venv
	@$(RM) -r .uv
	@$(RM) *.sarif.json
	@$(RM) nvim-checkhealth.log
