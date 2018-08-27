{ pkgs }:

let
  python = import ./requirements.nix { inherit pkgs; };

in 

pkgs.python36Packages.buildPythonApplication rec {
  name = "bigchaindb-${version}";
  version = "2.0.0b5";
  
  src = pkgs.fetchFromGitHub {
    owner = "bigchaindb";
    repo = "bigchaindb";
    rev = "49bc495cc4bc08531e557cb863949a678dc9456b";
    sha256 = "1c7x2lv9iic87y9r108bww8f3cv60jvkx1qzi7gfmx0cy28j6c94";
  };

  doCheck = false;
  
  #nativeBuildInputs = with pkgs; [ python36Packages.setuptools_scm ];
  
  propagatedBuildInputs = [
    python.packages."pymongo"
    python.packages."pysha3"
    python.packages."cryptoconditions"
    python.packages."python-rapidjson"
    python.packages."logstats"
    python.packages."flask"
    python.packages."flask-cors"
    python.packages."flask-restful"
    python.packages."requests"
    python.packages."gunicorn"
    python.packages."jsonschema"
    python.packages."pyyaml"
    python.packages."aiohttp"
    python.packages."bigchaindb-abci"
    python.packages."setproctitle"
  ];
}
