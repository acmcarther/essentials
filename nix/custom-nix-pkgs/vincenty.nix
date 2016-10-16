with import <nixpkgs> {};

python3Packages.buildPythonPackage rec {
  name = "vincenty";
  version = "0.1.4";
  src = fetchurl {
    url = "https://pypi.python.org/packages/source/v/vincenty/vincenty-${version}.tar.gz";
    sha256 = "0nkqhbhrqar4jab7rvxfyjh2sh8d9v6ir861f6yrqdjzhggg58pa";
  };
}
