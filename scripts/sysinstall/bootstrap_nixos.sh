#! /usr/bin/env bash

echo "I sure hope you're running this from /tmp/essentials!"

echo "Copying nixos into /etc/nixos for now. Remember to replace with symplinks from ~/essentials later."

cp /tmp/essentials/nixos /mnt/etc/nixos -r
