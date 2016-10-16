{ config, pkgs, ... }:

# Symlink this file to /etc/nixos/configuration.nix
# This file is excluded from version control.
# It will be added manually to reflect the laptop installation,
# but it should not be used verbatim
{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      /home/alex/essentials/nix/common.nix
      /home/alex/essentials/nix/development.nix
      /home/alex/essentials/nix/games.nix
      /home/alex/essentials/nix/wm.nix
      /home/alex/essentials/nix/workstation.nix
    ];
}
