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
    elinks
    jenkins
    letsencrypt                      # Auto SSL Cert
    logstash
    lynx
    miniupnpc
    miniupnpd
    mrxvt
    openssl
    pavucontrol
    prometheus
    prometheus-node-exporter
    python35
    snort
    vlc
    wireshark
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
      allowedTCPPorts = [80 443 7789 8080 8123 25980 5601 1900 9090 3000];
      allowedUDPPorts = [80 443 7789 8080 8123 25980 5601 1900 9090 3000];
    };
  };

  services = {
    kubernetes = {
      #roles = [ "master" "node" ];
      #apiserver.securePort = 6443;
      #apiserver.extraOpts = " --kubelet-preferred-address-types=InternalIP,Hostname,ExternalIP";
    };

    openssh = {
      enable = true;
      forwardX11 = true;
      ports = [ 25980 ];
      passwordAuthentication = false;
    };

    fail2ban.enable = false;
    redis.enable = true;
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
