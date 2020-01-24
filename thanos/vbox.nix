{ machinesConfigPath ? ./machines.json }:

let
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makeThanosServer = machine: {
    name  = machine.name;
    value =
      { ... }:
      {
        deployment = {
          targetEnv = "virtualbox";
          virtualbox = {
            vcpu = 2;
            memorySize = 2048;
            headless = true;
            #vmFlags = [];
            disks = { 
              data = {
                port = 1;
                size = 5120; # 5Gb
              };
            };
          };
        };
        fileSystems.data = {
          device = "/dev/sdb";
          fsType = "xfs";
          label = "data";
          autoFormat = true;
          mountPoint = "/data";
        };
      };
  };
  thanosServers = map makeThanosServer machines.thanos.configs;

in {}
//  builtins.listToAttrs thanosServers