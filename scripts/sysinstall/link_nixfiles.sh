#! /usr/bin/env bash

find nixos -type f -name "*nix" | awk '{ c=$0; e=$0; gsub(/nixos/, "/etc/nixos", c); gsub(/nixos/, "/home/alex/essentials/nixos", e); print e, c}'| sudo xargs -t -n 2 ln -s

