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

  elasticsearch = deployment {
    instanceType = "m4.large";
    associatePublicIpAddress = true;
    #securityGroupIds = [ "sg-" ];
    tags = {
      Environment = environment;
      Group = "elasticsearch";
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

  kibana = deployment {
    instanceType = "m4.large";
    associatePublicIpAddress = true; # should be false if hidden in vpc
    #securityGroupIds = [ "sg-" ];
    ebsInitialRootDiskSize = 30;
    tags = {
      Environment = environment;
      Group = "kibana";
    }; 
  } {};

  logstash = deployment {
    instanceType = "m4.large";
    associatePublicIpAddress = true; # should be false if hidden in vpc
    #securityGroupIds = [ "sg-" ];
    tags = {
      Environment = environment;
      Group = "logstash";
    }; 
  } {
    "/data" = {
      autoFormat = true;
      fsType = "ext4";
      device = "/dev/xvdf";
      ec2.size = 20;
      ec2.volumeType = "gp2";
      ec2.deleteOnTermination = true; # should be false by security
    };
  };

in {
  es-0   = elasticsearch;
  es-1   = elasticsearch;
  es-2   = elasticsearch;

  kibana = kibana;
  
  ls-0   = logstash;

  # Provision an EC2 key pair.
  resources.ec2KeyPairs.k8s-key-pair =
    { inherit region accessKeyId; };
}
