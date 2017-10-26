{ config, pkgs, ... }:
let
  localhostReverseProxy = {url, port}:
  ''
    server {
      listen 443;
      server_name ${url};

      ssl_certificate /etc/letsencrypt/live/${url}/fullchain.pem;
      ssl_certificate_key /etc/letsencrypt/live/${url}/privkey.pem;
      ssl_dhparam /etc/letsencrypt/live/${url}/dhparams.pem;

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
        proxy_pass          http://localhost:${toString port};
        proxy_read_timeout  90;

        proxy_redirect      http://localhost:${toString port} https://${url};
      }
    }
  '';
in {
  services.nginx = {
    enable = true;
    config = ''
      http {
        server {
          listen 80;
          return 301 https://$host$request_uri;
        }
        ${localhostReverseProxy { url = "short.cheapassbox.com"; port = 7721; }}
        ${localhostReverseProxy { url = "wai.fi"; port = 7721;}}
        ${localhostReverseProxy { url = "cron.cheapassbox.com"; port = 2291;}}
        ${localhostReverseProxy { url = "jenkins.cheapassbox.com"; port = 7789;}}
        ${localhostReverseProxy { url = "grafana.cheapassbox.com"; port = 3000;}}
      }
      events {
        worker_connections 768;
        # multi_accept on;
      }
    '';
  };
}
