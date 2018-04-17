let

  k8s-master = { ... }: {
    services.kubernetes.roles = [ "master" ];
    services.zerotierone.enable = true;
  };

  k8s-worker = { ... }: {
    services.kubernetes.roles = [ "node" ];
  };

in {

  network.description = "k8s-cluster";
  network.enableRollback = true;

  defaults.imports = [
    ../common.nix
    ./kubernetes
  ];

  master-1 = k8s-master;
  master-2 = k8s-master;
  master-3 = k8s-master;

  worker-1 = k8s-worker;
  worker-2 = k8s-worker; 

}
