{ config, pkgs, lib, ... }:

let rustNightlyNixRepo = pkgs.fetchFromGitHub {
     owner = "solson";
     repo = "rust-nightly-nix";
     rev = "9e09d579431940367c1f6de9463944eef66de1d4";
     sha256 = "03zkjnzd13142yla52aqmgbbnmws7q8kn1l5nqaly22j31f125xy";
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
    gdb = pkgs.gdb.overrideDerivation(oldAttrs:{
      src = pkgs.fetchurl {
        url = "mirror://gnu/gdb/gdb-7.12.tar.xz";
        sha256 = "152g2qa8337cxif3lkvabjcxfd9jphfb2mza8f1p2c4bjk2z6kw3";
      };
    });
    cargoLatest = rustPackages.cargo { date = "2016-10-28"; };
    rustcLatest = rustcLatestBuilder { buildDate = "2017-06-16"; };
    bazel-custom = import ./bazel/default.nix {
      inherit (pkgs) stdenv fetchFromGitHub buildFHSUserEnv writeScript jdk zip unzip;
      inherit (pkgs) which makeWrapper binutils fetchurl;
    };
    concourse = pkgs.stdenv.mkDerivation rec {
      name = "concourse-v3.3.2";
      src = pkgs.fetchurl {
        url = "https://github.com/concourse/concourse/releases/download/v3.3.2/concourse_linux_amd64";
        sha256 = "0xjpqka8g2x3mb6h6y3mzkh7f3mcv8jminn9jilxfriyy6zyfk0c";
        executable = true;
      };
      phases = [ "unpackPhase" "installPhase" ];
      nativeBuildInputs = [ pkgs.patchelf ];
      unpackPhase = ''
        mkdir -v ${name}
        cp ${src} ./${name}/concourse_linux_amd64
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp ${name}/concourse_linux_amd64 $out/bin/concourse
        chmod +w $out/bin/concourse
        patchelf --set-interpreter \
            ${pkgs.stdenv.glibc}/lib/ld-linux-x86-64.so.2 $out/bin/concourse
        patchelf --set-rpath ${pkgs.stdenv.glibc}/lib $out/bin/concourse
        chmod a+x $out/bin/concourse
      '';
    };

    concourse-fly = pkgs.stdenv.mkDerivation rec {
      name = "concourse-fly-v3.3.2";
      src = pkgs.fetchurl {
        url = "https://github.com/concourse/concourse/releases/download/v3.3.2/fly_linux_amd64";
        sha256 = "1hvsw03s5y50cn6p02fr6fcyzkfil4nnns85qlla1blqnkm4jwpj";
        executable = true;
      };
      phases = [ "unpackPhase" "installPhase" ];
      nativeBuildInputs = [ pkgs.patchelf ];
      unpackPhase = ''
        mkdir -v ${name}
        cp ${src} ./${name}/fly_linux_amd64
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp ${name}/fly_linux_amd64 $out/bin/fly
        chmod +w $out/bin/fly
        patchelf --set-rpath ${pkgs.stdenv.glibc}/lib $out/bin/fly
        echo $(< $NIX_CC/nix-support/dynamic-linker) $out/bin/fly.wrapped \"\$@\" > $out/bin/fly

        chmod a+x $out/bin/fly
      '';
    };
  };
}
