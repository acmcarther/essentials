{ config, pkgs, ... }:

with import ../data/ssh-pub.nix {};
{
  imports =
    [
      ./common.nix
      ../services/xmonad.nix
    ];

  hardware = {
    # Enable audio
    pulseaudio.enable = true;

    # Enable bluetooth
    bluetooth.enable = false;

    # Enable direct rendering for 32 bit applications
    #   Required to run steam games on 64 bit system
    opengl = {
      driSupport = true;
      driSupport32Bit = true;
    };

    bumblebee = {
      enable = false;
      connectDisplay = false;
    };
  };

  environment.systemPackages = with pkgs; [
    tlp                                # Power management
    powerstat
  ];

  networking = {
    hostName = "bbq"; # Define your hostname.
    hostId = "87813f15";
  };


  services = {
    openssh = {
      enable = true;
      ports = [ 25980 ];
      passwordAuthentication = true;
    };

    tlp.enable = true;

    postgresql = {
      enable = false;
      initialScript = pkgs.writeText"postgresql-init.sql"
        ''
        CREATE ROLE postgres WITH superuser login createdb
        '';
    };
    xserver = {
      libinput = {
        enable = true;
        middleEmulation = true;
        naturalScrolling = false;
        tapping = true;
      };

      videoDrivers = [ "intel" ];
    };
  };
  users.users.guest.openssh.authorizedKeys.keys = [
    acmcartherServer
  ];

}
