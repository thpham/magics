{ machinesConfigPath ? ./machines.json }:

let 
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makeRegistryServer = machine: {   
    name  = machine.name;
    value =
      { config, pkgs, lib, ... }:
      let

      in {

        services = {
          nexus = {
            enable = true;
            package = pkgs.nexus;
            listenAddress = "0.0.0.0";
            home = "/data/sonatype-work";
          };
        };

        services.nginx = {
          enable = true;
          virtualHosts = {
            "${machine.name}.domain.tld" = {
              #addSSL = true;
              #enableACME = true;
              default = true;
              locations = {
                "/" = { 
                  proxyPass = "http://localhost:8081";
                };
              };
            };
          };
        };

        networking.firewall = {
          allowedTCPPorts = [
            80 443 # HTTP/S
            8081 # Nexus
          ];
        };

        #environment.systemPackages = with pkgs; [
        #];

      };
  };
  registryServers = map makeRegistryServer machines.registry.configs;

in  { 
  network.description = "registry server";
  network.enableRollback = true;

  defaults = {
    imports = [ ../common.nix ];
  };
  
}
//  builtins.listToAttrs registryServers