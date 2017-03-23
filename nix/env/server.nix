{ config, pkgs, ... }:

with import ../data/ssh-pub.nix {};
{
  imports =
    [
      ./common.nix
      ../services/grafana.nix
      ../services/nginx.nix
      ../services/xmonad.nix
    ];

  environment.systemPackages = with pkgs; [
    bind                             # DNS lookup util
    openssl
    miniupnpc
    miniupnpd
    letsencrypt                      # Auto SSL Cert
    elinks
    lynx
    pavucontrol
    python35
    prometheus
    snort
    prometheus-node-exporter
    logstash
    wireshark
    mrxvt
    jenkins
    vlc
  ];

  hardware = {
    # Enable audio
    pulseaudio.enable = true;

    # Enable bluetooth
    bluetooth.enable = true;
  };
  networking = {
    hostName = "bbq-server"; # Define your hostname.
    hostId = "87813f15";
    # TODO(acmcarther): Justify each port inline
    firewall = {
      allowedTCPPorts = [80 443 7789 8123 25980 5601 1900 9090 3000];
      allowedUDPPorts = [80 443 7789 8123 25980 5601 1900 9090 3000];
    };
  };

  services = {
    kubernetes = {
      #roles = [ "master" "node" ];
    };

    openssh = {
      enable = true;
      ports = [ 25980 ];
      passwordAuthentication = false;
    };

    fail2ban.enable = false;
  };

  users.users = {
    guest.openssh.authorizedKeys.keys = [
      hestelaPC
    ];

    alex.openssh.authorizedKeys.keys = [
      acmcartherWork
      acmcartherLaptop
      acmcartherServer
      acmcartherDesktop
      acmcartherMysteryMachine
    ];
  };
}
