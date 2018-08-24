{ machinesConfigPath ? ./machines.json }:

let
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makePostgresServer = machine: {
    name  = machine.name;
    value =
      { ... }:
      {
        deployment.targetHost = machine.targetHost;
      };
  };
  postgresServers = map makePostgresServer machines.postgres.configs;

in {}
//  builtins.listToAttrs postgresServers