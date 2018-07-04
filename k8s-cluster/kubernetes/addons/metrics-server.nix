{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.kubernetes.addons.metrics-server;
in {
  options.services.kubernetes.addons.metrics-server = {
    enable = mkEnableOption "kubernetes metrics-server addon";

    rbac = mkOption {
      description = "Role-based access control (RBAC) options";
      type = types.submodule {

        options = {
          enable = mkOption {
            description = "Whether to enable role based access control is enabled for kubernetes metrics-server";
            type = types.bool;
            default = elem "RBAC" config.services.kubernetes.apiserver.authorizationMode;
          };          
        };
      };
    };

    version = mkOption {
      description = "Which version of the kubernetes metrics-server to deploy";
      type = types.str;
      default = "v0.2.1";
    };

    image = mkOption {
      description = "Docker image to seed for the kubernetes metrics-server container.";
      type = types.attrs;
      default = {
        imageName = "k8s.gcr.io/metrics-server-amd64";
        imageDigest = "sha256:49a9f12f7067d11f42c803dbe61ed2c1299959ad85cb315b25ff7eef8e6b8892";
        finalImageTag = cfg.version;
        sha256 = "07b8pc763rawj57s6dbqpkcfbykqcmjr4414ybaj2327ga40w4hf";
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
      metrics-server-sa = {
        apiVersion = "v1";
        kind = "ServiceAccount";
        metadata = {
          name = "metrics-server";
          namespace = "kube-system";
          labels = {
            "kubernetes.io/cluster-service" = "true";
            "addonmanager.kubernetes.io/mode" = "Reconcile";
          };
        };
      };

      metrics-server-cm = {
        apiVersion = "v1";
        kind = "ConfigMap";
        metadata = {
          name = "metrics-server-config";
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

      metrics-server-deployment = {
        kind = "Deployment";
        apiVersion = "extensions/v1beta1";
        metadata = {
          name = "metrics-server";
          namespace = "kube-system";
          labels = {
            k8s-app = "metrics-server";
            "kubernetes.io/cluster-service" = "true";
            "addonmanager.kubernetes.io/mode" = "Reconcile";
            version = cfg.version;
          };
        };
        spec = {
          selector.matchLabels = {
            "k8s-app" = "metrics-server";
            version = cfg.version;
          };
          template = {
            metadata = {
              name = "metrics-server";
              labels = {
                k8s-app = "metrics-server";
                version = cfg.version;
              };
              annotations = {
                "scheduler.alpha.kubernetes.io/critical-pod" = "";
                "seccomp.security.alpha.kubernetes.io/pod" = "docker/default";
              };
            };
            spec = {
              priorityClassName = "system-cluster-critical";
              serviceAccountName = "metrics-server";
              containers = [
                {
                  name = "metrics-server";
                  image = with cfg.image; "${imageName}:${finalImageTag}";
                  ports = [{
                    containerPort = 443;
                    name = "https";
                    protocol = "TCP";
                  }];
                  command = [
                    "/metrics-server"
                    "--source=kubernetes.summary_api:''"
                    "--v=5"
                  ];
                  livenessProbe = {
                    httpGet = {
                      scheme = "HTTPS";
                      path = "/";
                      port = 443;
                    };
                    initialDelaySeconds = 30;
                    timeoutSeconds = 30;
                  };
                }
                {
                  name = "metrics-server-nanny";
                  image = with cfg.addon-resizer; "${imageName}:${finalImageTag}";
                  resources = {
                    limits = {
                      cpu = "100m";
                      memory = "300Mi";
                    };
                    requests = {
                      cpu = "5m";
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
                    name = "metrics-server-config-volume";
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
                    "--deployment=metrics-server"
                    "--container=metrics-server"
                    "--poll-period=300000"
                    "--estimator=exponential"
                  ];
                }
              ];
              volumes = [{
                  name = "metrics-server-config-volume";
                  configMap = {
                    name = "metrics-server-config";
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

      metrics-server-svc = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "metrics-server";
          namespace  = "kube-system";
          labels = {
            "addonmanager.kubernetes.io/mode" = "Reconcile";
            "kubernetes.io/cluster-service" = "true";
            "kubernetes.io/name" = "Metrics-server";
          };
        };
        spec = {
          selector.k8s-app = "metrics-server";
          ports = [{
            port = 443;
            protocol = "TCP";
            targetPort = "https";
          }];
        };
      };

      metrics-server-apiservice = {
        apiVersion = "apiregistration.k8s.io/v1beta1";
        kind = "APIService";
        metadata = {
          name = "v1beta1.metrics.k8s.io";
          labels = {
            "kubernetes.io/cluster-service" = "true";
            "addonmanager.kubernetes.io/mode" = "Reconcile";
          };
        };
        spec = {
          service = {
            name = "metrics-server";
            namespace = "kube-system";
          };
          group = "metrics.k8s.io";
          version = "v1beta1";
          insecureSkipTLSVerify = true;
          groupPriorityMinimum = 100;
          versionPriority = 100;
        };
      };
      
    } // (optionalAttrs cfg.rbac.enable
      (let
        subjects = [{
          kind = "ServiceAccount";
          name = "metrics-server";
          namespace = "kube-system";
        }];
        labels = {
          "kubernetes.io/cluster-service" = "true";
          "addonmanager.kubernetes.io/mode" = "Reconcile";
        };
      in {
        
        metrics-server-cr = {
          apiVersion = "rbac.authorization.k8s.io/v1";
          kind = "ClusterRole";
          metadata = {
            name = "system:metrics-server";
            inherit labels;
          };
          rules = [
            {
              apiGroups = [""];
              resources = ["pods" "nodes" "nodes/stats" "namespaces"];
              verbs = ["get" "list" "watch"];
            }
            {
              apiGroups = ["extensions"];
              resources = ["deployments"];
              verbs = ["get" "list" "watch" "update"];
            }
          ];
        };

        metrics-server-crb = {
          apiVersion = "rbac.authorization.k8s.io/v1";
          kind = "ClusterRoleBinding";
          metadata = {
            name = "system:metrics-server";
            inherit labels;
          };
          roleRef = {
            apiGroup = "rbac.authorization.k8s.io";
            kind = "ClusterRole";
            name = "system:metrics-server";
          };
          inherit subjects;
        };

        metrics-server-crb-delegator = {
          apiVersion = "rbac.authorization.k8s.io/v1beta1";
          kind = "ClusterRoleBinding";
          metadata = {
            name = "metrics-server:system:auth-delegator";
            inherit labels;
          };
          roleRef = {
            apiGroup = "rbac.authorization.k8s.io";
            kind = "ClusterRole";
            name = "system:auth-delegator";
          };
          inherit subjects;
        };
         
        metrics-server-rb = {
          apiVersion = "rbac.authorization.k8s.io/v1beta1";
          kind = "RoleBinding";
          metadata = {
            name = "metrics-server-auth-reader";
            namespace = "kube-system";
            inherit labels;
          };
          roleRef = {
            apiGroup = "rbac.authorization.k8s.io";
            kind = "Role";
            name = "extension-apiserver-authentication-reader";
          };
          inherit subjects;
        };
        
      }
    ));
  };
}