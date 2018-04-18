let
  elasticsearch = { ... }: {
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

  logstash = { ... }: {    
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
  es-0   = elasticsearch;
  es-1   = elasticsearch;
  es-2   = elasticsearch;

  kibana = kibana;
  
  ls-0   = logstash;
}