{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.concourse;
in {
  options.services.concourse = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the standalone Concourse service.";
    };

    atc_port = mkOption {
      type = types.int;
      default = 8080;
      description = "Concourse web UI port";
    };

    tsa_port = mkOption {
      type = types.int;
      default = 2222;
      description = "Concourse web scheduling port";
    };

    scheduler_user = mkOption {
      type = types.str;
      default = "concourse-scheduler";
      description = "User to run Concourse scheduler as";
    };

    scheduler_state_path = mkOption {
      type = types.str;
      default = "/var/lib/concourse/scheduler";
      description = "Concourse scheduler state directory";
    };

    worker_user = mkOption {
      type = types.str;
      default = "concourse-worker";
      description = "User to run Concourse worker as";
    };

    local_worker_state_path = mkOption {
      type = types.str;
      default = "/var/lib/concourse/local_worker";
      description = "Concourse worker state directory";
    };

    group = mkOption {
      type = types.str;
      default = "concourse";
      description = "Group to run all Concourse jobs as";
    };

    external_url = mkOption {
      type = types.str;
      default = "http://127.0.0.1:8080";
      description = "Path to this running service on the web for generated URLs";
    };

    basic_auth_username = mkOption {
      type = types.str;
      default = "admin";
      description = "Username for basic auth";
    };

    packages.concourse = mkOption {
      type = types.package;
      default = pkgs.concourse;
      defaultText = "pkgs.concourse";
      description = "Reference to the concourse package";
    };

    basic_auth_password = mkOption {
      type = types.str;
      default = "admin";
      description = "Password for basic auth";
    };

    postgres_username = mkOption {
      type = types.str;
      default = "concourse_scheduler";
      description = "Username that Concourse uses for postgres";
    };

    postgres_password = mkOption {
      type = types.str;
      default = "concourse_scheduler_password";
      description = "Password that Concourse uses for postgres";
    };

    postgres_database_name = mkOption {
      type = types.str;
      default = "atc-default";
      description = "Database name for Scheduler postgres";
    };
  };

  config = mkIf config.services.concourse.enable {
    users = {
      extraGroups = [
        { name = cfg.group; }
      ];

      extraUsers = [
        { name = cfg.scheduler_user;
          group = cfg.group;
          shell = "${pkgs.bash}/bin/bash";
        }
        { name = cfg.worker_user;
          group = cfg.group;
          shell = "${pkgs.bash}/bin/bash";
          extraGroups = ["docker"];
        }
      ];
    };

    services.postgresql.enable = mkDefault true;

    systemd.services.concourse_web = {
      description = "Concourse CI Web Interface";
      after = [ "network.target" "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        config.services.postgresql.package
        bash
        gitAndTools.git
        openssh
        go
      ];
      preStart = ''
        mkdir -p ${cfg.scheduler_state_path}
        mkdir -p ${cfg.local_worker_state_path}

        # Init postgres
        if ! test -e "${cfg.scheduler_state_path}/db-created"; then
          psql postgres -c "CREATE ROLE ${cfg.postgres_username} WITH LOGIN NOCREATEDB NOCREATEROLE NOCREATEUSER ENCRYPTED PASSWORD '${cfg.postgres_password}'"
          ${config.services.postgresql.package}/bin/createdb --owner ${cfg.postgres_username} ${cfg.postgres_database_name} || true
          touch "${cfg.scheduler_state_path}/db-created"
        fi

        if ! test -e "${cfg.scheduler_state_path}/session_signing_key"; then
          ssh-keygen -t rsa -f ${cfg.scheduler_state_path}/session_signing_key -N "" -q
        fi
        if ! test -e "${cfg.scheduler_state_path}/tsa_host_key"; then
          ssh-keygen -t rsa -f ${cfg.scheduler_state_path}/tsa_host_key -N "" -q
        fi
        if ! test -e "${cfg.local_worker_state_path}/worker_key"; then
          ssh-keygen -t rsa -f ${cfg.local_worker_state_path}/worker_key -N "" -q
        fi
        cp ${cfg.local_worker_state_path}/worker_key.pub ${cfg.scheduler_state_path}/authorized_worker_keys
        cp ${cfg.scheduler_state_path}/tsa_host_key.pub ${cfg.local_worker_state_path}/tsa_host_key.pub

        chown ${cfg.worker_user}:${cfg.group} ${cfg.local_worker_state_path}/tsa_host_key.pub
        chown ${cfg.worker_user}:${cfg.group} ${cfg.local_worker_state_path}/worker_key
        chown ${cfg.worker_user}:${cfg.group} ${cfg.local_worker_state_path}/worker_key.pub

        chown -R ${cfg.scheduler_user}:${cfg.group} ${cfg.scheduler_state_path}
      '';
      serviceConfig = {
        PermissionsStartOnly = true; # preStart must be run as root
        Type = "simple";
        User = cfg.scheduler_user;
        TimeoutSec = "300";
        Restart = "on-failure";
        #WorkingDirectory="${cfg.scheduler_state_path}";
        ExecStart =
          "${cfg.packages.concourse.out}/bin/concourse web"
            + " --basic-auth-username=\"${cfg.basic_auth_username}\""
            + " --basic-auth-password=\"${cfg.basic_auth_password}\""
            + " --postgres-user=\"${cfg.postgres_username}\""
            + " --postgres-password=\"${cfg.postgres_password}\""
            + " --postgres-database=\"${cfg.postgres_database_name}\""
            + " --bind-port=\"${toString cfg.atc_port}\""
            + " --tsa-bind-port=\"${toString cfg.tsa_port}\""
            + " --tsa-host-key=${cfg.scheduler_state_path}/tsa_host_key"
            + " --tsa-authorized-keys=${cfg.scheduler_state_path}/authorized_worker_keys"
            + " --session-signing-key=${cfg.scheduler_state_path}/session_signing_key"
            + " --external-url=\"${cfg.external_url}\"";
      };
    };

    systemd.services.concourse_worker = {
      description = "Concourse CI Build Worker";
      after = [ "network.target" "postgresql.service" "concourse_web.service" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        bash
        gitAndTools.git
        openssh
        go
        gzip
        docker
      ];
      preStart = ''
        mkdir -p ${cfg.local_worker_state_path}
        chown -R ${cfg.worker_user}:${cfg.group} ${cfg.local_worker_state_path}
      '';
      serviceConfig = {
        PermissionsStartOnly = true; # preStart must be run as root
        Type = "simple";
        User = "root";
        TimeoutSec = "300";
        Restart = "on-failure";
        #WorkingDirectory="${cfg.local_worker_state_path}";
        ExecStart =
          "${cfg.packages.concourse.out}/bin/concourse worker"
            + " --work-dir=\"${cfg.local_worker_state_path}\""
            + " --tsa-host=\"127.0.0.1:${toString cfg.tsa_port}\""
            + " --tsa-public-key=${cfg.local_worker_state_path}/tsa_host_key.pub"
            + " --tsa-worker-private-key=${cfg.local_worker_state_path}/worker_key";
      };
    };
  };
}
