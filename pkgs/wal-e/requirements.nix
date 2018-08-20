# generated using pypi2nix tool (version: 1.8.1)
# See more at: https://github.com/garbas/pypi2nix
#
# COMMAND:
#   pypi2nix -v -V 3.6 --default-overrides --basename wal-e -E libffi openssl -r requirements.txt
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

  commonBuildInputs = with pkgs; [ libffi openssl ];
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
      name = "azure-4.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8e/7e/c744cd290906a1069f4d7481cf6cf30a9e42fa21b6b3f36f28d2acaeff1a/azure-4.0.0.zip"; sha256 = "7d6afa332fccffe1a9390bcfac5122317eec657c6029f144d794603a81cd0e50"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-applicationinsights"
      self."azure-batch"
      self."azure-cosmosdb-table"
      self."azure-datalake-store"
      self."azure-eventgrid"
      self."azure-graphrbac"
      self."azure-keyvault"
      self."azure-loganalytics"
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

    "azure-applicationinsights" = python.mkDerivation {
      name = "azure-applicationinsights-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a5/05/17986d75568a51e16e993f50331366035d33b02aea9e4cd4828ba9ea2ddb/azure-applicationinsights-0.1.0.zip"; sha256 = "6e1839169bb6ffd2d2c21ee3f4afbdd068ea428ad47cf884ea3167ecf7fd0859"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrest"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Application Insights Client Library for Python";
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
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Client Library for Python (Common)";
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
      name = "azure-datalake-store-0.0.27";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/82/22/e546bad3b8467e0ca386d5497a3001bfdf049d11c75ceb24f6cddfff543b/azure-datalake-store-0.0.27.tar.gz"; sha256 = "c13f73b02264a71ab450331a5c3d49cc70d3e8ada67443bfc148262e907fd5b8"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."adal"
      self."cffi"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-data-lake-store-python";
        license = licenses.mit;
        description = "Azure Data Lake Store Filesystem Client Library for Python";
      };
    };

    "azure-eventgrid" = python.mkDerivation {
      name = "azure-eventgrid-1.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/28/c2/9d7319490b61e32abeb4749f14547c606139fb24de6c5e738322ff115a3c/azure-eventgrid-1.1.0.zip"; sha256 = "fca3d830bf887fcc61fa71cb541531c9e155a4437d861149cbfb842d36fb272f"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
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
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Graph RBAC Client Library for Python";
      };
    };

    "azure-keyvault" = python.mkDerivation {
      name = "azure-keyvault-1.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8e/47/b71d7ab466189d0663a8aa216e4cc67eb16d5dfc7d69b62a9140dd8d1a20/azure-keyvault-1.1.0.zip"; sha256 = "37a8e5f376eb5a304fcd066d414b5d93b987e68f9212b0c41efa37d429aadd49"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."cryptography"
      self."msrest"
      self."msrestazure"
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Key Vault Client Library for Python";
      };
    };

    "azure-loganalytics" = python.mkDerivation {
      name = "azure-loganalytics-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/7a/37/6d296ee71319f49a93ea87698da2c5326105d005267d58fb00cb9ec0c3f8/azure-loganalytics-0.1.0.zip"; sha256 = "3ceb350def677a351f34b0a0d1637df6be0c6fe87ff32a5270b17f540f6da06e"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrest"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Log Analytics Client Library for Python";
      };
    };

    "azure-mgmt" = python.mkDerivation {
      name = "azure-mgmt-4.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b3/2d/800b26d5a1b3650c8a96161793be08687e75976ec8df91027afd2f31ab55/azure-mgmt-4.0.0.zip"; sha256 = "8dcbee7b323c3898ae92f5e2d88c3e6201f197ae48a712970929c4646cc2580a"; };
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
      self."azure-mgmt-datamigration"
      self."azure-mgmt-devspaces"
      self."azure-mgmt-devtestlabs"
      self."azure-mgmt-dns"
      self."azure-mgmt-eventgrid"
      self."azure-mgmt-eventhub"
      self."azure-mgmt-hanaonazure"
      self."azure-mgmt-iotcentral"
      self."azure-mgmt-iothub"
      self."azure-mgmt-iothubprovisioningservices"
      self."azure-mgmt-keyvault"
      self."azure-mgmt-loganalytics"
      self."azure-mgmt-logic"
      self."azure-mgmt-machinelearningcompute"
      self."azure-mgmt-managementgroups"
      self."azure-mgmt-managementpartner"
      self."azure-mgmt-maps"
      self."azure-mgmt-marketplaceordering"
      self."azure-mgmt-media"
      self."azure-mgmt-monitor"
      self."azure-mgmt-msi"
      self."azure-mgmt-network"
      self."azure-mgmt-notificationhubs"
      self."azure-mgmt-policyinsights"
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
      self."azure-mgmt-servicebus"
      self."azure-mgmt-servicefabric"
      self."azure-mgmt-signalr"
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
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Application Insights Management Client Library for Python";
      };
    };

    "azure-mgmt-authorization" = python.mkDerivation {
      name = "azure-mgmt-authorization-0.50.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/3e/8f/ccb1117884ffd81862ed03359c90aace89e9d2faa8bb50e35e7fb85154c3/azure-mgmt-authorization-0.50.0.zip"; sha256 = "535de12ff4f628b62b939ae17cc6186226d7783bf02f242cdd3512ee03a6a40e"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
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
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Batch Management Client Library for Python";
      };
    };

    "azure-mgmt-batchai" = python.mkDerivation {
      name = "azure-mgmt-batchai-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fa/7f/0a9e5aa22ea91db0771c267c4815396516177702a4a4eea389eed7af47dd/azure-mgmt-batchai-2.0.0.zip"; sha256 = "f1870b0f97d5001cdb66208e5a236c9717a0ed18b34dbfdb238a828f3ca2a683"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Batch AI Management Client Library for Python";
      };
    };

    "azure-mgmt-billing" = python.mkDerivation {
      name = "azure-mgmt-billing-0.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/24/35/3b9da47363a300203c324b572a1ae3c096dc031905d582d5a27bd59a8d4e/azure-mgmt-billing-0.2.0.zip"; sha256 = "85f73bb3808a7d0d2543307e8f41e5b90a170ad6eeedd54fe7fcaac61b5b22d2"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Billing Client Library for Python";
      };
    };

    "azure-mgmt-cdn" = python.mkDerivation {
      name = "azure-mgmt-cdn-3.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/3f/2a/2c5450add0e93067270b24a39444c1bfb1a18ee705c5735cf38f5900f270/azure-mgmt-cdn-3.0.0.zip"; sha256 = "069774eb4b59b76ff9bd01708be0c8f9254ed40237b48368c3bb173f298755dd"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure CDN Management Client Library for Python";
      };
    };

    "azure-mgmt-cognitiveservices" = python.mkDerivation {
      name = "azure-mgmt-cognitiveservices-3.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e0/34/def32a5bc74b565bc55ccfc9fd3a5ee3a8ccd36e6a98d6578167d7bbc65d/azure-mgmt-cognitiveservices-3.0.0.zip"; sha256 = "c3247f2786b996a5f328ebdaf65d31507571979e004de7a5ed0ff280f95d80b4"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
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
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Commerce Client Library for Python";
      };
    };

    "azure-mgmt-compute" = python.mkDerivation {
      name = "azure-mgmt-compute-4.0.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8c/19/059f8822886335c089b449b63285a3a5f7574b4a9e88ff58c9a6b4355272/azure-mgmt-compute-4.0.1.zip"; sha256 = "0f20565914e2afa1cc4b9ceacb1636ae9428c26e4547bcc6f322cfce837dc872"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrest"
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
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Consumption Management Client Library for Python";
      };
    };

    "azure-mgmt-containerinstance" = python.mkDerivation {
      name = "azure-mgmt-containerinstance-1.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/37/db/356a1d44dd6a5fc019780dfc098e17c4680601876349a4f4103b893d778e/azure-mgmt-containerinstance-1.0.0.zip"; sha256 = "68c8150b5431752484b4933a6a15856b503068314b9d87ff99b03df3549bc92f"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Container Instance Client Library for Python";
      };
    };

    "azure-mgmt-containerregistry" = python.mkDerivation {
      name = "azure-mgmt-containerregistry-2.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d9/7c/44822668ea94b748884fbcb4359673a9abbe1ff37bc7ae763ae99d351c3e/azure-mgmt-containerregistry-2.1.0.zip"; sha256 = "4624bdaae57b5e107264f286931d0d81f942d0c57b0d93e8a2432abf9b074d7d"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrest"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Container Registry Client Library for Python";
      };
    };

    "azure-mgmt-containerservice" = python.mkDerivation {
      name = "azure-mgmt-containerservice-4.2.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e4/1c/88e48e8fe7a5d13cfafc7716052d392b08dcc69d08c4302bc48c12b5c3e7/azure-mgmt-containerservice-4.2.2.zip"; sha256 = "99df430a03aada02625e35ef13d7de6c667e9bef56b5e2f60b2c284514223bff"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrest"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Container Service Management Client Library for Python";
      };
    };

    "azure-mgmt-cosmosdb" = python.mkDerivation {
      name = "azure-mgmt-cosmosdb-0.4.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fb/6e/5c6e26bfd2711250b88d288a14091ead249fd53621c0feeda4aa06388d52/azure-mgmt-cosmosdb-0.4.1.zip"; sha256 = "a6e70527994d8ce7f4eeca80c7691bc9555adf90819848a9a30284a33b0cffe2"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Cosmos DB Management Client Library for Python";
      };
    };

    "azure-mgmt-datafactory" = python.mkDerivation {
      name = "azure-mgmt-datafactory-0.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f5/48/38a547a2bc716163d9261d48c4dab4e421153b16cb7e7a53dee22d770558/azure-mgmt-datafactory-0.6.0.zip"; sha256 = "6ee02286e9950b9f5b76589459f6d060a962faaab1f49c263a55d011e98b30bf"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Data Factory Management Client Library for Python";
      };
    };

    "azure-mgmt-datalake-analytics" = python.mkDerivation {
      name = "azure-mgmt-datalake-analytics-0.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/6f/e9/91da6cea4cccb268237e7f16bddefb2dbb1507f75b78c13a79eae16eb1cc/azure-mgmt-datalake-analytics-0.6.0.zip"; sha256 = "0d64c4689a67d6138eb9ffbaff2eda2bace7d30b846401673183dcb42714de8f"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Data Lake Analytics Management Client Library for Python";
      };
    };

    "azure-mgmt-datalake-store" = python.mkDerivation {
      name = "azure-mgmt-datalake-store-0.5.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/00/13/037f0128bdfcd47253f69a3b4ca6a7ff7b673b35832bc48f7c74df24a9be/azure-mgmt-datalake-store-0.5.0.zip"; sha256 = "9376d35495661d19f8acc5604f67b0bc59493b1835bbc480f9a1952f90017a4c"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Data Lake Store Management Client Library for Python";
      };
    };

    "azure-mgmt-datamigration" = python.mkDerivation {
      name = "azure-mgmt-datamigration-1.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/97/7c/4290bd4822883593bda7b09558747acc8700f1cc572fcb9b59cde3b3eba6/azure-mgmt-datamigration-1.0.0.zip"; sha256 = "ea2920475f9e56e660003a06397228243042157d46674f8a09abaf2d0a933aed"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Data Migration Client Library for Python";
      };
    };

    "azure-mgmt-devspaces" = python.mkDerivation {
      name = "azure-mgmt-devspaces-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/41/99/9572cbadd62752284c40e6868a25c2694b7494041bfcaa9a817fd0029163/azure-mgmt-devspaces-0.1.0.zip"; sha256 = "4710dd59fc219ebfa4272dbbad58bf62093b52ce22bfd32a5c0279d2149471b5"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Dev Spaces Client Library for Python";
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
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure DevTestLabs Management Client Library for Python";
      };
    };

    "azure-mgmt-dns" = python.mkDerivation {
      name = "azure-mgmt-dns-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/dd/61/bc8dbb9b7addc33c8ba03b1cbf2399da20e7a9b6b9bd81d02c7172d30388/azure-mgmt-dns-2.0.0.zip"; sha256 = "fc9cfd44ab534f156fa850a61b37d24204b86731a7f5d363f06c1ae10690aebe"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrest"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure DNS Management Client Library for Python";
      };
    };

    "azure-mgmt-eventgrid" = python.mkDerivation {
      name = "azure-mgmt-eventgrid-1.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/52/bf/0aa0194083213a16b1691368ad19260f1472dadc417334356d43f2e9829d/azure-mgmt-eventgrid-1.0.0.zip"; sha256 = "824503b668137affa5b3782c6348c0bb6ab012c72fe47a3be9942c5639f82f8a"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure EventGrid Management Client Library for Python";
      };
    };

    "azure-mgmt-eventhub" = python.mkDerivation {
      name = "azure-mgmt-eventhub-2.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a5/f4/aa3ae0be1bd05127afd178bb363034dbf68f7e46af45c61cd364de4a3698/azure-mgmt-eventhub-2.1.0.zip"; sha256 = "6a3a0cc288c5fb40cff2b88f9abdf783b4dbac287ba1ddb05b3b7e668b89426b"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrest"
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
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure SAP Hana on Azure Management Client Library for Python";
      };
    };

    "azure-mgmt-iotcentral" = python.mkDerivation {
      name = "azure-mgmt-iotcentral-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/92/90/18f54035d66a906ec390b09803fd1922fda3bd03126a0b01eefd9e69e612/azure-mgmt-iotcentral-0.1.0.zip"; sha256 = "0d2101f3ea8a21ec3b29ee72d83e6ca606a241efec3b042cda8c656ad99b8fd2"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure IoTCentral Management Client Library for Python";
      };
    };

    "azure-mgmt-iothub" = python.mkDerivation {
      name = "azure-mgmt-iothub-0.5.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/34/7b/9a8aa8bebf77b18b208a65ceedb915167b314746572d6e4ea2913eb3526c/azure-mgmt-iothub-0.5.0.zip"; sha256 = "08388142ed6844f0a0e97d2740decf80ffc94f22adca174c15f60b9e2c2d14be"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure IoTHub Management Client Library for Python";
      };
    };

    "azure-mgmt-iothubprovisioningservices" = python.mkDerivation {
      name = "azure-mgmt-iothubprovisioningservices-0.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/7a/9e/179a404d2b3d999cf2dbdbec51c849e92625706e8eff6bd6d02df3ad2ab7/azure-mgmt-iothubprovisioningservices-0.2.0.zip"; sha256 = "8c37acfd1c33aba845f2e0302ef7266cad31cba503cc990a48684659acb7b91d"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure IoTHub Provisioning Services Client Library for Python";
      };
    };

    "azure-mgmt-keyvault" = python.mkDerivation {
      name = "azure-mgmt-keyvault-1.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ee/51/49aa83bc983020d69807ce5458d70009bff211e9f6e4f6bb081755e82af8/azure-mgmt-keyvault-1.1.0.zip"; sha256 = "05a15327a922441d2ba32add50a35c7f1b9225727cbdd3eeb98bc656e4684099"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrest"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Key Vault Management Client Library for Python";
      };
    };

    "azure-mgmt-loganalytics" = python.mkDerivation {
      name = "azure-mgmt-loganalytics-0.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/93/e2/6b47cc232357b05d0c8c788d6bbece67428ea997ba29d50e5cd90c1bd104/azure-mgmt-loganalytics-0.2.0.zip"; sha256 = "c7315ff0ee4d618fb38dca68548ef4023a7a20ce00efe27eb2105a5426237d86"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Log Analytics Management Client Library for Python";
      };
    };

    "azure-mgmt-logic" = python.mkDerivation {
      name = "azure-mgmt-logic-3.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/20/1d/857b2356bfd4990cbabfb4995833df4c0328ccf8abf593dc2df0278ffeea/azure-mgmt-logic-3.0.0.zip"; sha256 = "d163dfc32e3cfa84f3f8131a75d9e94f5c4595907332cc001e45bf7e4efd5add"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Logic Apps Management Client Library for Python";
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
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Machine Learning Compute Management Client Library for Python";
      };
    };

    "azure-mgmt-managementgroups" = python.mkDerivation {
      name = "azure-mgmt-managementgroups-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/3e/fd/0601266fd246b84a8f6882822b6cbccee18b85d5405dab1b85db82ba2606/azure-mgmt-managementgroups-0.1.0.zip"; sha256 = "ff62d982edda634a36160cb1d15a367a9572a5acb419e5e7ad371e8c83bd47c7"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Management Groups Client Library for Python";
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
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure ManagementPartner Management Client Library for Python";
      };
    };

    "azure-mgmt-maps" = python.mkDerivation {
      name = "azure-mgmt-maps-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/58/99/735fc6f274d2f2a493071b4bc3e6ec2bc3d0d6caf1425eb903647785532c/azure-mgmt-maps-0.1.0.zip"; sha256 = "c120e210bb61768da29de24d28b82f8d42ae24e52396eb6569b499709e22f006"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Maps Client Library for Python";
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
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Market Place Ordering Client Library for Python";
      };
    };

    "azure-mgmt-media" = python.mkDerivation {
      name = "azure-mgmt-media-1.0.0rc2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/90/67/7617a2f9402061150dc857139d79bf3a2f71fb75abdbebeda67d45cbff8c/azure-mgmt-media-1.0.0rc2.zip"; sha256 = "7be7aec9d2726fec63c1bf276cc127a3696002dca7b8edd53a1aca28a143dbab"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Media Services Client Library for Python";
      };
    };

    "azure-mgmt-monitor" = python.mkDerivation {
      name = "azure-mgmt-monitor-0.5.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c6/e7/7a05e95d742605c08b38864693e82d0424bb66dd5870b5e2edfc0f71fd0c/azure-mgmt-monitor-0.5.2.zip"; sha256 = "f1a58d483e3292ba4f7bbf3104573130c9265d6c9262e26b60cbfa950b5601e4"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Monitor Client Library for Python";
      };
    };

    "azure-mgmt-msi" = python.mkDerivation {
      name = "azure-mgmt-msi-0.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/da/6f/60f92469f93e2820949f967b8c722fe0c04f03e4cc9a6332ffaf5e9f405b/azure-mgmt-msi-0.2.0.zip"; sha256 = "8622bc9a164169a0113728ebe7fd43a88189708ce6e10d4507247d6907987167"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure MSI Management Client Library for Python";
      };
    };

    "azure-mgmt-network" = python.mkDerivation {
      name = "azure-mgmt-network-2.0.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/23/af/df2d8fc56d1fc043b3f50fc0a3e45903ca4254330349f01bf1893ddffa93/azure-mgmt-network-2.0.1.zip"; sha256 = "8d75dc6eac82f0593106903d0fd616115b4472772f867535dd5d21f2e5e21cdf"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrest"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Network Management Client Library for Python";
      };
    };

    "azure-mgmt-notificationhubs" = python.mkDerivation {
      name = "azure-mgmt-notificationhubs-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b1/d6/c5fdeed29289e6d4ea8a5857811842b15ff686117fa0a20c98f3e2bb4476/azure-mgmt-notificationhubs-2.0.0.zip"; sha256 = "7c4c7755c28c8301cfa90d6ded9509c30444e5dfc5001b132dca57836930602b"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Notification Hubs Management Client Library for Python";
      };
    };

    "azure-mgmt-policyinsights" = python.mkDerivation {
      name = "azure-mgmt-policyinsights-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/72/f8/ead482ae756cc04b61f96ffa29d4a6dca736dddc5407697cdc98cde17015/azure-mgmt-policyinsights-0.1.0.zip"; sha256 = "ff94cb12d6e01bf1470c2a6af4ce6960669ab4209106153879ff97addc569ce1"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Policy Insights Client Library for Python";
      };
    };

    "azure-mgmt-powerbiembedded" = python.mkDerivation {
      name = "azure-mgmt-powerbiembedded-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/5f/2f/7d3c7b97d5d469a0c68c2881c69b62b5c88184fb439daa41b061dd4ced25/azure-mgmt-powerbiembedded-2.0.0.zip"; sha256 = "2f05be73f2a086c579a78fc900e3b2ae14ccde5bcec54e29dfc73e626b377476"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Power BI Embedded Management Client Library for Python";
      };
    };

    "azure-mgmt-rdbms" = python.mkDerivation {
      name = "azure-mgmt-rdbms-1.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/de/61/80e7b2510efee13334095e509f8daf42187b811f7eb7fab830be9f453d19/azure-mgmt-rdbms-1.2.0.zip"; sha256 = "6e5abef2fcac1149dda1119443ea26c847e55e8b4c771b7b033f92d1b3140263"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure RDBMS Management Client Library for Python";
      };
    };

    "azure-mgmt-recoveryservices" = python.mkDerivation {
      name = "azure-mgmt-recoveryservices-0.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0e/be/fb8fe04ac181a63b563d172dbe658eba1b75fa5a0df8e3659dac04e0f608/azure-mgmt-recoveryservices-0.3.0.zip"; sha256 = "e48f7769fb10a85ad857710c2cba47880166f69fe7da6b331771f129b21de95c"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Recovery Services Client Library for Python";
      };
    };

    "azure-mgmt-recoveryservicesbackup" = python.mkDerivation {
      name = "azure-mgmt-recoveryservicesbackup-0.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/5c/18/a60608752a23d585f6fe13fb3bd9a9a11ceac69129c72a3cf0dc32524028/azure-mgmt-recoveryservicesbackup-0.3.0.zip"; sha256 = "1e55b6cbb808df83576cef352ba0065f4878fe505299c0a4c5a97f4f1e5793df"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Recovery Services Backup Management Client Library for Python";
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
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Relay Client Library for Python";
      };
    };

    "azure-mgmt-reservations" = python.mkDerivation {
      name = "azure-mgmt-reservations-0.2.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/27/04/fd610a6e3095ec09f6c0e3d9b3ba356c7fac329b260b82014a7cb7b0eb2b/azure-mgmt-reservations-0.2.1.zip"; sha256 = "40618a3700c47a788182649f238d985edf15b08b6577ea27557e70e2866ac171"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Reservations Client Library for Python";
      };
    };

    "azure-mgmt-resource" = python.mkDerivation {
      name = "azure-mgmt-resource-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/48/31/5996d2af3e32cf6ccc3f44da401ae397e6302b08d7ef7d8736191a8bfe61/azure-mgmt-resource-2.0.0.zip"; sha256 = "2e83289369be88d0f06792118db5a7d4ed7150f956aaae64c528808da5518d7f"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Resource Management Client Library for Python";
      };
    };

    "azure-mgmt-scheduler" = python.mkDerivation {
      name = "azure-mgmt-scheduler-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a8/e0/a045f6a62c2fca6a84fabc812b961511565eec31103f9c688ce887dc6d17/azure-mgmt-scheduler-2.0.0.zip"; sha256 = "c6e6edd386ddc4c21d54b1497c3397b970bc127b71809b51bd2391cb1f3d1a14"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Scheduler Management Client Library for Python";
      };
    };

    "azure-mgmt-search" = python.mkDerivation {
      name = "azure-mgmt-search-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d3/ac/45dc77a33fa08f09f27a28a42321780d41830f22b554951836bca8665a5e/azure-mgmt-search-2.0.0.zip"; sha256 = "0ec5de861bd786bcb8691322feed6e6caa8d2f0806a50dc0ca5d640591926893"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Search Management Client Library for Python";
      };
    };

    "azure-mgmt-servicebus" = python.mkDerivation {
      name = "azure-mgmt-servicebus-0.5.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/bf/73/ab9df5d9e771a54457d8e20bff1b2ef3be4f6817f5df9efa37a785ec016e/azure-mgmt-servicebus-0.5.1.zip"; sha256 = "7977e9118206c7740e00b5e37c697b195125cbaedca19a54ed4bdb79ec4b988d"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Service Bus Management Client Library for Python";
      };
    };

    "azure-mgmt-servicefabric" = python.mkDerivation {
      name = "azure-mgmt-servicefabric-0.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/13/cd/996d5887c207c175eb1be0936b994db3382d0e2998e58baaf5255e53ddc2/azure-mgmt-servicefabric-0.2.0.zip"; sha256 = "b2bf2279b8ff8450c35e78e226231655021482fdbda27db09975ebfc983398ad"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrest"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Service Fabric Management Client Library for Python";
      };
    };

    "azure-mgmt-signalr" = python.mkDerivation {
      name = "azure-mgmt-signalr-0.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d2/4d/8093ed05713cf31b427353de9bc9de61283c55400f26f061fb430d647fc4/azure-mgmt-signalr-0.1.0.zip"; sha256 = "c7db8bbfb7423305433ca4764ea66c4ff98ea92e7cba2da5bf367fb6d44532a5"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure SignalR Client Library for Python";
      };
    };

    "azure-mgmt-sql" = python.mkDerivation {
      name = "azure-mgmt-sql-0.9.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9e/68/d7df2ec227c9082454981f4043f4994e0f1b8aa92beca0cf21c25cf1cfbe/azure-mgmt-sql-0.9.1.zip"; sha256 = "5da488a56d5265757b45747cf5fd22413eb089e606658d6e6d84fe3e9b07e4fa"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure SQL Management Client Library for Python";
      };
    };

    "azure-mgmt-storage" = python.mkDerivation {
      name = "azure-mgmt-storage-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/38/8a/2ea5b07a1a8341f064f3e7f92a7ebeeacb26540959cf58381f66dd2d19a6/azure-mgmt-storage-2.0.0.zip"; sha256 = "512a29798833453f8c32a5b6d038a459649bbb5b9970ac23c982b5787057fa2b"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Storage Management Client Library for Python";
      };
    };

    "azure-mgmt-subscription" = python.mkDerivation {
      name = "azure-mgmt-subscription-0.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/49/23/31b74f6cfdbcd27d91e98b49bfe13a6ac26137be99a0f6f91d6e5ec87cf0/azure-mgmt-subscription-0.2.0.zip"; sha256 = "309b23f0de65f26da80c801e913b0c3b2aea8b90ba583d919f81fe6f329d3f1b"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Subscription Management Client Library for Python";
      };
    };

    "azure-mgmt-trafficmanager" = python.mkDerivation {
      name = "azure-mgmt-trafficmanager-0.50.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/bb/66/ca0d8190a227ba2fcd2b712209cd39e10e28f71b4d621ef07e7c325e29ca/azure-mgmt-trafficmanager-0.50.0.zip"; sha256 = "126167eaa82b443b5b71394050ec292f45074701232bdbdda71f636e9b46516b"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Traffic Manager Client Library for Python";
      };
    };

    "azure-mgmt-web" = python.mkDerivation {
      name = "azure-mgmt-web-0.35.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/44/d6/08ba5653702e67d401291128fc30aa6cff05fb82299832899c2ce63ca6cd/azure-mgmt-web-0.35.0.zip"; sha256 = "8ea0794eef22a257773c13269b94855ab79d36c342ad15a98135403c9785cc0a"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
      self."msrestazure"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.mit;
        description = "Microsoft Azure Web Apps Management Client Library for Python";
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
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-sdk-for-python";
        license = licenses.asl20;
        description = "Microsoft Azure Service Bus Client Library for Python";
      };
    };

    "azure-servicefabric" = python.mkDerivation {
      name = "azure-servicefabric-6.3.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c6/3f/15df9c3321568bc89eec3f168c50710f603e32bcaba2c005fa5c794a2e5f/azure-servicefabric-6.3.0.0.zip"; sha256 = "c82575cbdf95cc897c3230ea889d4e751d8760a2223857fe6fbeeea5b802e5e2"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure-common"
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
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Azure/azure-storage-python";
        license = licenses.mit;
        description = "Microsoft Azure Storage File Client Library for Python";
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
      name = "certifi-2018.8.13";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/53/0d/d1d13a63563cc50a27b310f5612645bef06d29a5022a7e79ac659dd0fc50/certifi-2018.8.13.tar.gz"; sha256 = "4c1d68a1408dd090d2f3a869aa94c3947cc1d967821d1ed303208c9f41f0f2f4"; };
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

    "gevent" = python.mkDerivation {
      name = "gevent-1.3.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/49/13/aa4bb3640b5167fe58875d3d7e65390cdb14f9682a41a741a566bb560842/gevent-1.3.6.tar.gz"; sha256 = "7b413c391e8ad6607b7f7540d698a94349abd64e4935184c595f7cdcc69904c6"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."cffi"
      self."greenlet"
      self."idna"
      self."requests"
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
      name = "msrestazure-0.5.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a5/d1/5ca5d6b8647030e51d4b39d115976c4c4cc8d28293dfaa06c43268cf7c87/msrestazure-0.5.0.tar.gz"; sha256 = "2e756de45ddc2ea7c34b8dc267a5d18804f2eb6a432626ace465ffed6081455d"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."adal"
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
      name = "python-dateutil-2.7.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a0/b0/a4e3241d2dee665fea11baec21389aec6886655cd4db7647ddf96c3fad15/python-dateutil-2.7.3.tar.gz"; sha256 = "e27001de32f627c22380a688bcc43ce83504a7bc5da472209b4c70f02829f0b8"; };
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

    "wal-e" = python.mkDerivation {
      name = "wal-e-1.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d6/73/b210a8900d4fc8ef4e5b919f96358cdddcb2b909fcd81bf673b3c7f08aa6/wal-e-1.1.0.tar.gz"; sha256 = "1b49590a325a25b28471526d739d904428d6f2f20d1761364266a646181fa916"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."azure"
      self."boto"
      self."gevent"
      self."google-cloud-storage"
      self."python-keystoneclient"
      self."python-swiftclient"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/wal-e/wal-e";
        license = licenses.bsdOriginal;
        description = "Continuous Archiving for Postgres";
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
  localOverridesFile = ./wal-e_override.nix;
  localOverrides = import localOverridesFile { inherit pkgs python; };
  commonOverrides = [
        (let src = pkgs.fetchFromGitHub { owner = "garbas"; repo = "nixpkgs-python"; rev = "c175a6e3fe56707e94aca7506e2d0f72f55c7ff4"; sha256 = "09nfbidi3ws597jzwcg53hbdylcril29hsmzhsz3kbsvjn0jglg1"; } ; in import "${src}/overrides.nix" { inherit pkgs python; })
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