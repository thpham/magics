{ machinesConfigPath ? ./machines.json }:

let
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makeRegistryServer = machine: {
    name  = machine.name;
    value =
      { ... }:
      {
        deployment = {
          targetEnv = "none";
          targetHost = machine.targetHost;
        };

        # Be careful, not to have a /etc/boto.cfg set (i.e. http://bit.ly/2MNBsL7)
        imports = [<nixpkgs/nixos/modules/virtualisation/google-compute-config.nix>];

        #fileSystems."/data" = {
        #  device = "/dev/disk/by-label/data";
        #  autoResize = true;
        #};

      };
  };
  registryServers = map makeRegistryServer machines.registry.configs;

in {}
//  builtins.listToAttrs registryServers