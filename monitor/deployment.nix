{ machinesConfigPath ? ./machines.json }:

let 
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makeMonitorServer = machine: {   
    name  = machine.name;
    value =
      { config, pkgs, lib, ... }:

      with lib;
      let
        #configs = import ./configs.nix { inherit pkgs; };

        influxdbInit = pkgs.writeText "influxdb-init.txt" ''
          # DDL
          CREATE DATABASE "prometheus"
          CREATE USER ${machine.influxdb.dbUser} WITH PASSWORD '${machine.influxdb.dbPass}'
          GRANT ALL ON "prometheus" TO ${machine.influxdb.dbUser}
          ALTER RETENTION POLICY "autogen" ON "prometheus" DURATION 60d REPLICATION 1 SHARD DURATION 1d DEFAULT
        '';

        mkHtpasswd = vhostName: authDef: pkgs.writeText "${vhostName}.htpasswd" (
          concatStringsSep "\n" (mapAttrsToList (user: password: ''
            ${user}:{PLAIN}${password}
          '') authDef)
        );

        externalBaseUrl = "${if machine.tlsEnable then "https" else "http"}://${machine.fqdn}/";

      in {

        imports = [
          ../modules/services/prometheus/default.nix
          ../modules/services/databases/influxdb.nix
          ../modules/services/grafana/default.nix
        ];
        disabledModules = [
          "services/monitoring/prometheus/default.nix"
          "services/databases/influxdb.nix"
          "services/monitoring/grafana.nix"
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
            # alertingConfigs = {
            #   alertmanagers = [
            #     { 
            #       scheme = "http";
            #       static_configs = [
            #         { targets = [ "localhost:9093" ]; }
            #       ];
            #     }
            #   ];
            # };
            remoteWriteConfigs = [
              {
                url = "http://localhost:8086/api/v1/prom/write?u=${machine.influxdb.dbUser}&p=${machine.influxdb.dbPass}&db=prometheus";
              }
            ];
            remoteReadConfigs = [
              {
                url = "http://localhost:8086/api/v1/prom/read?u=${machine.influxdb.dbUser}&p=${machine.influxdb.dbPass}&db=prometheus";
                read_recent = true;
              }
            ];
            scrapeConfigs = [
              {
                job_name = "prometheus";
                scrape_interval = "1m";
                static_configs = [
                  {targets = ["localhost:9090"]; labels = { alias = "prometheus"; };}
                ];
              }
              {
                job_name = "influxdb";
                scrape_interval = "1m";
                static_configs = [
                  {targets = ["localhost:8086"]; labels = { alias = "influxdb"; };}
                ];
              }
              {
                job_name = "grafana";
                scrape_interval = "1m";
                static_configs = [
                  {targets = ["localhost:3000"]; labels = { alias = "grafana"; };}
                ];
              }
              {
                job_name = "node";
                scrape_interval = "1m";
                static_configs = [
                  {targets = ["localhost:9100"]; labels = { alias = "node"; };}
                ];
              }
            ];
            #configText = configs.prometheusConfig;
            exporters.node = {
              enable = true;
              listenAddress = "localhost";
            };
            # alertmanager = {
            #   enable = true;
            #   port = 9093;
            #   listenAddress = "0.0.0.0";
            #   webExternalUrl = "${externalBaseUrl}alertmanager";
            #   configText = ''
            #     global:
            #       resolve_timeout: 5m
            #     route:
            #       group_by: ['alertname']
            #       group_wait: 10s
            #       group_interval: 10s
            #       repeat_interval: 1h
            #       receiver: 'web.hook'
            #     receivers:
            #     - name: 'web.hook'
            #       webhook_configs:
            #       - url: 'http://127.0.0.1:5001/'
            #     inhibit_rules:
            #       - source_match:
            #           severity: 'critical'
            #         target_match:
            #           severity: 'warning'
            #         equal: ['alertname', 'dev', 'instance']
            #   '';
            # };
          };
          grafana = {
            enable = true;
            domain = machine.fqdn;
            rootUrl = externalBaseUrl;
            addr = "0.0.0.0";
            dataDir = "/data/grafana";
            database = {
              type = "sqlite3";
              path = "/data/grafana/data/grafana.db";
            };
            security = {
              adminUser = "admin";
              adminPassword = machine.grafana.adminPassword;
              secretKey = machine.grafana.secretKey;
            };
            analytics.reporting.enable = false;
            users = {
              autoAssignOrg = false;
            };
            smtp = {
              enable = true;
              host = machines.monitor.smtp.host;
              user = machines.monitor.smtp.user;
              password = machines.monitor.smtp.password;
              fromAddress = machines.monitor.smtp.fromAddress;
            };
            extraOptions = {};
          };
        };

        services.nginx = {
          enable = true;
          virtualHosts = {
            "${machine.fqdn}" = {
              addSSL = machine.tlsEnable;
              enableACME = machine.tlsEnable;
              default = true;
              locations = {
                "/" = { 
                  proxyPass = "http://localhost:3000";
                };
                "/prometheus/" = { 
                  proxyPass = "http://localhost:9090/";
                  extraConfig = ''
                    auth_basic secured;
                    auth_basic_user_file ${mkHtpasswd machine.name machine.HttpBasicAuth};
                    
                    proxy_set_header Accept-Encoding "";
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $scheme;

                    sub_filter_types text/html;
                    sub_filter_once off;
                    sub_filter '="/' '="/prometheus/';
                    ## APPEARS TO BE UNNECESSARY? sub_filter '="/static/' '="/static/prometheus/';
                    sub_filter 'var PATH_PREFIX = "";' 'var PATH_PREFIX = "/prometheus";';

                    rewrite ^/prometheus/?$ /prometheus/graph redirect;
                    rewrite ^/prometheus/(.*)$ /$1 break;
                  '';
                };
                #"/alertmanager/" = { 
                #  proxyPass = "http://localhost:9093/";
                #  extraConfig = ''
                #    auth_basic secured;
                #    auth_basic_user_file ${mkHtpasswd machine.name machine.HttpBasicAuth};
                #    proxy_set_header Host $host;
                #    proxy_set_header X-Real-IP $remote_addr;
                #    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                #    proxy_set_header X-Forwarded-Proto $scheme;
                #  '';
                #};
                "/influxdb/" = { 
                  proxyPass = "http://localhost:8086/";
                  extraConfig = ''
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $scheme;

                    proxy_max_temp_file_size 0;
                  '';
                };
              };
            };
          };
        };

        networking.firewall = {
          allowedTCPPorts = [
            80 443 # HTTP/S
            #9090   # Prometheus
            #9093   # AlertManager
            #8086   # InfluxDB HTTP service
            #3000   # Grafana
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
                ${influxdb}/bin/influx -execute "CREATE USER admin WITH PASSWORD '${machine.influxdb.adminPassword}' WITH ALL PRIVILEGES"
                ${influxdb}/bin/influx -username 'admin' -password '${machine.influxdb.adminPassword}' -import -path=${influxdbInit}
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