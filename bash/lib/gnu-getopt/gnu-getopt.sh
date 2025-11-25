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

# get_gnu_getopt prints the path to the GNU getopt binary if available.
# It first checks if the ARGSPARSE_GNU_GETOPT environment variable is set and
# uses that value if present. On macOS systems, it attempts to locate the
# GNU getopt installed via Homebrew.
#
# Exit Codes:
#   0 - GNU getopt path found and printed
#   1 - Homebrew is not installed (on macOS)
#   2 - gnu-getopt is not installed (on macOS)
#   3 - gnu-getopt is not installed (non-macOS)
function get_gnu_getopt() {
    if [[ ${ARGSPARSE_GNU_GETOPT:-} != "" ]]; then
        echo "${ARGSPARSE_GNU_GETOPT}"
        return 0
    fi

    local gnu_getopt_path

    if [[ "$(uname -s)" == "Darwin" ]]; then
        if ! command -v brew >/dev/null 2>&1; then
            return 1
        fi

        if ! gnu_getopt_path=$(brew --prefix gnu-getopt 2>/dev/null); then
            return 2
        fi

        if [[ ! -x "${gnu_getopt_path}/bin/getopt" ]]; then
            return 2
        fi
        gnu_getopt_path="${gnu_getopt_path}/bin/getopt"
    else
        if ! gnu_getopt_path=$(command -v getopt); then
            return 3
        fi
    fi

    echo "${gnu_getopt_path}"
    return 0
}

# get_gnu_getopt_or_error prints the path to the GNU getopt binary if available.
# If not available, it prints an error message to stderr and suggests installing
# it via Homebrew on macOS.
#
# Exit Codes:
#   0 - GNU getopt path found and printed
#   1 - Homebrew is not installed (on macOS)
#   2 - gnu-getopt is not installed.
function get_gnu_getopt_or_error() {
    local getopt_path
    local get_gnu_getopt_ret

    if getopt_path=$(get_gnu_getopt); then
        echo "${getopt_path}"
    else
        get_gnu_getopt_ret="$?"
        echo "${0}: GNU getopt is required" >&2
        if [[ ${get_gnu_getopt_ret} -eq 1 ]]; then
            echo "${0}: install Homebrew from https://brew.sh/" >&2
            echo "${0}: then install gnu-getopt with Homebrew: brew install gnu-getopt" >&2
        elif [[ ${get_gnu_getopt_ret} -eq 2 ]]; then
            echo "${0}: install it with Homebrew: brew install gnu-getopt" >&2
        fi
        return "${get_gnu_getopt_ret}"
    fi
}
