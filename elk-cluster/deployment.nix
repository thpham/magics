{ pkgs ? import <nixpkgs> {},
  environment ? "dev" }:

let
  elasticSearchInstanceSettings = [
    { id = 0; name = "es-0"; } 
    { id = 1; name = "es-1"; }
    { id = 2; name = "es-2"; }
  ];

  logstashInstanceSettings = [
    { id = 0; name = "ls-0"; }
  ];

  esMasters =
    with pkgs.lib;
    let 
      toLine = n: x: "  - ${x.name}\n";
    in 
      concatImapStrings toLine elasticsearchServers;
    
  makeElasticsearchServer = machine: {
    name  = machine.name;
    value = { config, pkgs, ... }:
      let

      in {       
        networking.firewall.enable = false;

        services.elasticsearch = {
          enable = true;
          package = pkgs.elasticsearch6;
          cluster_name = environment;
          dataDir = "/data";
          listenAddress = "${config.networking.privateIPv4}";
          extraJavaOptions = [
            "-Djava.net.preferIPv4Stack=true"
            #"-Dlog4j2.disable.jmx=true"
          ];
          extraConf = ''
            # Minimum nodes alive to constitute an operational cluster
            node.name: ${machine.name}
            discovery.zen.minimum_master_nodes: 2
            discovery.zen.ping.unicast.hosts:
            ${esMasters}
              - kibana
          '';
        };
      };
  };

  kibana = { config, pkgs, ... }: {
    networking.firewall.enable = false;

    services.kibana = {
      enable = true;
      package = pkgs.kibana6;
      listenAddress = "0.0.0.0";
    };

    services.elasticsearch = {
      enable = true;
      package = pkgs.elasticsearch6;
      cluster_name = environment;
      dataDir = "/data";
      extraJavaOptions = [
        "-Djava.net.preferIPv4Stack=true"
        #"-Dlog4j2.disable.jmx=true"
      ];
      extraConf = ''
        node.name: kibana
        node.master: false
        node.data: false
        node.ingest: false
        
        # by default transport.host refers to network.host
        transport.host: ${config.networking.privateIPv4}

        # Minimum nodes alive to constitute an operational cluster
        discovery.zen.minimum_master_nodes: 2
        discovery.zen.ping.unicast.hosts:
        ${esMasters}
          - kibana
      '';
    };
  };

  makeLogstashServer = machine: {
    name  = machine.name;
    value = { config, pkgs, lib, ... }:
      let
        esMasterUriList = builtins.concatStringsSep "," 
          (builtins.map (hostName: "\"http://"+hostName+":9200\"") 
            (builtins.map (x: x.name) 
              elasticSearchInstanceSettings) );
        
        logstashConfig = pkgs.writeText "logstash.conf" ''
          input {
            tcp {
              port => 5000
            }
            tcp {
              port  => 4560
              type  => "logback"
              codec => json_lines
            }
            tcp {
              port => 4561
              type => "winston"
            }
          }

          ## Add your filters / logstash plugins configuration here
          filter {
          }

          output {
            elasticsearch {
              hosts => [ ${esMasterUriList} ] # (required)
            }
            #stdout { codec => rubydebug }
          }
        '';

        logstash-filter-de_dot =  pkgs.stdenv.mkDerivation rec {
          name = "logstash-filter-de_dot";
          version = "1.0.3";

          src = pkgs.fetchurl {
            url = "https://github.com/logstash-plugins/${name}/archive/v${version}.tar.gz";
            sha256 = "031q3arwxzfl2i536jw8ylp302z48wnc8h406vakmpi4sbwpzbyf";
          };

          dontBuild    = true;
          dontPatchELF = true;
          dontStrip    = true;
          dontPatchShebangs = true;

          installPhase = ''
            mkdir -p $out/logstash
            cp -r lib/* $out
          '';
        };

        pathPlugins = pkgs.writeText "path-plugins.yml" ''
          path.plugins:
            - "${logstash-filter-de_dot}"
            - "${pkgs.logstash-contrib}"
        '';

        logstash6 = pkgs.stdenv.mkDerivation rec {
          version = "6.2.4";
          name = "logstash-${version}";

          src = pkgs.fetchurl {
            url = "https://artifacts.elastic.co/downloads/logstash/${name}.tar.gz";
            sha256 = "07j3jjg5ik4gjgvcx15qqqas9p1m3815jml82a5r1ip9l6vc4h20" ;
          };

          dontBuild         = true;
          dontPatchELF      = true;
          dontStrip         = true;
          dontPatchShebangs = true;

          buildInputs = with pkgs; [
            makeWrapper jre
          ];

          installPhase = ''
            mkdir -p $out
            cp -r {Gemfile*,modules,vendor,lib,bin,config,data,logstash-core,logstash-core-plugin-api} $out
            cat ${pathPlugins} >> $out/config/logstash.yml
            patchShebangs $out/bin/logstash
            patchShebangs $out/bin/logstash-plugin
            wrapProgram $out/bin/logstash \
              --set JAVA_HOME "${pkgs.jre}"
            wrapProgram $out/bin/logstash-plugin \
              --set JAVA_HOME "${pkgs.jre}"
          '';
        };

      in {            
        networking.firewall.enable = false;

        systemd.services.logstash = with pkgs; {
          description = "Logstash Daemon";
          wantedBy = [ "multi-user.target" ];
          environment = { JAVA_HOME = jre; };
          path = [ pkgs.bash ];
          serviceConfig = {
            ExecStartPre = ''${pkgs.coreutils}/bin/mkdir -p /data/logs ; ${pkgs.coreutils}/bin/chmod -R 700 /data '';
            ExecStart = lib.concatStringsSep " " (lib.filter (s: lib.stringLength s != 0) [
              "${logstash6}/bin/logstash"
              "-w 2"
              # BUG: NameError: `@path.plugins' is not allowable as an instance variable name
              #"--path.plugins ${pluginPath}" # have to put this in logstash.yml
              "--log.level warn"
              "-f ${logstashConfig}"
              "--path.settings ${logstash6}/config"
              "--path.data /data"
              "--path.logs /data/logs"
            ]);
          };
        };
      };
  };

  elasticsearchServers = map makeElasticsearchServer elasticSearchInstanceSettings;
  logstashServers     = map makeLogstashServer logstashInstanceSettings;

in  { 
  network.description = "elk-cluster";
  network.enableRollback = true;

  defaults = {
    imports = [ ../common.nix ];
  };

  "kibana" = kibana;
}
// builtins.listToAttrs elasticsearchServers
// builtins.listToAttrs logstashServers
