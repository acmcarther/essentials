{ config, pkgs, ... }:

{
  environment = {
    variables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      awscli                             # AWS command line interface
      bundix                             # Structured Ruby package manager
      cargoUnstable                      # Rust package manager
      git                                # Git source control
      imagemagick                        # Image manip library
      nix-repl                           # Repl for nix package manager
      nodejs-5_x                         # Node.js event driven JS framework
      python27                           # Python programming language
      python27Packages.pip               # Python package manager
      python27Packages.virtualenv
      ruby                               # Ruby programming language
      rubygems                           # Ad hoc Ruby package manager
      rustc                              # Rust compiler
      silver-searcher                    # Code searching tool
      sqlite                             # sqlite database
      vimPlugins.YouCompleteMe
      vim_configurable                   # Text editor
    ];
  };

  services = {
    # Enable postgres
    postgresql = {
      enable = true;
      package = pkgs.postgresql94;
      authentication = "local all all ident";
    };

    # Enable Mongo
    mongodb.enable = true;

    # Enable Redis
    redis.enable = true;
  };

  # Enable docker contaner svc
  virtualisation.docker.enable = true;
}
