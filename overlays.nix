self: pkgs:

with pkgs;

{
  # Allow callPackage to fill in the pkgs argument
  inherit pkgs;

  bigchaindb = callPackage ./pkgs/bigchaindb { };
  tendermint = callPackage ./pkgs/tendermint { };
}