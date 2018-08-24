{ machinesConfigPath ? ./machines.json }:

let
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makePostgresServer = machine: {
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
  postgresServers = map makePostgresServer machines.postgres.configs;

in {}
//  builtins.listToAttrs postgresServers