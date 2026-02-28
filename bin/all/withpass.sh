#!/usr/bin/env bash
# vim: set ft=bash:
#
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

set -euo pipefail

# withpass reads a password from stdin and saves it to the given environment
# variable name. The password is not echoed to the terminal, and the environment
# variable is only set for the duration of the command that is run with the
# password as an environment variable. The password is not stored in the shell
# history or in the environment of the shell after the command is run.

function _main() {
    # These variables are used by the argsparse library.
    local program_params
    local argsparse_usage_description

    # shellcheck source=/dev/null
    . "${HOME}/.local/share/bash/lib/gnu-getopt/gnu-getopt.sh"

    ARGSPARSE_GNU_GETOPT="${ARGSPARSE_GNU_GETOPT:-$(get_gnu_getopt_or_error)}"

    # shellcheck source=/dev/null
    . "${HOME}/.local/share/bash/lib/bash-argsparse/argsparse.sh"

    # Command is optional and could contain many parts.
    argsparse_describe_parameters "ENV_VAR COMMAND*"

    # shellcheck disable=SC2034 # Used by argsparse.
    argsparse_usage_description="Read password and pass it to the command as an environment variable."

    # Command line parsing is done here.
    argsparse_parse_options "$@"

    local varname="${program_params[0]}"
    local cmd=("${program_params[@]:1}")

    read -r -s -p "$varname: " "${varname?}"
    echo

    export "${varname?}"
    "${cmd[@]}"
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    _main "$@"
fi
