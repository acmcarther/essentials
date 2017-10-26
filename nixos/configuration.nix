{ config, pkgs, ... }:

# Symlink this file to /etc/nixos/configuration.nix
# This file is excluded from version control.
# It will be added manually to reflect the laptop installation,
# but it should not be used verbatim
{
  imports =
    [
      ./hardware-configuration.nix
      ./env/laptop.nix
    ];
}
