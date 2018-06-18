{ config, pkgs, nodes, ... }:

with pkgs.lib;

let
  masterNames = 
    (filter (hostName: any (role: role == "master")
                           nodes.${hostName}.config.services.kubernetes.roles)
            (attrNames nodes));
  
  masterName = head masterNames;
  masterHost = nodes.${masterName};

  isMaster = any (role: role == "master") config.services.kubernetes.roles;

  domain = "kubernetes.local";
  certs = import ./certs.nix { 
    inherit pkgs;
    externalDomain = domain;
    serviceClusterIp = "10.0.0.1";
    etcdMasterHosts = builtins.map (hostName: hostName+".${domain}") masterNames;
    kubelets = attrNames nodes;
  };

  kubeconfig = pkgs.writeText "nixops-kubeconfig.json" (builtins.toJSON {
    apiVersion = "v1";
    kind = "Config";
    clusters = [{
      name = domain;
      cluster.certificate-authority = "${certs.master}/ca.pem";
      cluster.server = "https://${masterHost.config.networking.privateIPv4}";
    }];
    users = [{
      name = "admin";
      user = {
        client-certificate = "${certs.admin}/admin.pem";
        client-key = "${certs.admin}/admin-key.pem";
      };
    }];
    contexts = [{
      context = {
        cluster = domain;
        user = "admin";
      };
      current-context = "admin-context";
    }];
  });

  guard = pkgs.buildGoPackage rec {
    name = "guard-${version}";
    version = "0.1.3";

    src = pkgs.fetchFromGitHub {
      owner = "appscode";
      repo = "guard";
      rev = "${version}";
      sha256 = "1jzaqzil6pkyka1bdnhwva9486fb0p0jcvd71y650kkvxy3dr1mn";
    };

    goPackagePath = "github.com/appscode/guard";
  };

  # token,user,uid,"group1,group2,group3"
  tokenAuthFile = pkgs.writeText "token-auth-file" ''
    02b50b05283e98dd0fd71db496ef01e8,admin,0,"cluster-admin"
  '';

in

{

  networking = {
    inherit domain;

    extraHosts = ''
      ${masterHost.config.networking.privateIPv4}  api.${domain}
      ${concatMapStringsSep "\n" (hostName:"${nodes.${hostName}.config.networking.privateIPv4} ${hostName}.${domain}") (attrNames nodes)}
    '';

    firewall = {
      allowedTCPPorts = if isMaster then [
        10250      # kubelet
        2379 2380  # etcd
        443        # kubernetes apiserver
      ] else [
        10250      # kubelet
      ];

      trustedInterfaces = [ "docker0" "flannel.1" "zt0" ];

      # allow any traffic from all of the nodes in the cluster
      extraCommands = concatMapStrings (node: ''
        iptables -A INPUT -s ${node.config.networking.privateIPv4} -j ACCEPT
      '') (attrValues nodes);
    };
  };
  
  services.monit = if isMaster then {
    enable = true;
    config =  builtins.readFile ./monitrc;
  } else {};

  #services.dnsmasq = if isMaster then {
  #  enable = true;
  #  resolveLocalQueries = true;
  #  servers = [ "8.8.8.8" "8.8.4.4" ];
  #  extraConfig = ''
  #  '';
  #} else {};

  services.etcd = if isMaster then {
    enable = true;
    certFile = "${certs.master}/etcd.pem";
    keyFile = "${certs.master}/etcd-key.pem";
    trustedCaFile = "${certs.master}/ca.pem";
    peerClientCertAuth = true;
    listenClientUrls = ["https://0.0.0.0:2379"];
    listenPeerUrls = ["https://0.0.0.0:2380"];
    advertiseClientUrls = [
      "https://${config.networking.hostName}.${config.networking.domain}:2379"
    ];
    initialClusterState = "new"; # "new" when create, update it to "existing", when recovering
    initialCluster = builtins.map (hostName: hostName+"=https://"+hostName+".${domain}:2380") masterNames;
    initialAdvertisePeerUrls = [
      "https://${config.networking.hostName}.${config.networking.domain}:2380"
    ];
  } else {};

  systemd.services.guard = if isMaster then {
    description = "Kubernetes Authentication WebHook Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-interfaces.target" ];
    serviceConfig = {
      ExecStart = ''${guard}/bin/guard run --v=1 --logtostderr --analytics=false \
        --auth-providers="token-auth" \
        --secure-addr="localhost:9443" \
        --tls-ca-file=${certs.master}/ca.pem \
        --tls-cert-file=${certs.master}/guard.pem \
        --tls-private-key-file=${certs.master}/guard-key.pem \
        --token-auth-file=${tokenAuthFile}
      '';
      Restart = "on-failure";
      RestartSec = 5;
    };
  } else {};

  environment.variables = {
    ETCDCTL_CERT_FILE = "${certs.worker}/etcd-client.pem";
    ETCDCTL_KEY_FILE = "${certs.worker}/etcd-client-key.pem";
    ETCDCTL_CA_FILE = "${certs.worker}/ca.pem";
    ETCDCTL_PEERS = builtins.concatStringsSep "," (builtins.map (hostName: "https://"+hostName+".${domain}:2379") masterNames);
  };

  services.kubernetes = {
    featureGates = ["AllAlpha"];
    flannel.enable = true;
    clusterCidr = "10.1.0.0/16"; ## used by flannel too

    addons = {
      dashboard = {
        enable = true;
        rbac = {
          enable = true;
          clusterAdmin = true;
        };
      };
      dns = {
        enable = true; ## enable=true by default
        clusterDomain = "cluster.local";
      };
    };
    verbose = true;

    caFile = "${certs.master}/ca.pem";

    apiserver = if false then {
      advertiseAddress = config.networking.privateIPv4;
      extraOpts = "--apiserver-count=3 --endpoint-reconciler-type=lease";
    } else {
      # this may be the address of an LB
      advertiseAddress = masterHost.config.networking.privateIPv4;
      bindAddress = "0.0.0.0";
      tlsCertFile = "${certs.master}/kube-apiserver.pem";
      tlsKeyFile = "${certs.master}/kube-apiserver-key.pem";
      kubeletClientCertFile = "${certs.master}/kubelet-client.pem";
      kubeletClientKeyFile = "${certs.master}/kubelet-client-key.pem";
      serviceAccountKeyFile = "${certs.master}/kube-service-accounts.pem";
      authorizationMode = ["Node" "RBAC" "Webhook"]; # default # AlwaysAllow/AlwaysDeny/ABAC/Webhook/RBAC/Node
      #authorizationPolicy = [ ]; #ABAC only
      webhookConfig = pkgs.writeText "kube-auth-webhook.yaml" ''
        apiVersion: v1
        clusters:
          - name: guard-server
            cluster:
              certificate-authority: ${certs.master}/ca.pem
              server: https://localhost:9443/apis/authentication.k8s.io/v1/tokenreviews
        current-context: webhook
        kind: Config
        preferences: {}
        contexts:
        - context:
            cluster: guard-server
            user: guard-user
          name: webhook
        users:
          - name: guard-user
            user:
              client-certificate: ${certs.master}/guard-client.pem
              client-key: ${certs.master}/guard-client-key.pem
      '';
      basicAuthFile = pkgs.writeText "users" ''
        kubernetes,admin,0,"cluster-admin"
      '';
      # admissionControl = [];
      ## should be in the same range than the serviceClusterIp certs
      serviceClusterIpRange = "10.0.0.0/24"; 
    };
    etcd = {
      servers = builtins.map (hostName: "https://"+hostName+".${domain}:2379") masterNames;
      certFile = "${certs.worker}/etcd-client.pem";
      keyFile = "${certs.worker}/etcd-client-key.pem";
    };
    kubeconfig = {
      server = "https://api.${config.networking.domain}";
    };
    kubelet = {
      tlsCertFile = "${certs.worker}/kubelet.pem";
      tlsKeyFile = "${certs.worker}/kubelet-key.pem";
      hostname = "${config.networking.hostName}.${config.networking.domain}";
      kubeconfig = {
        certFile = "${certs.worker}/apiserver-client-kubelet-${config.networking.hostName}.pem";
        keyFile = "${certs.worker}/apiserver-client-kubelet-${config.networking.hostName}-key.pem";
      };
      ## nixos dnsmasq service on master node
      #clusterDns = "${masterHost.config.networking.privateIPv4}";
    };
    controllerManager = {
      serviceAccountKeyFile = "${certs.master}/kube-service-accounts-key.pem";
      kubeconfig = {
        certFile = "${certs.master}/apiserver-client-kube-controller-manager.pem";
        keyFile = "${certs.master}/apiserver-client-kube-controller-manager-key.pem";
      };
    };
    scheduler = {
      kubeconfig = {
        certFile = "${certs.master}/apiserver-client-kube-scheduler.pem";
        keyFile = "${certs.master}/apiserver-client-kube-scheduler-key.pem";
      };
    };
    proxy = {
      kubeconfig = {
        certFile = "${certs.worker}/apiserver-client-kube-proxy.pem";
        keyFile = "${certs.worker}/apiserver-client-kube-proxy-key.pem";
      };
    };
  };
}
