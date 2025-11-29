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

@test ".bashrc is linked correctly" {
    assert_symlink_to "${BASE_PATH}/bash/_bashrc" "${E2E_HOME}/.bashrc"
}

@test ".profile is linked correctly" {
    assert_symlink_to "${BASE_PATH}/bash/_profile" "${E2E_HOME}/.profile"
}

@test ".bash_completion is linked correctly" {
    assert_symlink_to "${BASE_PATH}/bash/_bash_completion" "${E2E_HOME}/.bash_completion"
}

@test ".bash_aliases is linked correctly" {
    assert_symlink_to "${BASE_PATH}/bash/_bash_aliases" "${E2E_HOME}/.bash_aliases"
}

@test ".bash_profile is linked correctly" {
    assert_symlink_to "${BASE_PATH}/bash/_bash_profile" "${E2E_HOME}/.bash_profile"
}

@test ".bash_logout is linked correctly" {
    assert_symlink_to "${BASE_PATH}/bash/_bash_logout" "${E2E_HOME}/.bash_logout"
}

@test ".inputrc is linked correctly" {
    assert_symlink_to "${BASE_PATH}/bash/_inputrc" "${E2E_HOME}/.inputrc"
}

@test "bash lib directory is linked correctly" {
    assert_symlink_to "${BASE_PATH}/bash/lib" "${E2E_HOME}/.local/share/bash/lib"
}

@test "sbp config directory is linked correctly" {
    assert_symlink_to "${BASE_PATH}/bash/sbp" "${E2E_HOME}/.config/sbp"
}
