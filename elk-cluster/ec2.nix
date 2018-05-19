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
          keyPair = resources.ec2KeyPairs.elk-key-pair;
          accessKeyId = accessKeyId;
          region = region;
          ebsInitialRootDiskSize = 20;
          usePrivateIpAddress = false;  # should be true if managed within vpc
          associatePublicIpAddress = true;  # should be false if hidden within vpc
        } // ec2Deployment;
      fileSystems = filesys;
    };

  makeElasticsearchServer = machine: {
    name  = machine.name;
    value = makeEC2configs {
        instanceType = machines.elasticsearch.aws.instanceType;
        securityGroupIds =  machines.elasticsearch.aws.securityGroupIds;
        subnetId = machine.aws-subnetId;
        tags = {
          Environment = environment;
          Group = "elasticsearch";
        }; 
      } {
        "/data" = {
          autoFormat = true;
          fsType = "ext4";
          device = "/dev/xvdf";
          ec2.size = machines.elasticsearch.aws.storageSize;
          ec2.volumeType = "gp2";
          ec2.deleteOnTermination = true; # should be false by security
        };
      };
  };
  elasticsearchServers = map makeElasticsearchServer machines.elasticsearch.configs;

  makeLogstashServer = machine: {
    name  = machine.name;
    value = makeEC2configs {
        instanceType = machines.logstash.aws.instanceType;
        securityGroupIds =  machines.logstash.aws.securityGroupIds;
        subnetId = machine.aws-subnetId;
        tags = {
          Environment = environment;
          Group = "logstash";
        }; 
      } {
        "/data" = {
          autoFormat = true;
          fsType = "ext4";
          device = "/dev/xvdf";
          ec2.size = machines.logstash.aws.storageSize;
          ec2.volumeType = "gp2";
          ec2.deleteOnTermination = true; # should be false by security
        };
      };
  };
  logstashServers = map makeLogstashServer machines.logstash.configs;

  kibana = makeEC2configs {
    instanceType = machines.kibana.aws.instanceType;
    securityGroupIds = machines.kibana.aws.securityGroupIds;
    subnetId = machines.kibana.aws.subnetId;
    ebsInitialRootDiskSize = machines.kibana.aws.storageSize;
    tags = {
      Environment = environment;
      Group = "kibana";
    }; 
  } {};

in {
  kibana = kibana;
  
  # Provision an EC2 key pair.
  resources.ec2KeyPairs.elk-key-pair =
    { inherit region accessKeyId; };
}
//  builtins.listToAttrs elasticsearchServers
//  builtins.listToAttrs logstashServers
