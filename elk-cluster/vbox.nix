{ machinesConfig ? builtins.readFile ./machines.json }:

let
  machines = builtins.fromJSON machinesConfig;
  
  makeElasticsearchServer = machine: {
    name  = machine.name;
    value =
      { ... }:
      {
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
  elasticsearchServers = map makeElasticsearchServer machines.elasticsearch.configs;

  makeLogstashServer = machine: {
    name  = machine.name;
    value =
      { ... }:
      {
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
  logstashServers = map makeLogstashServer machines.logstash.configs;

  kibana = { ... }: {    
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

in {
  kibana = kibana;
}
//  builtins.listToAttrs elasticsearchServers
//  builtins.listToAttrs logstashServers