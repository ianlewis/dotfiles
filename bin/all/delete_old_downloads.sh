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

# Explicitly specify the directories for safety.
DIRS="$HOME/tmp/ $HOME/Downloads/"

DAYS=${1:-""}

if [ "$DAYS" = "" ]; then
    DAYS=14
fi

for DIR in $DIRS; do
    if [ -d "$DIR" ]; then
        # Delete old files
        find "$DIR" -type f -mtime +"$DAYS" -delete

        # Delete old symbolic links
        find "$DIR" -type l -mtime +"$DAYS" -delete

        # Delete empty directories
        find "$DIR" -type d -empty -delete
    fi

    # Finally make sure the directory itself exists
    mkdir -p "$DIR"
done
