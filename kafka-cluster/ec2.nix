{ aws-profile ? "default",
  environment ? "dev",
  aws-region  ? "us-east-1" }:

let
  region = aws-region;
  accessKeyId = aws-profile;

  deployment = ec2Deployment: filesys:
    { resources, ... }:
    { 
      deployment.targetEnv = "ec2";
      deployment.ec2 = {
          keyPair = resources.ec2KeyPairs.k8s-key-pair;
          accessKeyId = accessKeyId;
          region = region;
          subnetId = "subnet-";   # to be adapted accordingly, e.g. default
          ebsInitialRootDiskSize = 20;
          usePrivateIpAddress = false;  # should be true if managed within vpc
          associatePublicIpAddress = false;
        } // ec2Deployment;
      fileSystems = filesys;
    };

  zookeeper = deployment {
    instanceType = "m4.large";
    associatePublicIpAddress = true;
    #securityGroupIds = [ "sg-" ];
    tags = {
      Environment = environment;
      Group = "zookeeper";
    }; 
  } {};

  kafka = deployment {
    instanceType = "m4.large";
    associatePublicIpAddress = true; # should be false if hidden in vpc
    #securityGroupIds = [ "sg-" ];
    tags = {
      Environment = environment;
      Group = "kafka";
    }; 
  } {
    "/data" = {
      autoFormat = true;
      fsType = "ext4";
      device = "/dev/xvdf";
      ec2.size = 30;
      ec2.volumeType = "gp2";
      ec2.deleteOnTermination = true; # should be false by security
    };
  };

in {

  zk-0 = zookeeper;
  zk-1 = zookeeper;
  zk-2 = zookeeper;
  
  kafka-0 = kafka;
  kafka-1 = kafka;
  kafka-2 = kafka;

  # Provision an EC2 key pair.
  resources.ec2KeyPairs.k8s-key-pair =
    { inherit region accessKeyId; };

}
