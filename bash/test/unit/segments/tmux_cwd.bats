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

setup_file() {
    # Set a test timeout in seconds.
    export BATS_TEST_TIMEOUT=10
}

setup() {
    BASE_PATH="$(cd "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "${BATS_TEST_FILENAME}")")")")")" >/dev/null 2>&1 && pwd)"

    load "${BASE_PATH}/bash/test/test_helper/bats-support/load"
    load "${BASE_PATH}/bash/test/test_helper/bats-assert/load"
    load "${BASE_PATH}/bash/test/test_helper/sbp/load"

    TMUX_SOCKET="$(mktemp -u "${BATS_TEST_TMPDIR}/tmux_socket_XXXXXX")"
    export TMUX_SOCKET
}

teardown() {
    # For debugging purposes, we can capture the tmux pane output before killing
    # the server using capture-pane. e.g.
    # tmux -S "${TMUX_SOCKET}" capture-pane -p >&3 || true

    # Kill the tmux server to clean up any sessions created during the test.
    tmux -S "${TMUX_SOCKET}" kill-server 2>/dev/null || true
}

@test "test_cwd segment sets tmux_cwd option" {
    cd "${BATS_TEST_TMPDIR}"

    # Create a new tmux session. Don't load the user's .bashrc.
    run tmux -S "${TMUX_SOCKET}" new-session -d -s "test_session_${BATS_TEST_NUMBER}" "bash --norc --noprofile"
    [ "${status}" -eq 0 ] || fail "Failed to create tmux session: ${output}"

    # Create a lock to synchronize the test with the tmux session.
    run tmux -S "${TMUX_SOCKET}" wait-for -L "wait_channel_${BATS_TEST_NUMBER}"
    [ "${status}" -eq 0 ] || fail "Failed to lock tmux session: ${output}"

    # Source the test helper.
    run tmux -S "${TMUX_SOCKET}" send-keys -t "test_session_${BATS_TEST_NUMBER}" \
        "source ${BASE_PATH}/bash/test/test_helper/sbp/load.bash && tmux wait-for -U wait_channel_${BATS_TEST_NUMBER}" \
        Enter
    [ "${status}" -eq 0 ] || fail "Failed to send keys to tmux session: ${output}"

    # Wait for the tmux session to initialize.
    run tmux -S "${TMUX_SOCKET}" wait-for -L "wait_channel_${BATS_TEST_NUMBER}"
    [ "${status}" -eq 0 ] || fail "Failed wait on tmux session: ${output}"

    # Run the segment in the tmux session.
    run tmux -S "${TMUX_SOCKET}" send-keys -t "test_session_${BATS_TEST_NUMBER}" \
        "execute_segment 'tmux_cwd' && tmux wait-for -U wait_channel_${BATS_TEST_NUMBER}" \
        Enter
    [ "${status}" -eq 0 ] || fail "Failed to send keys to tmux session: ${output}"

    # Wait for the segment to run
    run tmux -S "${TMUX_SOCKET}" wait-for -L "wait_channel_${BATS_TEST_NUMBER}"
    [ "${status}" -eq 0 ] || fail "Failed wait on tmux session: ${output}"

    # Capture the tmux option value.
    run tmux -S "${TMUX_SOCKET}" show-option -p -t "test_session_${BATS_TEST_NUMBER}" "@tmux_cwd"
    [ "${status}" -eq 0 ] || fail "Failed to get tmux option: ${output}"

    assert_equal "${output}" "@tmux_cwd ${BATS_TEST_TMPDIR}"
}
