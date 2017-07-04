# Use this file as an example for your own config
# Nix fails to autogenerate this, which is why we do it manually
# This file is excluded from version control.
# It will be added manually to reflect the laptop installation,
# but it should not be used verbatim
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/hardware/network/broadcom-43xx.nix>
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];
  # Laptop's disk is this funny nvme0, you probably want sda2
  boot.initrd.luks.devices = [ { device  = "/dev/nvme0n1p7"; name = "luksroot";} ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.blacklistedKernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/mapper/vgroup-lvroot";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      mountPoint = "/boot";
      device = "/dev/nvme0n1p6";
    };

  fileSystems."/home" =
    {
      device = "/dev/mapper/vgroup-lvhome";
      fsType = "ext4";
    };

  fileSystems."/var" =
    {
      device = "/dev/mapper/vgroup-lvvar";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/mapper/vgroup-lvswap"; }
    ];

  nix.maxJobs = 8;
}
