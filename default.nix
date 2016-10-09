{ pkgs ? import <nixpkgs> {} }:

let styx =

{ stdenv, caddy, asciidoctor }:

stdenv.mkDerivation rec {
  name    = "styx-${version}";
  version = pkgs.lib.fileContents ./VERSION;

  src = ./src;

  server = "${caddy.bin}/bin/caddy";

  nativeBuildInputs = [ asciidoctor ];

  installPhase = ''
    mkdir $out
    install -D -m 777 styx.sh $out/bin/styx

    mkdir -p $out/share/styx
    cp -r sample $out/share/styx

    mkdir -p $out/share/doc/styx
    asciidoctor doc/manual.doc -o $out/share/doc/styx/index.html

    substituteAllInPlace $out/bin/styx
    substituteAllInPlace $out/share/doc/styx/index.html
  '';

  meta = with stdenv.lib; {
    description = "Nix based static site generator";
    maintainers = with maintainers; [ ericsagnes ];
    platforms   = platforms.all;
  };
}

;in
  pkgs.callPackage styx {}
