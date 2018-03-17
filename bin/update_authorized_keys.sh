#!/bin/bash
# Adds public certs from Github to authorized_keys
mkdir -p "${HOME}/.ssh"
if [ ! -f "${HOME}/.ssh/authorized_keys" ]; then
    touch "${HOME}/.ssh/authorized_keys"
fi

# Only update authorized_keys if we can contact github. We want
# to avoid writing an empty authorized_keys file if github.com is
# inaccessible.
TEMPFILE=$(mktemp)
if curl -s https://github.com/ianlewis.keys > "${TEMPFILE}"; then
    cat "${TEMPFILE}" > "${HOME}/.ssh/authorized_keys"
fi

# Adds local authorized_keys if not already there
if [ -f "${HOME}/.ssh/authorized_keys.local" ]; then
    while read -r key; do
        grep -qF "$key" "${HOME}/.ssh/authorized_keys" || echo "$key" >> "${HOME}/.ssh/authorized_keys"
    done < "${HOME}/.ssh/authorized_keys.local"
fi
