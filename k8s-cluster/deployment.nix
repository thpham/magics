{ machinesConfig ? builtins.readFile ./machines.json }:

let
  machines = builtins.fromJSON machinesConfig;

  makeMasterServer = machine: {   
    name  = machine.name;
    value =
      { config, pkgs, lib, ... }:
      {
        services.kubernetes.roles = [ "master" ];
        services.zerotierone.enable = true;
      };
  };
  masterServers = map makeMasterServer machines.masters.configs;

  makeWorkerServer = machine: {   
    name  = machine.name;
    value =
      { config, pkgs, lib, ... }:
      {
        services.kubernetes.roles = [ "node" ];
      };
  }; 
  workerServers = map makeWorkerServer machines.workers.configs;

in {
  network.description = "k8s-cluster";
  network.enableRollback = true;

  defaults.imports = [
    ../common.nix
    ./kubernetes
  ];

}
//  builtins.listToAttrs masterServers
//  builtins.listToAttrs workerServers