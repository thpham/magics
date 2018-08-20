self: pkgs:

with pkgs;

{
  # Allow callPackage to fill in the pkgs argument
  inherit pkgs;

  bigchaindb = callPackage ./pkgs/bigchaindb { };
  
  pgrouting  = callPackage ./pkgs/pgrouting  { };
  postgis    = (pkgs.postgis.override { postgresql = pkgs.postgresql96; });

  pg_qualstats   = callPackage ./pkgs/powa-team/pg_qualstats.nix { };
  pg_stat_kcache = callPackage ./pkgs/powa-team/pg_stat_kcache.nix { };
  powa-archivist = callPackage ./pkgs/powa-team/powa-archivist.nix { };

  prometheus-postgres-exporter = callPackage ./pkgs/prometheus-postgres-exporter { };

  tendermint = callPackage ./pkgs/tendermint { };

  wal-e      = callPackage ./pkgs/wal-e      { };
  wal-g      = callPackage ./pkgs/wal-g      { };
}