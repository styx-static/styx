{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells.renderers) docs;
  inherit (inputs.cells.data) styxthemes;

  styxlib = (import (inputs.self + /src/lib)) {
    pkgs = nixpkgs;
    conf = null;
  };

  l = nixpkgs.lib // builtins;
in {
  update-doc = let
    site = {...}: rec {
      loaded =
        (import (inputs.self + /src/default.nix) {
          pkgs = nixpkgs;
          themes = l.reverseList (l.attrValues styxthemes);
          env = {
            data = {};
            pages = {};
          };
          config = [{siteUrl = "http://domain.org";}];
        })
        .themes;
      site = styxlib.generation.mkSite {
        pageList = styxlib.generation.pagesToList {inherit (loaded.env) pages;};
      };
    };
    doc-theme = docs.theme site {};
    doc-library = docs.library site {};
  in
    nixpkgs.writeScriptBin "update-doc" ''
      repoRoot="$(git rev-parse --show-toplevel)"
      target="$(readlink -f -- "$repoRoot/src/doc/")"

      if ! cmp "${doc-theme}/themes-generated.adoc" "$target/styx-themes-generated.adoc"
      then
        cp ${doc-theme}/themes-generated.adoc $target/styx-themes-generated.adoc --no-preserve=all
        cp ${doc-theme}/imgs/* $target/imgs/ --no-preserve=all
        echo "Themes documentation updated!"
      fi

      if ! cmp "${doc-library}/library-generated.adoc" "$target/library-generated.adoc"
      then
        cp ${doc-library}/library-generated.adoc $target/library-generated.adoc --no-preserve=all
        echo "Library documentation updated!"
      fi

    '';
}
