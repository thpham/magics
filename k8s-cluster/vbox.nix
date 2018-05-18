{ machinesConfig ? builtins.readFile ./machines.json }:

let
  machines = builtins.fromJSON machinesConfig;

  makeMasterServer = machine: {
    name  = machine.name;
    value =
      { ... }:
      {
        # because of interface creation order in vbox
        services.flannel.iface = "enp0s8";
        deployment = {
          targetEnv = "virtualbox";
          virtualbox = {
            vcpu = 2;
            memorySize = 4096;
            headless = true;
            #vmFlags = [];
          };
        };
      };
  };
  masterServers = map makeMasterServer machines.masters.configs;

  makeWorkerServer = machine: {
    name  = machine.name;
    value =
      { ... }:
      {
        # because of interface creation order in vbox
        services.flannel.iface = "enp0s8";
        deployment = {
          targetEnv = "virtualbox";
          virtualbox = {
            vcpu = 2;
            memorySize = 4096;
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
  workerServers = map makeWorkerServer machines.workers.configs;

in {}
//  builtins.listToAttrs masterServers
//  builtins.listToAttrs workerServers
