#!/usr/bin/env sh

find . -type file -name "*secret*.yaml.gpg" |\
  sed -e "s/\.gpg$//" |\
  xargs -I% gpg --output % --decrypt %.gpg
