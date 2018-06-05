{ config, pkgs, lib, ... }:

let rustNightlyNixRepo = pkgs.fetchFromGitHub {
     owner = "solson";
     repo = "rust-nightly-nix";
     rev = "7081bacc88037d9e218f62767892102c96b0a321";
     sha256 = "0dzqmbwl2fkrdhj3vqczk7fqah8q7mfn40wx9vqavcgcsss63m8p";
  };
  rustPackages = pkgs.callPackage rustNightlyNixRepo { };
  rustcLatestBuilder = {buildDate}: rustPackages.rustcWithSysroots {
    rustc = rustPackages.rustc { date = buildDate; };
    sysroots = [
      (rustPackages.rust-std { date = buildDate; })
      (rustPackages.rust-std { date = buildDate; system = "asmjs-unknown-emscripten"; })
      (rustPackages.rust-std { date = buildDate; system = "wasm32-unknown-emscripten"; })
    ];
  };
in {
  nixpkgs.config.packageOverrides = pkgs: rec {
    cargoLatest = rustPackages.cargo { date = "2018-02-01"; };
    rustcLatest = rustcLatestBuilder { buildDate = "2018-02-01"; };
    ksonnet = import ./ksonnet.nix {
      inherit (pkgs) stdenv fetchFromGitHub buildFHSUserEnv writeScript jdk zip unzip lib buildGoPackage;
      inherit (pkgs) which makeWrapper binutils fetchurl;
    };
    bazel-custom = import ./bazel/default.nix {
      inherit (pkgs) stdenv fetchFromGitHub buildFHSUserEnv writeScript jdk zip unzip;
      inherit (pkgs) which makeWrapper binutils fetchurl;
    };
  };
}

