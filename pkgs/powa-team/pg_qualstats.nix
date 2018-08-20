{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  name = "pg_qualstats-${version}";
  version = "1.0.5";

  src = pkgs.fetchFromGitHub {
    owner = "powa-team";
    repo = "pg_qualstats";
    rev = "49caa780c11c9fb06e39a4a29e83b8fa97103be7";
    sha256 = "10rvq2r7zxdwl9m2656saya0nsknb3zq9rw0zh4nh1ly97lrcr3c";
  };

  buildInputs = with pkgs; [ postgresql96 ];

  installPhase = ''
    mkdir -p $out/bin   # for buildEnv to setup proper symlinks
    install -D pg_qualstats.so -t $out/lib/
    install -D ./{pg_qualstats--1.0.5.sql,pg_qualstats.control} -t $out/share/extension
  '';
}