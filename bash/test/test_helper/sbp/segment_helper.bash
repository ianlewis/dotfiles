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

source_segment() {
    local base_path
    base_path="$(cd "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")")" >/dev/null 2>&1 && pwd)"
    local segment_name="${1}"

    local segment_source="${base_path}/bash/lib/sbp/src/segments/${segment_name}.bash"
    if [[ ! -f ${segment_source} ]]; then
        segment_source="${base_path}/bash/sbp/segments/${segment_name}.bash"
        if [[ ! -f ${segment_source} ]]; then
            echo >&2 "Could not find segment ${segment_name}"
            return 1
        fi
    fi

    # shellcheck disable=SC1090
    source "${segment_source}"
}

execute_segment() {
    local segment_name="${1}"
    source_segment "${segment_name}"
    "segments::${segment_name}"
}

print_themed_segment() {
    for argument in "${@}"; do
        [[ -z $argument ]] && continue
        printf '%s\n' "$argument"
    done
}

export -f print_themed_segment
