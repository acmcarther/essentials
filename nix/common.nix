{ config, pkgs, ... }:

{
  # Use gummiboot
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      ubuntu_font_family # Ubuntu fonts
      liberation_ttf
    ];
  };

  networking.firewall.allowedTCPPorts = [ 80 3000  8888 25980 4040 ];
  networking.firewall.allowedUDPPorts = [ 80 3000  8888 25980 4040 ];

  nixpkgs.config = {
    # Nonfree packages (for nvidia drivers)
    allowUnfree = true;

    # Configure chromium for flash and pdf reading
    chromium = {
      enablePepperFlash = true;
      enablePepperPdf = true;
    };
  };

  environment.systemPackages = with pkgs; [
    firefox
    arandr                             # GUI frontend for xrandr monitor configuration
    baobab                             # Disk usage analyser
    bc                                 # Basic calculator
    byzanz                             # Screen recording software
    chromium                           # Browser
    cups
    cups-bjnp
    deadbeef-with-plugins              # music player
    ffmpeg                             # Video recording/converting/streaming
    ffmpeg-full                             # Video recording/converting/streaming
    glxinfo                            # GFX Debug
    gnome.gnome_icon_theme             # icons for thunar
    google-chrome
    gtk                                # To get GTK+'s themes
    gutenprint # printer
    gutenprintBin # more printer
    hicolor_icon_theme                 # Default theme for thunar
    htop                               # System monitor
    irssi                              # Irc client
    live555                            # RTSP libs for
    mplayer                            # Video player
    nix-repl                           # Repl for nix package manager
    pavucontrol
    pcmanfm                            # Lightweight file browser
    physlock                           # Screen locker
    pinta      #simple paint program
    powertop # See power consumption
    pulseaudioFull                     # Audio
    rxvt_unicode-with-plugins          # Terminal emulator
    scrot                              # Screenshot capturing
    skype
    sshfsFuse                          # FS over SSH
    taskwarrior                        # Task management TODO: Remove if not used
    tmux                               # Console multiplexer
    transmission                       # Bittorrent Client
    tree                               # File tree
    unzip                              # .zip file util
    vlc
    wget
    xclip                              # Clipboard command line util
    xdotool                            # Diagnostic for Mouse & KB
  ];


  hardware = {
    # Enable audio
    pulseaudio.enable = true;

    # Enable bluetooth
    bluetooth.enable = true;
  };

  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Use network manager for networking (in lieu of wpa_supplicant)
  networking.networkmanager.enable = true;

  programs.zsh.enable = true;

  # Set sudo to use user home
  security.sudo.extraConfig = ''
    Defaults !always_set_home
    Defaults env_keep+="HOME"
  '';

  services = {
    # Configure physlock screen locker
    physlock = {
      enable = true;
      user = "alex";
      lockOn = {
        suspend = true;
        hibernate = true;
      };
    };

    # Enable CUPS to print documents.
    printing.enable = true;
  };


  time.timeZone = "US/Pacific";

  users = {
    defaultUserShell = "/run/current-system/sw/bin/zsh";

    extraGroups.ssl-cert.gid = 1040;
    extraGroups.essentials.gid = 1050;
    extraUsers.alex = {
      isNormalUser = true;
      home = "/home/alex";

      # Configure for sudo, network, gfx, and docker
      extraGroups = ["wheel" "networkmanager" "video" "docker" "ssl-cert" "essentials"];
      uid = 1000;
      shell = "/run/current-system/sw/bin/zsh";
    };

    extraUsers.guest = {
      isNormalUser = true;
      home = "/home/guest";

      uid = 1001;
      shell = "/run/current-system/sw/bin/zsh";
    };
  };
}
