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
}

@test "project-windowizer uses logical PWD for the new pane working directory" {
    local fake_home="${BATS_TEST_TMPDIR}/home"
    local real_tmp="${BATS_TEST_TMPDIR}/dotfiles-user-tmp"
    local logical_project="${fake_home}/.tmp/workspace/project"
    local real_project="${real_tmp}/workspace/project"
    local fake_lib_dir="${fake_home}/.local/share/bash/lib"
    local fake_bin="${BATS_TEST_TMPDIR}/bin"
    local tmux_log="${BATS_TEST_TMPDIR}/tmux.log"

    mkdir -p "${fake_lib_dir}/gnu-getopt"
    mkdir -p "${fake_lib_dir}/bash-argsparse"
    mkdir -p "${real_project}"
    mkdir -p "${fake_bin}"
    ln -s "${real_tmp}" "${fake_home}/.tmp"

    cat >"${fake_lib_dir}/gnu-getopt/gnu-getopt.sh" <<'GNU_GETOPT'
get_gnu_getopt_or_error() {
    echo "getopt"
}
GNU_GETOPT

    cat >"${fake_lib_dir}/bash-argsparse/argsparse.sh" <<'ARGSPARSE'
argsparse_describe_parameters() {
    :
}
argsparse_allow_no_argument() {
    :
}
argsparse_parse_options() {
    program_params=("$@")
}
ARGSPARSE

    cat >"${fake_bin}/tmux" <<'TMUX'
#!/usr/bin/env bash
set -eu

case "$1" in
    display-message)
        echo "200"
        ;;
    split-window)
        printf '%s\n' "$@" >"${TMUX_LOG}"
        ;;
esac
TMUX
    chmod +x "${fake_bin}/tmux"

    cd "${logical_project}" || exit 1

    run env HOME="${fake_home}" PATH="${fake_bin}:${PATH}" TMUX_LOG="${tmux_log}" TMUX=1 TERM=xterm "${BASE_PATH}/bin/all/project-windowizer" nvim
    assert_success

    run grep -Fx -- "${logical_project}" "${tmux_log}"
    assert_success

    run grep -Fx -- "${real_project}" "${tmux_log}"
    assert_failure
}
