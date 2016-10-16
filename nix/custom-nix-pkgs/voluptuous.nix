with import <nixpkgs> {};

python3Packages.buildPythonPackage rec {
  name = "voluptuous";
  version = "0.8.9";
  src = fetchurl {
    url = "https://pypi.python.org/packages/source/v/voluptuous/voluptuous-${version}.tar.gz";
    sha256 = "1d047s98cg2sc0v047yc9clh0k7av3idjycla297dxvz3gan45bf";
  };
}
