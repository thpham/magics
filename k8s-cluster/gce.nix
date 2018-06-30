{ gce-project ? "default",
  gce-serviceAccount ? "",
  gce-accessKeyId ? "~/.ssh/gce.pem",
  region  ? "us-east-1",
  environment ? "dev",
  machinesConfigPath ? ./machines.json }:

let
  credentials = {
    project = gce-project;
    serviceAccount = gce-serviceAccount; ## roles: Compute Admin, Service Account User
    accessKey = gce-accessKeyId;
  };

  machines = builtins.fromJSON (builtins.readFile machinesConfigPath);

  makeMasterServer = machine: {   
    name  = machine.name;
    value = { resources, ... }:
      let
      in {
        #services.flannel.iface = "eth0"; 
        deployment.targetEnv = "gce";
        deployment.gce = credentials // {
          region = gce-region;
          rootDiskSize = 30;
          instanceType = machines.masters.gce.instanceType;
          subnet = machine.gce-subnetId;
          tags = machines.masters.gce.tags;
          labels = {
            Environment = environment;
            Group = "k8s-master";
            "kubernetes.io/cluster/${environment}" = "owned"; # ClusterID
            "k8s.io/role/master" = "1";
          };
        };
        services.kubernetes.apiserver.extraOpts = "--cloud-provider=gce";
        services.kubernetes.controllerManager.extraOpts = "--cloud-provider=gce";
        services.kubernetes.kubelet.extraOpts = "--cloud-provider=gce";
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
        deployment.targetEnv = "gce";
        deployment.gce = credentials // {
          region = region;
          rootDiskSize = 30;
          instanceType = machines.workers.gce.instanceType;
          subnet = machine.gce-subnetId;
          tags = machines.workers.gce.tags;
          labels = {
            Environment = environment;
            Group = "k8s-worker";
            "kubernetes.io/cluster/${environment}" = "owned"; # ClusterID
            "k8s.io/role/node" = "1";
          };
          blockDeviceMapping."/dev/sdb" = {
            disk_name = "data";
            diskType = "ssd";
            size = machines.workers.gce.storageSize;
          };
        };
        fileSystems = {
          data = {
            device = "/dev/sdb";
            fsType = "xfs";
            label = "data";
            autoFormat = true;
            mountPoint = "/data";
          };
        };
        services.kubernetes.kubelet.extraOpts = "--cloud-provider=gce";

        # fix route conflict with flannel subnet and AWS instance metadata api
        networking.dhcpcd.runHook = "ip route add 169.254.169.254/32 dev eth0";
      };
  }; 
  workerServers = map makeWorkerServer machines.workers.configs;

in {
  ## For image creation: `nixos/maintainers/scripts/gce/create-gce.sh`
  ## and update the script with `-I nixpkgs=/path/to/nixpkgs-channels/branch` for specific base.
  resources.gceImages.bootstrap = credentials // {
     name = "nixos-1803";
     description = "NixOS bootstrap image for gce node";
     sourceUri = "gs://nixos/nixos-image-18.03pre-git-x86_64-linux.raw.tar.gz";
  };

}
//  builtins.listToAttrs masterServers
//  builtins.listToAttrs workerServers