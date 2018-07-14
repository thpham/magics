{ machinesConfigPath ? ./machines.json }:

let
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makeMasterServer = machine: {
    name  = machine.name;
    value =
      { ... }:
      {
        deployment = {
          targetEnv = "libvirtd";
          libvirtd = {
            vcpu = 2;
            memorySize = 4096;
            headless = true;
            baseImageSize = 20;
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
        deployment = {
          targetEnv = "libvirtd";
          libvirtd = {
            vcpu = 2;
            memorySize = 4096;
            headless = true;
            baseImageSize = 20;
          };
        };
      };
  };
  workerServers = map makeWorkerServer machines.workers.configs;

in {}
//  builtins.listToAttrs masterServers
//  builtins.listToAttrs workerServers
