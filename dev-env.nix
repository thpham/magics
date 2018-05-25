with import <nixpkgs> {};
let
  
in 
  stdenv.mkDerivation {
    name = "my-env";
    buildInputs = [ 
      (import ./nixops/release.nix {}).build.x86_64-linux
      kubernetes
      kubernetes-helm
      awscli
    ];

    KUBECONFIG = "./k8s-cluster/kubeconfig.yaml";
  }
