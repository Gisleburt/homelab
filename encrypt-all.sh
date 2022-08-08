#!/usr/bin/env sh

find . -type file -name "*secret*.yaml" |\
  xargs -I% gpg --output %.gpg --encrypt --recipient "daniel@danielmason.com" %
