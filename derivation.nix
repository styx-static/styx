{ stdenv, caddy, asciidoctor
, file, lessc, sass, multimarkdown
, callPackage }:

stdenv.mkDerivation rec {
  name    = "styx-${version}";
  version = stdenv.lib.fileContents ./VERSION;

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

  outputs = [ "out" "lib" ];

  installPhase = ''
    mkdir $out
    install -D -m 777 styx.sh $out/bin/styx

    mkdir -p $out/share/styx
    cp -r scaffold $out/share/styx
    cp    builder.nix $out/share/styx

    mkdir -p $out/share/doc/styx
    asciidoctor doc/index.adoc       -o $out/share/doc/styx/index.html
    asciidoctor doc/styx-themes.adoc -o $out/share/doc/styx/styx-themes.html
    cp -r doc/imgs $out/share/doc/styx/

    substituteAllInPlace $out/bin/styx
    substituteAllInPlace $out/share/doc/styx/index.html
    substituteAllInPlace $out/share/doc/styx/styx-themes.html

    mkdir $lib
    cp -r lib/* $lib
  '';

  meta = with stdenv.lib; {
    description = "Nix based static site generator";
    maintainers = with maintainers; [ ericsagnes ];
    platforms   = platforms.all;
  };
}
