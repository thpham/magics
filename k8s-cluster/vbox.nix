let

  k8s-master = { ... }: {
    # because of interface creation order in vbox
    services.flannel.iface = "enp0s8";
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

  k8s-worker = { ... }: {
    # because of interface creation order in vbox
    services.flannel.iface = "enp0s8";
    deployment = {
      targetEnv = "virtualbox";
      virtualbox = {
        vcpu = 2;
        memorySize = 4096;
        headless = true;
        #vmFlags = [];
        disks = { 
          data = {
            port = 1;
            size = 5120; # 5Gb
          };
        };
      };
    };
    fileSystems.data = {
      device = "/dev/sdb";
      fsType = "xfs";
      label = "data";
      autoFormat = true;
      mountPoint = "/data";
    };
  };

in {

  master-0 = k8s-master;
  master-1 = k8s-master;
  master-2 = k8s-master;
  
  worker-0 = k8s-worker;
  worker-1 = k8s-worker;

}
