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
  boot.initrd.luks.devices = [ { device  = "/dev/nvme0n1p6"; name = "luksroot";} ];
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
      device = "/dev/nvme0n1p5";
    };
  nix.maxJobs = 8;
}
