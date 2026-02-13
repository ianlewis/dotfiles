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

@test ".config/ghostty is linked correctly" {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        assert_symlink_to "${BASE_PATH}/ghostty/config" "${E2E_HOME}/Library/Application Support/com.mitchellh.ghostty/config"
    else
        assert_symlink_to "${BASE_PATH}/ghostty/config" "${E2E_HOME}/.config/ghostty/config"
    fi
}

@test "fonts are installed correctly" {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        skip "fonts not installed on non-Darwin system"
    fi

    assert_file_exists "${E2E_HOME}/Library/Fonts/NotoSansJP-VariableFont_wght.ttf"
    assert_file_exists "${E2E_HOME}/Library/Fonts/RobotoMonoNerdFontMono-Regular.ttf"
    assert_file_exists "${E2E_HOME}/Library/Fonts/RobotoMonoNerdFontMono-Italic.ttf"
    assert_file_exists "${E2E_HOME}/Library/Fonts/RobotoMonoNerdFontMono-Bold.ttf"
    assert_file_exists "${E2E_HOME}/Library/Fonts/RobotoMonoNerdFontMono-BoldItalic.ttf"
    assert_file_exists "${E2E_HOME}/Library/Fonts/RobotoMonoNerdFontMono-Medium.ttf"
    assert_file_exists "${E2E_HOME}/Library/Fonts/RobotoMonoNerdFontMono-MediumItalic.ttf"
}
