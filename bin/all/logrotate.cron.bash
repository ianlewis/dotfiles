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

# logrotate.cron.bash is meant to be run as a cron job to rotate user logs.
# It is meant to be run under the user's crontab, and will rotate logs in the
# user's home directory. The environment where it is run may not have the same
# environment variables as a normal shell.

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"

# Look for the logrotate command in the following locations:
logrotate_cmds=(
    # Use the logrotate command from the PATH if available.
    "logrotate"
    "/usr/local/sbin/logrotate"
    "/usr/local/bin/logrotate"
    "/usr/sbin/logrotate"
    "/usr/bin/logrotate"
    "/sbin/logrotate"
    "/bin/logrotate"
    "${HOMEBREW_PREFIX}/bin/logrotate"
    "${HOMEBREW_PREFIX}/sbin/logrotate"
    "${HOMEBREW_PREFIX}/opt/logrotate/bin/logrotate"
    "${HOMEBREW_REPOSITORY}/bin/logrotate"
    "${HOMEBREW_REPOSITORY}/sbin/logrotate"
    "${HOMEBREW_REPOSITORY}/opt/logrotate/bin/logrotate"
    "${HOMEBREW_CELLAR}/logrotate/bin/logrotate"
)
logrotate_cmd=""
for cmd in "${logrotate_cmds[@]}"; do
    if command -v "${cmd}" >/dev/null 2>&1; then
        logrotate_cmd="${cmd}"
        break
    fi
done

if [[ -z "${logrotate_cmd}" ]]; then
    echo "$(basename "${0}"): ERROR: logrotate command not found." >&2
    exit 1
fi

mkdir -p "${XDG_STATE_HOME}/logrotate"
"${logrotate_cmd}" \
    --state "${XDG_STATE_HOME}/logrotate/logrotate.status" \
    "${XDG_CONFIG_HOME}/logrotate/logrotate.conf"
