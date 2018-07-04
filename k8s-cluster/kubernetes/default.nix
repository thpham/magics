{ config, pkgs, nodes, oidc, ... }:

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

in

{
  imports = [
    ./addons/heapster.nix
  ];

  networking = {
    inherit domain;

    enableIPv6 = false;

    extraHosts = ''
      ${masterHost.config.networking.privateIPv4}  api.${domain}
      ${concatMapStringsSep "\n" (hostName:"${nodes.${hostName}.config.networking.privateIPv4} ${hostName}.${domain}") (attrNames nodes)}
    '';

    firewall = {
      allowedTCPPorts = if isMaster then [
        10250      # kubelet
        10255      # kubelet read-only port
        2379 2380  # etcd
        443        # kubernetes apiserver
      ] else [
        10250      # kubelet
        10255      # kubelet read-only port
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
        enable = true;
        clusterDomain = "cluster.local";
      };
      heapster = {
        enable = true;
        rbac.enable = true;
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
      authorizationMode = ["Node" "RBAC"]; # default # AlwaysAllow/AlwaysDeny/ABAC/RBAC/Node/Webhook
      #authorizationPolicy = [ ];
      extraOpts = ''
        --oidc-issuer-url=${oidc.issuer-url} \
        --oidc-client-id=${oidc.client-id} \
        --oidc-username-claim=${oidc.username-claim} \
        --oidc-groups-claim=${oidc.groups-claim} \
        --oidc-groups-prefix=${oidc.groups-prefix}
      '';
      # Disable basicAuth in production
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
      extraOpts = ''
        --read-only-port=10255
      '';
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
