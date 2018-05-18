{ aws-profile ? "default",
  environment ? "dev",
  aws-region  ? "us-east-1",
  machinesConfig ? builtins.readFile ./machines.json }:

let
  region = aws-region;
  accessKeyId = aws-profile;

  machines = builtins.fromJSON machinesConfig;

  makeEC2configs = ec2Deployment: filesys:
    { resources, ... }:
    { 
      deployment.targetEnv = "ec2";
      deployment.ec2 = {
          keyPair = resources.ec2KeyPairs.kafkazk-key-pair;
          accessKeyId = accessKeyId;
          region = region;
          ebsInitialRootDiskSize = 20;
          usePrivateIpAddress = false;  # should be true if managed within vpc
          associatePublicIpAddress = true;  # should be false if hidden within vpc
        } // ec2Deployment;
      fileSystems = filesys;
    };
  
  makeZookeeperServer = machine: {
    name  = machine.name;
    value = makeEC2configs {
        instanceType = machines.zookeeper.aws.instanceType;
        securityGroupIds =  machines.zookeeper.aws.securityGroupIds;
        subnetId = machine.aws-subnetId;
        tags = {
          Environment = environment;
          Group = "zookeeper";
        }; 
      } {};
  };
  zookeeperServers = map makeZookeeperServer machines.zookeeper.configs;

  makeKafkaServer = machine: {
    name  = machine.name;
    value = makeEC2configs {
        instanceType = machines.kafka.aws.instanceType;
        securityGroupIds = machines.kafka.aws.securityGroupIds;
        subnetId = machine.aws-subnetId;
        tags = {
          Environment = environment;
          Group = "kafka";
        }; 
      } {
        "/data" = {
          autoFormat = true;
          fsType = "ext4";
          device = "/dev/xvdf";
          ec2.size = machines.kafka.aws.storageSize;
          ec2.volumeType = "gp2";
          ec2.deleteOnTermination = true; # should be false for security
        };
      };
  };
  kafkaServers = map makeKafkaServer machines.kafka.configs;

in {
  # Provision an EC2 key pair.
  resources.ec2KeyPairs.kafkazk-key-pair =
    { inherit region accessKeyId; };
}
//  builtins.listToAttrs zookeeperServers
//  builtins.listToAttrs kafkaServers
