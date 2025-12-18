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

setup() {
    E2E_HOME="${E2E_HOME:-${HOME}}"
    BASE_PATH="$(cd "$(dirname "$(dirname "$(dirname "$(dirname "${BATS_TEST_FILENAME}")")")")" >/dev/null 2>&1 && pwd)"

    load "${BASE_PATH}/bash/test/test_helper/bats-support/load"
    load "${BASE_PATH}/bash/test/test_helper/bats-assert/load"
    load "${BASE_PATH}/bash/test/test_helper/bats-file/load"
}

@test ".ruby-version linked correctly" {
    assert_equal "${BASE_PATH}/.ruby-version" "$(readlink "${E2E_HOME}/.ruby-version")"
}

@test "rbenv is installed" {
    assert_file_executable "${E2E_HOME}/.local/share/rbenv/bin/rbenv"
    assert_file_executable "${E2E_HOME}/.local/share/rbenv/shims/ruby"
    assert_dir_exists "${E2E_HOME}/.local/share/rbenv/plugins/ruby-build"
}
