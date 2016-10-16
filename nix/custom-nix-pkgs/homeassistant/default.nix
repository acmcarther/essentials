with import <nixpkgs> {};

python3Packages.buildPythonApplication rec {

  propagatedBuildInputs = [
    python35
    python3Packages.jinja2
    python3Packages.pyyaml
    python3Packages.requests2
    (import ../eventlet.nix)
    (import ../netdisco.nix)
    (import ../webcolors.nix)
    (import ../psutil.nix)
    (import ../pytz.nix)
    (import ../voluptuous.nix)
    (import ../vincenty.nix)
  ];

  name = "homeassistant-${version}";
  version = "0.21.0";

  # No module named tests
  doCheck = false;

  src = fetchurl {
    url = "https://pypi.python.org/packages/de/b5/16eef12e8a3a9fc914f6eb3610758413cd026819475081cdf50206e00bc3/homeassistant-${version}.tar.gz";
    sha256 = "08z6yr1sfq85n6an1bjvdiqdkknd0rpsradniz7agrjaljmxjpz0";
  };
}
