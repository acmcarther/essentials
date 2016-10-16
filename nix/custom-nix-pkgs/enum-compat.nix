with import <nixpkgs> {};

python3Packages.buildPythonPackage rec {
  name = "enum-compat";
  version = "0.0.2";
  src = fetchurl {
    url = "https://pypi.python.org/packages/source/e/enum-compat/enum-compat-${version}.tar.gz";
    sha256 = "14j1i963jic2vncbf9k5nq1vvv8pw2zsg7yvwhm7d9c6h7qyz74k";
  };
}
