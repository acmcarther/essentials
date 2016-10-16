with import <nixpkgs> {};

python3Packages.buildPythonPackage rec {
  name = "netdisco";
  version = "0.6.7";
  propagatedBuildInputs = [
    python3Packages.netifaces
    python3Packages.requests2
    (import ./zeroconf.nix)
  ];
  src = fetchurl {
    url = "https://pypi.python.org/packages/0a/14/23c35b11ab2562689855290381918c0562d9b65689ef5070c1c5ff925521/netdisco-0.6.7.tar.gz";
    sha256 = "0n00bqi8cipbfy8mqhy7zgib8559iz5zqv5ly3a6ygdvaxjgdw3s";
  };
}
