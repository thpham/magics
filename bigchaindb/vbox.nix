{ machinesConfigPath ? ./machines.json }:

let
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makeBigchainDBServer = machine: {
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
          };
        };
      };
  };
  bigchainDBServers = map makeBigchainDBServer machines.bigchaindb.configs;

in {}
//  builtins.listToAttrs bigchainDBServers