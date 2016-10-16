with import <nixpkgs> {};

python3Packages.buildPythonPackage rec {
  name = "greenlet";
  version = "0.4.9";

  # No module named tests
  doCheck = false;

  propagatedBuildInputs = [
    python3Packages.pyopenssl
  ];

  src = fetchurl {
    url = "https://pypi.python.org/packages/ba/19/7ae57aa8b66f918859206532b1afd7f876582e3c87434ff33261da1cf50c/greenlet-0.4.9.tar.gz";
    sha256 = "04h0m54dyqg49vyarq26mry6kbivnpl47rnmmrk9qn8wpfxviybr";
  };
}
