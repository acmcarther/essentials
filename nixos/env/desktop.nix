{ config, pkgs, ... }:

with import ../data/ssh-pub.nix {};
{
  imports =
    [
      ./common.nix
      ../services/xmonad.nix
    ];

  environment.systemPackages = with pkgs; [
    playonlinux                        # Wine DirectX/Syscall
    prometheus
    prometheus-node-exporter
    protobuf
    steam                              # Games
    teamspeak_client                   # Team voice chat
    vulkan-loader                      # Vulkan gfxlib api
  ];

  hardware = {
    bluetooth.enable = true;
    opengl.driSupport32Bit = true;
    pulseaudio.enable = true;
  };

  networking = {
    hostName = "campfire"; # Define your hostname.
    hostId = "87813f15";
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];
    openssh = {
      enable = true;
      ports = [ 25980 ];
      passwordAuthentication = true;
    };
  };

  users.users.guest.openssh.authorizedKeys.keys = [
    acmcartherLaptop
  ];
}
