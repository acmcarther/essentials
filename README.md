# Alex's linux "Essentials": OS in a box

## Contents
- nixos/ -> NixOs configuration file. Sets up the whole OS. Get linked via scripts/sysinstall/link_nixfiles.sh
- dotfiles/ -> Dotfiles for the OS. Get linked via /script/sysinstall/link_dotfiles.sh
- scripts/ -> Grab bag of random scripts I've found useful

## Current Desktop
![](screenshot.png?raw=true)

## Installation Gory Details

### Get a NixOS liveUSB

You'll want this to be sizeable if you plan to install the entire user environment at once (lots and lots of packages!).

### Boot into live usb and perform partioning:
```
# check you are booted in uefi
$ efivar -l

### Set up disk.
# Nuke disk (just in case)
$ sgdisk -Z /dev/sdX

# Set disk partition alignment and clear all partition data
$ sgdisk -a 2048 -o /dev/sdX

# New partition for boot, 0 to 200M
$ sgdisk -n 1:0:+200M /dev/sdX

# The rest is for the LUKS partition
$ sgdisk -n 2:0:0 /dev/sdX

# Boot partition's type is EFI System
$ sgdisk -t 1:ef00 /dev/sdX

# LUKS partition is 'Linux filesystem'
$ sgdisk -t 2:8300 /dev/sdX

# Set partition names
$ sgdisk -c 1:bootefi /dev/sdX
$ sgdisk -c 2:root /dev/sdX

### Set up LUKS and encrypt sdX2
# The actual setup
$ cryptsetup --cipher aes-xts-plain64 --key-size 512 --hash sha512\
--iter-time 5000 --use-random --verify-passphrase luksFormat /dev/sdX2

# Mount the partition
$ cryptsetup luksOpen /dev/sdX2 cryptdisk

### Set up LVM on the LUKS partition
# setup logical volumes
$ pvcreate /dev/mapper/cryptdisk
$ pvdisplay

$ vgcreate vgroup /dev/mapper/cryptdisk
$ vgdisplay

# Partitioning. Customize this for yourself
$ lvcreate --extents +100%FREE --name lvroot vgroup
$ lvdisplay

### Formatting partitions
# Boot should be vfat
$ mkfs.vfat -F32 /dev/sdX1
# The rest are ext4
$ mkfs.ext4 /dev/mapper/vgroup-lvroot

### Mount the partitions
$ mount /dev/mapper/vgroup-lvroot /mnt
$ mkdir -p /mnt/boot/efi
$ mount -t vfat /dev/sdX1 /mnt/boot
```

### Bootstrap nixos files
```
### Set up networking (either ethernet, or wpa_supplicant)
# ....

### Get youself git
$ nix-env -i git

### Get a temp copy of essentials for bootstrapping
$ cd /tmp && git clone http://github.com/acmcarther/essentials

### Edit configuration.nix and hardware-configuration.nix as needed
# ....

### Copy bootstrap nixfiles into nixdir
$ ./essentials/scripts/bootstrap_nixos.sh
```

### Install nixos
```
$ nixos-install
```

### Reboot
```
### Perform a reboot
# ....
```

### Init User
```
### Boot into tty (ctrl+alt+f2) and log in
# ....

### Set up user
$ passwd alex

### Pull down essentials for realsies
$ cd ~ && git clone https://github.com/acmcarther/essentials

### Duplicate local modifications to configuration.nix and hardware-configuration.nix as needed
# ....

### Get rid of bootstrap nix files
$ ./essentials/scripts/rm_bootstrap.sh

### Symlink local nix files
$ ./essentials/scripts/link_nixfiles.sh

### Symlink dotfiles
$ ./essentials/scripts/link_dotfiles.sh
```

### Verify working order of XMonad, wrap up init
```
### Boot into WM, open terminal (ctrl + alt + t)
# ....

### Install Vundle for vim
$ git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

### Open vim and run :PluginInstall
# ....
```

