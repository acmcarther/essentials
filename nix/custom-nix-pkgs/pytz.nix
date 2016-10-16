with import <nixpkgs> {};

python3Packages.buildPythonPackage rec {
  name = "pytz";
  version = "2016.4";
  src = fetchurl {
    url = "https://pypi.python.org/packages/ad/30/5ab2298c902ac92fdf649cc07d1b7d491a241c5cac8be84dd84464db7d8b/pytz-2016.4.tar.gz";
    sha256 = "1qgy1cx6iiw6kc7px28vck582f2hw11w7kl7w1prkla0zxhxw8y8";
  };
}
