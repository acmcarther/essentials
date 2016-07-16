{ config, pkgs, ... }:

{
  nixpkgs.config.packageOverrides = pkgs:
    let
      funs = (import ./rust);
      stdenv = pkgs.stdenv;
      callPackage = pkgs.callPackage;
    in {
      rustcNightly = funs {
        stdenv = stdenv; 
        callPackage = callPackage;
      };
    };

  environment = {
    variables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      awscli                             # AWS command line interface
      bundler
      bundix                             # Structured Ruby package manager
      cargoUnstable                      # Rust package manager
      rustcNightly
      git                                # Git source control
      go
      fzf
      godep
      imagemagick                        # Image manip library
      ngrok
      nix-repl                           # Repl for nix package manager
      nodejs-5_x                         # Node.js event driven JS framework
      python27                           # Python programming language
      python27Packages.pip               # Python package manager
      python27Packages.virtualenv
      elixir
      ruby                               # Ruby programming language
      rubygems                           # Ad hoc Ruby package manager
      #rustc                              # Rust compiler
      silver-searcher                    # Code searching tool
      sqlite                             # sqlite database
      which                              # Dependency for fzf.vim
      vimPlugins.YouCompleteMe
      vim_configurable                   # Text editor
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
