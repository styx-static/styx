{ pkgs ? import <nixpkgs> {} }:

let styx =

{ stdenv, caddy }:

stdenv.mkDerivation rec {
  name    = "styx-${version}";
  version = "0.1.0";

  src = ./src;

  server = caddy.bin;

  installPhase = ''
    mkdir $out
    install -D -m 777 styx.sh $out/bin/styx

    mkdir -p $out/share/styx
    cp -r sample $out/share/styx

    substituteAllInPlace $out/bin/styx
    substituteAllInPlace $out/share/styx/sample/templates/atom.nix
  '';

  meta = with stdenv.lib; {
    description = "Nix based static site generator";
    maintainers = with maintainers; [ ericsagnes ];
    platforms   = platforms.all;
  };
}

;in
  pkgs.callPackage styx {}
