{ machinesConfigPath ? ./machines.json }:

let
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makeZookeeperServer = machine: {
    name  = machine.name;
    value =
      { ... }:
      {
        deployment = {
          targetEnv = "virtualbox";
          virtualbox = {
            vcpu = 1;
            memorySize = 1024;
            headless = true;
            #vmFlags = [];
          };
        };
      };
  };
  zookeeperServers = map makeZookeeperServer machines.zookeeper.configs;

  makeKafkaServer = machine: {
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
  kafkaServers = map makeKafkaServer machines.kafka.configs;

in {}
//  builtins.listToAttrs zookeeperServers
//  builtins.listToAttrs kafkaServers