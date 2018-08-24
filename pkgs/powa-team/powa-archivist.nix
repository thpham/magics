{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  name = "powa-archivist-${version}";
  version = "3.1.2";

  src = pkgs.fetchFromGitHub {
    owner = "powa-team";
    repo = "powa-archivist";
    rev = "b8be8d535705633356cc1fbf0551bbff33dd211b";
    sha256 = "00i8hcrjczf4xllay9ii5750x9glxljgd1dxf7ad4xl2s0i0vnqi";
  };

  buildInputs = with pkgs; [ postgresql96 ];

  installPhase = ''
    mkdir -p $out/bin   # for buildEnv to setup proper symlinks
    install -D powa.so -t $out/lib/
    install -D ./{install_all.sql,powa--3.1.2.sql,powa.control} -t $out/share/extension
  '';
}