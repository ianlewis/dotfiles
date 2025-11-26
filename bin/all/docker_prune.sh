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

set -euo pipefail

function _main() {
    # These variables are used by the argsparse library.
    local program_options
    local argsparse_usage_description

    # shellcheck source=/dev/null
    . "${HOME}/.local/share/bash/lib/gnu-getopt/gnu-getopt.sh"

    ARGSPARSE_GNU_GETOPT="${ARGSPARSE_GNU_GETOPT:-$(get_gnu_getopt_or_error)}"

    # shellcheck source=/dev/null
    . "${HOME}/.local/share/bash/lib/bash-argsparse/argsparse.sh"

    argsparse_use_option "container-until" "Remove containers older than duration" "value" "default:160h" "type:string"
    argsparse_use_option "image-until" "Remove images older than duration" "value" "default:720h" "type:string"

    # shellcheck disable=SC2034 # Used by argsparse.
    argsparse_usage_description="Remove unused Docker data."

    # Options are not required (there are none).
    argsparse_allow_no_argument "true"

    # Command line parsing is done here.
    argsparse_parse_options "$@"

    if ! command -v docker >/dev/null 2>&1; then
        # Docker is not installed. Exiting.
        # NOTE: no output is made to stdout/stderr so that cron jobs remain
        #       silent. i.e. no docker == nothing to do.
        return 0
    fi

    local container_duration
    local image_duration

    container_duration=${1:-${program_options['container-until']}}
    image_duration=${2:-${program_options['image-until']}}

    # Prune unused Docker containers
    echo "Pruning Docker containers older than ${container_duration}..."
    docker container prune \
        --force \
        --filter "until=${container_duration}"

    # Delete all unused Docker images (not just hanging images).
    echo "Pruning Docker images older than ${image_duration}..."
    docker image prune \
        --all \
        --force \
        --filter "until=${image_duration}"

    # Delete all unused Docker volumes (not just anonymous volumes).
    echo "Pruning all unused Docker volumes..."
    docker volume prune \
        --all \
        --force
}

_main "$@"
