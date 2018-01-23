#!/bin/bash
# Adds public certs from Github to authorized_keys if not already added.
mkdir -p "${HOME}/.ssh"
if [ ! -f "${HOME}/.ssh/authorized_keys" ]; then
    touch "${HOME}/.ssh/authorized_keys"
fi
curl -s https://github.com/ianlewis.keys | while read -r key; do
    grep -qF "$key" "${HOME}/.ssh/authorized_keys" || echo "$key" >> "${HOME}/.ssh/authorized_keys"
done
