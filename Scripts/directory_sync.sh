#!/bin/bash

# Script to monitor a given directory and, if it changes, sync it to the current directory.
# Use e.g. to keep a web root up-to-date from an alternate working directory.

# Inspired by:
# http://valeriu.palos.ro/169/recursive-filedirectory-change-detection/#more-169
# http://linuxadminzone.com/detect-directory-or-file-changes-in-linuxunix/

# On a Mac, brew install md5sha1sum

if [ -z "$1" ]; then
    echo "Usage: $0 directory"
    echo "  Keeps a local copy of 'directory' in sync with the directory specified"
    exit 1
elif [ ! -d "$1" ]; then
    echo "Usage: $0 directory"
    echo "Error: $1 directory not found"
    exit 1
else
    # Directory to watch
    DIR="$1"
fi

# Store current statistics of dir
OLD=`ls -lR "$DIR" | sha1sum | sed 's/[ -]//g'`
clear
echo "Monitoring $DIR"

while true
do
    # Take a new snapshot of stats
    NEW=`ls -lR "$DIR" | sha1sum | sed 's/[ -]//g'`

    # Compare it with old
    if [ "$NEW" != "$OLD" ]; then
        rsync --delete -avz $DIR .
        OLD=$NEW
    fi

    # How frequently the sync check should run
    sleep 3
    clear
    echo "Monitoring $DIR"

done