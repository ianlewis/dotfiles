#!/usr/bin/env bats
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

setup() {
    BASE_PATH="$(cd "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "${BATS_TEST_FILENAME}")")")")")" >/dev/null 2>&1 && pwd)"

    load "${BASE_PATH}/bash/test/test_helper/bats-support/load"
    load "${BASE_PATH}/bash/test/test_helper/bats-assert/load"
    load "${BASE_PATH}/bash/test/test_helper/sbp/load"
}

@test "test a normal path_cwd segment" {
    cd "${BATS_TEST_TMPDIR}"
    mapfile -t result <<<"$(execute_segment "path_cwd")"

    # The # of arguments should be 2, the segment type and the base directory
    # name.
    assert_equal "${#result[@]}" 2
    assert_equal "${result[0]}" 'normal'
    assert_equal "${result[1]}" "$(basename "${BATS_TEST_TMPDIR}")"
}
