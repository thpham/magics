{ pkgs }:

let
  python = import ./powa-web/requirements.nix { inherit pkgs; };

in 

pkgs.python36Packages.buildPythonApplication rec {
  name = "powa-web-${version}";
  version = "3.1.4";

  src = pkgs.fetchFromGitHub {
    owner = "powa-team";
    repo = "powa-web";
    rev = "de4e2dbd8010e91e26198d99a30d063484cb47a8";
    sha256 = "0hvyxy35nd28d2xrrp184qp2z3syaz7zpy2lka34bsgjsdvf3agp";
  };

  doCheck = false;

  propagatedBuildInputs = builtins.attrValues python.packages;
}