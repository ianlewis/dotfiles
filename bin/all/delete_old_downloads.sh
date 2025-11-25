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

# A simple script to clean up files from a list of temporary directories.

set -euo pipefail

function _main() {
    local dirs
    local days

    # Explicitly specify the directories for safety.
    dirs="$HOME/tmp/ $HOME/Downloads/"

    days=${1:-""}

    if [ "${days}" = "" ]; then
        days=14
    fi

    for d in ${dirs}; do
        if [ -d "${d}" ]; then
            # Delete old files
            find "${d}" -type f -mtime +"${days}" -delete

            # Delete old symbolic links
            find "${d}" -type l -mtime +"${days}" -delete

            # Delete empty directories
            find "${d}" -type d -empty -delete
        fi
    done
}

_main "$@"
