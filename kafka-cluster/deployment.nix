{ machinesConfigPath ? ./machines.json }:

let 
  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makeKafkaServer = machine: {   
    name  = machine.name;
    value =
      { config, pkgs, lib, ... }:
      {
        networking.firewall.enable = false;

        services.apache-kafka = {
          enable = true;
          logDirs = [
            "/data"
          ];
          brokerId  = machine.id;
          hostname  = "${config.networking.privateIPv4}";
          zookeeper = lib.concatStringsSep "," (map (x: x.name) zookeeperServers);
          extraProperties = "zookeeper.connection.timeout.ms=600000";
          jvmOptions = [
            "-server"
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
  };
  kafkaServers = map makeKafkaServer machines.kafka.configs;
  
  makeZookeeperServer = machine: {
    name  = machine.name;
    value =
      { config, pkgs, lib, ... }:
      {          
        networking.firewall.enable = false;

        services.zookeeper = {
          enable  = true;
          dataDir = "/data";
          id = machine.id;
          servers =
            let toLine = n: x: "server.${toString (builtins.sub n 1)}=${x.name}:2888:3888\n";
            in lib.concatImapStrings toLine zookeeperServers;
        };
      };
  };
  zookeeperServers = map makeZookeeperServer machines.zookeeper.configs;

in  { 
  network.description = "kafkazk-cluster";
  network.enableRollback = true;

  defaults = {
    imports = [ ../common.nix ];
  };
  
} 
//  builtins.listToAttrs zookeeperServers
//  builtins.listToAttrs kafkaServers