{ machinesConfigPath ? ./machines.json }:

let 
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makeMonitorServer = machine: {   
    name  = machine.name;
    value =
      { config, pkgs, lib, ... }:
      {
        imports = [ ../modules/services/prometheus/default.nix  ];
        disabledModules = [ "services/monitoring/prometheus/default.nix" ];
        
        services = {
          influxdb = {
            enable = true;
            package = pkgs.influxdb;
            dataDir = "/data/influxdb";
          };
          prometheus = {
            enable = true;
            dataDir = "/data/prometheus";
            extraFlags = [
              "--storage.tsdb.retention=15d"
            ];
            remoteWriteConfigs = [
              {
                url = "http://localhost:8086/api/v1/prom/write?db=prometheus";
              }
            ];
            remoteReadConfigs = [
              {
                url = "http://localhost:8086/api/v1/prom/read?db=prometheus";
              }
            ];
            scrapeConfigs = [
              {
                job_name = "prometheus";
                scrape_interval = "1m";
                static_configs = [
                  {
                    targets = [
                      "localhost:9090"
                    ];
                    labels = {
                      alias = "monitor";
                    };
                  }
                ];
              }
            ];
            #configText = builtins.readFile machine.prometheusConfigFile;
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
            9090   # Prometheus
            8086   # InfluxDB HTTP service
            3000   # Grafana
          ];
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