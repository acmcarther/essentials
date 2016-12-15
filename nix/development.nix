{ config, pkgs, ... }:

let rustNightlyNixRepo = pkgs.fetchFromGitHub {
     owner = "solson";
     repo = "rust-nightly-nix";
     rev = "9e09d579431940367c1f6de9463944eef66de1d4";
     sha256 = "03zkjnzd13142yla52aqmgbbnmws7q8kn1l5nqaly22j31f125xy";
  };
  rustPackages = pkgs.callPackage rustNightlyNixRepo { };
  bazel-custom = import ./custom-nix-pkgs/bazel/default.nix {
    inherit (pkgs) stdenv fetchFromGitHub buildFHSUserEnv writeScript jdk zip unzip;
    inherit (pkgs) which makeWrapper binutils fetchurl;
  };
in {
  nixpkgs.config.packageOverrides = pkgs: rec {
    gdb = pkgs.gdb.overrideDerivation(oldAttrs:{
      src = pkgs.fetchurl {
        url = "mirror://gnu/gdb/gdb-7.12.tar.xz";
        sha256 = "152g2qa8337cxif3lkvabjcxfd9jphfb2mza8f1p2c4bjk2z6kw3";
      };
    });
    cargoLatest = rustPackages.cargo { date = "2016-10-28"; };
    rustcLatest = rustPackages.rustcWithSysroots {
      rustc = rustPackages.rustc {
        date = "2016-10-28";
      };
      sysroots = [
        (rustPackages.rust-std {
          date = "2016-10-28";
        })
        (rustPackages.rust-std {
          date = "2016-10-28";
          system = "asmjs-unknown-emscripten";
        })
        (rustPackages.rust-std {
          date = "2016-10-28";
          system = "wasm32-unknown-emscripten";
        })
      ];
    };
  };

  environment = {
    variables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      #capnproto
      cargoLatest
      awscli                             # AWS command line interface
      bazel-custom
      gcc
      bind                               # Provides `dig` dns lookup util
      bundix                             # Structured Ruby package manager
      cmake
      gnumake
      elixir
      fzf
      git                                # Git source control
      go
      gdb
      rr
      godep
      imagemagick                        # Image manip library
      ngrok
      nix-repl                           # Repl for nix package manager
      nodejs-5_x                         # Node.js event driven JS framework
      openjdk8
      protobuf
      python27                           # Python programming language
      python27Packages.pip               # Python package manager
      python27Packages.virtualenv
      python2nix
      python35                           # Python programming language
      python35Packages.pip               # Python package manager
      python35Packages.virtualenv
      ruby                               # Ruby programming language
      rustcLatest
      silver-searcher                    # Code searching tool
      sqlite                             # sqlite database
      vimPlugins.YouCompleteMe
      vim_configurable                   # Text editor
      which                              # Dependency for fzf.vim
    ];
  };

  services = {
    # Postgres SQL database
    postgresql = {
      enable = false;
      package = pkgs.postgresql94;
      authentication = "local all all ident";
    };

    # Mongodb NoSQL db
    mongodb.enable = false;

    # Redis KV store
    redis.enable = true;

    # Consul service registry
    consul = {
      enable = true;
      extraConfig = {
        server = true;
        bootstrap = true;
        services = [{
          name = "redis";
          port = 6379;
          address = "127.0.0.1";
          checks = [{
            name = "active";
            script = "/var/run/current-system/sw/bin/systemctl is-active redis";
            interval = "30s";
          }];
        }];
      };
    };

    dnsmasq = {
      enable = true;
      extraConfig = ''
        server=/consul/127.0.0.1#8600
      '';
    };
  };

  # Enable docker contaner svc
  virtualisation.docker.enable = true;
}
