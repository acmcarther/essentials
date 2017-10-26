#! /usr/bin/env bash

echo 'Obliterating bootstrap files in /etc/nixos'

find /etc/nixos -type f -name "*nix" | sudo xargs -t rm

