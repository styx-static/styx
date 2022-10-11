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
  run-tests = let
  in
    nixpkgs.writeScriptBin "run-tests" ''
      echo ""

      echo "Main tests:"
      if nix-build "${inputs.self + /tests}" --no-out-link --show-trace; then
        echo "  success"
      else
        echo "  failure"
        exit 1
      fi

      echo ""

      echo "Library tests:"

      if [ "$(nix-instantiate --eval -A success ${inputs.self + /tests/lib.nix} --read-write-mode)" = "true" ]; then
        echo "  success";
      else
        cat $(nix-build --no-out-link -A report ${inputs.self + /tests/lib.nix})
        exit 1
      fi

      echo ""
      echo "Finished"
    '';
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
