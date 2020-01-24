{ machinesConfigPath ? ./machines.json }:

let
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makeThanosServer = machine: {
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

        fileSystems."/data" = {
          device = "/dev/sdb";
          autoResize = true;
        };

      };
  };
  thanosServers = map makeThanosServer machines.thanos.configs;

in {}
//  builtins.listToAttrs thanosServers