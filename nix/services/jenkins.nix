{ config, pkgs, ... }:
{
  nixpkgs.config.packageOverrides = pkgs: rec {
    jenkins = pkgs.jenkins.overrideDerivation( oldAttrs: {
      src = pkgs.fetchurl {
        url = "http://mirrors.jenkins-ci.org/war/2.37/jenkins.war";
        sha256 = "12jcpmka594qpn22s7x1p1kszd5bbp7y6x5a6ncvq30m093993yk";
      };
    });
  };

  services.jenkins = {
    enable = false;
    extraGroups = [ "essentials" ];
    port = 7789;
    packages =
      let env = pkgs.buildEnv {
        name = "jenkins-env";
        pathsToLink = [ "/bin" ];
        paths = [
          # defaults
          pkgs.stdenv pkgs.git pkgs.jdk pkgs.openssh pkgs.nix
          # put your packages here:
          pkgs.gzip pkgs.bash pkgs.wget pkgs.unzip pkgs.glibc pkgs.cmake pkgs.clang
          # ...
          pkgs.gcc49 pkgs.bash pkgs.rustcLatest pkgs.cargoLatest
        ];
      };
      in [ env ];
  };

  systemd.services.jenkins.serviceConfig.TimeoutStartSec = "10min";
}
