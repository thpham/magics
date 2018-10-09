{ pkgs }:

pkgs.buildGoPackage rec {
  name = "prometheus-${version}";
  version = "2.3.2";

  goPackagePath = "github.com/prometheus/prometheus";

  src = pkgs.fetchFromGitHub {
    owner = "prometheus";
    repo = "prometheus";
    rev = "v${version}";
    sha256 = "09q3p3kvgrvgyfkkvpy2mmlr6jxzxad6nzjni3iycs4bahsxl27a";
  };

  doCheck = true;

  buildFlagsArray = let t = "${goPackagePath}/vendor/github.com/prometheus/common/version"; in ''
    -ldflags=
        -X ${t}.Version=${version}
        -X ${t}.Revision=unknown
        -X ${t}.Branch=unknown
        -X ${t}.BuildUser=nix@nixpkgs
        -X ${t}.BuildDate=unknown
        -X ${t}.GoVersion=${pkgs.stdenv.lib.getVersion pkgs.go}
  '';

  preInstall = ''
    mkdir -p "$bin/share/doc/prometheus" "$bin/etc/prometheus"
    cp -a $src/documentation/* $bin/share/doc/prometheus
    cp -a $src/console_libraries $src/consoles $bin/etc/prometheus
  '';
}