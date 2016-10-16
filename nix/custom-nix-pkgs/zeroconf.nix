with import <nixpkgs> {};

python3Packages.buildPythonPackage rec {
  name = "zeroconf";
  version = "0.17.5";
  propagatedBuildInputs = [
    python3Packages.netifaces
    python3Packages.six
    (import ./enum-compat.nix)
  ];
  src = fetchurl {
    url = "https://pypi.python.org/packages/source/z/zeroconf/zeroconf-${version}.tar.gz";
    sha256 = "0bhi6sjbbl36b079k4885bzawblw2cqn1902wzamj8jiqgzqmsji";
  };
}
