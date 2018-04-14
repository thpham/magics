let
  # The colon states that this is a function, with an argument named id.
  makeMaster = id: {
    name = "mesos-master-${toString id}";
    value = { config, pkgs, lib, nodes, ... }: {
      deployment.targetEnv = "virtualbox";
      deployment.virtualbox.memorySize = 512;
      deployment.virtualbox.headless = true;
      networking.firewall.enable = false;
      services.zookeeper = {
        enable = true;
        id = id;
        servers = let 
            zk_servers = map zk_server_line masterServers;
            zk_server_line = zk: (let
                zkId = toString nodes.${zk.name}.config.services.zookeeper.id;
              in "server.${zkId}=${zk.name}:2888:3888");
          in
            builtins.concatStringsSep "\n"  zk_servers;
      };
      services.mesos.master = {
        enable = true;
        zk = mesosZkString;
        quorum = (nrMasterServers / 2 ) + 1; # Ensure a quorum of at least half + 1.
      };

      services.marathon = {
        enable = true;
        zookeeperHosts = builtins.map (s: s.name + ":2181") masterServers;
        user = "root";
      };
    };
  };
  makeSlave = id: {
    name = "mesos-slave-${toString id}";
    # So 'value' is a function that takes an attribute set (Dictionary in python speak) as an input, and returns a new attribute set.
    value = { config, pkgs, lib, ... }: {
      deployment.targetEnv = "virtualbox";
      deployment.virtualbox.memorySize = 1024 * 2;
      deployment.virtualbox.headless = true;
      networking.firewall.enable = false;
      virtualisation.docker.enable = true;

      services.mesos.slave = {
        enable = true;
        withDocker = true;
        master = mesosZkString;
      };
    };
  };
  nrMasterServers = 3;
  nrSlaveServers = 2;
  # This generates a list [ { name = "mesos-master-0", value = <LAMBDA> } { name = "mesos-master-1”; value = <LAMBDA> } ]
  masterServers = builtins.genList makeMaster nrMasterServers;
  slaveServers = builtins.genList makeSlave nrSlaveServers;
  mesosZkString = let 
                   zkServers = builtins.concatStringsSep "," (builtins.map (s: s.name + ":2181") masterServers);
                  in 
                    "zk://${zkServers}/mesos";

in
  { network.description = "Marathon test"; }
    // builtins.listToAttrs masterServers
    // builtins.listToAttrs slaveServers
# The listToAttrs function builds an attribute set from a list of attribute sets with some { name = "attr_name"; value = "attr_value"; }. It returns a set { attr_name = "attr_value" }
