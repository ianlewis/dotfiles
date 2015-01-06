#!/bin/bash

DIR=$1
DAYS=$2
if [ $DAYS = "" ]; then
    DAYS=14
fi

# Delete old files
find $DIR -type f -mtime +$DAYS -exec rm -f {} \;

# Delete empty directories
find $DIR -type d -empty -exec rmdir {} \;
