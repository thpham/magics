{ pkgs }:

pkgs.buildGoPackage rec {
  name = "tendermint-${version}";
  version = "0.23.0";

    goPackagePath = "github.com/tendermint/tendermint";
    
    src = pkgs.fetchFromGitHub {
    owner = "tendermint";
    repo = "tendermint";
    rev = "013b9cef642f875634c614019ab13b17570778ad";
    sha256 = "09lx8flxqx54khvpdk7jdc6yap1sqijvn30prl7f75c8ks2na9iz";
  };

  #goDeps = ./deps.nix;

}