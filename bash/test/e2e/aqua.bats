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

@test "aqua is installed correctly" {
    assert [ -n "${AQUA_VERSION}" ]
    assert_symlink_to "${E2E_HOME}/opt/aqua-${AQUA_VERSION}/aqua" "${E2E_HOME}/.local/bin/aqua"
}

@test "aqua configured correctly" {
    assert_symlink_to "${BASE_PATH}/aqua/aqua.yaml" "${E2E_HOME}/.aqua.yaml"
    assert_symlink_to "${BASE_PATH}/aqua/aqua-checksums.json" "${E2E_HOME}/.aqua-checksums.json"
}

@test "aqua root created" {
    assert_dir_exists "${E2E_HOME}/.local/share/aquaproj-aqua/pkgs"
}

@test "buf installed correctly" {
    assert_symlink_to \
        "${E2E_HOME}/.local/share/aquaproj-aqua/bin/buf" \
        "${E2E_HOME}/.local/share/aquaproj-aqua/aqua-proxy"
}

@test "dysk installed correctly" {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        skip "dysk not installed on Darwin system"
    fi

    assert_symlink_to \
        "${E2E_HOME}/.local/share/aquaproj-aqua/bin/dysk" \
        "${E2E_HOME}/.local/share/aquaproj-aqua/aqua-proxy"
}

@test "goimports installed correctly" {
    assert_symlink_to \
        "${E2E_HOME}/.local/share/aquaproj-aqua/bin/goimports" \
        "${E2E_HOME}/.local/share/aquaproj-aqua/aqua-proxy"
}

@test "gci installed correctly" {
    assert_symlink_to \
        "${E2E_HOME}/.local/share/aquaproj-aqua/bin/gci" \
        "${E2E_HOME}/.local/share/aquaproj-aqua/aqua-proxy"
}
