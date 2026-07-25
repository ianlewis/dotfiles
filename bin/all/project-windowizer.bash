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

# project-windowizer splits the current tmux window into two panes. The left
# pane is sized to 80 columns by default. The right pane is size to fill the
# rest of the window and runs the command provided as an argument. If no command
# is provided, it defaults to running `nvim`.

function _main() {
    # These variables are used by the argsparse library.
    local program_params
    local program_options
    local argsparse_usage_description

    # shellcheck source=/dev/null
    . "${HOME}/.local/share/bash/lib/gnu-getopt/gnu-getopt.sh"

    ARGSPARSE_GNU_GETOPT="${ARGSPARSE_GNU_GETOPT:-$(get_gnu_getopt_or_error)}"

    # shellcheck source=/dev/null
    . "${HOME}/.local/share/bash/lib/bash-argsparse/argsparse.sh"

    argsparse_use_option "width" "Width of the left pane." "value" "default:80" "short:w" "type:uint"

    # Command is optional and could contain many parts.
    argsparse_describe_parameters "COMMAND*"

    # Options are not required.
    argsparse_allow_no_argument "true"

    # shellcheck disable=SC2034 # Used by argsparse.
    argsparse_usage_description="Split the current tmux window."

    # Command line parsing is done here.
    argsparse_parse_options "$@"

    if ! command -v tmux >/dev/null 2>&1; then
        echo "${0}: ERROR: this script requires tmux." >&2
        return 1
    fi

    if [[ -z ${TMUX+x} ]]; then
        echo "${0}: ERROR: this script requires tmux to be running." >&2
        return 1
    fi

    local pw_cmd=("${program_params[@]:-"nvim"}")

    # Calculate the new size by subtracting width + 1 columns from the current
    # window width. This leaves `width` columns for the left pane and 1 column
    # for the separator.
    local left_pane_width=$((program_options["width"] + 1))
    local tmux_window_width
    tmux_window_width=$(tmux display-message -p "#{window_width}")
    local new_window_size=$((tmux_window_width - left_pane_width))

    # Run the command in the right pane, defaulting to `nvim`.
    # First we run bash with --norc and --noprofile to change directory to the
    # current directory. This is done to preserve the path with symlinks. Using
    # tmux -c will resolve the path and lose the symlinks.
    #
    # Then we exec bash to replace the current process with a new interactive
    # bash that will run the full bash environment (e.g. .bashrc etc.).
    local pwd_escaped
    printf -v pwd_escaped "%q" "${PWD}"
    local sub_cmd="bash -i -c '${pw_cmd[*]}'"
    # If the user explicitly passed "bash" as the first argument, run bash with
    # their chosen arguments directly instead of wrapping it in another bash
    # shell.
    if [[ ${program_params[0]:-""} == "bash" ]]; then
        sub_cmd="${program_params[*]}"
    fi
    local full_cmd="bash --norc --noprofile -c \"cd -- ${pwd_escaped} && exec ${sub_cmd}\""

    tmux split-window -hd -l "${new_window_size}" "${full_cmd}"

    # clear the left window
    clear
}

_main "$@"
