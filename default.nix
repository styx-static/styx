{ pkgs ? import <nixpkgs> {} }:

let 

styx =

{ stdenv, caddy, asciidoctor
, file, lessc, sass, multimarkdown
, callPackage }:

stdenv.mkDerivation rec {
  name    = "styx-${version}";
  version = pkgs.lib.fileContents ./VERSION;

  src = ./src;

  server = "${caddy.bin}/bin/caddy";

  nativeBuildInputs = [ asciidoctor ];

  propagatedBuildInputs = [
    file
    lessc
    sass
    asciidoctor
    multimarkdown
  ];

  installPhase = ''
    mkdir $out
    install -D -m 777 styx.sh $out/bin/styx

    mkdir -p $out/share/styx
    cp -r lib $out/share/styx
    cp -r scaffold $out/share/styx
    cp    builder.nix $out/share/styx

    mkdir -p $out/share/doc/styx
    asciidoctor doc/manual.adoc -o $out/share/doc/styx/index.html

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
