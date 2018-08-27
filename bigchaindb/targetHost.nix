{ machinesConfigPath ? ./machines.json }:

let
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makeBigchainDBServer = machine: {
    name  = machine.name;
    value =
      { ... }:
      {
        deployment.targetHost = machine.targetHost;
      };
  };
  bigchainDBServers = map makeBigchainDBServer machines.bigchaindb.configs;

in {}
//  builtins.listToAttrs bigchainDBServers