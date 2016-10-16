with import <nixpkgs> {};

python3Packages.buildPythonPackage rec {
  name = "eventlet";
  version = "0.19.0";

  # No module named tests
  doCheck = false;

  propagatedBuildInputs = [
    python3Packages.pyopenssl
    python3Packages.nose
    (import ./greenlet.nix)
  ];
  src = fetchurl {
    url = "https://pypi.python.org/packages/5a/e8/ac80f330a80c18113df0f4f872fb741974ad2179f8c2a5e3e45f40214cef/eventlet-0.19.0.tar.gz";
    sha256 = "08dgdhvrvqfxrpsxld6dis647y9kr9crr0pmf7abg16smnw76qrh";
  };
}
