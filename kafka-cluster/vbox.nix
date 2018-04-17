let

  zookeeper = { ... }: {
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

  kafka = { ... }: {    
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

in {

  zk-0 = zookeeper;
  zk-1 = zookeeper;
  zk-2 = zookeeper;
  
  kafka-0 = kafka;
  kafka-1 = kafka;
  kafka-2 = kafka;

}