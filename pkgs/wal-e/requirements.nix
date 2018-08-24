# generated using pypi2nix tool (version: 1.8.1)
# See more at: https://github.com/garbas/pypi2nix
#
# COMMAND:
#   pypi2nix -v -V 3.6 --default-overrides -E libffi openssl glibcLocales -r requirements.txt
#

{ pkgs ? import <nixpkgs> {},
  overrides ? ({ pkgs, python }: self: super: {})
}:

let

  inherit (pkgs) makeWrapper;
  inherit (pkgs.stdenv.lib) fix' extends inNixShell;

  pythonPackages =
  import "${toString pkgs.path}/pkgs/top-level/python-packages.nix" {
    inherit pkgs;
    inherit (pkgs) stdenv;
    python = pkgs.python36;
    # patching pip so it does not try to remove files when running nix-shell
    overrides =
      self: super: {
        bootstrapped-pip = super.bootstrapped-pip.overrideDerivation (old: {
          patchPhase = old.patchPhase + ''
            if [ -e $out/${pkgs.python36.sitePackages}/pip/req/req_install.py ]; then
              sed -i \
                -e "s|paths_to_remove.remove(auto_confirm)|#paths_to_remove.remove(auto_confirm)|"  \
                -e "s|self.uninstalled = paths_to_remove|#self.uninstalled = paths_to_remove|"  \
                $out/${pkgs.python36.sitePackages}/pip/req/req_install.py
            fi
          '';
        });
      };
  };

  commonBuildInputs = with pkgs; [ libffi openssl glibcLocales ];
  commonDoCheck = false;

  withPackages = pkgs':
    let
      pkgs = builtins.removeAttrs pkgs' ["__unfix__"];
      interpreterWithPackages = selectPkgsFn: pythonPackages.buildPythonPackage {
        name = "python36-interpreter";
        buildInputs = [ makeWrapper ] ++ (selectPkgsFn pkgs);
        buildCommand = ''
          mkdir -p $out/bin
          ln -s ${pythonPackages.python.interpreter} \
              $out/bin/${pythonPackages.python.executable}
          for dep in ${builtins.concatStringsSep " "
              (selectPkgsFn pkgs)}; do
            if [ -d "$dep/bin" ]; then
              for prog in "$dep/bin/"*; do
                if [ -x "$prog" ] && [ -f "$prog" ]; then
                  ln -s $prog $out/bin/`basename $prog`
                fi
              done
            fi
          done
          for prog in "$out/bin/"*; do
            wrapProgram "$prog" --prefix PYTHONPATH : "$PYTHONPATH"
          done
          pushd $out/bin
          ln -s ${pythonPackages.python.executable} python
          ln -s ${pythonPackages.python.executable} \
              python3
          popd
        '';
        passthru.interpreter = pythonPackages.python;
      };

      interpreter = interpreterWithPackages builtins.attrValues;
    in {
      __old = pythonPackages;
      inherit interpreter;
      inherit interpreterWithPackages;
      mkDerivation = pythonPackages.buildPythonPackage;
      packages = pkgs;
      overrideDerivation = drv: f:
        pythonPackages.buildPythonPackage (
          drv.drvAttrs // f drv.drvAttrs // { meta = drv.meta; }
        );
      withPackages = pkgs'':
        withPackages (pkgs // pkgs'');
    };

  python = withPackages {};

  generated = self: {
    "Babel" = python.mkDerivation {
      name = "Babel-2.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/be/cc/9c981b249a455fa0c76338966325fc70b7265521bad641bf2932f77712f4/Babel-2.6.0.tar.gz"; sha256 = "8cba50f48c529ca3fa18cf81fa9403be176d374ac4d60738b839122dfaaa3d23"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pytz"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://babel.pocoo.org/";
        license = licenses.bsdOriginal;
        description = "Internationalization utilities";
      };
    };

    "PyJWT" = python.mkDerivation {
      name = "PyJWT-1.6.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/00/5e/b358c9bb24421e6155799d995b4aa3aa3307ffc7ecae4ad9d29fd7e07a73/PyJWT-1.6.4.tar.gz"; sha256 = "4ee413b357d53fd3fb44704577afac88e72e878716116270d722723d65b42176"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."cryptography"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/jpadilla/pyjwt";
        license = licenses.mit;
        description = "JSON Web Token implementation in Python";
      };
    };

    "PyYAML" = python.mkDerivation {
      name = "PyYAML-3.13";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9e/a3/1d13970c3f36777c583f136c136f804d70f500168edc1edea6daa7200769/PyYAML-3.13.tar.gz"; sha256 = "3ef3092145e9b70e3ddd2c7ad59bdd0252a94dfe3949721633e41344de00a6bf"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pyyaml.org/wiki/PyYAML";
        license = licenses.mit;
        description = "YAML parser and emitter for Python";
      };
    };

    "SecretStorage" = python.mkDerivation {
      name = "SecretStorage-3.0.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/65/02/1f0d2a7b1221bc9a15f8b8d4de2c8ad8272c4d0af76cbdc72e2cf51d42e0/SecretStorage-3.0.1.tar.gz"; sha256 = "819087ca89c0d6c5711692f41fb26f786af9dcc5bb89d567722a66edfbb2a689"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."cryptography"
      self."jeepney"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/mitya57/secretstorage";
        license = licenses.bsdOriginal;
        description = "Python bindings to FreeDesktop.org Secret Service API";
      };
    };

    "adal" = python.mkDerivation {
      name = "adal-1.0.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/80/65/d62a4b43eca475cf865ffc2acc18be08fe3430f374b0a0d931d7063b5d72/adal-1.0.2.tar.gz"; sha256 = "4c020807b3f3cfd90f59203077dd5e1f59671833f8c3c5028ec029ed5072f9ce"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyJWT"
      self."cryptography"
      self."python-dateutil"
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/AzureAD/azure-activedirectory-library-for-python";
        license = licenses.mit;
        description = "The ADAL for Python library makes it easy for python application to authenticate to Azure Active Directory (AAD) in order to access AAD protected web resources.";
      };
    };

    "asn1crypto" = python.mkDerivation {
      name = "asn1crypto-0.24.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fc/f1/8db7daa71f414ddabfa056c4ef792e1461ff655c2ae2928a2b675bfed6b4/asn1crypto-0.24.0.tar.gz"; sha256 = "9d5c20441baf0cb60a4ac34cc447c6c189024b6b4c6cd7877034f4965c464e49"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/wbond/asn1crypto";
        license = licenses.mit;
        description = "Fast ASN.1 parser and serializer with definitions for private keys, public keys, certificates, CRL, OCSP, CMS, PKCS#3, PKCS#7, PKCS#8, PKCS#12, PKCS#5, X.509 and TSP";
      };
    };

    "azure" = python.mkDerivation {
      name = "azure-3.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d0/52/713a87dc433e576dfc344c0406fdb9e649fb7e9af3fa4d07a61553e18003/azure-3.0.0.zip"; sha256 = "4380c1ef6ad34f9ecf41a84b8f24f56804825cff7ce43c4fded0fb75ff90b396"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-batch"
      self."azure-cosmosdb-table"
      self."azure-datalake-store"
      self."azure-eventgrid"
      self."azure-graphrbac"
      self."azure-keyvault"
      self."azure-mgmt"
      self."azure-servicebus"
      self."azure-servicefabric"
      self."azure-servicemanagement-legacy"
      self."azure-storage-blob"
      self."azure-storage-file"
      self."azure-storage-queue"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Client Libraries for Python";
      };
    };

    "azure-batch" = python.mkDerivation {
      name = "azure-batch-4.1.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/89/45/b79192d40f82588823ff46bd27941e419758ab6628ec3d7d06ddee1434ec/azure-batch-4.1.3.zip"; sha256 = "cd71c7ebb5beab174b6225bbf79ae18d6db0c8d63227a7e514da0a75f138364c"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Batch Client Library for Python";
      };
    };

    "azure-common" = python.mkDerivation {
      name = "azure-common-1.1.14";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/bb/c1/ac3842e1016561953872d7ee15aae2d246fb989e5b236abd22ee40b2c39a/azure-common-1.1.14.zip"; sha256 = "4f8fc8879cfded406d0032d86f5750d8c742658072aef5edb1d54a055a847645"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Client Library for Python (Common)";
      };
    };

    "azure-cosmosdb-nspkg" = python.mkDerivation {
      name = "azure-cosmosdb-nspkg-2.0.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/91/1b/68df002d2b3992da134244c27ca2380ad8159535391373fac66d7fb5f9fa/azure-cosmosdb-nspkg-2.0.2.tar.gz"; sha256 = "acf691e692818d9a65c653c7a3485eb8e35c0bdc496bba652e5ea3905ba09cd8"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-nspkg"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-cosmosdb-python";
        license = licenses.asl20;
        description = "Microsoft Azure CosmosDB Namespace Package [Internal]";
      };
    };

    "azure-cosmosdb-table" = python.mkDerivation {
      name = "azure-cosmosdb-table-1.0.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9c/65/e39d626792e1c0be235f3567586a7e1db779bb11e0fd9d6b657fd65b77c9/azure-cosmosdb-table-1.0.4.tar.gz"; sha256 = "661a3b941944e4716f674ab6355ec5a33e69a999ddf321ce6d3becfd7186878b"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-cosmosdb-nspkg"
      self."azure-storage-common"
      self."cryptography"
      self."python-dateutil"
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-cosmosdb-python";
        license = licenses.asl20;
        description = "Microsoft Azure CosmosDB Table Client Library for Python";
      };
    };

    "azure-datalake-store" = python.mkDerivation {
      name = "azure-datalake-store-0.0.29";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/1b/f5/666b3a49c05b4328d180636b30a122afec781cea8979f9f96e054d1603c9/azure-datalake-store-0.0.29.tar.gz"; sha256 = "9493de3bbee9762f1dc7d7d81e30f9bbf092d571394ad7c80dfafafa6ec81c3e"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."adal"
      self."azure-nspkg"
      self."cffi"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-data-lake-store-python";
        license = licenses.mit;
        description = "Azure Data Lake Store Filesystem Client Library for Python";
      };
    };

    "azure-eventgrid" = python.mkDerivation {
      name = "azure-eventgrid-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/67/59/698b2908cc71bf8d272625835c89fb3350c139d58b732f873230f9cb59aa/azure-eventgrid-0.1.0.zip"; sha256 = "33816fa4912786ea55ca610837685f23e2de8d1b1968cef917ba0a64a8c92b4a"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-nspkg"
      self."msrest"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Event Grid Client Library for Python";
      };
    };

    "azure-graphrbac" = python.mkDerivation {
      name = "azure-graphrbac-0.40.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c1/4c/3904f9c7b4470df6a2e49c2d1c6f314a337f34dccbadcdcb892d12493c52/azure-graphrbac-0.40.0.zip"; sha256 = "f94b97bdcf774878fe2f8b8c46a5d6550a4ed891350ed0730c1561a24d488ee2"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Graph RBAC Client Library for Python";
      };
    };

    "azure-keyvault" = python.mkDerivation {
      name = "azure-keyvault-0.3.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/10/92/24d4371d566f447e2b4ecebb9c360ca52e80f0a3381504974b0e37d865e7/azure-keyvault-0.3.7.zip"; sha256 = "549fafb04e1a3af1fdc94ccde05d59180d637ff6485784f716e7ddb30e6dd0ff"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Key Vault Client Library for Python";
      };
    };

    "azure-mgmt" = python.mkDerivation {
      name = "azure-mgmt-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/3f/2e/f1a9cfe65ef594f715c5276be70d829ec6c8ab08684fff91d6ab225186c8/azure-mgmt-2.0.0.zip"; sha256 = "c027defac273731a3cebba6dbda560b965f4dbc47b7b16b73cce5fa98a3ba4de"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-mgmt-advisor"
      self."azure-mgmt-applicationinsights"
      self."azure-mgmt-authorization"
      self."azure-mgmt-batch"
      self."azure-mgmt-batchai"
      self."azure-mgmt-billing"
      self."azure-mgmt-cdn"
      self."azure-mgmt-cognitiveservices"
      self."azure-mgmt-commerce"
      self."azure-mgmt-compute"
      self."azure-mgmt-consumption"
      self."azure-mgmt-containerinstance"
      self."azure-mgmt-containerregistry"
      self."azure-mgmt-containerservice"
      self."azure-mgmt-cosmosdb"
      self."azure-mgmt-datafactory"
      self."azure-mgmt-datalake-analytics"
      self."azure-mgmt-datalake-store"
      self."azure-mgmt-devtestlabs"
      self."azure-mgmt-dns"
      self."azure-mgmt-eventgrid"
      self."azure-mgmt-eventhub"
      self."azure-mgmt-hanaonazure"
      self."azure-mgmt-iothub"
      self."azure-mgmt-iothubprovisioningservices"
      self."azure-mgmt-keyvault"
      self."azure-mgmt-loganalytics"
      self."azure-mgmt-logic"
      self."azure-mgmt-machinelearningcompute"
      self."azure-mgmt-managementpartner"
      self."azure-mgmt-marketplaceordering"
      self."azure-mgmt-media"
      self."azure-mgmt-monitor"
      self."azure-mgmt-msi"
      self."azure-mgmt-network"
      self."azure-mgmt-notificationhubs"
      self."azure-mgmt-powerbiembedded"
      self."azure-mgmt-rdbms"
      self."azure-mgmt-recoveryservices"
      self."azure-mgmt-recoveryservicesbackup"
      self."azure-mgmt-redis"
      self."azure-mgmt-relay"
      self."azure-mgmt-reservations"
      self."azure-mgmt-resource"
      self."azure-mgmt-scheduler"
      self."azure-mgmt-search"
      self."azure-mgmt-servermanager"
      self."azure-mgmt-servicebus"
      self."azure-mgmt-servicefabric"
      self."azure-mgmt-sql"
      self."azure-mgmt-storage"
      self."azure-mgmt-subscription"
      self."azure-mgmt-trafficmanager"
      self."azure-mgmt-web"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Resource Management Client Libraries for Python";
      };
    };

    "azure-mgmt-advisor" = python.mkDerivation {
      name = "azure-mgmt-advisor-1.0.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f0/67/5de0f7f8f71f2adbed66f981fcd77c0db5ed8801be87dc00799f3296f686/azure-mgmt-advisor-1.0.1.zip"; sha256 = "8fdcb41f760a216e6b835eaec11dba61822777b386139d83eee31f0ff63b05da"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Advisor Client Library for Python";
      };
    };

    "azure-mgmt-applicationinsights" = python.mkDerivation {
      name = "azure-mgmt-applicationinsights-0.1.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/83/ad/27c3e2c618c08ea451a80d6a0dc5b73b8c8c2392706909f297c37389766f/azure-mgmt-applicationinsights-0.1.1.zip"; sha256 = "f10229eb9e3e9d0ad20188b8d14d67055e86f3815b43b75eedf96b654bee2a9b"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Application Insights Management Client Library for Python";
      };
    };

    "azure-mgmt-authorization" = python.mkDerivation {
      name = "azure-mgmt-authorization-0.30.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/27/ed/e857a8d638fe605c24ca11fe776edad2b0ff697e2395fff25db254b37dfb/azure-mgmt-authorization-0.30.0.zip"; sha256 = "ff965fe74916974a51e834615b7204f494a1bad42ad8d43874bd879855554466"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Authorization Management Client Library for Python";
      };
    };

    "azure-mgmt-batch" = python.mkDerivation {
      name = "azure-mgmt-batch-5.0.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8b/c3/ffd878e309a2e3905f9f4aa453344abad1e41caca33d495501c05074458c/azure-mgmt-batch-5.0.1.zip"; sha256 = "6e375ecdd5966ee9ee45b29c90a806388c27ceacc2cbd6dd406ff311b5d7da72"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Batch Management Client Library for Python";
      };
    };

    "azure-mgmt-batchai" = python.mkDerivation {
      name = "azure-mgmt-batchai-0.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/5c/e7/d29acdca0136c9e74cfcf8d78a12e9f890f77a66b375de7351f95dd2015e/azure-mgmt-batchai-0.2.0.zip"; sha256 = "35bda8468cedd0da03841789d96386f2d06d3789e53df72d9b620ac44e6b6f80"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Batch AI Management Client Library for Python";
      };
    };

    "azure-mgmt-billing" = python.mkDerivation {
      name = "azure-mgmt-billing-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/53/78/fccfdc17d9c22757a58ce96b6f46d6c136f56672e7f1f74032129d64a4ad/azure-mgmt-billing-0.1.0.zip"; sha256 = "56a4365ac272f0221f79396aaabb2217f5b5eb970d28f3d80f83efc5a9481532"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Billing Management Client Library for Python";
      };
    };

    "azure-mgmt-cdn" = python.mkDerivation {
      name = "azure-mgmt-cdn-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/18/eb/49b957614df3829866687ab7f8a0eec7ed8dda02092fcef8444271f7a750/azure-mgmt-cdn-2.0.0.zip"; sha256 = "57e5a78443e65c4ed7bfb9152efd593b87bcc66f0404eb822a63b059a099963b"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure CDN Management Client Library for Python";
      };
    };

    "azure-mgmt-cognitiveservices" = python.mkDerivation {
      name = "azure-mgmt-cognitiveservices-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/94/1c/1407ddec10a46506193acb35a572284517930efebe836db3fe3b81d01e17/azure-mgmt-cognitiveservices-2.0.0.zip"; sha256 = "bd4e1dcfbaa7b6dce5c236196f2cff0f3a92d7246e60eba888b03137f4fafa87"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Cognitive Services Management Client Library for Python";
      };
    };

    "azure-mgmt-commerce" = python.mkDerivation {
      name = "azure-mgmt-commerce-1.0.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9b/06/f071cb84153858492664eb6a4a2aac8b831907b255b4e5745f0a1e06fc18/azure-mgmt-commerce-1.0.1.zip"; sha256 = "c48e84ed322fa9ddbc2d7fcca754c5e97171919be94f510bd2579cf5666684c3"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Commerce Client Library for Python";
      };
    };

    "azure-mgmt-compute" = python.mkDerivation {
      name = "azure-mgmt-compute-3.0.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/33/34/27b48ea344325e06e71a752ac418ae0baf73e912a160393b85c39376bbb6/azure-mgmt-compute-3.0.1.zip"; sha256 = "7a28dbef42c4cfe70d9b3a9e9371668f0f448d343136ce98095b503a3085d854"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Compute Management Client Library for Python";
      };
    };

    "azure-mgmt-consumption" = python.mkDerivation {
      name = "azure-mgmt-consumption-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8c/f0/e2d94b246e2dce71eff8d362836a1979f02b4185f5403a13e4fb26c07ccb/azure-mgmt-consumption-2.0.0.zip"; sha256 = "9a85a89f30f224d261749be20b4616a0eb8948586f7f0f20573b8ea32f265189"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Consumption Management Client Library for Python";
      };
    };

    "azure-mgmt-containerinstance" = python.mkDerivation {
      name = "azure-mgmt-containerinstance-0.3.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/26/51/37aac0d7025adc49271081e5b7acad9c2f047c60622430b083a18b2e799d/azure-mgmt-containerinstance-0.3.1.zip"; sha256 = "3dad1d75a1d210eb001d67e7edc9dbee6f0a965ca928c6632e64243a1e6dfeb5"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Container Instance Client Library for Python";
      };
    };

    "azure-mgmt-containerregistry" = python.mkDerivation {
      name = "azure-mgmt-containerregistry-1.0.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/10/78/8a8b88b5cd662e0ac797996fad1a4ad09e3cad615fc9239d9a8fd46323b2/azure-mgmt-containerregistry-1.0.1.zip"; sha256 = "12589d5aeba82fdd4bd58cc7676560b31b73c818f59358ce6f598c28b905843a"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Container Registry Client Library for Python";
      };
    };

    "azure-mgmt-containerservice" = python.mkDerivation {
      name = "azure-mgmt-containerservice-3.0.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/1b/7e/0aad556bbe57fb8b57f0c2ad6a6936f209ef5aeb73029d21cb4db05a2dbb/azure-mgmt-containerservice-3.0.1.zip"; sha256 = "cabf729e503a47c76d31033928c9769ba5a6f1dbf73afa42436adb7226ce4e76"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Container Service Client Library for Python";
      };
    };

    "azure-mgmt-cosmosdb" = python.mkDerivation {
      name = "azure-mgmt-cosmosdb-0.3.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/56/e7/cea449bb3d438dbc98a01e8b10ae236a0e70211b288f5893933e16b7de94/azure-mgmt-cosmosdb-0.3.1.zip"; sha256 = "65911bd31d40197a5b5631b5327034bff7cc6bc3f9b1001be0e6abf11f535182"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Cosmos DB Management Client Library for Python";
      };
    };

    "azure-mgmt-datafactory" = python.mkDerivation {
      name = "azure-mgmt-datafactory-0.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/af/52/5fe6c9bd311df1031a2f11c46e23a10068aadfe0b99f0383910a3e011d99/azure-mgmt-datafactory-0.4.0.zip"; sha256 = "bd991036df940bf56381fc0d46ddb10fbb0ded248405bd0ba612971cdcff94ae"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Data Factory Management Client Library for Python";
      };
    };

    "azure-mgmt-datalake-analytics" = python.mkDerivation {
      name = "azure-mgmt-datalake-analytics-0.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a0/8c/f8696a4d34f8f14b0594c2245e966a3bfaf12c002e38b27048f53286fc47/azure-mgmt-datalake-analytics-0.3.0.zip"; sha256 = "7b5ed7a7ceaf6de8ce594b1b6474754a07cfcbfb06d613c09b1e539d4f62483a"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-datalake-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Data Lake Analytics Management Client Library for Python";
      };
    };

    "azure-mgmt-datalake-nspkg" = python.mkDerivation {
      name = "azure-mgmt-datalake-nspkg-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f7/eb/3b330ffd3a925db473175c3a28244bdf87c4736ce16a55be7a7535c6bfa5/azure-mgmt-datalake-nspkg-2.0.0.zip"; sha256 = "28b8774a1aba3e11c431f9c6cc984fde31a0ecbb89270924f392504f4260ca37"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-mgmt-nspkg"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Data Lake Management Namespace Package [Internal]";
      };
    };

    "azure-mgmt-datalake-store" = python.mkDerivation {
      name = "azure-mgmt-datalake-store-0.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/2d/48/d9477303445e24616b87d49592dfe8792cf5d1dc383440b3f96e84765191/azure-mgmt-datalake-store-0.3.0.zip"; sha256 = "d3bdd3071632574d52a423be86a4e24bb1302b1415061d16d8d0ea83edf97d17"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-datalake-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Data Lake Store Management Client Client Library for Python";
      };
    };

    "azure-mgmt-devtestlabs" = python.mkDerivation {
      name = "azure-mgmt-devtestlabs-2.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/1d/67/b3fad6c04240edf278d2afa71129b8a86f43803ee681c518beac5729e58b/azure-mgmt-devtestlabs-2.2.0.zip"; sha256 = "d416a6d0883b0d33a63c524db6455ee90a01a72a9d8757653e446bf4d3f69796"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure DevTestLabs Management Client Library for Python";
      };
    };

    "azure-mgmt-dns" = python.mkDerivation {
      name = "azure-mgmt-dns-1.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/41/43/ec4c6205a1b756e9feafe61346527c217171982fb5e6317f47fb0696600d/azure-mgmt-dns-1.2.0.zip"; sha256 = "676cdcd2b83bd4b24782047ec4395657103ea89dacdcf824cf9ed8eb5584d1bf"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure DNS Management Client Library for Python";
      };
    };

    "azure-mgmt-eventgrid" = python.mkDerivation {
      name = "azure-mgmt-eventgrid-0.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a8/b5/a3e49faa5bd5618294d411bbd11ed1ae9eb886c65b78cdcb9bea360a53e4/azure-mgmt-eventgrid-0.4.0.zip"; sha256 = "cf22195fe453627e20d81695a14e3c7b9329790763b65243be55d66964c789ac"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure EventGrid Management Client Library for Python";
      };
    };

    "azure-mgmt-eventhub" = python.mkDerivation {
      name = "azure-mgmt-eventhub-1.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/7f/07/94a08651d8afa5f9174a80b3198d1fc3e0f2baf522bcf9fc4596cbfdd1e4/azure-mgmt-eventhub-1.2.0.zip"; sha256 = "30a316ccd7a91fbf397a3df2648ae7dfa218566177f85ed65450a13698f77215"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure EventHub Management Client Library for Python";
      };
    };

    "azure-mgmt-hanaonazure" = python.mkDerivation {
      name = "azure-mgmt-hanaonazure-0.1.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/60/3f/35077df2dce6ff6201da5f809a8af2231e37b0d4a83a44582dfea701eda0/azure-mgmt-hanaonazure-0.1.1.zip"; sha256 = "aec953c54809d0cc2f61f24d4d62a97f02c466bdc7906fd66f30120becf0c3df"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure SAP Hana on Azure Management Client Library for Python";
      };
    };

    "azure-mgmt-iothub" = python.mkDerivation {
      name = "azure-mgmt-iothub-0.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/33/46/1283ee4c6dda32bd92018adcbdf521595a6ca80fa7e203064a2eb284d56d/azure-mgmt-iothub-0.4.0.zip"; sha256 = "65ff5bf8cc6096ab468ba444d64b501366218af15f937f0ce14173fadbc1653d"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure IoTHub Management Client Library for Python";
      };
    };

    "azure-mgmt-iothubprovisioningservices" = python.mkDerivation {
      name = "azure-mgmt-iothubprovisioningservices-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9c/a8/1ddbe8bda18673a76ad35862651242ab2dfb0dadaf770135dad8dba50f56/azure-mgmt-iothubprovisioningservices-0.1.0.zip"; sha256 = "afc226a76477e9f881979cd5376533a0fdc276b3e9540c3620ada65ef0187bd2"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure IoTHub Provisioning Services Client Library for Python";
      };
    };

    "azure-mgmt-keyvault" = python.mkDerivation {
      name = "azure-mgmt-keyvault-0.40.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e0/c2/6c572800601330c343f993b93432f06ff2abdc35ee40ef42f81ee3a00ec2/azure-mgmt-keyvault-0.40.0.zip"; sha256 = "fb7facbcdc9157f7fb83abb41032f257a6013a02205d7c0327b56779ca20fd30"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure KeyVault Apps Resource Management Client Library for Python";
      };
    };

    "azure-mgmt-loganalytics" = python.mkDerivation {
      name = "azure-mgmt-loganalytics-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/80/24/d3d4da97b013d837a367feae1b06f007866c6333f5ab1e6e46de623efb3f/azure-mgmt-loganalytics-0.1.0.zip"; sha256 = "0b4e92becb60f3c4d8cb4243ba8f8e285f5593c6c0d05781420f62968f2f9660"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Log Analytics Management Client Library for Python";
      };
    };

    "azure-mgmt-logic" = python.mkDerivation {
      name = "azure-mgmt-logic-2.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/56/3d/73c27708d003d37f3ad4c5d93978aa14ff00665a5da44eb80100a547863e/azure-mgmt-logic-2.1.0.zip"; sha256 = "a64ced3e50a566f60c8e0fc7c697a3db58a88e62583b2dec0d79f570b8efcdea"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Logic Apps Resource Management Client Library for Python";
      };
    };

    "azure-mgmt-machinelearningcompute" = python.mkDerivation {
      name = "azure-mgmt-machinelearningcompute-0.4.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/13/0c/2cb43ea257535b587faa77efa440b0ebe90e0fe1840b8544906a067b0306/azure-mgmt-machinelearningcompute-0.4.1.zip"; sha256 = "7a52f85591114ef33a599dabbef840d872b7f599b7823e596af9490ec51b873f"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Machine Learning Compute Management Client Library for Python";
      };
    };

    "azure-mgmt-managementpartner" = python.mkDerivation {
      name = "azure-mgmt-managementpartner-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/87/05/0a5cd0b038ff6255be44af60bb0bc79dd4a9d6841a97325f7072a56463f1/azure-mgmt-managementpartner-0.1.0.zip"; sha256 = "1b0ec9b9d084e331b863cef77f002ede8cbc6214bb56c3c8dd7945d10c7ffc77"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure ManagementPartner Management Client Library for Python";
      };
    };

    "azure-mgmt-marketplaceordering" = python.mkDerivation {
      name = "azure-mgmt-marketplaceordering-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/30/16/e381dd68bfc281f110a94733abdce0626b9c38647ea17f89adc937c61f49/azure-mgmt-marketplaceordering-0.1.0.zip"; sha256 = "6da12425cbab0cc62f246e7266b4d67aff6bdd031ecbe50c7542c2f2b2440ad4"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Market Place Ordering Client Library for Python";
      };
    };

    "azure-mgmt-media" = python.mkDerivation {
      name = "azure-mgmt-media-0.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0c/96/4f6ae0f92895aaba8868ea9dbc44e088c2babd01ac4a3de090247365a63d/azure-mgmt-media-0.2.0.zip"; sha256 = "656181ee580ff9a6e15cdd5db16e9adfc98b6f39c5108181c36a7ec825fccb87"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Media Services Management Client Library for Python";
      };
    };

    "azure-mgmt-monitor" = python.mkDerivation {
      name = "azure-mgmt-monitor-0.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b2/5a/ac8f8ce8b537d7c4ba6f21729a24c71da464f84d62f1e3d3daa533fb5963/azure-mgmt-monitor-0.4.0.zip"; sha256 = "1c9457c38cfe6704de3ab7320a145bb3a25cd41f55242d53e5519bf3e676eb44"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Monitor Management Client Library for Python";
      };
    };

    "azure-mgmt-msi" = python.mkDerivation {
      name = "azure-mgmt-msi-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/2b/75/d48876229987f592358b3d4475877797fda939d9d04bbbbc13edf141fa52/azure-mgmt-msi-0.1.0.zip"; sha256 = "53eed7bc8453b764b4d568320eed032328da5b606185c216f3e93c75fa328858"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure MSI Management Client Library for Python";
      };
    };

    "azure-mgmt-network" = python.mkDerivation {
      name = "azure-mgmt-network-1.7.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/2d/f6/1ae5eb3414dc259bb8a67ce72354dc8a5095ca02dc6376672c4ee27bce5b/azure-mgmt-network-1.7.1.zip"; sha256 = "ddfff3dd31c7329b26f282615b719e7030c5206e56951daae4f180957c1e5201"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Network Management Client Library for Python";
      };
    };

    "azure-mgmt-notificationhubs" = python.mkDerivation {
      name = "azure-mgmt-notificationhubs-1.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/82/97/407bfba09fdbff5b9a73831ac567bb1a9b0563c88c5b08c65cbd4d4ac989/azure-mgmt-notificationhubs-1.0.0.zip"; sha256 = "fa5889ace3a900ade01ad904d04b3778c0488bb67fa9b87c7ea389e83e5d5cd4"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Notification Hubs Management Client Library for Python";
      };
    };

    "azure-mgmt-nspkg" = python.mkDerivation {
      name = "azure-mgmt-nspkg-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fe/66/66eb0d5ead69b7371649466fa160a166de0d1ddafc4a1d7a172858a8abc9/azure-mgmt-nspkg-2.0.0.zip"; sha256 = "e36488d4f5d7d668ef5cc3e6e86f081448fd60c9bf4e051d06ff7cfc5a653e6f"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-nspkg"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Resource Management Namespace Package [Internal]";
      };
    };

    "azure-mgmt-powerbiembedded" = python.mkDerivation {
      name = "azure-mgmt-powerbiembedded-1.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/17/5d/db62d4c811d4a2ca9daccefedda6c541bd35fa2a709389bc7a74832b19f2/azure-mgmt-powerbiembedded-1.0.0.zip"; sha256 = "bb04025c6c9ae314cb4279c0dcb1def43ee1057ad19caf012b0d3bcf5117e1f6"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Power BI Embedded Management Client Library for Python";
      };
    };

    "azure-mgmt-rdbms" = python.mkDerivation {
      name = "azure-mgmt-rdbms-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4f/bb/fd668496474ca4a43361a83e1db7de41d4f4ff632f74bd446ede9d9f7a2a/azure-mgmt-rdbms-0.1.0.zip"; sha256 = "c06419399f04e2757f447731a09d232090a855369c9f975fc90ed9a8bddd0b01"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure RDBMS Management Client Library for Python";
      };
    };

    "azure-mgmt-recoveryservices" = python.mkDerivation {
      name = "azure-mgmt-recoveryservices-0.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/30/5d/339b935d921e951f38c0842bb2386049d08f355019faf7b5ca06b28aeaaf/azure-mgmt-recoveryservices-0.2.0.zip"; sha256 = "4acba8a6279dc85f8d9951cffb1205e88f956dab53a703854a08b2af5404936a"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Recovery Services Client Library for Python";
      };
    };

    "azure-mgmt-recoveryservicesbackup" = python.mkDerivation {
      name = "azure-mgmt-recoveryservicesbackup-0.1.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9f/fb/731b07c573c660780e660d883cb1d1a6d09c1b4ebd5348383eae854a4024/azure-mgmt-recoveryservicesbackup-0.1.1.zip"; sha256 = "a09a514f5c7877406bdf777007683f036f5444f878cf595a15e541e7ba5c1c66"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Recovery Services Backup Client Library for Python";
      };
    };

    "azure-mgmt-redis" = python.mkDerivation {
      name = "azure-mgmt-redis-5.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/be/18/3f350eb5ddba594b1775b5f3a0cc60f53357feaf3986b7cd2da5400d2802/azure-mgmt-redis-5.0.0.zip"; sha256 = "374a267b83ec4e71077b8afad537863fb93816c96407595cdd02973235356ded"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Redis Cache Management Client Library for Python";
      };
    };

    "azure-mgmt-relay" = python.mkDerivation {
      name = "azure-mgmt-relay-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/df/76/f4673094df467c1198dfd944f8a800a25d0ed7f4bbd7c73e9e2605874576/azure-mgmt-relay-0.1.0.zip"; sha256 = "d9f987cf2998b8a354f331b2a71082c049193f1e1cd345812e14b9b821365acb"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Relay Client Library for Python";
      };
    };

    "azure-mgmt-reservations" = python.mkDerivation {
      name = "azure-mgmt-reservations-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/76/32/5d7c2d8e4f71679301562cef1ae4e18536d601741c5b4789a275659ed101/azure-mgmt-reservations-0.1.0.zip"; sha256 = "73645c247b9fb2cc39d4cdab85405e55df2e8eab5a478514be0825e253660b9d"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Reservations Management Client Library for Python";
      };
    };

    "azure-mgmt-resource" = python.mkDerivation {
      name = "azure-mgmt-resource-1.2.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/27/f0/ab10f7851e9437da02b981d79545cd7290380d396d822bf71f99d457637b/azure-mgmt-resource-1.2.2.zip"; sha256 = "fe65dc43c8643a8c3e731783e98334258bf5dc57cf4ae063401e2b05b9d71d71"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Resource Management Client Library for Python";
      };
    };

    "azure-mgmt-scheduler" = python.mkDerivation {
      name = "azure-mgmt-scheduler-1.1.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e3/23/b6ac7cbad15b877b371d7b019c4845b8269d96f0c35f22c0afd806bc526b/azure-mgmt-scheduler-1.1.3.zip"; sha256 = "ffd0aa675a7bfc53ce57cf335fcbccf7055b8927413c6b19af3d57d0ac2ce250"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Scheduler Management Client Library for Python";
      };
    };

    "azure-mgmt-search" = python.mkDerivation {
      name = "azure-mgmt-search-1.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/58/94/e2bc41576b730a578848b17b8a337efdf579c7593393a7d2fe54e5700431/azure-mgmt-search-1.0.0.zip"; sha256 = "20399e114dced423563a32fe9b8af5d8ea2cd1e1d08d6df603fbd5ce2e4dbf28"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Search Management Client Library for Python";
      };
    };

    "azure-mgmt-servermanager" = python.mkDerivation {
      name = "azure-mgmt-servermanager-1.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/97/6e/f18aefa55165fb7035953fc1e006b14749a4cf7c2ffbc34b259fad01c377/azure-mgmt-servermanager-1.2.0.zip"; sha256 = "0ac10b4481b66325db63a17397a7f1e8a8a9299a006cf89ac746338e943015f4"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Server Manager Management Client Library for Python";
      };
    };

    "azure-mgmt-servicebus" = python.mkDerivation {
      name = "azure-mgmt-servicebus-0.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/bc/30/46b609e02a79c1a464e83a0e3b1c6e1184df69ca374d8c9322bff28703e1/azure-mgmt-servicebus-0.4.0.zip"; sha256 = "d678ec3220270dede73863db22506307638d51001c1fd97de07b0ca77210371a"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Service Bus Management Client Library for Python";
      };
    };

    "azure-mgmt-servicefabric" = python.mkDerivation {
      name = "azure-mgmt-servicefabric-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e6/79/597d3e5fe6ee4ac44a42918e83a99734d25f38f0f3ef48b854bbac0a34a3/azure-mgmt-servicefabric-0.1.0.zip"; sha256 = "9f7789bdc221fcf81608cc5a3e64f1d59d41c453ff1567cb81197b19a2cd6373"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Service Fabric Management Client Library for Python";
      };
    };

    "azure-mgmt-sql" = python.mkDerivation {
      name = "azure-mgmt-sql-0.8.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e6/9f/4745f23eb5f91f236d7fbca748ffb4db86d4ac44d059ecdecdac3040f438/azure-mgmt-sql-0.8.6.zip"; sha256 = "6cdfe3d5c2d9660f85f9d19a20d9d79e2efd04d3369d2bf58aa99c34db6aefb2"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure SQL Management Client Library for Python";
      };
    };

    "azure-mgmt-storage" = python.mkDerivation {
      name = "azure-mgmt-storage-1.5.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/bb/8c/e276e122ba7881446c500e20ae8832a7eb67c71fc01d2508a15100080601/azure-mgmt-storage-1.5.0.zip"; sha256 = "b1fc3a293051dee35dffe12d618f925581d6536c94ca5c05b69461ce941125a1"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Storage Management Client Library for Python";
      };
    };

    "azure-mgmt-subscription" = python.mkDerivation {
      name = "azure-mgmt-subscription-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/50/cb/981c7866d88eb2372d09f603b0e95a83b07e72370afe0b220c4a6aa469cc/azure-mgmt-subscription-0.1.0.zip"; sha256 = "f9cf41a7db8b55e4ec279027cad54635a0f78f9a6527fc8bcca4aef69ceb4e15"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Subscription Management Client Library for Python";
      };
    };

    "azure-mgmt-trafficmanager" = python.mkDerivation {
      name = "azure-mgmt-trafficmanager-0.40.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/68/4f/c8b62406174c8355b2c1fb62720152c0bb8046dd62bb1029fcf8c8d049d2/azure-mgmt-trafficmanager-0.40.0.zip"; sha256 = "32cd1f5fd8d902cba5dd68f5876eadf5f98f5bef8b33319b20e6b547e7c21d68"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Traffic Manager Client Library for Python";
      };
    };

    "azure-mgmt-web" = python.mkDerivation {
      name = "azure-mgmt-web-0.34.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c9/27/74a4d384efd03fb9aa8f0f971806695286961b45d154a0287eed2f142bcf/azure-mgmt-web-0.34.1.zip"; sha256 = "6d44f248f36dafb3a8f5175060d1959fdfa267dbd4e808b0270b8bbfd2c695c1"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-mgmt-nspkg"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Web Apps Management Client Library for Python";
      };
    };

    "azure-nspkg" = python.mkDerivation {
      name = "azure-nspkg-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/06/a2/77820fa07ec4657d6456b67edfa78856b4789ada42d1bb8e8485df19824e/azure-nspkg-2.0.0.zip"; sha256 = "fe19ee5d8c66ee8ef62557fc7310f59cffb7230f0a94701eef79f6e3191fdc7b"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Namespace Package [Internal]";
      };
    };

    "azure-servicebus" = python.mkDerivation {
      name = "azure-servicebus-0.21.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/82/29/cb0cfd5cc8b7b92b1a67c2fbab55e72792080255498cab7a2bbfe50ce90a/azure-servicebus-0.21.1.zip"; sha256 = "bb6a27afc8f1ea9ab46ff2371069243d45000d351d9b64e450b63d52409b934d"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-nspkg"
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.asl20;
        description = "Microsoft Azure Service Bus Client Library for Python";
      };
    };

    "azure-servicefabric" = python.mkDerivation {
      name = "azure-servicefabric-6.1.2.9";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f5/f7/29735073c98291e527a065343ce6b2004393b04a468a99f94123e26ccf96/azure-servicefabric-6.1.2.9.zip"; sha256 = "22b034c9245cea556e892a9d7a998a9bab3d6d65c3673e0603f7bd9459a3c8c8"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-nspkg"
      self."msrest"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Service Fabric Client Library for Python";
      };
    };

    "azure-servicemanagement-legacy" = python.mkDerivation {
      name = "azure-servicemanagement-legacy-0.20.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/7e/9e/ad8c5e8b2715736df200c0d1baf63d38044d9113145d86c4d53923a81919/azure-servicemanagement-legacy-0.20.6.zip"; sha256 = "c883ff8fa3d4f4cb7b9344e8cb7d92a9feca2aa5efd596237aeea89e5c10981d"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-nspkg"
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.asl20;
        description = "Microsoft Azure Legacy Service Management Client Library for Python";
      };
    };

    "azure-storage-blob" = python.mkDerivation {
      name = "azure-storage-blob-1.3.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/41/0d/a9d63c97b59c9853a9a491809c3c2d06e766bbfb72366549939ee9b7e554/azure-storage-blob-1.3.1.tar.gz"; sha256 = "8cab5420ba6646ead09fdb497646f735b12645cba8efed96a86f7b370e175ade"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-storage-common"
      self."azure-storage-nspkg"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-storage-python";
        license = licenses.mit;
        description = "Microsoft Azure Storage Blob Client Library for Python";
      };
    };

    "azure-storage-common" = python.mkDerivation {
      name = "azure-storage-common-1.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/42/7e/fa7e93011cf319ea5c47ae75024b649b84f011bb06c3cdff5c605ba85730/azure-storage-common-1.3.0.tar.gz"; sha256 = "585658ebc784e843a285732a69aa69ef922e17c3063460c2c7b27c89f377004c"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-storage-nspkg"
      self."cryptography"
      self."python-dateutil"
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-storage-python";
        license = licenses.mit;
        description = "Microsoft Azure Storage Common Client Library for Python";
      };
    };

    "azure-storage-file" = python.mkDerivation {
      name = "azure-storage-file-1.3.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/08/ee/3e04c3233f3da99eb2268b657fe96c4d3ec281964fc153a5e15162d18b58/azure-storage-file-1.3.1.tar.gz"; sha256 = "3f16962d06a4bb3321b6545d4168050abd2b549f607d1fcb2633d268e8323576"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-storage-common"
      self."azure-storage-nspkg"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-storage-python";
        license = licenses.mit;
        description = "Microsoft Azure Storage File Client Library for Python";
      };
    };

    "azure-storage-nspkg" = python.mkDerivation {
      name = "azure-storage-nspkg-3.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/bc/2c/5e3a8c535779ef6e7b2d556676e49768c17dd29066f41587080f23aea485/azure-storage-nspkg-3.0.0.tar.gz"; sha256 = "855315c038c0e695868025127e1b3057a1f984af9ccfbaeac4fbfd6c5dd3b466"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-nspkg"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-storage-python";
        license = licenses.mit;
        description = "Microsoft Azure Storage Namespace Package [Internal]";
      };
    };

    "azure-storage-queue" = python.mkDerivation {
      name = "azure-storage-queue-1.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/2a/16/7b1c6a3250e0eec6c88257a0fc6a376352b108cb1494c628b19802da7dad/azure-storage-queue-1.3.0.tar.gz"; sha256 = "3a170b87e5ddfc3de61ede9597e52a5bbcd0e70cce4818e1cbd84b62d7b89d9e"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."azure-storage-common"
      self."azure-storage-nspkg"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-storage-python";
        license = licenses.mit;
        description = "Microsoft Azure Storage Queue Client Library for Python";
      };
    };

    "boto" = python.mkDerivation {
      name = "boto-2.49.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c8/af/54a920ff4255664f5d238b5aebd8eedf7a07c7a5e71e27afcfe840b82f51/boto-2.49.0.tar.gz"; sha256 = "ea0d3b40a2d852767be77ca343b58a9e3a4b00d9db440efb8da74b4e58025e5a"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/boto/boto/";
        license = licenses.mit;
        description = "Amazon Web Services Library";
      };
    };

    "cachetools" = python.mkDerivation {
      name = "cachetools-2.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/87/41/b3e00059f3c34b57a653d2120d213715abb4327b36fee22e59c1da977d25/cachetools-2.1.0.tar.gz"; sha256 = "90f1d559512fc073483fe573ef5ceb39bf6ad3d39edc98dc55178a2b2b176fa3"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/tkem/cachetools";
        license = licenses.mit;
        description = "Extensible memoizing collections and decorators";
      };
    };

    "certifi" = python.mkDerivation {
      name = "certifi-2018.8.24";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e1/0f/f8d5e939184547b3bdc6128551b831a62832713aa98c2ccdf8c47ecc7f17/certifi-2018.8.24.tar.gz"; sha256 = "376690d6f16d32f9d1fe8932551d80b23e9d393a8578c5633a2ed39a64861638"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://certifi.io/";
        license = licenses.mpl20;
        description = "Python package for providing Mozilla's CA Bundle.";
      };
    };

    "cffi" = python.mkDerivation {
      name = "cffi-1.11.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e7/a7/4cd50e57cc6f436f1cc3a7e8fa700ff9b8b4d471620629074913e3735fb2/cffi-1.11.5.tar.gz"; sha256 = "e90f17980e6ab0f3c2f3730e56d1fe9bcba1891eeea58966e89d352492cc74f4"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pycparser"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://cffi.readthedocs.org";
        license = licenses.mit;
        description = "Foreign Function Interface for Python calling C code.";
      };
    };

    "chardet" = python.mkDerivation {
      name = "chardet-3.0.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz"; sha256 = "84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/chardet/chardet";
        license = licenses.lgpl2;
        description = "Universal encoding detector for Python 2 and 3";
      };
    };

    "cryptography" = python.mkDerivation {
      name = "cryptography-2.3.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/22/21/233e38f74188db94e8451ef6385754a98f3cad9b59bedf3a8e8b14988be4/cryptography-2.3.1.tar.gz"; sha256 = "8d10113ca826a4c29d5b85b2c4e045ffa8bad74fb525ee0eceb1d38d4c70dfd6"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."asn1crypto"
      self."cffi"
      self."idna"
      self."iso8601"
      self."pytz"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyca/cryptography";
        license = licenses.bsdOriginal;
        description = "cryptography is a package which provides cryptographic recipes and primitives to Python developers.";
      };
    };

    "debtcollector" = python.mkDerivation {
      name = "debtcollector-1.20.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/56/ea/e8867c97ae9650ecf67edf66ed844c89b3b0a7a54c9ea00b23d889195ec6/debtcollector-1.20.0.tar.gz"; sha256 = "f48639881e0dd492e3576fd714e2a4e422492bb586b9f90affe0f093d7a09ac8"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pbr"
      self."six"
      self."wrapt"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/debtcollector/latest";
        license = "License :: OSI Approved :: Apache Software License";
        description = "A collection of Python deprecation patterns and strategies that help you collect your technical debt in a non-destructive manner.";
      };
    };

    "entrypoints" = python.mkDerivation {
      name = "entrypoints-0.2.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/27/e8/607697e6ab8a961fc0b141a97ea4ce72cd9c9e264adeb0669f6d194aa626/entrypoints-0.2.3.tar.gz"; sha256 = "d2d587dde06f99545fb13a383d2cd336a8ff1f359c5839ce3a64c917d10c029f"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/takluyver/entrypoints";
        license = "";
        description = "Discover and load entry points from installed packages.";
      };
    };

    "gevent" = python.mkDerivation {
      name = "gevent-1.2.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/1b/92/b111f76e54d2be11375b47b213b56687214f258fd9dae703546d30b837be/gevent-1.2.2.tar.gz"; sha256 = "4791c8ae9c57d6f153354736e1ccab1e2baf6c8d9ae5a77a9ac90f41e2966b2d"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."greenlet"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.gevent.org/";
        license = licenses.mit;
        description = "Coroutine-based network library";
      };
    };

    "google-api-core" = python.mkDerivation {
      name = "google-api-core-1.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/85/e5/edfb19739e4aa98306b14a08ec5ab22f656631ad2d0c148367c69a3a8f82/google-api-core-1.3.0.tar.gz"; sha256 = "ac85fc7f6687bb0271f2f70ca298da90f35789f9de1fe3a11e8caeb571332b77"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."google-auth"
      self."googleapis-common-protos"
      self."protobuf"
      self."pytz"
      self."requests"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/GoogleCloudPlatform/google-cloud-python";
        license = licenses.asl20;
        description = "Google API client core library";
      };
    };

    "google-auth" = python.mkDerivation {
      name = "google-auth-1.5.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/7e/cd/dae5c39974b040741215ed346263152c93af21a22dc124c7ad451fbee417/google-auth-1.5.1.tar.gz"; sha256 = "9ca363facbf2622d9ba828017536ccca2e0f58bd15e659b52f312172f8815530"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."cachetools"
      self."pyasn1-modules"
      self."rsa"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/GoogleCloudPlatform/google-auth-library-python";
        license = licenses.asl20;
        description = "Google Authentication Library";
      };
    };

    "google-cloud-core" = python.mkDerivation {
      name = "google-cloud-core-0.28.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/22/f0/a062f4d877420e765f451af99045326e44f9b026088d621ca40011f14c66/google-cloud-core-0.28.1.tar.gz"; sha256 = "89e8140a288acec20c5e56159461d3afa4073570c9758c05d4e6cb7f2f8cc440"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."google-api-core"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/GoogleCloudPlatform/google-cloud-python";
        license = licenses.asl20;
        description = "Google Cloud API client core library";
      };
    };

    "google-cloud-storage" = python.mkDerivation {
      name = "google-cloud-storage-1.10.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/62/73/1ea71c8b319064bc6ae0530cb0f78fe15987c7881f132938e3fa83ddff46/google-cloud-storage-1.10.0.tar.gz"; sha256 = "c1969558df8d7994cf4f89f60c01c619d77fc19facb38f66640d1f749a663e2e"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."google-api-core"
      self."google-cloud-core"
      self."google-resumable-media"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/GoogleCloudPlatform/google-cloud-python";
        license = licenses.asl20;
        description = "Google Cloud Storage API client library";
      };
    };

    "google-resumable-media" = python.mkDerivation {
      name = "google-resumable-media-0.3.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c8/7e/ebfb88a31fa8d90080d5ae87c8eacf004980f3cb258abbaead8796294db3/google-resumable-media-0.3.1.tar.gz"; sha256 = "97de518f8166d442cc0b61fab308bcd319dbb970981e667ec8ded44f5ce49836"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."requests"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/GoogleCloudPlatform/google-resumable-media-python";
        license = licenses.asl20;
        description = "Utilities for Google Media Downloads and Resumable Uploads";
      };
    };

    "googleapis-common-protos" = python.mkDerivation {
      name = "googleapis-common-protos-1.5.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/00/03/d25bed04ec8d930bcfa488ba81a2ecbf7eb36ae3ffd7e8f5be0d036a89c9/googleapis-common-protos-1.5.3.tar.gz"; sha256 = "c075eddaa2628ab519e01b7d75b76e66c40eaa50fc52758d8225f84708950ef2"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."protobuf"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/googleapis/googleapis";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Common protobufs used in Google APIs";
      };
    };

    "greenlet" = python.mkDerivation {
      name = "greenlet-0.4.14";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/5d/82/2e53a8def6f99db51992ca3a0a2448c3bbec1a9db3a7cbf7d5dad011e138/greenlet-0.4.14.tar.gz"; sha256 = "f1cc268a15ade58d9a0c04569fe6613e19b8b0345b64453064e2c3c6d79051af"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/python-greenlet/greenlet";
        license = licenses.mit;
        description = "Lightweight in-process concurrent programming";
      };
    };

    "idna" = python.mkDerivation {
      name = "idna-2.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/65/c4/80f97e9c9628f3cac9b98bfca0402ede54e0563b56482e3e6e45c43c4935/idna-2.7.tar.gz"; sha256 = "684a38a6f903c1d71d6d5fac066b58d7768af4de2b832e426ec79c30daa94a16"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/kjd/idna";
        license = licenses.bsdOriginal;
        description = "Internationalized Domain Names in Applications (IDNA)";
      };
    };

    "iso8601" = python.mkDerivation {
      name = "iso8601-0.1.12";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/45/13/3db24895497345fb44c4248c08b16da34a9eb02643cea2754b21b5ed08b0/iso8601-0.1.12.tar.gz"; sha256 = "49c4b20e1f38aa5cf109ddcd39647ac419f928512c869dc01d5c7098eddede82"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://bitbucket.org/micktwomey/pyiso8601";
        license = licenses.mit;
        description = "Simple module to parse ISO 8601 dates";
      };
    };

    "isodate" = python.mkDerivation {
      name = "isodate-0.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b1/80/fb8c13a4cd38eb5021dc3741a9e588e4d1de88d895c1910c6fc8a08b7a70/isodate-0.6.0.tar.gz"; sha256 = "2e364a3d5759479cdb2d37cce6b9376ea504db2ff90252a2e5b7cc89cc9ff2d8"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/gweis/isodate/";
        license = licenses.bsdOriginal;
        description = "An ISO 8601 date/time/duration parser and formatter";
      };
    };

    "jeepney" = python.mkDerivation {
      name = "jeepney-0.3.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/18/17/7dbc70bc13dc9c8ba8c9b25fbc8b75dffb6bc7e56c3d7cecd87e6b563e5f/jeepney-0.3.1.tar.gz"; sha256 = "a6f2aa72e61660248d4d524dfccb6405f17c693b69af5d60dd7f2bab807d907e"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://gitlab.com/takluyver/jeepney";
        license = "";
        description = "Low-level, pure Python DBus protocol wrapper.";
      };
    };

    "keyring" = python.mkDerivation {
      name = "keyring-13.2.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a0/c9/c08bf10bd057293ff385abaef38e7e548549bbe81e95333157684e75ebc6/keyring-13.2.1.tar.gz"; sha256 = "6364bb8c233f28538df4928576f4e051229e0451651073ab20b315488da16a58"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."SecretStorage"
      self."entrypoints"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/jaraco/keyring";
        license = licenses.psfl;
        description = "Store and access your passwords safely.";
      };
    };

    "keystoneauth1" = python.mkDerivation {
      name = "keystoneauth1-3.10.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b6/90/0249c5cbe72f486fdb8c8387d5807ea97519237edb1b0f58a7b57a41fb3d/keystoneauth1-3.10.0.tar.gz"; sha256 = "a47e6d2f676ab226dfd5343edb8c76f7c1fc314fc163d305e79bf18afae445d9"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyYAML"
      self."iso8601"
      self."oauthlib"
      self."os-service-types"
      self."oslo.config"
      self."oslo.utils"
      self."pbr"
      self."requests"
      self."six"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/keystoneauth/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Authentication Library for OpenStack Identity";
      };
    };

    "monotonic" = python.mkDerivation {
      name = "monotonic-1.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/19/c1/27f722aaaaf98786a1b338b78cf60960d9fe4849825b071f4e300da29589/monotonic-1.5.tar.gz"; sha256 = "23953d55076df038541e648a53676fb24980f7a1be290cdda21300b3bc21dfb0"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/atdt/monotonic";
        license = "License :: OSI Approved :: Apache Software License";
        description = "An implementation of time.monotonic() for Python 2 & < 3.3";
      };
    };

    "msgpack" = python.mkDerivation {
      name = "msgpack-0.5.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f3/b6/9affbea179c3c03a0eb53515d9ce404809a122f76bee8fc8c6ec9497f51f/msgpack-0.5.6.tar.gz"; sha256 = "0ee8c8c85aa651be3aa0cd005b5931769eaa658c948ce79428766f1bd46ae2c3"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://msgpack.org/";
        license = licenses.asl20;
        description = "MessagePack (de)serializer.";
      };
    };

    "msrest" = python.mkDerivation {
      name = "msrest-0.5.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d9/48/e636320da2f5ebf2a0786af61f9656ede1448f57b5b8d1a232e313fc5081/msrest-0.5.4.tar.gz"; sha256 = "d609c2997ab66aa8985a6ced972e895cd7aa0a415d715af042a554c5c791934a"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."certifi"
      self."isodate"
      self."requests"
      self."requests-oauthlib"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/msrest-for-python";
        license = licenses.mit;
        description = "AutoRest swagger generator Python client runtime.";
      };
    };

    "msrestazure" = python.mkDerivation {
      name = "msrestazure-0.4.34";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/cd/ce/1381822930cb2e90e889e43831428982577acb9caec5244bcce1c9c542f9/msrestazure-0.4.34.tar.gz"; sha256 = "4fc94a03ecd5b094ab904d929cc5be7a6a80262eab93948260cfe9081a9e6de4"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."adal"
      self."keyring"
      self."msrest"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/msrestazure-for-python";
        license = licenses.mit;
        description = "AutoRest swagger generator Python client runtime. Azure-specific module.";
      };
    };

    "netaddr" = python.mkDerivation {
      name = "netaddr-0.7.19";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0c/13/7cbb180b52201c07c796243eeff4c256b053656da5cfe3916c3f5b57b3a0/netaddr-0.7.19.tar.gz"; sha256 = "38aeec7cdd035081d3a4c306394b19d677623bf76fa0913f6695127c7753aefd"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/drkjam/netaddr/";
        license = licenses.bsdOriginal;
        description = "A network address manipulation library for Python";
      };
    };

    "netifaces" = python.mkDerivation {
      name = "netifaces-0.10.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/81/39/4e9a026265ba944ddf1fea176dbb29e0fe50c43717ba4fcf3646d099fe38/netifaces-0.10.7.tar.gz"; sha256 = "bd590fcb75421537d4149825e1e63cca225fd47dad861710c46bd1cb329d8cbd"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/al45tair/netifaces";
        license = licenses.mit;
        description = "Portable network interface information.";
      };
    };

    "oauthlib" = python.mkDerivation {
      name = "oauthlib-2.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/df/5f/3f4aae7b28db87ddef18afed3b71921e531ca288dc604eb981e9ec9f8853/oauthlib-2.1.0.tar.gz"; sha256 = "ac35665a61c1685c56336bda97d5eefa246f1202618a1d6f34fccb1bdd404162"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyJWT"
      self."cryptography"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/oauthlib/oauthlib";
        license = licenses.bsdOriginal;
        description = "A generic, spec-compliant, thorough implementation of the OAuth request-signing logic";
      };
    };

    "os-service-types" = python.mkDerivation {
      name = "os-service-types-1.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a2/bc/c8bc9cce8ec064558ae9b8ab2dbea9d5bdfbaf5c50f637a19cb120410b10/os-service-types-1.3.0.tar.gz"; sha256 = "5790117948d1673319a2dcf4c545c2059a1a933705e8ded586add88200ac9d95"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pbr"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.openstack.org/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Python library for consuming OpenStack sevice-types-authority data";
      };
    };

    "oslo.config" = python.mkDerivation {
      name = "oslo.config-6.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/64/79/a65267c8a6f734dccd52a46688339e00764703a00aa99da679e837c9c734/oslo.config-6.4.0.tar.gz"; sha256 = "483f43fa7b0e54cb1000d56b4e56fb23169816e65061e7600ca8ccd4cafa45e3"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyYAML"
      self."debtcollector"
      self."netaddr"
      self."oslo.i18n"
      self."requests"
      self."rfc3986"
      self."six"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/oslo.config/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Configuration API";
      };
    };

    "oslo.i18n" = python.mkDerivation {
      name = "oslo.i18n-3.21.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/80/e8/4b2dee4783e058837785466dadac0746af26468dee614c65b71e81c556a9/oslo.i18n-3.21.0.tar.gz"; sha256 = "037e3474db4c2bbc28c5ecfd92cc6539e4fa34283bd15978c8c08706eaae556a"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."pbr"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/oslo.i18n/latest";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo i18n library";
      };
    };

    "oslo.serialization" = python.mkDerivation {
      name = "oslo.serialization-2.27.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/21/b0/15a593a9fe8963cf3798f5b892389036936f0972ddc60d2b089b90c56517/oslo.serialization-2.27.0.tar.gz"; sha256 = "ec3f8ef108199204dcbded425e940625c3d4d8663cb69724c58d3c29031ab8e3"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."msgpack"
      self."oslo.utils"
      self."pbr"
      self."pytz"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://docs.openstack.org/developer/oslo.serialization/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Serialization library";
      };
    };

    "oslo.utils" = python.mkDerivation {
      name = "oslo.utils-3.36.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/5b/28/f249ceed4f7e12a5ccafcac008fb2f7bd96c52d77079407465476bd98c93/oslo.utils-3.36.4.tar.gz"; sha256 = "c9f5afb4055f60c5dc36341ed5ff09e536ca5e584d7278234c319c7cd38b55d9"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."debtcollector"
      self."iso8601"
      self."monotonic"
      self."netaddr"
      self."netifaces"
      self."oslo.i18n"
      self."pbr"
      self."pyparsing"
      self."pytz"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/oslo.utils/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Utility library";
      };
    };

    "pbr" = python.mkDerivation {
      name = "pbr-4.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c8/c3/935b102539529ea9e6dcf3e8b899583095a018b09f29855ab754a2012513/pbr-4.2.0.tar.gz"; sha256 = "1b8be50d938c9bb75d0eaf7eda111eec1bf6dc88a62a6412e33bf077457e0f45"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/pbr/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Python Build Reasonableness";
      };
    };

    "protobuf" = python.mkDerivation {
      name = "protobuf-3.6.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/1b/90/f531329e628ff34aee79b0b9523196eb7b5b6b398f112bb0c03b24ab1973/protobuf-3.6.1.tar.gz"; sha256 = "1489b376b0f364bcc6f89519718c057eb191d7ad6f1b395ffd93d1aa45587811"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://developers.google.com/protocol-buffers/";
        license = "3-Clause BSD License";
        description = "Protocol Buffers";
      };
    };

    "pyasn1" = python.mkDerivation {
      name = "pyasn1-0.4.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/10/46/059775dc8e50f722d205452bced4b3cc965d27e8c3389156acd3b1123ae3/pyasn1-0.4.4.tar.gz"; sha256 = "f58f2a3d12fd754aa123e9fa74fb7345333000a035f3921dbdaa08597aa53137"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/etingof/pyasn1";
        license = licenses.bsdOriginal;
        description = "ASN.1 types and codecs";
      };
    };

    "pyasn1-modules" = python.mkDerivation {
      name = "pyasn1-modules-0.2.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/37/33/74ebdc52be534e683dc91faf263931bc00ae05c6073909fde53999088541/pyasn1-modules-0.2.2.tar.gz"; sha256 = "a0cf3e1842e7c60fde97cb22d275eb6f9524f5c5250489e292529de841417547"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pyasn1"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/etingof/pyasn1-modules";
        license = licenses.bsdOriginal;
        description = "A collection of ASN.1-based protocols modules.";
      };
    };

    "pycparser" = python.mkDerivation {
      name = "pycparser-2.18";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8c/2d/aad7f16146f4197a11f8e91fb81df177adcc2073d36a17b1491fd09df6ed/pycparser-2.18.tar.gz"; sha256 = "99a8ca03e29851d96616ad0404b4aad7d9ee16f25c9f9708a11faf2810f7b226"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/eliben/pycparser";
        license = licenses.bsdOriginal;
        description = "C parser in Python";
      };
    };

    "pyparsing" = python.mkDerivation {
      name = "pyparsing-2.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/3c/ec/a94f8cf7274ea60b5413df054f82a8980523efd712ec55a59e7c3357cf7c/pyparsing-2.2.0.tar.gz"; sha256 = "0832bcf47acd283788593e7a0f542407bd9550a55a8a8435214a1960e04bcb04"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pyparsing.wikispaces.com/";
        license = licenses.mit;
        description = "Python parsing module";
      };
    };

    "python-dateutil" = python.mkDerivation {
      name = "python-dateutil-2.7.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ee/f5/d81ec46577350dcd96a26885d418969cd2b07c7d8c78e24e25c10bfc5c6f/python-dateutil-2.7.1.tar.gz"; sha256 = "14eb44faa298942c6385636bfd76bd5c21361632cf8ebc9c20d63fd00f6a069f"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://dateutil.readthedocs.io";
        license = licenses.bsdOriginal;
        description = "Extensions to the standard Python datetime module";
      };
    };

    "python-keystoneclient" = python.mkDerivation {
      name = "python-keystoneclient-3.17.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f0/b4/f918f4873f1a3d4f7a00e874cddcc1bb67dc5ec1ce58166d96d42738d8fe/python-keystoneclient-3.17.0.tar.gz"; sha256 = "7fb770e194760fa3508e758e6ad316fc55d5b4ff97aa688867ef50f62f687624"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."debtcollector"
      self."keystoneauth1"
      self."oslo.config"
      self."oslo.i18n"
      self."oslo.serialization"
      self."oslo.utils"
      self."pbr"
      self."requests"
      self."six"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/python-keystoneclient/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Client Library for OpenStack Identity";
      };
    };

    "python-swiftclient" = python.mkDerivation {
      name = "python-swiftclient-3.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e0/29/fcb14f9008d26eb2dc073e51fe7dde23828d089afc2f78b13334a692f1d8/python-swiftclient-3.6.0.tar.gz"; sha256 = "1b0308d1675ebc58b04fc6c139fe4dd66755051d5336f0ac6cfcf3f6c5f9666b"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."keystoneauth1"
      self."python-keystoneclient"
      self."requests"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/python-swiftclient/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "OpenStack Object Storage API Client Library";
      };
    };

    "pytz" = python.mkDerivation {
      name = "pytz-2018.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ca/a9/62f96decb1e309d6300ebe7eee9acfd7bccaeedd693794437005b9067b44/pytz-2018.5.tar.gz"; sha256 = "ffb9ef1de172603304d9d2819af6f5ece76f2e85ec10692a524dd876e72bf277"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pythonhosted.org/pytz";
        license = licenses.mit;
        description = "World timezone definitions, modern and historical";
      };
    };

    "requests" = python.mkDerivation {
      name = "requests-2.19.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/54/1f/782a5734931ddf2e1494e4cd615a51ff98e1879cbe9eecbdfeaf09aa75e9/requests-2.19.1.tar.gz"; sha256 = "ec22d826a36ed72a7358ff3fe56cbd4ba69dd7a6718ffd450ff0e9df7a47ce6a"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."certifi"
      self."chardet"
      self."cryptography"
      self."idna"
      self."urllib3"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://python-requests.org";
        license = licenses.asl20;
        description = "Python HTTP for Humans.";
      };
    };

    "requests-oauthlib" = python.mkDerivation {
      name = "requests-oauthlib-1.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/95/be/072464f05b70e4142cb37151e215a2037b08b1400f8a56f2538b76ca6205/requests-oauthlib-1.0.0.tar.gz"; sha256 = "8886bfec5ad7afb391ed5443b1f697c6f4ae98d0e5620839d8b4499c032ada3f"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."oauthlib"
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/requests/requests-oauthlib";
        license = licenses.bsdOriginal;
        description = "OAuthlib authentication support for Requests.";
      };
    };

    "rfc3986" = python.mkDerivation {
      name = "rfc3986-1.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4b/f6/8f0a24e50454494b0736fe02e6617e7436f2b30148b8f062462177e2ca2d/rfc3986-1.1.0.tar.gz"; sha256 = "8458571c4c57e1cf23593ad860bb601b6a604df6217f829c2bc70dc4b5af941b"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://rfc3986.readthedocs.io";
        license = licenses.asl20;
        description = "Validating URI References per RFC 3986";
      };
    };

    "rsa" = python.mkDerivation {
      name = "rsa-3.4.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/14/89/adf8b72371e37f3ca69c6cb8ab6319d009c4a24b04a31399e5bd77d9bb57/rsa-3.4.2.tar.gz"; sha256 = "25df4e10c263fb88b5ace923dd84bf9aa7f5019687b5e55382ffcdb8bede9db5"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pyasn1"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://stuvel.eu/rsa";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Pure-Python RSA implementation";
      };
    };

    "six" = python.mkDerivation {
      name = "six-1.11.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/16/d8/bc6316cf98419719bd59c91742194c111b6f2e85abac88e496adefaf7afe/six-1.11.0.tar.gz"; sha256 = "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pypi.python.org/pypi/six/";
        license = licenses.mit;
        description = "Python 2 and 3 compatibility utilities";
      };
    };

    "stevedore" = python.mkDerivation {
      name = "stevedore-1.29.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/61/c9/1d10fc4ffd9657caea9e3f0428cad6e0eefed9dfea11435f97ab34c1927f/stevedore-1.29.0.tar.gz"; sha256 = "1e153545aca7a6a49d8337acca4f41c212fbfa60bf864ecd056df0cafb9627e8"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pbr"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/stevedore/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Manage dynamic plugins for Python applications";
      };
    };

    "urllib3" = python.mkDerivation {
      name = "urllib3-1.23";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/3c/d2/dc5471622bd200db1cd9319e02e71bc655e9ea27b8e0ce65fc69de0dac15/urllib3-1.23.tar.gz"; sha256 = "a68ac5e15e76e7e5dd2b8f94007233e01effe3e50e8daddf69acfd81cb686baf"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."certifi"
      self."cryptography"
      self."idna"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://urllib3.readthedocs.io/";
        license = licenses.mit;
        description = "HTTP library with thread-safe connection pooling, file post, and more.";
      };
    };

    "wrapt" = python.mkDerivation {
      name = "wrapt-1.10.11";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a0/47/66897906448185fcb77fc3c2b1bc20ed0ecca81a0f2f88eda3fc5a34fc3d/wrapt-1.10.11.tar.gz"; sha256 = "d4d560d479f2c21e1b5443bbd15fe7ec4b37fe7e53d335d3b9b0a7b1226fe3c6"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/GrahamDumpleton/wrapt";
        license = licenses.bsdOriginal;
        description = "Module for decorators, wrappers and monkey patching.";
      };
    };
  };
  localOverridesFile = ./requirements_override.nix;
  localOverrides = import localOverridesFile { inherit pkgs python; };
  commonOverrides = [
        (let src = pkgs.fetchFromGitHub { owner = "garbas"; repo = "nixpkgs-python"; rev = "5ced58ca0f00a0d0947b4d5329e99b15e70ee898"; sha256 = "0psbv3s2sgix1vlf8l86dpwiyz3qi4a3prss1b6j440ipc7c7d8z"; } ; in import "${src}/overrides.nix" { inherit pkgs python; })
  ];
  paramOverrides = [
    (overrides { inherit pkgs python; })
  ];
  allOverrides =
    (if (builtins.pathExists localOverridesFile)
     then [localOverrides] else [] ) ++ commonOverrides ++ paramOverrides;

in python.withPackages
   (fix' (pkgs.lib.fold
            extends
            generated
            allOverrides
         )
   )