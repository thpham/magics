self: pkgs:

with pkgs;

{
  # Allow callPackage to fill in the pkgs argument
  inherit pkgs;

  bigchaindb = callPackage ./pkgs/bigchaindb { };
  docker2aci = callPackage ./pkgs/docker2aci { };
  
  pgrouting   = callPackage ./pkgs/pgrouting  { };
  postgis_2_3 = (pkgs.postgis_2_3.override { postgresql = pkgs.postgresql96; });

  pg_qualstats   = callPackage ./pkgs/powa-team/pg_qualstats.nix { };
  pg_stat_kcache = callPackage ./pkgs/powa-team/pg_stat_kcache.nix { };
  powa-archivist = callPackage ./pkgs/powa-team/powa-archivist.nix { };
  powa-web = callPackage ./pkgs/powa-team/powa-web.nix { };

  prometheus-postgres-exporter = callPackage ./pkgs/prometheus-postgres-exporter { };

  tendermint = callPackage ./pkgs/tendermint { };

  wal-e      = callPackage ./pkgs/wal-e      { };
  wal-g      = callPackage ./pkgs/wal-g      { };
}