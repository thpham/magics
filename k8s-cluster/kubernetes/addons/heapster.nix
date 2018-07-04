{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.kubernetes.addons.heapster;
in {
  options.services.kubernetes.addons.heapster = {
    enable = mkEnableOption "kubernetes heapster addon";

    rbac = mkOption {
      description = "Role-based access control (RBAC) options";
      type = types.submodule {

        options = {
          enable = mkOption {
            description = "Whether to enable role based access control is enabled for kubernetes heapster";
            type = types.bool;
            default = elem "RBAC" config.services.kubernetes.apiserver.authorizationMode;
          };          
        };
      };
    };

    version = mkOption {
      description = "Which version of the kubernetes heapster to deploy";
      type = types.str;
      default = "v1.5.3";
    };

    image = mkOption {
      description = "Docker image to seed for the kubernetes heapster container.";
      type = types.attrs;
      default = {
        imageName = "k8s.gcr.io/heapster-amd64";
        imageDigest = "sha256:fc33c690a3a446de5abc24b048b88050810a58b9e4477fa763a43d7df029301a";
        finalImageTag = cfg.version;
        sha256 = "19d2p0gnib8hlmhlnwjycpshwkpfm6fi0b1z9hxmsyrigjsp4xk8";
      };
    };

    addon-resizer = mkOption {
      description = "Docker image to seed for the kubernetes addon-resizer container.";
      type = types.attrs;
      default = {
        imageName = "k8s.gcr.io/addon-resizer";
        imageDigest = "sha256:507aa9845ecce1fdde4d61f530c802f4dc2974c700ce0db7730866e442db958d";
        finalImageTag = "1.8.1";
        sha256 = "0mrkq023h683izaz48zn9zdr3gf1i6si12h403p8hyhc9sck7qs3";
      };
    };
  };

  config = mkIf cfg.enable {
    services.kubernetes.kubelet.seedDockerImages = [
      (pkgs.dockerTools.pullImage cfg.image)
      (pkgs.dockerTools.pullImage cfg.addon-resizer)
    ];

    services.kubernetes.addonManager.addons = {
      heapster-sa = {
        apiVersion = "v1";
        kind = "ServiceAccount";
        metadata = {
          name = "heapster";
          namespace = "kube-system";
          labels = {
            "kubernetes.io/cluster-service" = "true";
            "addonmanager.kubernetes.io/mode" = "Reconcile";
          };
        };
      };

      heapster-cm = {
        apiVersion = "v1";
        kind = "ConfigMap";
        metadata = {
          name = "heapster-config";
          namespace = "kube-system";
          labels = {
            "kubernetes.io/cluster-service" = "true";
            "addonmanager.kubernetes.io/mode" = "EnsureExists";
          };
        };
        data = {
          NannyConfiguration = ''
            apiVersion: nannyconfig/v1alpha1
            kind: NannyConfiguration
          '';
        };
      };

      heapster-deployment = {
        kind = "Deployment";
        apiVersion = "extensions/v1beta1";
        metadata = {
          name = "heapster";
          namespace = "kube-system";
          labels = {
            k8s-app = "heapster";
            "kubernetes.io/cluster-service" = "true";
            "addonmanager.kubernetes.io/mode" = "Reconcile";
            version = cfg.version;
          };
        };
        spec = {
          selector.matchLabels = {
            "k8s-app" = "heapster";
            version = cfg.version;
          };
          template = {
            metadata = {
              name = "heapster";
              labels = {
                k8s-app = "heapster";
                version = cfg.version;
              };
              annotations = {
                "scheduler.alpha.kubernetes.io/critical-pod" = "";
                "seccomp.security.alpha.kubernetes.io/pod" = "docker/default";
              };
            };
            spec = {
              priorityClassName = "system-cluster-critical";
              serviceAccountName = "heapster";
              containers = [
                {
                  name = "heapster";
                  image = with cfg.image; "${imageName}:${finalImageTag}";
                  ports = [{
                    containerPort = 443;
                    name = "https";
                    protocol = "TCP";
                  }];
                  command = [
                    "/heapster"
                    "--source=kubernetes.summary_api:''"
                  ];
                  livenessProbe = {
                    httpGet = {
                      scheme = "HTTP";
                      path = "/healthz";
                      port = 8082;
                    };
                    initialDelaySeconds = 180;
                    timeoutSeconds = 5;
                  };
                }
                {
                  name = "heapster-nanny";
                  image = with cfg.addon-resizer; "${imageName}:${finalImageTag}";
                  resources = {
                    limits = {
                      cpu = "100m";
                      memory = "300Mi";
                    };
                    requests = {
                      cpu = "50m";
                      memory = "50Mi";
                    };
                  };
                  env = [{
                    name = "MY_POD_NAME";
                    valueFrom = {
                      fieldRef = {
                        fieldPath = "metadata.name";
                      };
                    };
                  }
                  {
                    name = "MY_POD_NAMESPACE";
                    valueFrom = {
                      fieldRef = {
                        fieldPath = "metadata.namespace";
                      };
                    };
                  }];
                  volumeMounts = [{
                    name = "heapster-config-volume";
                    mountPath = "/etc/config";
                  }];
                  command = [
                    "/pod_nanny"
                    "--config-dir=/etc/config"
                    "--cpu=40m"
                    "--extra-cpu=0.5m"
                    "--memory=40Mi"
                    "--extra-memory=4Mi"
                    "--threshold=5"
                    "--deployment=heapster"
                    "--container=heapster"
                    "--poll-period=300000"
                    "--estimator=exponential"
                  ];
                }
              ];
              volumes = [{
                  name = "heapster-config-volume";
                  configMap = {
                    name = "heapster-config";
                  };
              }];
              tolerations = [{
                key = "CriticalAddonsOnly";
                operator = "Exists";
              }];
            };
          };
        };
      };

      heapster-svc = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "heapster";
          namespace  = "kube-system";
          labels = {
            "addonmanager.kubernetes.io/mode" = "Reconcile";
            "kubernetes.io/cluster-service" = "true";
            "kubernetes.io/name" = "Heapster";
          };
        };
        spec = {
          selector.k8s-app = "heapster";
          ports = [{
            port = 80;
            targetPort = 8082;
          }];
        };
      };
      
    } // (optionalAttrs cfg.rbac.enable
      (let
        subjects = [{
          kind = "ServiceAccount";
          name = "heapster";
          namespace = "kube-system";
        }];
        labels = {
          "kubernetes.io/cluster-service" = "true";
          "addonmanager.kubernetes.io/mode" = "Reconcile";
        };
      in {

        heapster-crb = {
          apiVersion = "rbac.authorization.k8s.io/v1";
          kind = "ClusterRoleBinding";
          metadata = {
            name = "heapster-binding";
            inherit labels;
          };
          roleRef = {
            apiGroup = "rbac.authorization.k8s.io";
            kind = "ClusterRole";
            name = "system:heapster";
          };
          inherit subjects;
        };
        
        heapster-role = {
          apiVersion = "rbac.authorization.k8s.io/v1";
          kind = "Role";
          metadata = {
            name = "system:pod-nanny";
            namespace = "kube-system";
            inherit labels;
          };
          rules = [
            {
              apiGroups = [""];
              resources = ["pods"];
              verbs = ["get"];
            }
            {
              apiGroups = ["extensions"];
              resources = ["deployments"];
              verbs = ["get" "update"];
            }
          ];
        };
         
        heapster-rb = {
          apiVersion = "rbac.authorization.k8s.io/v1";
          kind = "RoleBinding";
          metadata = {
            name = "heapster-binding";
            namespace = "kube-system";
            inherit labels;
          };
          roleRef = {
            apiGroup = "rbac.authorization.k8s.io";
            kind = "Role";
            name = "system:pod-nanny";
          };
          inherit subjects;
        };
        
      }
    ));
  };
}