{ aws-profile ? "default",
  environment ? "dev",
  aws-region  ? "us-east-1",
  machinesConfigPath ? ./machines.json }:

let
  region = aws-region;
  accessKeyId = aws-profile;

  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makeMasterServer = machine: {   
    name  = machine.name;
    value = { resources, ... }:
      let
      in {
        #services.flannel.iface = "eth0"; 
        deployment.targetEnv = "ec2";
        deployment.ec2 = {
          keyPair = resources.ec2KeyPairs.k8s-key-pair;
          accessKeyId = accessKeyId;
          region = region;
          ebsInitialRootDiskSize = 30;
          usePrivateIpAddress = false;  # should be true if managed within vpc
          associatePublicIpAddress = true;  # should be false if hidden within vpc
          #spotInstancePrice = 5;
          #spotInstanceTimeout = 60;
          instanceType = machines.masters.aws.instanceType;
          securityGroupIds = machines.masters.aws.securityGroupIds;
          subnetId = machine.aws-subnetId;
          instanceProfile = "k8sMaster-Instance-Profile";
          tags = {
            Environment = environment;
            Group = "k8s-master";
            "kubernetes.io/cluster/${environment}" = "owned";
            "k8s.io/role/master" = "1";
          };
        };
        services.kubernetes.apiserver.extraOpts = "--cloud-provider=aws";
        services.kubernetes.controllerManager.extraOpts = "--cloud-provider=aws";
        services.kubernetes.kubelet.extraOpts = "--cloud-provider=aws";
        # fix route conflict with flannel subnet and AWS instance metadata api
        networking.dhcpcd.runHook = "ip route add 169.254.169.254/32 dev eth0";
      };
  };
  masterServers = map makeMasterServer machines.masters.configs;

  makeWorkerServer = machine: {   
    name  = machine.name;
    value = { resources, ... }:
      let
      in {
        #services.flannel.iface = "eth0"; 
        deployment.targetEnv = "ec2";
        deployment.ec2 = {
          keyPair = resources.ec2KeyPairs.k8s-key-pair;
          accessKeyId = accessKeyId;
          region = region;
          ebsInitialRootDiskSize = 30;
          usePrivateIpAddress = false;  # should be true if managed within vpc
          associatePublicIpAddress = true;  # should be false if hidden within vpc
          #spotInstancePrice = 5;
          #spotInstanceTimeout = 60;
          instanceType = machines.workers.aws.instanceType;
          securityGroupIds =  machines.workers.aws.securityGroupIds;
          subnetId = machine.aws-subnetId;
          instanceProfile = "k8sWorker-Instance-Profile";
          tags = {
            Environment = environment;
            Group = "k8s-worker";
            "kubernetes.io/cluster/${environment}" = "owned";
            "k8s.io/role/node" = "1";
          };
        };
        fileSystems = {
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
        services.kubernetes.kubelet.extraOpts = "--cloud-provider=aws";

        # fix route conflict with flannel subnet and AWS instance metadata api
        networking.dhcpcd.runHook = "ip route add 169.254.169.254/32 dev eth0";
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