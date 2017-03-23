{ config, pkgs, ... }:
{
  nixpkgs.config.packageOverrides = pkgs: rec {
    elasticsearch2 = pkgs.elasticsearch2.overrideDerivation( oldAttrs: {
      src = pkgs.fetchurl {
        url = "https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.4.0/elasticsearch-2.4.0.tar.gz";
        sha256 = "1jglmj1dnh1n2niyds6iyrpf6x6ppqgkivzy6qabkjvvmr013q1s";
      };
    });
  };

  services = {
    elasticsearch.enable = false;
    kibana = {
      enable = false;
      listenAddress = "0.0.0.0";
    };
  };
}
