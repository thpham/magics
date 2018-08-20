{ machinesConfigPath ? ./machines.json }:

let 
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makePostgresServer = machine: {   
    name  = machine.name;
    value =
      { config, pkgs, lib, nodes , ... }:
      let
        #postgis = (pkgs.postgis.override { postgresql = pkgs.postgresql96; });

      in {
        #networking.firewall.enable = false;
        networking.firewall.allowedTCPPorts = [
          5432  # PostgreSQL
          9187  # prometheus postgres_exporter
        ];

        services.postgresql = {
          enable = true;
          package = pkgs.postgresql96;
          extraPlugins = with pkgs; [ postgis pgrouting pg_qualstats pg_stat_kcache powa-archivist ];
          enableTCPIP = true;
          dataDir = "/data/postgresql/9.6";
          authentication = ''
            local   all           all                        trust
            host    all           all      127.0.0.1/32      trust
            host    all           all      ::1/128           trust
            host    all           all      192.168.0.0/16    md5
          '';
        };

        systemd.services = {
          postgres_exporter = {
            description = "Prometheus PostgreSQL exporter";
            wantedBy = [ "multi-user.target" ];
            after = [ "network-interfaces.target" ];
            environment = {
              DATA_SOURCE_NAME="postgresql://postgres:postgres@localhost:5432/postgres?sslmode=disable";
            };
            serviceConfig = {
              User = "postgres";
              ExecStart = "${pkgs.prometheus-postgres-exporter}/bin/postgres_exporter";
              Restart = "always";
            };
          };
        };

        environment.systemPackages = with pkgs; [
          #wal-e
          wal-g
        ];

      };
  };
  postgresServers = map makePostgresServer machines.postgres.configs;

in  {
  network.description = "PostgreSQL machines";
  network.enableRollback = true;

  defaults = {
    imports = [ ../common.nix ];
  };
  
} 
//  builtins.listToAttrs postgresServers