{ lib
, stdenv
, callPackage
, themes

, writePython3Bin

, asciidoctor
, caddy
, linkchecker
}:

stdenv.mkDerivation rec {
  preferLocalBuild = true;
  allowSubstitutes = false;

  name    = "styx-${version}";
  version = builtins.unsafeDiscardStringContext (lib.fileContents ./VERSION);

  src = lib.cleanSource ./.;

  buildInputs = [ pkgs.caddy pkgs.linkchecker ];
  nativeBuildInputs = [ pkgs.asciidoctor ];

  # outputs = [ "out" ];

  installPhase = ''
    mkdir $out
    install -D -m 777 src/styx.sh $out/bin/styx


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

    # old pkg functor compatibility
    cp compat/default.nix $out/default.nix
    cp flake.lock         $out/flake.lock
    cp -r src/lib         $out/share/
  '';

  passthru = {
   # old pkg functor compatibility
   pkgfunctor =
   # old theme compatibility
   themes = ./compat/themes.nix;
   # old lib compatibility
   lib = ./compat/lib.nix;
   asciidoc-parser = writePython3Bin "asciidoc-parser" {libraries = [pkgs.parsimonious];} (lib.fileContent ./src/tools/asciidoc-parser.py);
   markdown-parser = writePython3Bin "markdown-parser" {libraries = [pkgs.parsimonious];} (lib.fileContent ./src/tools/markdown-parser.py);
  };

  meta = with lib; {
    description = "Nix based static site generator";
    maintainers = with maintainers; [ ericsagnes blaggacao ];
    platforms   = platforms.all;
  };
}
