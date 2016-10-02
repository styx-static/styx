{ pkgs ? import <nixpkgs> {} }:
with pkgs;

stdenv.mkDerivation rec {
  name = "styx-${version}";
  version = "0.1";

  caddy = pkgs.caddy.bin;

  installPhase = ''
    mkdir $out
    install -D -m 777 styx.sh $out/bin/styx

    mkdir -p $out/share/styx
    cp -r sample $out/share/styx

    substituteAllInPlace $out/bin/styx
    substituteAllInPlace $out/share/styx/sample/templates/atom.nix
  '';

  src = ./src;
}
