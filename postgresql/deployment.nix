{ machinesConfigPath ? ./machines.json }:

let 
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makePostgresServer = machine: {   
    name  = machine.name;
    value =
      { config, pkgs, lib, nodes , ... }:
      let
        configs = import ./configs.nix { inherit pkgs; };
      in {
        #networking.firewall.enable = false;
        networking.firewall.allowedTCPPorts = [
          5432  # PostgreSQL
          8888  # powa-web
          9187  # prometheus postgres_exporter
        ];

        services.postgresql = {
          enable = true;
          package = pkgs.postgresql96;
          extraPlugins = with pkgs; [ postgis pgrouting pg_qualstats pg_stat_kcache powa-archivist ];
          enableTCPIP = true;
          dataDir = "/data/postgresql/9.6";
          initialScript = "${configs.postgresInitScript}";
          extraConfig = configs.postgres-conf;
          authentication = configs.pg_hba;
        };

        users.groups.powa = {};
        users.users.powa = {
          name  = "powa";
          group = "powa";
          description = "powa-web server user";
        };
        
        environment.etc = {
          powa-web-config = {
            source = "${configs.powa-web-config}";
            target = "powa-web.conf";
            user = "powa";
            mode = "0400";
          };
        };

        systemd.services = {
          postgres_exporter = {
            description = "Prometheus PostgreSQL exporter";
            wantedBy = [ "multi-user.target" ];
            after = [ "network-interfaces.target" ];
            environment = {
              DATA_SOURCE_NAME="postgresql://postgres_exporter:Aechoh7yoogi@localhost:5432/postgres?sslmode=disable";
            };
            serviceConfig = {
              User = "postgres";
              ExecStart = "${pkgs.prometheus-postgres-exporter}/bin/postgres_exporter";
              Restart = "always";
            };
          };
          powa-web = {
            description = "Web interface for PoWa project";
            wantedBy = [ "multi-user.target" ];
            after = [ "network-interfaces.target" ];
            serviceConfig = {
              User = "powa";
              ExecStart = "${pkgs.powa-web}/bin/powa-web";
              Restart = "always";
            };
          };
        };

        environment.systemPackages = with pkgs; [
          wal-e
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