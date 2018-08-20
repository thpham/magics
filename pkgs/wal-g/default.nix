{ pkgs }:

pkgs.buildGoPackage rec {
  name = "wal-g-${version}";
  version = "0.1.10";

  goPackagePath = "github.com/wal-g/wal-g";

  src = pkgs.fetchFromGitHub {
    owner = "wal-g";
    repo = "wal-g";
    rev = "5b91597038a1d5f5e509f8a28ebc8916914ca709";
    sha256 = "0klqnrrjzzxcj3clg7vapmbga1vqsfh8mkci5r2ir1bjp0z1xfnp";
  };

  doCheck = false;
}