let

  masterInstanceSettings = [
    { id = 0; name = "master-0"; } 
    { id = 1; name = "master-1"; }
    { id = 2; name = "master-2"; }
  ];

  workerInstanceSettings = [
    { id = 0; name = "worker-0"; }
    { id = 1; name = "worker-1"; }
  ];

  makeMasterServer = machine: {   
    name  = machine.name;
    value =
      { config, pkgs, lib, ... }:
      {
        services.kubernetes.roles = [ "master" ];
        services.zerotierone.enable = true;
      };
  };

  makeWorkerServer = machine: {   
    name  = machine.name;
    value =
      { config, pkgs, lib, ... }:
      {
        services.kubernetes.roles = [ "node" ];
      };
  };

  masterServers = map makeMasterServer masterInstanceSettings;
  workerServers = map makeWorkerServer workerInstanceSettings;

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