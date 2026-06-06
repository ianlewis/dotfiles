#!/usr/bin/env bash
# vim: set ft=bash foldmethod=marker:
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

## Enable vim mode.

set -o vi

##{{{ "edit_bell" controls the behavior of the bell.

bleopt edit_bell=none
#}}}

##{{{ "exec_elapsed_mark" specifies the format of the execution time report.

bleopt exec_elapsed_mark=""
bleopt exec_elapsed_enabled=""
#}}}

##{{{ "exec_errexit_mark" specifies the the mark to show the exit status
## of the command when it is non-zero.  If this setting is an empty string, the
## exit status will not be shown.  The value can contain ANSI escape sequences.

bleopt exec_errexit_mark=""
#}}}

##{{{ "exec_exit_mark" specifies the marker printed when the bash session ends.
## When an empty string is specified, the marker is disabled.

bleopt exec_exit_mark=""
#}}}

##{{{ "prompt_eol_mark" specifies the contents of the mark used to indicate the
## command output is not ended with newlines.

bleopt prompt_eol_mark=""
#}}}

#{{{ ble/widget/discard-and-enter-insert clears the current line.
function ble/widget/discard-and-enter-insert {
    # 1. Clear the current line/buffer
    ble/widget/discard-line
    # 2. Force switch to Insert Mode
    ble/widget/vi_nmap/insert-mode
}
#}}}

#{{{ blerc/vim-load-hook sets up the keybindings for vim mode.
function blerc/vim-load-hook {
    # shellcheck disable=SC2154
    ((_ble_bash >= 40300)) && builtin bind 'set keyseq-timeout 1'

    #{{{ Dvorak keybindings for Normal and Operator-Pending Modes
    ble-bind -m vi_nmap -f h vi-command/backward-char
    ble-bind -m vi_nmap -f t vi-command/forward-line
    ble-bind -m vi_nmap -f n vi-command/backward-line
    ble-bind -m vi_nmap -f s vi-command/forward-char

    ble-bind -m vi_omap -f h vi-command/backward-char
    ble-bind -m vi_omap -f t vi-command/forward-line
    ble-bind -m vi_omap -f n vi-command/backward-line
    ble-bind -m vi_omap -f s vi-command/forward-char
    #}}}

    # In Insert Mode, use the native discard behavior
    ble-bind -m vi_imap -f 'C-c' discard-line

    # In Normal Mode, clear the buffer and force switch back to Insert Mode
    ble-bind -m vi_nmap -f 'C-c' discard-and-enter-insert
}
blehook/eval-after-load keymap_vi blerc/vim-load-hook
#}}}
