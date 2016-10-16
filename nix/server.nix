{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    openssl
    skype
    miniupnpc
    miniupnpd
    letsencrypt                      # Auto SSL Cert
    elinks
    lynx
    pavucontrol
    python35
    wireshark
    mrxvt
    jenkins
    vlc
    (import ./custom-nix-pkgs/homeassistant/default.nix)
  ];

  nixpkgs.config.packageOverrides = pkgs: rec {
    jenkins = pkgs.jenkins.overrideDerivation( oldAttrs: {
      src = pkgs.fetchurl {
        url = "http://mirrors.jenkins-ci.org/war/2.3/jenkins.war";
        sha256 = "0x59dbvh6y25ki5jy51djbfbhf8g2j3yd9f3n66f7bkdfw8p78g1";
      };
    });
  };

  networking = {
    hostName = "bbq-server"; # Define your hostname.
    hostId = "87813f15";
    firewall.allowedTCPPorts = [80 443 7789 8123 25980 1900];
    firewall.allowedUDPPorts = [80 443 7789 8123 25980 1900];
  };

  services.nginx = {
    config = ''
      http {
        server {
          listen 80;
          return 301 https://$host$request_uri;
        }
        # Home Assistant
        server {
          listen 443;
          server_name home.cheapassbox.com;

          ssl_certificate /etc/letsencrypt/live/home.cheapassbox.com/fullchain.pem;
          ssl_certificate_key /etc/letsencrypt/live/home.cheapassbox.com/privkey.pem;
          ssl_dhparam /etc/letsencrypt/live/home.cheapassbox.com/dhparams.pem;

          ssl on;
          ssl_session_cache  builtin:1000  shared:SSL:10m;
          ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
          ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
          ssl_prefer_server_ciphers on;

          location / {
            proxy_set_header        Host $host;
            proxy_set_header        X-Real-IP $remote_addr;
            proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header        X-Forwarded-Proto $scheme;

            # Fix the “It appears that your reverse proxy set up is broken" error.
            proxy_pass          http://localhost:8123;
            proxy_read_timeout  90;

            proxy_redirect      http://localhost:8123 https://home.cheapassbox.com;
          }
        }

        # Jenkins
        server {
          listen 443;
          server_name jenkins.cheapassbox.com;

          ssl_certificate /etc/letsencrypt/live/jenkins.cheapassbox.com/fullchain.pem;
          ssl_certificate_key /etc/letsencrypt/live/jenkins.cheapassbox.com/privkey.pem;
          ssl_dhparam /etc/letsencrypt/live/jenkins.cheapassbox.com/dhparams.pem;

          ssl on;
          ssl_session_cache  builtin:1000  shared:SSL:10m;
          ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
          ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
          ssl_prefer_server_ciphers on;

          location / {
            proxy_set_header        Host $host;
            proxy_set_header        X-Real-IP $remote_addr;
            proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header        X-Forwarded-Proto $scheme;

            # Fix the “It appears that your reverse proxy set up is broken" error.
            proxy_pass          http://localhost:7789;
            proxy_read_timeout  90;

            proxy_redirect      http://localhost:7789 https://jenkins.cheapassbox.com;
          }
        }
      }
      events {
        worker_connections 768;
        # multi_accept on;
      }
    '';

    enable = true;
  };

  services.openssh = {
    enable = true;
    ports = [ 25980 ];
    passwordAuthentication = false;
  };

  systemd.services.homeassistant = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      User = "alex";
      ExecStart = ''/run/current-system/sw/bin/hass'';
      ExecStop = ''/run/current-system/sw/bin/pkill hass'';
    };
  };

  services.jenkins = {
    enable = true;
    extraGroups = [ "essentials" ];
    port = 7789;
  };

  services.jenkins.packages =
    let env = pkgs.buildEnv {
      name = "jenkins-env";
      pathsToLink = [ "/bin" ];
      paths = [
        # defaults
        pkgs.stdenv pkgs.git pkgs.jdk pkgs.openssh pkgs.nix
        # put your packages here:
        pkgs.gzip pkgs.bash pkgs.wget pkgs.unzip pkgs.glibc pkgs.cmake pkgs.clang
        # ...
        pkgs.gcc49 pkgs.bash pkgs.rustNightlyWithi686 pkgs.cargoNightly
      ];
    };
    in [ env ];

  systemd.services.jenkins.serviceConfig.TimeoutStartSec = "10min";

  users.users.alex.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDnQusENKbsEzR4o8Sbrs3gkZVNWhBxS9b16vWIs75q47k+/tMZ0OgL541OSgGEIxKsvf0kUYpG9q/sAQNoRcb1pUw23HmfgFs+w7whcQK0HudjW3/f8js3eI/dka+6/Q7cxe0P/X/+P31PwXAHJcmN0/aARTyEITmCufm6mcyO/aCDBpKoDy0YK9f+nbpRBnybgDVp3ac8Wbqtd8c6NJjtmLHWNAtl6jthejf0NJoXGvrIHbawogVtHBAD4vUXUOt1kZjUrR+AItOT49JlzJCjR/3qYFC+Ce8VNYa7TOHQourgPNHJ2vlhz6a4QFUNyN7FcdfK/qfQYOpDN4JqcsO1mCkZvR78LcDZG4Mqt3DQK04Xaip75PfSKdLz/joP4zkey5Lp9656ForGcUWfjYxXtODWx/5+2rEvQncprcRUJNh8mDRMWK/LaVBICFPTsMJ/lzLYShMdpUtlEEwPHDwURqzXXPbaTeaJsqARr/Kmk4l/ghaa+R5upoqID+jURb9MrX7fMdv3PSe9mq7wpUJzZ81cY2WKJ1l8KiS15nhEenThAJwRB9uFuJhuRWeP8qqUv6zKq28LmcbGAApNF9SbvzMWPrsSwS4vlolDuZOoau41V+4ETkbVuazmGOmgQfdWIR8LKHybWbv3gnxdOSJXC0GQ56apnz1XnJDSMr8uxw== acmcarther@gmail.com"
   "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBfrtb0GD9/+ZNRw58UJKFgEbVaOwRs0TmuleD3GHNXEI4iDcUMbQpaw6d3cJ/fo8HgSlal2I2EmwdMZBjFAJixDCXGjs92D3YjHjxKCqPAaKb+gEs8vg3kU/+JXVdibQpyynrR34Daxy+vpP/MXMmJkmpZgJbTIWQflcj/tsboS62HE0JX/sZ29FvECXYR2Skg+QqjiUxNDNPPvv6EOf62NDI7dEQYmNDjJmZREmeykrMPJldA7ynLA8tVo1gp+C4Q89tFjQOe5Rl16f9TDhwzeEsONIk6M4i0Md7NxgMRPIpEsqCYX139Nx54UJxpFY1v7uPTScBRoJx3/RRDQ7JxzNJexIXOBBCU57KDyAwF1tYWMKPSyWSocnzxHLBLnI5pnAS4P/OuuBDCcjBs/tz/GUsxEWHyZn97cR2kogLsxctxu3rO6r0AfBSEBvkFN1lEEyVJC1cktCzLBs9tZFloa5dkc7UuuUI2MRaaiK/c8IgbwqYD4xzPVoN7oAk+mxcM6Ab2fnUOueJHcq3odKL5pa4e7oTTdDklh+Rm98Hax88w7QP2dDWWUNKNhdEPLu1HtHgNdWyun7EnXJ879UXJJAz3hhhwWTbx3HLOiT5xoZuISc7jCfRNmOThCthw5Ti0skeLRgICA1LlszZUanxAH8sZlO8F4igqrS73C6luw== acmcarther@acmcarther0.mtv.corp.google.com"
  ];
}
