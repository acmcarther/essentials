{ stdenv, fetchFromGitHub, fetchurl, buildFHSUserEnv, writeScript, jdk, zip, unzip,
  which, makeWrapper, binutils, lib, buildGoPackage}:

with lib;

buildGoPackage rec {
  name = "kubecfg-2169ce8";

  goPackagePath = "github.com/ksonnet/kubecfg";

  src = fetchFromGitHub {
    rev = "2169ce8";
    owner = "ksonnet";
    repo = "kubecfg";
    sha256 = "0mp1ngnj8j4q8bbcda8lvckqlwr5lnwrica2jjs4825qbmcg392j";
  };

  meta = {
    description = "A tool for managing Kubernetes resources as code.";
    homepage = https://github.com/ksonnet/kubecfg;
    platforms = platforms.unix;
  };
}
