{ stdenv, fetchFromGitHub, fetchurl, buildFHSUserEnv, writeScript, jdk, zip, unzip,
  which, makeWrapper, binutils, lib, buildGoPackage}:

with lib;

buildGoPackage rec {
  name = "ksonnet-b70c996";

  goPackagePath = "github.com/ksonnet/ksonnet";

  src = fetchFromGitHub {
    rev = "b70c996";
    owner = "ksonnet";
    repo = "ksonnet";
    sha256 = "13wkd08ds2n4w2wp6bc4f1hkhwgl6yb06yd08m1w8mlmjdb0zxy6";
  };

  meta = {
    description = "A tool for managing Kubernetes resources as code.";
    homepage = https://github.com/ksonnet/ksonnet;
    platforms = platforms.unix;
  };
}
