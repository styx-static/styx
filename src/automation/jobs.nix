{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells.renderers) docs styxlib;
  inherit (inputs.cells.data) styxthemes;

  l = nixpkgs.lib // builtins;
in {
  update-doc = let
    site = {...}: rec {
      loaded = styxlib.themes.load {
        themes = l.reverseList (l.attrValues styxthemes);
        env = {inherit data pages;};
        config = [{siteUrl = "http://domain.org";}];
      };
      data = {};
      pages = {};
      site = styxlib.generation.mkSite {
        pageList = styxlib.generation.pagestolist {inherit pages;};
      };
    };
    doc-theme = docs.theme site;
    doc-library = docs.library site;
  in
    nixpkgs.writeScriptBin "update-doc" ''
      repoRoot="$(git rev-parse --show-toplevel)"
      target="$(readlink -f -- "$repoRoot/docs/")"

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
