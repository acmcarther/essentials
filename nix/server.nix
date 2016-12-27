{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bind                             # DNS lookup util
    openssl
    skype
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
    prometheus-cli
    wireshark
    mrxvt
    jenkins
    vlc
    #(import ./custom-nix-pkgs/homeassistant/default.nix)
  ];

  nixpkgs.config.packageOverrides = pkgs: rec {
    jenkins = pkgs.jenkins.overrideDerivation( oldAttrs: {
      src = pkgs.fetchurl {
        url = "http://mirrors.jenkins-ci.org/war/2.37/jenkins.war";
        sha256 = "12jcpmka594qpn22s7x1p1kszd5bbp7y6x5a6ncvq30m093993yk";
      };
    });

    grafana = pkgs.grafana.overrideDerivation( oldAttrs: rec {
      version = "4.0.2";
      ts = "1481203731";

      src = pkgs.fetchFromGitHub {
        rev = "v${version}";
        owner = "grafana";
        repo = "grafana";
        sha256 = "1z71nb4qmp1qavsc101k86hc4yyis3mlqb1csrymkhgl94qpiiqm";
      };

      srcStatic = pkgs.fetchurl {
        url = "https://grafanarel.s3.amazonaws.com/builds/grafana-${version}-${ts}.linux-x64.tar.gz";
        sha256 = "1jnh2hn95r1ik0z31b4p0niq7apykppf8jcjjhsbqf8yp8i2b737";
      };
    });

    elasticsearch2 = pkgs.elasticsearch2.overrideDerivation( oldAttrs: {
      src = pkgs.fetchurl {
        url = "https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.4.0/elasticsearch-2.4.0.tar.gz";
        sha256 = "1jglmj1dnh1n2niyds6iyrpf6x6ppqgkivzy6qabkjvvmr013q1s";
      };
    });
  };

  networking = {
    hostName = "bbq-server"; # Define your hostname.
    hostId = "87813f15";
    firewall.allowedTCPPorts = [80 443 7789 8123 25980 5601 1900 9090 3000];
    firewall.allowedUDPPorts = [80 443 7789 8123 25980 5601 1900 9090 3000];
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

        # Shortener
        server {
          listen 443;
          server_name short.cheapassbox.com;

          ssl_certificate /etc/letsencrypt/live/short.cheapassbox.com/fullchain.pem;
          ssl_certificate_key /etc/letsencrypt/live/short.cheapassbox.com/privkey.pem;
          ssl_dhparam /etc/letsencrypt/live/short.cheapassbox.com/dhparams.pem;

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
            proxy_pass          http://localhost:7721;
            proxy_read_timeout  90;

            proxy_redirect      http://localhost:7721 https://short.cheapassbox.com;
          }
        }

        # Shortener (short version)
        server {
          listen 443;
          server_name wai.fi;

          ssl_certificate /etc/letsencrypt/live/wai.fi/fullchain.pem;
          ssl_certificate_key /etc/letsencrypt/live/wai.fi/privkey.pem;
          ssl_dhparam /etc/letsencrypt/live/wai.fi/dhparams.pem;

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
            proxy_pass          http://localhost:7721;
            proxy_read_timeout  90;

            proxy_redirect      http://localhost:7721 https://wai.fi;
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

        # grafana
        server {
          listen 443;
          server_name grafana.cheapassbox.com;

          ssl_certificate /etc/letsencrypt/live/grafana.cheapassbox.com/fullchain.pem;
          ssl_certificate_key /etc/letsencrypt/live/grafana.cheapassbox.com/privkey.pem;
          ssl_dhparam /etc/letsencrypt/live/grafana.cheapassbox.com/dhparams.pem;

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
            proxy_pass          http://localhost:3000;
            proxy_read_timeout  90;

            proxy_redirect      http://localhost:3000 https://grafana.cheapassbox.com;
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

  services.kibana = {
    enable = true;
    listenAddress = "0.0.0.0";
  };

  services.elasticsearch.enable = true;

  services.logstash = {
    enable = true;
    enableWeb = true;
    port = "9292";
    inputConfig = ''
      file {
        type => "nginx-access"
        path => "/var/spool/nginx/logs/access.log"
        start_position => "beginning"
        sincedb_path => "/dev/null"
      }
    '';
    /*
      file {
        type => "nginx-error"
        path => "/var/spool/nginx/logs/error.log"
        start_position => "error"
      }
      pipe {
        command => "${pkgs.systemd}/bin/journalctl -f -o json"
        type => "syslog"
        codec => json {}
      }
      */
    filterConfig = ''
      if [type] == "nginx-access" {
        grok {
          match => { "message" => "%{IPORHOST:remote_addr} - %{USERNAME:remote_user} \[%{HTTPDATE:time_local}\] %{QS:request} %{INT:status} %{INT:body_bytes_sent} %{QS:http_referer} %{QS:http_user_agent}" }
        }
        geoip {
          source => "remote_addr"
          target => "geoip"
          add_field => [ "[geoip][coordinates]", "%{[geoip][longitude]}" ]
          add_field => [ "[geoip][coordinates]", "%{[geoip][latitude]}" ]
        }
        mutate {
          convert => [ "[geoip][coordinates]", "float" ]
        }
      }
    '';
    outputConfig = ''
      elasticsearch {
        hosts => ["localhost:9200"]
      }
      stdout {
        codec => rubydebug
      }
    '';
  };

  services.fail2ban.enable = false;

  /*
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
  */

  services.jenkins = {
    enable = true;
    extraGroups = [ "essentials" ];
    port = 7789;
  };

  services.grafana = {
    addr = "0.0.0.0";
    enable = true;
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
        pkgs.gcc49 pkgs.bash pkgs.rustcLatest pkgs.cargoLatest
      ];
    };
    in [ env ];

  systemd.services.jenkins.serviceConfig.TimeoutStartSec = "10min";

  users.users.guest.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxx9Up0yJ/txCDtZRL7rb1qCfU5Hh81Il53OKMTF7EkTB2V915amgoHdjdTac2TisIasq9uNIpmZ8GA1mEICBa9A+enk31k/AI3DC6LwfPIOh+rdueB+acuhE8keTENEdwiwZ5KtiCELtCEidA0mPxu2n5tLPGk+u871/Coes73csHtMgLzI5nQkGZSwbjWSBcMzOjGKF9fhpoItQpZHt4kKTyZkpfKU4pvT8vNcyAPNQsQ4BXHfofl02n8qUDgZ/DeNgzBc4efuMiSFKOnUQd0cHLQVAYIjvj91WohiqblmkdarDLMZJ67x9qjhrK/epUCh/F48EKtUFPrSghW6vV henryestela@gmail.com"
  ];

  users.users.alex.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDnQusENKbsEzR4o8Sbrs3gkZVNWhBxS9b16vWIs75q47k+/tMZ0OgL541OSgGEIxKsvf0kUYpG9q/sAQNoRcb1pUw23HmfgFs+w7whcQK0HudjW3/f8js3eI/dka+6/Q7cxe0P/X/+P31PwXAHJcmN0/aARTyEITmCufm6mcyO/aCDBpKoDy0YK9f+nbpRBnybgDVp3ac8Wbqtd8c6NJjtmLHWNAtl6jthejf0NJoXGvrIHbawogVtHBAD4vUXUOt1kZjUrR+AItOT49JlzJCjR/3qYFC+Ce8VNYa7TOHQourgPNHJ2vlhz6a4QFUNyN7FcdfK/qfQYOpDN4JqcsO1mCkZvR78LcDZG4Mqt3DQK04Xaip75PfSKdLz/joP4zkey5Lp9656ForGcUWfjYxXtODWx/5+2rEvQncprcRUJNh8mDRMWK/LaVBICFPTsMJ/lzLYShMdpUtlEEwPHDwURqzXXPbaTeaJsqARr/Kmk4l/ghaa+R5upoqID+jURb9MrX7fMdv3PSe9mq7wpUJzZ81cY2WKJ1l8KiS15nhEenThAJwRB9uFuJhuRWeP8qqUv6zKq28LmcbGAApNF9SbvzMWPrsSwS4vlolDuZOoau41V+4ETkbVuazmGOmgQfdWIR8LKHybWbv3gnxdOSJXC0GQ56apnz1XnJDSMr8uxw== acmcarther@gmail.com"
   "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBfrtb0GD9/+ZNRw58UJKFgEbVaOwRs0TmuleD3GHNXEI4iDcUMbQpaw6d3cJ/fo8HgSlal2I2EmwdMZBjFAJixDCXGjs92D3YjHjxKCqPAaKb+gEs8vg3kU/+JXVdibQpyynrR34Daxy+vpP/MXMmJkmpZgJbTIWQflcj/tsboS62HE0JX/sZ29FvECXYR2Skg+QqjiUxNDNPPvv6EOf62NDI7dEQYmNDjJmZREmeykrMPJldA7ynLA8tVo1gp+C4Q89tFjQOe5Rl16f9TDhwzeEsONIk6M4i0Md7NxgMRPIpEsqCYX139Nx54UJxpFY1v7uPTScBRoJx3/RRDQ7JxzNJexIXOBBCU57KDyAwF1tYWMKPSyWSocnzxHLBLnI5pnAS4P/OuuBDCcjBs/tz/GUsxEWHyZn97cR2kogLsxctxu3rO6r0AfBSEBvkFN1lEEyVJC1cktCzLBs9tZFloa5dkc7UuuUI2MRaaiK/c8IgbwqYD4xzPVoN7oAk+mxcM6Ab2fnUOueJHcq3odKL5pa4e7oTTdDklh+Rm98Hax88w7QP2dDWWUNKNhdEPLu1HtHgNdWyun7EnXJ879UXJJAz3hhhwWTbx3HLOiT5xoZuISc7jCfRNmOThCthw5Ti0skeLRgICA1LlszZUanxAH8sZlO8F4igqrS73C6luw== acmcarther@acmcarther0.mtv.corp.google.com"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXLnoHSc8UJ4WbLZ/ZS8RJRBeBhVhTAAcwKu2m8b2rgpUIczbA9MkiafbVh/Z2lli5Mv4hlfGkInlolJ0VaUX8e4eV60kqaNcnd5h5z9883hN2oX9SslGOMuQVdsEKmyTle+Mi1IrVKGUhYlwyB2w3jborbvHvNZ3xVqfH9PYDY9vXn7UkYvgqRbZM8JlI+Lf9w4bNPDFGjfkaZVibCGj2nDXAI9Ja0j4BpjKAnSzAZugAjeERuhspBZrfesvJSzUzB2Vt91RwXVSfcm1/hI3zXWAN3nc8XXkwFK/e3r7BN92lPgOdEuM89LkmGKcRaIcd59r55eKymVzTEPRptyCPuDKWZtkoFEBwy8SILU49r8bowolRYvhRFoy4Mx1vj6b9XtKHTQOD3+0//1DZsrhJ/3NNmXt7poFAsOID9gG+Z+hI/zisQmkKy+l0n3Vs3+aUHVKjcL4lzA00bUFP6dKPzIuX50Y5Ui0VwuYpaCk0ztbMzpYkgqjZZpl/5xsw/nS9AtdapfAMjoW2ILyhvLHNoGSfgEbpIpnP15exlQ6xJoGmCgUIZ9OL8cuBDIAcYX3VoUtvsvso8TbPvx60TuBsN5Ip/VEsVCJajksu3rCMRMSN4/Vh9+88yQZXz+hyaeUOTKi8r55q5idMrUtjbKcA+/3kGCbtZeHm4+HpyUO2Ew== acmcarther@gmail.com"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1XsuNMmaBTBfHWuRqrxK58961aD1JqAeo5rCNHThczzoEvNwkPwWQ5qOcNnAxpnnlk0UVz7iB+tnXyxzASZ5QFLlbHOIqXXHHKJ4wIAsJup5ED8thhp+CVKrzUHWAngQoFT5F3BFi1rFyPGxRYqrZu1/C1IR4CZfaKiMlnZYRm1pF3al9J8sf7FJFaRv2F5dJTosHAM6A2IILPgh2dtTdou7OYoylu+wU4Mns9K7Q7WSgzWYS8vjcSfH6KFiSrsygvyHFvnWVcpdK+zoUN2J9wEBxPxxO0vcxI1t0ehyg70Cfcg7UFmHYh7KhOIy8cZtap7ZW7uuePYgV2MDX2BRJ alex@slowcooker"
  ];
}
