{
  inputs,
  cell,
}: let
  l = inputs.nixpkgs.lib // builtins;

  inherit (inputs) nixpkgs;
  inherit (inputs.cells.renderers) styxlib;
  inherit (inputs.cells.data) styxthemes;
  inherit (inputs.cells.app.cli) styx;

  defaultEnv = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };

  themes-sites =
    l.mapAttrs' (
      n: v:
        l.nameValuePair "${n}-site"
        (styxlib.callStyxSite (import "${v}/example/site.nix") {
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
    new = nixpkgs.writeShellApplication {
      name = "styx-new-site";
      text = ''
        tmptestdir="$(mktemp -d)"
        mkdir -p "$tmptestdir"
        echo "staging test inside $tmptestdir ..."
        ${styx}/bin/styx new site my-site --in "$tmptestdir"
        ${styx}/bin/styx gen-sample-data  --in "$tmptestdir"/my-site
        rm -rf "$tmptestdir"
      '';
    };

    new-build = nixpkgs.writeShellApplication {
      name = "styx-new-site";
      text = ''
        tmptestdir="$(mktemp -d)"
        mkdir -p "$tmptestdir"
        echo "staging test inside $tmptestdir ..."
        ${styx}/bin/styx new site my-site --in "$tmptestdir"
        # shellcheck disable=SC2016
        sed -i 's/pages = rec {/pages = rec {\nindex = { path="\/index.html"; template = p: "<p>''${p.content}<\/p>"; content="test"; layout = t: "<html>''${t}<\/html>"; };/' "$tmptestdir"/my-site/site.nix
        ${styx}/bin/styx build --in "$tmptestdir"/my-site
        rm -rf "$tmptestdir"
      '';
    };
    new-theme = nixpkgs.writeShellApplication {
      name = "styx-new-theme";
      text = ''
        tmptestdir="$(mktemp -d)"
        mkdir -p "$tmptestdir"
        echo "staging test inside $tmptestdir ..."
        ${styx}/bin/styx new site my-site --in "$tmptestdir"
        ${styx}/bin/styx new theme my-theme --in "$tmptestdir"/my-site/themes
        rm -rf "$tmptestdir"
      '';
    };
    deploy-gh-pages = nixpkgs.writeShellApplication {
      name = "styx-deploy-gh";
      runtimeInputs = [nixpkgs.gitMinimal];
      text = ''
        tmptestdir="$(mktemp -d)"
        mkdir -p "$tmptestdir"
        echo "staging test inside $tmptestdir ..."
        cp -r ${styxthemes.showcase}/example/* "$tmptestdir"/
        export HOME=$tmptestdir
        export GIT_CONFIG_NOSYSTEM=1
        git config --global user.name  "styx test"
        git config --global user.email "styx@test.styx"
        git config --global init.defaultBranch main
        cd "$tmptestdir" && git init && git add . && git commit -m "init repo"
        ${styx}/bin/styx deploy --init-gh-pages --in "$tmptestdir"
        ${styx}/bin/styx deploy --gh-pages --in "$tmptestdir" --build-path "${themes-sites.showcase-site}/"
        rm -rf "$tmptestdir"
      '';
    };
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
