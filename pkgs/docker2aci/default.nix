{ pkgs }:

pkgs.buildGoPackage rec {
  name = "docker2aci-${version}";
  version = "0.17.2";

  goPackagePath = "github.com/appc/docker2aci";

  src = pkgs.fetchFromGitHub {
    owner = "appc";
    repo = "docker2aci";
    rev = "1bfc43596cd2fdca46e9ddb33cfe7d56f87644ab";
    sha256 = "0hwk3x9fnywkkk8jskm863qyz2lbk8s8mabgb05pd5nqqxdc9aqk";
  };

  doCheck = false;
}