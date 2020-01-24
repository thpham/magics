{ machinesConfigPath ? ./machines.json }:

let 
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makeThanosServer = machine: {   
    name  = machine.name;
    value =
      { config, pkgs, lib, ... }:

      with lib;
      let
        mkHtpasswd = vhostName: authDef: pkgs.writeText "${vhostName}.htpasswd" (
          concatStringsSep "\n" (mapAttrsToList (user: password: ''
            ${user}:{PLAIN}${password}
          '') authDef)
        );

        externalBaseUrl = "${if machine.tlsEnable then "https" else "http"}://${machine.fqdn}/";

        minioListenAddress = "127.0.0.1:9000";
        minioConfigDir = "/var/lib/minio/config";
        minioAccessKey = "12345";
        minioSecretKey = "87654321";

        thanosBucketName = "thanos-store";

        storeConfigFile = pkgs.writeText "thanos-store_config.yaml" ''
          type: S3
          config:
            bucket: ${thanosBucketName}
            endpoint: "${minioListenAddress}"
            access_key: "${minioAccessKey}"
            insecure: true
            signature_version2: false
            encrypt_sse: false
            secret_key: "${minioSecretKey}"
            http_config:
              insecure_skip_verify: true
              idle_conn_timeout: 10s
        '';        

      in {

        #imports = [
        #  ../modules/services/grafana/default.nix
        #];
        #disabledModules = [
        #  "services/monitoring/grafana.nix"
        #];
        
        services = {
          
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
              host = machines.thanos.smtp.host;
              user = machines.thanos.smtp.user;
              password = machines.thanos.smtp.password;
              fromAddress = machines.thanos.smtp.fromAddress;
            };
            extraOptions = {};
          };

          nginx = {
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
                  "/remote_write" = { 
                    proxyPass = "http://localhost:10908";
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
                };
              };
            };
          };

          minio = {
            enable = true;
            configDir = minioConfigDir;
            #dataDir = "";
            listenAddress = minioListenAddress;
            browser = false;
            accessKey = minioAccessKey;
            secretKey = minioSecretKey;
          };

          thanos = {
            package = pkgs.thanos;
            sidecar = {
              enable = false;
              grpc-address = "127.0.0.1:10901";
              http-address = "127.0.0.1:10902";
            };
            query = {
              enable = true;
              grpc-address = "127.0.0.1:10903";
              http-address = "127.0.0.1:10904"; # the grafana datasource(prometheus)
            };
            store = {
              enable = true;
              grpc-address = "127.0.0.1:10905";
              http-address = "127.0.0.1:10906";
              objstore.config-file = builtins.toPath storeConfigFile;
            };
            receive = {
              enable = true;
              tsdb.retention = "7d";
              grpc-address = "127.0.0.1:10907";
              remote-write.address = "127.0.0.1:10908";
              http-address = "127.0.0.1:10909";
              
            };
            rule = {
              enable = true;
              grpc-address = "127.0.0.1:10910";
              http-address = "127.0.0.1:10911";
            };
            compact = {
              enable = true;
              http-address = "127.0.0.1:10912";
            };
            downsample = {
              enable = true;
            };  
          };
          
        };

        networking.firewall = {
          allowedTCPPorts = [
            80 443 # HTTP/S
            #3000   # Grafana
          ];
        };

        environment.systemPackages = with pkgs; [
          minio-client
        ];


        systemd = {
          services.thanos-minio-init = {
            after = [ "minio.service" ];
            wantedBy = [ "thanos-store.service" ];
            before = [ "thanos-store.service" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true ;
              ExecStart =  with pkgs; writeScript "bucket-init.sh" ''
                #! ${bash}/bin/sh
                
                export PATH="$PATH:${minio-client}/bin:${glibc}/bin"
                
                sleep 2
                
                mc config host add local http://${minioListenAddress} ${minioAccessKey} ${minioSecretKey};
                mc rm -r --force local/${thanosBucketName};
                mc mb local/${thanosBucketName}
              '';
            };
            environment = with pkgs; {
              HOME = "/root";
            };

          };
        };

      };
  };
  thanosServers = map makeThanosServer machines.thanos.configs;

in  { 
  network.description = "thanos server";
  network.enableRollback = true;

  defaults = {
    imports = [ ../common.nix ];
  };
  
}
//  builtins.listToAttrs thanosServers