#!/usr/bin/env sh

if [ -z "$1" ]
  then
    echo "No file specified"
    exit
fi

if [ ! -f "$1" ]
  then
    echo "File not found"
    exit
fi

gpg --output $1.gpg --encrypt --recipient "daniel@danielmason.com" $1
