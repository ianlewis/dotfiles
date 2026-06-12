#!/usr/bin/env bash
# vim: set ft=bash:
#
# Copyright 2026 Ian Lewis
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

# randstr will generate a random string of a specified length. By default, it
# generates an 16 character encoded base64 url-safe string using /dev/urandom.

set -euo pipefail

function _randstr() {
    # These variables are used by the argsparse library.
    local program_options
    local argsparse_usage_description

    # shellcheck source=/dev/null
    . "${HOME}/.local/share/bash/lib/gnu-getopt/gnu-getopt.sh"

    ARGSPARSE_GNU_GETOPT="${ARGSPARSE_GNU_GETOPT:-$(get_gnu_getopt_or_error)}"

    # shellcheck source=/dev/null
    . "${HOME}/.local/share/bash/lib/bash-argsparse/argsparse.sh"

    argsparse_use_option "length" "Length of the generated string." "value" "default:16" "short:l" "type:uint"
    argsparse_use_option "pattern" "Pattern for characters to include." "value" "default:A-Za-z0-9" "short:p"
    argsparse_use_option "exclude-newline" "Do not output a trailing newline." "short:n"

    argsparse_allow_no_argument "true"

    # shellcheck disable=SC2034 # Used by argsparse.
    argsparse_usage_description="Generate a random string."

    # Command line parsing is done here.
    argsparse_parse_options "$@"

    local length="${program_options['length']}"
    local pattern="${program_options['pattern']}"

    head -c "${length}" <(tr -dc "${pattern}" </dev/urandom)
    if [[ -z ${program_options['exclude-newline']:-} ]]; then
        echo
    fi
}

_randstr "$@"
