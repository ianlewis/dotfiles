#!/bin/bash
set -e
set -o pipefail

ERRORS=()

# find all executables and run `shellcheck`
for f in $(find . -path ./vim/bundle -prune -o -type f -not -iwholename '*.git*' -not -name "yubitouch.sh" | sort -u); do
	if file "$f" | cut -d':' -f2 | grep --quiet shell; then
		{
			shellcheck -x "$f" && echo "[OK]: sucessfully linted $f"
		} || {
			# add to errors
			ERRORS+=("$f")
		}
	fi
done

if [ ${#ERRORS[@]} -ne 0 ]; then
	echo "These files failed shellcheck: ${ERRORS[*]}"
	exit 1
fi
