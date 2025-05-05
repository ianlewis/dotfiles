#!/usr/bin/env bash
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

# Adds public certs from Github to authorized_keys
mkdir -p "${HOME}/.ssh"
if [ ! -f "${HOME}/.ssh/authorized_keys" ]; then
    touch "${HOME}/.ssh/authorized_keys"
fi

# Only update authorized_keys if we can contact github. We want
# to avoid writing an empty authorized_keys file if github.com is
# inaccessible.
TEMPFILE=$(mktemp)
if curl -s https://github.com/ianlewis.keys >"${TEMPFILE}"; then
    cat "${TEMPFILE}" >"${HOME}/.ssh/authorized_keys"
fi

# Adds local authorized_keys if not already there
if [ -f "${HOME}/.ssh/authorized_keys.local" ]; then
    while read -r key; do
        grep -qF "$key" "${HOME}/.ssh/authorized_keys" || echo "$key" >>"${HOME}/.ssh/authorized_keys"
    done <"${HOME}/.ssh/authorized_keys.local"
fi
