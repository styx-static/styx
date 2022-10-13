{
  inputs,
  cell,
}: let
  l = inputs.nixpkgs.lib // builtins;

  inherit (inputs) nixpkgs;
  inherit (inputs.cells.data) styxthemes;

  styxlib =
    ((import (inputs.self + /src)) {
      pkgs =
        nixpkgs
        // {
          styx = nixpkgs.callPackage (inputs.self + /derivation.nix) {};
        };
    })
    .lib;

  styx = nixpkgs.callPackage (inputs.self + /derivation.nix) {};

  callStyxSite = siteFnOrFile: let
    call = l.customisation.callPackageWith (import ./tests/compat.nix inputs);
  in
    call siteFnOrFile;

  defaultEnv = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };

  themes-sites =
    l.mapAttrs' (
      n: v:
        l.nameValuePair "${n}-site"
        (callStyxSite (import "${v}/example/site.nix") {
          extraConf = {
            siteUrl = ".";
            renderDrafts = true;
          };
        })
        .site
    )
    (l.filterAttrs (n: _: n != "__functor") styxthemes);
in
  {
    new = nixpkgs.runCommand "styx-new-site" defaultEnv ''
      mkdir $out
      ${styx}/bin/styx new site my-site --in $out
      ${styx}/bin/styx gen-sample-data  --in $out/my-site
    '';

    new-build = let
      site = nixpkgs.runCommand "styx-new-site" defaultEnv ''
        mkdir $out
        ${styx}/bin/styx new site my-site --in $out
        sed -i 's/pages = rec {/pages = rec {\nindex = { path="\/index.html"; template = p: "<p>''${p.content}<\/p>"; content="test"; layout = t: "<html>''${t}<\/html>"; };/' $out/my-site/site.nix
      '';
    in
      (callStyxSite (import "${site}/my-site/site.nix") {}).site;
    new-theme = nixpkgs.runCommand "styx-new-theme" defaultEnv ''
      mkdir $out
      ${styx}/bin/styx new site my-site --in $out
      ${styx}/bin/styx new theme my-theme --in $out/my-site/themes
    '';
    deploy-gh-pages = nixpkgs.runCommand "styx-deploy-gh" ({buildInputs = [nixpkgs.git];} // defaultEnv) ''
      mkdir $out
      cp -r ${styxthemes.showcase}/example/* $out/
      export HOME=$out
      export GIT_CONFIG_NOSYSTEM=1
      git config --global user.name  "styx test"
      git config --global user.email "styx@test.styx"
      cd $out && git init && git add . && git commit -m "init repo"
      ${styx}/bin/styx deploy --init-gh-pages --in $out
      ${styx}/bin/styx deploy --gh-pages --in $out --build-path "${themes-sites.showcase-site}/"
    '';
  }
  // themes-sites
  // {
    lib-report = let
      lsep = "====================\n";
      sep = "---\n";
      inSep = x: sep + x + sep;
      pretty = l.generators.toPretty {};
    in
      nixpkgs.writeText "lib-tests-report.sh" ''
        REPORT=$(cat <<'REPORT'
        ---
        Lib Tests Report
        ${l.toString ((l.length cell.libtests.results.success) + (l.length cell.libtests.results.failures))} tests run.
        - ${l.toString (l.length cell.libtests.results.success)} success(es).
        - ${l.toString (l.length cell.libtests.results.failures)} failure(s).
        ${l.optionalString ((l.length cell.libtests.results.failures) > 0) ''

          Failures details:

          ${lsep}${styxlib.template.mapTemplate (
              failure: let
                header = "${failure.name}${l.optionalString (failure ? index) ", example number ${l.toString failure.index}"}:\n";
                code = l.optionalString (failure ? literalCode) ("\ncode:\n" + inSep failure.literalCode);
                expected = "\nexpected:\n" + inSep "${pretty failure.expected}\n";
                got = "\ngot:\n" + inSep "${pretty failure.code}\n";
              in
                header + code + expected + got + lsep
            )
            cell.libtests.results.failures}''}
        ---
        REPORT
        )

        echo "$REPORT"
        ${l.optionalString ((l.length cell.libtests.results.failures) > 0) "exit 1"}
      '';

    lib-coverage = nixpkgs.writeText "lib-tests-coverage.sh" ''
      REPORT=$(cat <<'REPORT'
      ---
      Lib Tests Coverage
      ${l.toString (l.length cell.libtests.missingTests)} functions missing tests:

      ${styxlib.template.mapTemplate (f: " - ${f}") cell.libtests.missingTests}
      ---
      REPORT
      )

      echo "$REPORT"
    '';
  }
