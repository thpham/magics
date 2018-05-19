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
      #services.flannel.iface = "eth0"; 
      deployment.targetEnv = "ec2";
      deployment.ec2 = {
          keyPair = resources.ec2KeyPairs.k8s-key-pair;
          accessKeyId = accessKeyId;
          region = region;
          ebsInitialRootDiskSize = 30;
          usePrivateIpAddress = false;  # should be true if managed within vpc
          associatePublicIpAddress = true;  # should be false if hidden within vpc
        } // ec2Deployment;
      fileSystems = filesys;
    };

  makeMasterServer = machine: {   
    name  = machine.name;
    value = makeEC2configs {
        instanceType = machines.masters.aws.instanceType;
        securityGroupIds = machines.masters.aws.securityGroupIds;
        subnetId = machine.aws-subnetId;
        tags = {
          Environment = environment;
          Group = "k8s-master";
        }; 
      } {};
      #// { 
      #  services.kubernetes.apiserver.extraOpts = "--cloud-provider=aws";
      #};
  };
  masterServers = map makeMasterServer machines.masters.configs;

  makeWorkerServer = machine: {   
    name  = machine.name;
    value = makeEC2configs {
        instanceType = machines.workers.aws.instanceType;
        securityGroupIds =  machines.workers.aws.securityGroupIds;
        subnetId = machine.aws-subnetId;
        tags = {
          Environment = environment;
          Group = "k8s-worker";
        }; 
      } {
        data = {
          device = "/dev/xvdf";
          fsType = "xfs";
          label = "data";
          autoFormat = true;
          mountPoint = "/data";
          ec2.size = machines.workers.aws.storageSize;
          ec2.volumeType = "gp2";
          ec2.deleteOnTermination = true; # should be false by security
        };
      };
  }; 
  workerServers = map makeWorkerServer machines.workers.configs;

in {
  # Provision an EC2 key pair.
  resources.ec2KeyPairs.k8s-key-pair =
    { inherit region accessKeyId; };
}
//  builtins.listToAttrs masterServers
//  builtins.listToAttrs workerServers