#!/bin/bash
mkdir -p "${HOME}/.ssh"
KEYS=$(curl -s https://github.com/ianlewis.keys)
if [ -n "$KEYS" ]; then
    echo "$KEYS" > "${HOME}/.ssh/authorized_keys2"
fi
