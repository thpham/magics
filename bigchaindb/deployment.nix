{ machinesConfigPath ? ./machines.json }:

let 
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makeBigchainDBServer = machine: {   
    name  = machine.name;
    value =
      { config, pkgs, lib, nodes , ... }:
      let
        
      in {
        services.nginx = {
          enable  = true;
          package = pkgs.nginx;
          recommendedGzipSettings  = true;
          recommendedOptimisation  = true;
          recommendedProxySettings = true;
          recommendedTlsSettings   = true;
          appendHttpConfig = ''
            proxy_hide_header X-Powered-By;
            more_clear_headers 'Server';
          '';
          virtualHosts = {
            "domain.tld" = {
              #enableACME = true;
              #forceSSL = true;
              extraConfig = ''
              '';
              locations = {
                "/" = {
                  proxyPass = "http://localhost:8080"; # BigchainDB / tendermint
                };
              };
            };
          };
        };

        #networking.firewall.enable = false;
        networking.firewall.allowedTCPPorts = [
          80 443 # Nginx HTTP/S
          26656 26657 # Tendermint
        ];
      
        services.mongodb = {
          enable  = true;
          package = pkgs.mongodb;
          bind_ip = "0.0.0.0";
          replSetName = "";
          dbpath = "/data/mongodb";
          extraConfig = ''
          '';
        };

        users.groups.bigchaindb = {};
        users.users.bigchaindb = {
          name  = "bigchaindb";
          group = "bigchaindb";
          description = "BigchainDB server user";
        };
        
        users.groups.tendermint = {};
        users.users.tendermint = {
          name  = "tendermint";
          group = "tendermint";
          description = "tendermint server user";
        };

        virtualisation.rkt = {
          enable = true;
        };

        systemd.services = {
          bigchaindb = {
            description = "BigchainDB Service";
            wantedBy = [ "multi-user.target" ];
            after = [ "network-interfaces.target" ];
            environment = {
              BIGCHAINDB_DATABASE_BACKEND="localmongodb";
              BIGCHAINDB_DATABASE_HOST="localhost";
              BIGCHAINDB_DATABASE_PORT="27017";
              BIGCHAINDB_SERVER_BIND="0.0.0.0";
              BIGCHAINDB_WSSERVER_HOST="0.0.0.0";
              BIGCHAINDB_WSSERVER_ADVERTISED_HOST="localhost";
              BIGCHAINDB_TENDERMINT_HOST="localhost";
              BIGCHAINDB_TENDERMINT_PORT="26657";
            };
            serviceConfig = {
              Slice = "machine.slice";
              #ExecStartPre="${pkgs.rkt}/bin/rkt fetch --insecure-options=image docker://bigchaindb/bigchaindb:2.0.0-beta5";
              ExecStart = ''\
                ${pkgs.rkt}/bin/rkt run --insecure-options=image \
                --inherit-env --cpu=500 --memory=512M \
                --port=9984:9984 --port=9985:9985 --port=26658:26658 \
                docker://bigchaindb/bigchaindb:2.0.0-beta5
              '';
              ExecStopPost="${pkgs.rkt}/bin/rkt gc --mark-only";
              KillMode = "mixed";
              Restart = "always";
            };
          };
        };

        environment.systemPackages = [
          pkgs.docker2aci
        ];

      };
  };
  bigchainDBServers = map makeBigchainDBServer machines.bigchaindb.configs;

in  {
  network.description = "BigchainDB nodes";
  network.enableRollback = true;

  defaults = {
    imports = [ ../common.nix ];
  };
  
} 
//  builtins.listToAttrs bigchainDBServers