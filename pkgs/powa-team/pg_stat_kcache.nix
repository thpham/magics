{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  name = "pg_stat_kcache-${version}";
  version = "2.1.1";

  src = pkgs.fetchFromGitHub {
    owner = "powa-team";
    repo = "pg_stat_kcache";
    rev = "e47d5e71d8ae0640695995550595e7ec107bfbb0";
    sha256 = "0xxsmvaxjhlxz948mm4ia5ki9ki0yhr2xvy9ilwd7x3pdz7nhkns";
  };

  buildInputs = with pkgs; [ postgresql96 ];

  installPhase = ''
    mkdir -p $out/bin   # for buildEnv to setup proper symlinks
    install -D pg_stat_kcache.so -t $out/lib/
    install -D ./{pg_stat_kcache--2.1.1.sql,pg_stat_kcache.control} -t $out/share/extension
  '';
}