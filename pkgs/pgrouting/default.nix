{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  name = "pgrouting-${version}";
  version = "2.3.2";
  src = pkgs.fetchurl {
    url = "https://github.com/pgRouting/pgrouting/archive/v2.3.2.tar.gz";
    sha256 = "1cym45p5f8hjrrnhz6rhqlqdh2828risd9nx1d8nna5g3d2kwi7a";
  };
  buildInputs = with pkgs; [ postgis postgresql96 boost cgal cmake perl gmp mpfr ];
  #phases = [ "unpackPhase" "buildPhase" "installPhase" ];
  patches = [ ./pgrouting.patch ];
  configurePhase = ''
    env
    mkdir build
    cd build
    cmake ..
  '';
}