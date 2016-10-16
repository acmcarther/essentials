with import <nixpkgs> {};

python3Packages.buildPythonPackage rec {
  name = "psutil";
  version = "4.2.0";
  doCheck = false;
  src = fetchurl {
    url = "https://pypi.python.org/packages/a6/bf/5ce23dc9f50de662af3b4bf54812438c298634224924c4e18b7c3b57a2aa/psutil-4.2.0.tar.gz";
    sha256 = "1khsr8pbxhsc4c5harjcl1wm25nlylkmdziygvh9jwga18x02ksl";
  };
}
