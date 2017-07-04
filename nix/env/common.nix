{ config, pkgs, ... }:

{
  imports = [ ../packages/overrides.nix ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      ubuntu_font_family # Ubuntu fonts
      liberation_ttf
    ];
  };

  networking = {
    # Use network manager for networking (in lieu of wpa_supplicant)
    networkmanager.enable = true;

    firewall = {
      allowedTCPPorts = [ 80 3000  8888 25980 4040 ];
      allowedUDPPorts = [ 80 3000  8888 25980 4040 ];
    };
  };

  nixpkgs.config = {
    # Nonfree packages (for nvidia drivers)
    allowUnfree = true;

    # Configure chromium for flash and pdf reading
    chromium = {
      enablePepperFlash = false;
      enablePepperPdf = true;
    };
  };

  environment = {
    variables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      inotify-tools                      # Linux tools for detecting file changes
      arandr                             # GUI frontend for xrandr monitor configuration
      awscli                             # AWS command line interface
      baobab                             # Disk usage analyser
      bazel-custom                       # Bazel build tool
      bc                                 # Basic calculator
      bind                               # Provides `dig` dns lookup util
      bundix                             # Structured Ruby package manager
      byzanz                             # Screen recording software
      cargoLatest                        # Rust default build tool
      chromium                           # Browser
      cmake                              # Cmake build tool
      cups                               # Printer Support
      cups-bjnp                          # Printer Support (Canon Printer)
      deadbeef-with-plugins              # music player
      elixir                             # Support for the Elixir language
      ffmpeg                             # Video recording/converting/streaming
      ffmpeg-full                        # Video recording/converting/streaming
      file                               # Determine type of file
      firefox                            # Backup browser
      fzf                                # Fuzzy file Finder
      gcc                                # C compiler
      git                                # Git source control
      glxinfo                            # GFX Debug
      gnumake                            # Make build system
      go                                 # Support for the go language
      godep                              # Go dependency management tool
      google-chrome                      # Primary browser
      gutenprint                         # printer
      gutenprintBin                      # more printer
      hicolor_icon_theme                 # Default theme for thunar
      htop                               # System monitor
      imagemagick                        # Image manip library
      irssi                              # Irc client
      live555                            # RTSP libs for
      mplayer                            # Video player
      ngrok                              # Ad-hoc LAN to WAN port forwarding
      nix-repl                           # Repl for nix package manager
      nodejs                             # Node.js event driven JS framework
      openjdk8                           # Java language support
      openssl                            # Openssl
      openssl.dev                        # Openssl developer libs
      patchelf                           # Nix binary patching util
      pavucontrol                        # Audio volume mixer
      pcmanfm                            # Lightweight file browser
      pinta                              # Simple paint program
      pkgconfig                          # Crossplat dependency locator
      powertop                           # See power consumption
      protobuf                           # Cross-language data protocol format support
      pulseaudioFull                     # Audio drivers + support
      python27                           # Python programming language
      python27Packages.pip               # Python package manager
      python27Packages.virtualenv
      python2nix
      python35                           # Python programming language
      python35Packages.pip               # Python package manager
      python35Packages.virtualenv
      rr
      ruby                               # Ruby programming language
      rustcLatest
      rxvt_unicode-with-plugins          # Terminal emulator
      scrot                              # Screenshot capturing
      silver-searcher                    # Code searching tool
      skype                              # IM and Web chat
      sqlite                             # sqlite database
      sshfsFuse                          # FS over SSH
      taskwarrior                        # Task management TODO: Remove if not used
      tmux                               # Console multiplexer
      transmission                       # Bittorrent Client
      tree                               # File tree
      unzip                              # .zip file util
      vimPlugins.YouCompleteMe
      vim_configurable                   # Text editor
      vlc                                # Video player
      wget                               # CLI file downloader
      which                              # Dependency for fzf.vim
      xclip                              # Clipboard command line util
      xdotool                            # Diagnostic for Mouse & KB
      zlib                               # Compression support
      zlib.dev
    ];
  };

  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

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

    extraGroups = {
      ssl-cert.gid = 1040;
      essentials.gid = 1050;
    };

    extraUsers = {
      alex = {
        isNormalUser = true;
        home = "/home/alex";

        # Configure for sudo, network, gfx, and docker
        extraGroups = ["wheel" "networkmanager" "video" "docker" "ssl-cert" "essentials"];
        uid = 1000;
        shell = "/run/current-system/sw/bin/zsh";
      };

      guest = {
        isNormalUser = true;
        home = "/home/guest";

        uid = 1001;
        shell = "/run/current-system/sw/bin/zsh";
      };
    };
  };

  # Enable docker contaner svc
  virtualisation.docker.enable = true;
}
