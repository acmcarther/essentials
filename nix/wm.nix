{ config, pkgs, ... }:

{
  fonts = {
    fonts = with pkgs; [
      font-awesome-ttf
    ];
  };

  environment.systemPackages = with pkgs; [
    bar-xft                            # Lightweight xcb based bar
    compton                            # Windowing system for niceness
    dmenu                              # Application launcher
    feh                                # Wallpaper manager
    python27Packages.udiskie
    unclutter                          # Mouse hider
    xlaunch                            # Manual starting of X
    xlibs.xmodmap                      # Keyboard reconfiguration
    xmonad-with-packages               # Tiling window manager
    xorg.xbacklight                    # Backlight modification utility
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    font-awesome-ttf = pkgs.font-awesome-ttf.overrideDerivation (attrs: {
      name = "font-awesome-4.5.0";
      src = pkgs.fetchurl {
        url = "http://fortawesome.github.io/Font-Awesome/assets/font-awesome-4.5.0.zip";
        sha256 = "12m1rkpgq51gqyid0a1v1av3pcyc61asfy6bbbki1gkym2advfbf";
      };
    });
  };

  security.setuidPrograms = [ "xlaunch" ];

  services = {
    # Disk mounting
    udisks2.enable = true;

    # Enable the X11 windowing system.
    xserver = {
      enableTCP = false;
      exportConfiguration = false;
      enable = true;
      layout = "us";

      # Setup daemons for composting and wallpaper
      displayManager = {
        sessionCommands = ''
          xset r rate 300 30
          unclutter -grab &
          udiskie &
          compton --config /dev/null &
          feh --randomize --bg-fill ~/Pictures/Wallpapers/* &
        '';
      };

      # Disable default stuff
      desktopManager = {
        xterm.enable = false;
        xfce.enable = false;
      };

      # Enable xmonad
      windowManager = {
        xmonad.enable = true;
        xmonad.enableContribAndExtras = true;
        default = "xmonad";
      };
    };
  };
}
