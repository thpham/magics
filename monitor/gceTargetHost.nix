{ machinesConfigPath ? ./machines.json }:

let
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makeMonitorServer = machine: {
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
  monitorServers = map makeMonitorServer machines.monitor.configs;

in {}
//  builtins.listToAttrs monitorServers