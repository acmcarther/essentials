{ config, pkgs, ... }:

{
  nixpkgs.config.packageOverrides = pkgs: rec {
    rustGetter = pkgs.fetchFromGitHub {
      owner = "Ericson2314";
      repo = "nixos-configuration";
      rev = "ca75f2a08643faf913ab667199ef1b3fe5615618";
      sha256 = "131hp2zp1i740zqrbgpa57zjczs5clj3q2dmylbnr9cgsqbcyznp";
    };

    funs = pkgs.callPackage "${rustGetter}/user/.nixpkgs/rust-nightly.nix" { };

    rustDate = "2016-10-03";
    rustStdDate = "2016-10-03";

    rustcNightly = funs.rustc {
      date = rustDate;
      hash = "13hvrk03ndhx8jrsfvawrakfchv10y3kxxga0fdq3ssh8sv2ph0v";
    };

    rustStd = funs.rust-std {
      date = rustDate;
      hash = "1ms4q9qx7gfbah211sswl66yqi1khcq9h5zxl20hkkj6jzzvfy2i";
    };

    rustNightlyWithi686 = funs.rustcWithSysroots {
      rustc = rustcNightly;
      sysroots = [
        (funs.rust-std {
          hash = "178p0lzqscykxrf35jnb5kvxlb6xscsby901n4abz55mapkqlkky";
          date = rustStdDate;
        })
        (funs.rust-std {
          hash = "1ms4q9qx7gfbah211sswl66yqi1khcq9h5zxl20hkkj6jzzvfy2i";
          date = rustStdDate;
          system = "i686-linux";
        })
      ];
    };

    cargoNightly = funs.cargo {
      date = rustDate;
      hash = "140vdax2yfs66wada54svgrghfb41igvd7pkx3cqpl1wvrmf2gs6";
    };
  };

  environment = {
    variables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      #capnproto
      awscli                             # AWS command line interface
      bazel
      bundix                             # Structured Ruby package manager
      cargoNightly
      cmake
      elixir
      fzf
      git                                # Git source control
      go
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
      rubygems                           # Ad hoc Ruby package manager
      rustNightlyWithi686
      silver-searcher                    # Code searching tool
      sqlite                             # sqlite database
      vimPlugins.YouCompleteMe
      vim_configurable                   # Text editor
      which                              # Dependency for fzf.vim
    ];
  };

  services = {
    # Enable postgres
    postgresql = {
      enable = false;
      package = pkgs.postgresql94;
      authentication = "local all all ident";
    };

    # Enable Mongo
    mongodb.enable = false;

    # Enable Redis
    redis.enable = false;
  };

  # Enable docker contaner svc
  virtualisation.docker.enable = true;
}
