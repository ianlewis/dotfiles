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

# ble.sh init script.
# See: https://github.com/akinomyoga/ble.sh/blob/master/blerc.template

## "exec_errexit_mark" specifies the format of the mark to show the exit status
## of the command when it is non-zero.  If this setting is an empty string, the
## exit status will not be shown.  The value can contain ANSI escape sequences.

bleopt exec_errexit_mark=""

## "exec_exit_mark" specifies the marker printed when the bash session ends.
## When an empty string is specified, the marker is disabled.

bleopt exec_exit_mark=""
