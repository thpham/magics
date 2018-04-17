let

  k8s-master = { ... }: {
    # because of interface creation order in vbox
    services.flannel.iface = "enp0s8"; 
    
    deployment = {
      targetEnv = "virtualbox";
      virtualbox = {
        vcpu = 2;
        memorySize = 3072;
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
      };
    };
  };

in {

  master-1 = k8s-master;
  master-2 = k8s-master;
  master-3 = k8s-master;
  
  worker-1 = k8s-worker;
  worker-2 = k8s-worker;

}
