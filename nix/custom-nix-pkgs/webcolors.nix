with import <nixpkgs> {};

python3Packages.buildPythonPackage rec {
  name = "webcolors";
  version = "0.1.6";
  src = fetchurl {
    url = "https://pypi.python.org/packages/1d/e8/24f4a8854290c685c335076a322e9db7224e88ff723de5d01ced2e1d767d/webcolors-1.5.tar.gz";
    sha256 = "13hvqlnq6japjx7a4d603kwijm8i74957dkn5fcd2scw3sjc7cdk";
  };
}
