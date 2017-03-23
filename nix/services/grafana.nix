{ config, pkgs, ... }:
{
  nixpkgs.config.packageOverrides = pkgs: rec {
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
  };

  services.grafana = {
    addr = "0.0.0.0";
    enable = true;
  };
}
