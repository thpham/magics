{ machinesConfigPath ? ./machines.json }:

let 
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  influxDBAdminPass = "neeW8fu4Rae7";

  makeMonitorServer = machine: {   
    name  = machine.name;
    value =
      { config, pkgs, lib, ... }:
      let
        #configs = import ./configs.nix { inherit pkgs; };

        influxdbInit = pkgs.writeText "influxdb-init.txt" ''
          # DDL
          CREATE DATABASE "prometheus"
          CREATE USER ${machine.influxdbUser} WITH PASSWORD '${machine.influxdbPass}'
          GRANT ALL ON "prometheus" TO ${machine.influxdbUser}
          ALTER RETENTION POLICY "autogen" ON "prometheus" DURATION 1d REPLICATION 1 SHARD DURATION 1d DEFAULT
        '';

      in {

        imports = [
          ../modules/services/prometheus/default.nix
          ../modules/services/databases/influxdb.nix
        ];
        disabledModules = [
          "services/monitoring/prometheus/default.nix"
          "services/databases/influxdb.nix"
        ];
        
        services = {
          influxdb = {
            enable = true;
            package = pkgs.influxdb;
            dataDir = "/data/influxdb";
            #extraConfig = '' '';
          };
          prometheus = {
            enable = true;
            dataDir = "/data/prometheus";
            extraFlags = [
              "--storage.tsdb.retention=15d"
            ];
            remoteWriteConfigs = [
              {
                url = "http://localhost:8086/api/v1/prom/write?u=${machine.influxdbUser}&p=${machine.influxdbPass}&db=prometheus";
              }
            ];
            remoteReadConfigs = [
              {
                url = "http://localhost:8086/api/v1/prom/read?u=${machine.influxdbUser}&p=${machine.influxdbPass}&db=prometheus";
              }
            ];
            scrapeConfigs = [
              {
                job_name = "${machine.name}";
                scrape_interval = "1m";
                static_configs = [
                  {targets = ["localhost:9090"]; labels = { alias = "prometheus"; };}
                  {targets = ["localhost:8086"]; labels = { alias = "influxdb"; };}
                  {targets = ["localhost:3000"]; labels = { alias = "grafana"; };}
                ];
              }
            ];
            #configText = configs.prometheusConfig;
            exporters.node = {
              enable = true;
              listenAddress = "localhost";
            };
          };
          grafana = {
            enable = true;
            addr = "0.0.0.0";
            dataDir = "/data/grafana";
            database.path = "/data/grafana/data/grafana.db";
            security = {
              adminPassword = "changeme";
              adminUser = "admin";
              secretKey = "ahGai4oisof0aemu4lo5lah3wiesaiFe";
            };
            users = {
              allowOrgCreate = true;
            };
          };
        };
        networking.firewall = {
          allowedTCPPorts = [
            80 443 # HTTP/S
            9090   # Prometheus
            8086   # InfluxDB HTTP service
            3000   # Grafana
          ];
        };

        systemd = {
          services.influxdb-init = {
            wantedBy = [ "influxdb.service" ];
            after = [ "influxdb.service" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true ;
              ExecStart = with pkgs; writeScript "influxdb-init.sh" ''
                #! ${bash}/bin/sh
                ${coreutils}/bin/sleep 2
                ${influxdb}/bin/influx -execute "CREATE USER admin WITH PASSWORD '${influxDBAdminPass}' WITH ALL PRIVILEGES"
                ${influxdb}/bin/influx -username 'admin' -password '${influxDBAdminPass}' -import -path=${influxdbInit}
              '';
            };
          };
        };

        environment.systemPackages = with pkgs; [
          influxdb
        ];

      };
  };
  monitorServers = map makeMonitorServer machines.monitor.configs;

in  { 
  network.description = "monitoring server";
  network.enableRollback = true;

  defaults = {
    imports = [ ../common.nix ];
  };
  
}
//  builtins.listToAttrs monitorServers