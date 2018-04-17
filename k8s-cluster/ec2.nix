{ aws-profile ? "default",
  environment ? "dev",
  aws-region  ? "us-east-1" }:

let
  region = aws-region;
  accessKeyId = aws-profile;

  deployment = ec2Deployment: filesys:
    { resources, ... }:
    { 
      #services.flannel.iface = "eth0"; 

      deployment.targetEnv = "ec2";
      deployment.ec2 = {
          keyPair = resources.ec2KeyPairs.k8s-key-pair;
          accessKeyId = accessKeyId;
          region = region;
          subnetId = "subnet-";   # to be adapted accordingly, e.g. default
          ebsInitialRootDiskSize = 30;
          usePrivateIpAddress = false;  # should be true if managed within vpc
          associatePublicIpAddress = false;
        } // ec2Deployment;
      fileSystems = filesys;
    };

  k8s-master = deployment {
    instanceType = "m4.large";
    associatePublicIpAddress = true;
    #securityGroupIds = [ "sg-" ];
    tags = {
      Environment = environment;
      Group = "k8s-master";
    }; 
  } {};

  k8s-worker = deployment {
    instanceType = "m4.large";
    associatePublicIpAddress = true; # should be false if hidden in vpc
    #securityGroupIds = [ "sg-" ];
    tags = {
      Environment = environment;
      Group = "k8s-worker";
    }; 
  } {
    "/data" = {
      autoFormat = true;
      fsType = "ext4";
      device = "/dev/xvdf";
      ec2.size = 100;
      ec2.volumeType = "gp2";
      ec2.deleteOnTermination = true; # should be false by security
    };
  };

in {

  master-1 = k8s-master;
  master-2 = k8s-master;
  master-3 = k8s-master;
  
  worker-1 = k8s-worker;
  worker-2 = k8s-worker;

  # Provision an EC2 key pair.
  resources.ec2KeyPairs.k8s-key-pair =
    { inherit region accessKeyId; };

}
