{ lib, stdenv, asciidoctor
, caddy
, linkchecker
, callPackage
, python27
, pkgs }:

stdenv.mkDerivation rec {
  preferLocalBuild = true;
  allowSubstitutes = false;

  name    = "styx-${version}";
  version = builtins.unsafeDiscardStringContext (lib.fileContents ./VERSION);

  src = lib.cleanSource ./.;

  server = "${caddy}/bin/caddy";
  linkcheck = "${linkchecker}/bin/linkchecker";
  nixpkgs = pkgs.path;

  nativeBuildInputs = [ asciidoctor ];

  outputs = [ "out" "themes" ];

  installPhase = ''
    mkdir $out
    install -D -m 777 src/styx.sh $out/bin/styx

    cp src/default.nix $out/default.nix
    cp src/styx-config.nix $out/styx-config.nix

    mkdir -p $out/share/doc/styx
    asciidoctor src/doc/index.adoc       -o $out/share/doc/styx/index.html
    asciidoctor src/doc/styx-themes.adoc -o $out/share/doc/styx/styx-themes.html
    asciidoctor src/doc/library.adoc     -o $out/share/doc/styx/library.html
    cp -r src/doc/highlight $out/share/doc/styx/
    cp -r src/doc/imgs $out/share/doc/styx/

    substituteAllInPlace $out/bin/styx
    substituteAllInPlace $out/share/doc/styx/index.html
    substituteAllInPlace $out/share/doc/styx/styx-themes.html
    substituteAllInPlace $out/share/doc/styx/library.html

    mkdir -p $out/share/styx/scaffold
    cp -r src/scaffold $out/share/styx
    cp -r src/tools    $out/share/styx
    cp -r src/nix      $out/share/styx

    mkdir -p $out/lib
    cp -r src/lib/* $out/lib

    mkdir $themes
    cp -r themes/* $themes
  '';

  meta = with lib; {
    description = "Nix based static site generator";
    maintainers = with maintainers; [ ericsagnes ];
    platforms   = platforms.all;
  };
}
