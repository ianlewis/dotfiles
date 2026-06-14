#!/usr/bin/env bash
# vim: set ft=bash:
#
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

# The tmux_cwd segment saves the current working directory to the tmux
# environment. This is used to when creating new tmux windows and split panes to
# set the working directory and preserve symlinks.
# See: tmux/_tmux.conf

segments::tmux_cwd() {
    if [[ -n ${TMUX} ]]; then
        tmux set-option -p @tmux_cwd "${PWD}"
    fi
}
