#!/usr/bin/env bash
# vim: set ft=bash:
#
# Copyright 2025 Ian Lewis
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

# clone will clone a git repository from GitHub into a base directory with the
# directory structure `<base>/<owner>/<repo>`. This synchronizes well with
# `tmux-sessionizer` and it's search function.

set -euo pipefail

function _validate_repo_id() {
    local repo_id="$1"

    # Validate the repository ID format.
    if [[ ! ${repo_id} =~ ^[a-zA-Z0-9._-]+(/[a-zA-Z0-9._-]+)?$ ]]; then
        echo "$(basename "${0}"): ERROR: Invalid repository '${repo_id}'. Must be in the format of <owner>/<repo> or <repo>." >&2
        exit 1
    fi
}

function _clone() {
    # These variables are used by the argsparse library.
    local program_params
    local program_options
    local argsparse_usage_description

    # shellcheck source=/dev/null
    . "${HOME}/.local/share/bash/lib/gnu-getopt/gnu-getopt.sh"

    ARGSPARSE_GNU_GETOPT="${ARGSPARSE_GNU_GETOPT:-$(get_gnu_getopt_or_error)}"

    # shellcheck source=/dev/null
    . "${HOME}/.local/share/bash/lib/bash-argsparse/argsparse.sh"

    argsparse_use_option "dir" "Project source directory." "value" "default:${HOME}/src" "short:d" "type:directory"

    # New repository options.
    argsparse_use_option "new" "Create and clone new repository." "short:n" "exclude:fork"
    argsparse_use_option "gitignore" "Specify a gitignore template for the new repository." "value" "short:g" "require:new"
    argsparse_use_option "license" "Specify an Open Source License for the new repository." "value" "short:l" "require:new"
    argsparse_use_option "add-readme" "Add a README file to the new repository." "require:new"
    argsparse_use_option "template" "Create a new repository from template." "value" "short:p" "require:new"
    argsparse_use_option "private" "Make the new repository private." "require:new"

    # Options for creating a new fork.
    argsparse_use_option "fork" "Fork and clone a repository." "short:f" "exclude:new"
    argsparse_use_option "fork-name" "" "value" "require:fork"

    # --new or --fork is required.
    argsparse_use_option "private" "Make the new repository or fork private." "require:new"

    # Command is optional and could contain many parts.
    argsparse_describe_parameters "REPOSITORY"

    # Repository name is required.
    argsparse_allow_no_argument "false"

    # shellcheck disable=SC2034 # Used by argsparse.
    argsparse_usage_description="Clone a GitHub repository."

    # Command line parsing is done here.
    argsparse_parse_options "$@"

    local repo_id
    local owner
    local login_name
    local repo_name
    local dest

    repo_id="${program_params[0]}"

    _validate_repo_id "${repo_id}"

    owner="${repo_id%%/*}"
    repo_name="${repo_id##*/}"

    # Check that the GitHub CLI is installed.
    if ! command -v gh >/dev/null 2>&1; then
        echo "$(basename "${0}"): ERROR: GitHub CLI is not installed." >&2
        exit 1
    fi

    # Check if the user is authenticated with GitHub CLI.
    # NOTE: If not authenticated gh repo clone might check out the repository
    # using HTTPS which would make you unable to push.
    if ! login_name=$(gh auth status --json hosts | jq -r '.hosts."github.com"[0].login'); then
        echo "$(basename "${0}"): ERROR: You are not logged into any GitHub hosts. To log in, set the GH_TOKEN environment variable or run: gh auth login." >&2
        exit 1
    fi

    # Create the repository if requested.
    if argsparse_is_option_set "new"; then
        local create_command

        create_command=(gh repo create "${repo_id}")

        if argsparse_is_option_set "private"; then
            create_command+=("--private")
        else
            create_command+=("--public")
        fi

        if argsparse_is_option_set "add-readme"; then
            create_command+=("--add-readme")
        fi

        if argsparse_is_option_set "gitignore"; then
            create_command+=("--gitignore" "${program_options['gitignore']}")
        fi

        if argsparse_is_option_set "license"; then
            create_command+=("--license" "${program_options['license']}")
        fi

        if argsparse_is_option_set "template"; then
            create_command+=("--template" "${program_options['template']}")
        fi

        "${create_command[@]}"
    fi

    # Fork the repository if requested.
    if argsparse_is_option_set "fork"; then
        local fork_command
        local fork_owner
        local fork_repo_name

        fork_command=(gh repo fork "${repo_id}" "--clone=false")

        if argsparse_is_option_set "fork-name"; then
            _validate_repo_id "${program_options['fork-name']}"

            fork_owner="${program_options['fork-name']%%/*}"
            fork_repo_name="${program_options['fork-name']##*/}"

            # If the values are the same then the user only specified the fork
            # repository name. We will assume the fork owner is the same as the
            # login name.
            if [ "${fork_owner}" == "${fork_repo_name}" ]; then
                fork_owner="${login_name}"
            fi

            fork_command+=("--fork-name" "${fork_repo_name}")
            if [ "${fork_owner}" != "${login_name}" ]; then
                fork_command+=("--org" "${fork_owner}")
            fi
        else
            fork_owner="${login_name}"
            fork_repo_name="${repo_name}"
        fi

        "${fork_command[@]}"

        owner="${fork_owner}"
        repo_name="${fork_repo_name}"
    fi

    # Clone the repository.
    dest="${program_options['dir']}/${owner}/${repo_name}"

    if [ -e "${dest}" ]; then
        echo "$(basename "${0}"): ERROR: ${dest} already exists." >&2
        exit 1
    fi

    gh repo clone \
        "${owner}/${repo_name}" \
        "${dest}" \
        -- \
        --recursive
}

_clone "$@"
