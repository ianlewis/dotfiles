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
    BASE_PATH="$(cd "$(dirname "$(dirname "$(dirname "$(dirname "${BATS_TEST_FILENAME}")")")")" >/dev/null 2>&1 && pwd)"

    load "${BASE_PATH}/bash/test/test_helper/bats-support/load"
    load "${BASE_PATH}/bash/test/test_helper/bats-assert/load"
    load "${BASE_PATH}/bash/lib/gnu-getopt/gnu-getopt.sh"
}

@test "get_gnu_getopt uses ARGSPARSE_GNU_GETOPT if set" {
    ARGSPARSE_GNU_GETOPT="/custom/path/to/getopt" run get_gnu_getopt
    assert_output "/custom/path/to/getopt"
}

@test "get_gnu_getopt gets getopt from Homebrew (Darwin)" {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        skip "non-Darwin system"
    fi
    if ! command -v brew >/dev/null 2>&1; then
        fail "Homebrew is not installed"
    fi
    homebrew_getopt_dir="$(brew --prefix gnu-getopt 2>/dev/null)"
    run get_gnu_getopt
    assert_equal "${status}" 0
    assert_output "${homebrew_getopt_dir}/bin/getopt"
}

@test "get_gnu_getopt gets getopt from PATH (non-Darwin)" {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        skip "Darwin system"
    fi
    if ! getopt_path=$(command -v getopt 2>/dev/null); then
        fail "missing getopt in PATH"
    fi
    run get_gnu_getopt
    assert_equal "${status}" 0
    assert_output "${getopt_path}"
}

@test "get_gnu_getopt returns exit-code 3 (non-Darwin)" {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        skip "Darwin system"
    fi
    # Temporarily modify PATH to exclude getopt
    PATH="" run get_gnu_getopt
    assert_equal "${status}" 3
    assert_output ""
}

@test "get_gnu_getopt returns exit-code 1 (Darwin)" {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        skip "non-Darwin system"
    fi
    PATH="" run get_gnu_getopt
    assert_equal "${status}" 1
    assert_output ""
}

@test "get_gnu_getopt returns exit-code 2 (Darwin)" {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        skip "non-Darwin system"
    fi
    if ! command -v brew >/dev/null 2>&1; then
        fail "Homebrew is not installed"
    fi
    PATH="${BASE_PATH}/bash/test/fake/brew_fail" run get_gnu_getopt
    assert_equal "${status}" 2
    assert_output ""
}

@test "get_gnu_getopt_or_error prints error and returns exit-code 3 (non-Darwin)" {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        skip "Darwin system"
    fi
    # Temporarily modify PATH to exclude getopt
    PATH="" run get_gnu_getopt_or_error
    assert_equal "${status}" 3
    assert_output --partial "GNU getopt is required"
    refute_output --partial "Homebrew"
}

@test "get_gnu_getopt_or_error prints error and returns exit-code 1 (Darwin)" {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        skip "non-Darwin system"
    fi
    if ! command -v brew >/dev/null 2>&1; then
        fail "Homebrew is not installed"
    fi

    # Temporarily modify PATH to exclude getopt
    PATH="" run get_gnu_getopt_or_error
    assert_equal "${status}" 1
    assert_output --partial "GNU getopt is required"
    assert_output --partial "install Homebrew from https://brew.sh/"
    assert_output --partial "then install gnu-getopt with Homebrew: brew install gnu-getopt"
}

@test "get_gnu_getopt_or_error returns exit-code 2 (Darwin)" {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        skip "non-Darwin system"
    fi
    if ! command -v brew >/dev/null 2>&1; then
        fail "Homebrew is not installed"
    fi

    PATH="${BASE_PATH}/bash/test/fake/brew_fail" run get_gnu_getopt_or_error
    assert_equal "${status}" 2
    assert_output --partial "GNU getopt is required"
    assert_output --partial "install it with Homebrew: brew install gnu-getopt"
}
