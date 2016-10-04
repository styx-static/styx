# Packages to use
# This is the place to define packages that are not available in nixpkgs

let
  pkgs = (import (import ../nixpkgs-path.nix) {});

  # extra packages
  extraPkgs = {

    markdown = pkgs.callPackage ({ stdenv, fetchzip }: stdenv.mkDerivation {
      name = "markdown-1.0.1";
      src = fetchzip {
        url = http://daringfireball.net/projects/downloads/Markdown_1.0.1.zip;
        sha256 = "1mic1v7cliz59h04pj1gw001wzh346aw3dvb266agj706bg79kdf";
      };
      phases = ["installPhase"];
      installPhase = ''
        mkdir -p $out/bin
        cp $src/Markdown.pl $out/bin/markdown
        sed -i '1s:/usr/bin/perl:${pkgs.perl}/bin/perl:' $out/bin/markdown
      '';
    }) {};
  };
in
  pkgs // extraPkgs
