{ machinesConfigPath ? ./machines.json }:

let
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makePostgresServer = machine: {
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
  postgresServers = map makePostgresServer machines.postgres.configs;

in {}
//  builtins.listToAttrs postgresServers