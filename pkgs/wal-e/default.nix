{ pkgs }:

let
  python = import ./requirements.nix { inherit pkgs; };

in 

pkgs.python36Packages.buildPythonApplication rec {
  name = "wal-e-${version}";
  version = "1.1.0";

  src = pkgs.fetchurl {
    url = "https://github.com/wal-e/wal-e/archive/v${version}.tar.gz";
    sha256 = "1iyn2963xr40wwfab8csdzds584i9bnpsgmgjv30mq5znip8wiyk";
  };

  doCheck = false;

  propagatedBuildInputs = [
    pkgs.lzop
    pkgs.postgresql96
    pkgs.pv
    python.packages."gevent"
    python.packages."boto"
    #python.packages."azure" # azure storage doesn't work for the moment
    python.packages."google-cloud-storage"
    python.packages."python-swiftclient"
    python.packages."python-keystoneclient"
  ];
}