{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells.renderers) docs styxlib;
  inherit (inputs.cells.data) styxthemes;
  inherit (inputs.cells.app.cli) styx;

  l = nixpkgs.lib // builtins;
in {
  run-tests = let
    run-main = test: ''
      echo "Run '${test}' ..."
      if nix build --impure --extra-experimental-features recursive-nix --extra-experimental-features impure-derivations --extra-experimental-features ca-derivations "${inputs.self + "#${nixpkgs.system}._automation.tests.${test}"}" --show-trace; then
        echo "\e[0;32m  success: ${test}\e[0m"
      else
        echo "\e[0;101m  failure: ${test}\e[0m"
        exit 1
      fi
    '';
    write-report = report: ''
      nix build "${inputs.self + "#${nixpkgs.system}._automation.tests.${report}"}" --show-trace
      . ./result
    '';
  in
    nixpkgs.writeScriptBin "run-tests" ''
      echo ""
      echo "------------------------------------------------"
      echo ""
      echo "\e[1;93mCode Linting:\e[0m"
      echo ""

      ${l.getExe nixpkgs.statix} check

      echo ""
      echo "------------------------------------------------"
      echo ""
      echo "\e[1;93mMain tests:\e[0m"
      echo ""

      ${run-main "new"}
      ${run-main "new-build"}
      ${run-main "new-theme"}
      ${run-main "deploy-gh-pages"}

      echo ""
      echo "------------------------------------------------"
      echo ""
      echo "\e[1;93mTheme tests:\e[0m"
      echo ""

      ${run-main "generic-templates-site"}
      ${run-main "agency-site"}
      ${run-main "ghostwriter-site"}
      ${run-main "hyde-site"}
      ${run-main "nix-site"}
      ${run-main "orbit-site"}
      ${run-main "showcase-site"}

      echo ""
      echo "------------------------------------------------"
      echo ""
      echo "\e[1;93mLibrary tests:\e[0m"
      echo ""

      ${write-report "lib-report"}
      ${write-report "lib-coverage"}

      echo ""
      echo "Finished"
    '';
  update-doc = let
    site = _: rec {
      loaded =
        (import inputs.self {
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
    doc-site = docs.site site {};
    doc-library = docs.library site {};
  in
    nixpkgs.writeScriptBin "update-doc" ''
      repoRoot="$(git rev-parse --show-toplevel)"
      target="$(readlink -f -- "$repoRoot/docs/")"

      if ! cmp "${doc-site}/themes-generated.adoc" "$target/styx-themes-generated.adoc"
      then
        cp ${doc-site}/themes-generated.adoc $target/styx-themes-generated.adoc --no-preserve=all
        cp ${doc-site}/imgs/* $target/imgs/ --no-preserve=all
        echo "Themes documentation updated!"
      fi

      if ! cmp "${doc-library}/library-generated.adoc" "$target/library-generated.adoc"
      then
        cp ${doc-library}/library-generated.adoc $target/library-generated.adoc --no-preserve=all
        echo "Library documentation updated!"
      fi

    '';
}
