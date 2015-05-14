#!/bin/bash
############################
# fix_steam_libraries.sh
# This script removes the old versions of libraries that Steam installs sometimes. This can fix the "OpenGL is not using direct rendering" thing.
############################

# Credit to ArchLinux wiki on this
# http://wiki.archlinux.org/index.php/steam#Steam_runtime_issues

find ~/.steam/root/ \( -name "libgcc_s.so*" -o -name "libstdc++.so*" -o -name "libxcb.so*" \) -print -delete
