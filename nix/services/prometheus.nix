

let
  cfg = config.services.prometheus;
{
  options = {
    services.prometheus = {
      enable = mkEnableOption "Prometheus Server";
      config = mkOption {
        default = ""
        description = "
          Verbatim prometheus.yaml configuration.
        ";
      };
      web-listen-address = mkOption {
        type = types.str;
        default = ":9090";
        description = "
          Address to listen on for the web interface, API, and telemetry.
        ";
      };
      storage-local-path = mkOption {
        type = types.str;
        default = "/var/lib/prometheus";
        description = "
          Directory holding the prometheus state.
        ";
      };
      alertmanager = {
        url = {
          type = types.str;
          default = null;
          description = "Comma-separated list of Alertmanager URLs to send notification to.";
        };
      };
      user = mkOption {
        type = types.str;
        default = "prometheus";
        description = "User account under which prometheus runs.";
      };
      group = mkOption {
        type = types.str;
        default = "prometheus";
        description = "Group account under which prometheus runs.";
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.services.prometheus = {
      description = "Prometheus Server";
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        mkdir -p ${cfg.storage-local-path}
        chmod 700 ${cfg.storage-local-path}
        chown -R ${cfg.user}:${cfg.group} ${cfg.storage-local-path}
      '';
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/prometheus -config.file ${cfg.storage-local-path}";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "always";
        RestartSec = "10s";
        StartLimitInterval = "1min";
      };
    };
  }
};

