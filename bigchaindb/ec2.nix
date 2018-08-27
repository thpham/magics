{ aws-profile ? "default",
  environment ? "dev",
  aws-region  ? "us-east-1",
  machinesConfigPath ? ./machines.json }:

let
  region = aws-region;
  accessKeyId = aws-profile;

  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makeEC2configs = ec2Deployment: filesys:
    { resources, ... }:
    { 
      deployment.targetEnv = "ec2";
      deployment.ec2 = {
          keyPair = resources.ec2KeyPairs.bigchaindb-key-pair;
          accessKeyId = accessKeyId;
          region = region;
          ebsInitialRootDiskSize = 20;
          usePrivateIpAddress = false;  # should be true if managed within vpc
          associatePublicIpAddress = true;  # should be false if hidden within vpc
        } // ec2Deployment;
      fileSystems = filesys;
    };
  
  makeBigchainDBServer = machine: {
    name  = machine.name;
    value = makeEC2configs {
        instanceType = machines.bigchaindb.aws.instanceType;
        securityGroupIds = machines.bigchaindb.aws.securityGroupIds;
        subnetId = machine.aws-subnetId;
        tags = {
          Environment = environment;
          Group = "databases";
        }; 
      } {
        "/data" = {
          autoFormat = true;
          fsType = "ext4";
          device = "/dev/xvdf";
          ec2.size = machines.bigchaindb.aws.storageSize;
          ec2.volumeType = "gp2";
          ec2.deleteOnTermination = true; # should be false for security
        };
      };
  };
  bigchainDBServers = map makeBigchainDBServer machines.bigchaindb.configs;

in {
  # Provision an EC2 key pair.
  resources.ec2KeyPairs.bigchaindb-key-pair =
    { inherit region accessKeyId; };
}
//  builtins.listToAttrs bigchainDBServers
