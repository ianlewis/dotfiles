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
    BASE_PATH="$(cd "$(dirname "$(dirname "$(dirname "$(dirname "${BATS_TEST_FILENAME}")")")")" >/dev/null 2>&1 && pwd)"

    load "${BASE_PATH}/bash/test/test_helper/bats-support/load"
    load "${BASE_PATH}/bash/test/test_helper/bats-assert/load"
    load "${BASE_PATH}/bin/all/randstr.bash"

    TEST_HOME="$(mktemp -u "${BATS_TEST_TMPDIR}/home")"
    mkdir -p "${TEST_HOME}/.local/share/bash/lib"
    ln -s "${BASE_PATH}/bash/lib/gnu-getopt" "${TEST_HOME}/.local/share/bash/lib/gnu-getopt"
    ln -s "${BASE_PATH}/bash/lib/base-argsparse" "${TEST_HOME}/.local/share/bash/lib/bash-argsparse"
}

@test "randstr generates random string" {
    run _main
    assert_output --regexp '^[A-Za-z0-9]{16}$'
}

@test "randstr generates random string with length" {
    run _main --length 10
    assert_output --regexp '^[A-Za-z0-9]{10}$'
}

@test "randstr generates random string with pattern" {
    run _main --pattern '0-9'
    assert_output --regexp '^[0-9]{16}$'
}

@test "randstr generates random string with pattern and length" {
    run _main --length 18 --pattern 'A-Z'
    assert_output --regexp '^[A-Z]{18}$'
}
