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

@test "slsa-verifier is installed correctly" {
    assert_file_executable "${E2E_HOME}/.local/bin/slsa-verifier"
}

@test "opencode is installed correctly" {
    assert_file_executable "${E2E_HOME}/.local/bin/opencode"
}

@test "claude is installed correctly" {
    assert_file_executable "${E2E_HOME}/.local/bin/claude"
}

@test "scripts are installed correctly" {
    assert_symlink_to "${BASE_PATH}/bin/all/delete_old_downloads.sh" "${E2E_HOME}/.local/bin/delete_old_downloads.sh"
    assert_symlink_to "${BASE_PATH}/bin/all/docker_prune.sh" "${E2E_HOME}/.local/bin/docker_prune.sh"
    assert_symlink_to "${BASE_PATH}/bin/all/update_authorized_keys.sh" "${E2E_HOME}/.local/bin/update_authorized_keys.sh"
    assert_symlink_to "${BASE_PATH}/bin/all/clone" "${E2E_HOME}/.local/bin/clone"
    assert_symlink_to "${BASE_PATH}/bin/all/tmux-sessionizer" "${E2E_HOME}/.local/bin/tmux-sessionizer"
    assert_symlink_to "${BASE_PATH}/bin/all/project-windowizer" "${E2E_HOME}/.local/bin/project-windowizer"
}
