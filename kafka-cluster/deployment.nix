let
    
    zookeeperInstanceSettings = [
      { id = 0; name = "zk-0"; } 
      { id = 1; name = "zk-1"; }
      { id = 2; name = "zk-2"; }
    ];

    kafkaInstanceSettings = [
      { id = 0; name = "kafka-0"; }
      { id = 1; name = "kafka-1"; }
      { id = 2; name = "kafka-2"; }
    ];

    

    makeKafkaServer = machine:
    {   name  = machine.name;

        value =
        { config, pkgs, lib, ... }:
        {   
          
          deployment = { 
            targetEnv = "virtualbox";
            virtualbox.vcpu = 2;
            virtualbox.memorySize = 2048;
            virtualbox.headless = true;
          };

          networking.firewall.enable = false;

          services.apache-kafka.enable = true;

          services.apache-kafka.brokerId  = machine.id;
          services.apache-kafka.hostname  = "${config.networking.privateIPv4}";

          services.apache-kafka.zookeeper = lib.concatStringsSep "," (map (x: x.name) zookeeperServers);

          services.apache-kafka.extraProperties = "zookeeper.connection.timeout.ms=600000";

          services.apache-kafka.jvmOptions =
          [   "-server"
              "-Xmx2048M"
              "-Xms1024M"
              "-XX:+UseCompressedOops"
              "-XX:+UseParNewGC"
              "-XX:+UseConcMarkSweepGC"
              "-XX:+CMSClassUnloadingEnabled"
              "-XX:+CMSScavengeBeforeRemark"
              "-XX:+DisableExplicitGC"
              "-Djava.awt.headless=true"
              "-Djava.net.preferIPv4Stack=true"
          ];
        };
    };

    makeZookeeperServer = machine:
    {   name  = machine.name;

        value =
        { config, pkgs, lib, ... }:
        {   
          
          deployment = { 
            targetEnv = "virtualbox";
            virtualbox.vcpu = 1;
            virtualbox.memorySize = 1024;
            virtualbox.headless = true;
          };
          
          networking.firewall.enable = false;

          services.zookeeper.dataDir = "/data";

          services.zookeeper.enable  = true;

          services.zookeeper.id = machine.id;

          services.zookeeper.servers =
              let toLine = n: x: "server.${toString (builtins.sub n 1)}=${x.name}:2888:3888\n";
              in lib.concatImapStrings toLine zookeeperServers;
        };
    };

    zookeeperServers = map makeZookeeperServer zookeeperInstanceSettings;

    kafkaServers     = map makeKafkaServer kafkaInstanceSettings;

in  { 
  network.description = "Kafka/Zookeeper Cluster";
  network.enableRollback = true;

  defaults = {
    imports = [ ../common.nix ];
  };
  
} 
//  builtins.listToAttrs zookeeperServers
//  builtins.listToAttrs kafkaServers