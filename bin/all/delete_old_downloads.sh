#!/bin/bash

# A simple script to clean up files from a
# list of temporary directories.

# Explicitly specify the directories for safety.
DIRS="$HOME/tmp/ $HOME/Downloads/"

DAYS=$1

if [ "$DAYS" = "" ]; then
    DAYS=14
fi

for DIR in $DIRS; do
    if [ -d "$DIR" ]; then
        # Delete old files
        find "$DIR" -type f -mtime +"$DAYS" -delete

        # Delete old symbolic links
        find "$DIR" -type l -mtime +"$DAYS" -delete

        # Delete empty directories
        find "$DIR" -type d -empty -delete
    fi

    # Finally make sure the directory itself exists
    mkdir -p "$DIR"
done
