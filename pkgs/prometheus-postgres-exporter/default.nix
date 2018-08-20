{ pkgs }:

pkgs.buildGoPackage rec {
  name = "prometheus-postgres-exporter-${version}";
  version = "0.4.6";

  goPackagePath = "github.com/wrouesnel/postgres_exporter";

  src = pkgs.fetchFromGitHub {
    owner = "wrouesnel";
    repo = "postgres_exporter";
    rev = "2db74865b1ec8758cc798835cc109ac0f5c98dfc";
    sha256 = "1bw5qwf7qq3pcra6yly00hj3jk8sp2i7zwkw26m521569nvkjhd9";
  };

  doCheck = false;
}