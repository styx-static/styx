/*
Basic tests for Styx

run all tests with:

  nix-build tests

Open a theme example site in a browser with (many links will be broken):

  $BROWSER $(nix-build -A showcase-site ./tests)/index.html
*/
let
  pkgs = import ../nixpkgs;
in
  with pkgs.lib; let
    styx-themes = import pkgs.styx.themes;

    themes-sites =
      mapAttrs' (
        n: v:
          nameValuePair "${n}-site"
          (pkgs.callPackage (import "${v}/example/site.nix") {
            extraConf = {
              siteUrl = ".";
              renderDrafts = true;
            };
          })
          .site
      )
      (filterAttrs (n: _: n != "__functor")
        styx-themes);

    defaultEnv = {
      preferLocalBuild = true;
      allowSubstitutes = false;
    };
  in
    rec {
      inherit (pkgs) styx;

      new = pkgs.runCommand "styx-new-site" defaultEnv ''
        mkdir $out
        ${styx}/bin/styx new site my-site --in $out
        ${styx}/bin/styx gen-sample-data  --in $out/my-site
      '';

      new-build = let
        site = pkgs.runCommand "styx-new-site" defaultEnv ''
          mkdir $out
          ${styx}/bin/styx new site my-site --in $out
          sed -i 's/pages = rec {/pages = rec {\nindex = { path="\/index.html"; template = p: "<p>''${p.content}<\/p>"; content="test"; layout = t: "<html>''${t}<\/html>"; };/' $out/my-site/site.nix
        '';
      in
        (pkgs.callPackage (import "${site}/my-site/site.nix") {}).site;

      new-theme = pkgs.runCommand "styx-new-theme" defaultEnv ''
        mkdir $out
        ${styx}/bin/styx new site my-site --in $out
        ${styx}/bin/styx new theme my-theme --in $out/my-site/themes
      '';

      deploy-gh-pages = pkgs.runCommand "styx-deploy-gh" ({buildInputs = [pkgs.git];} // defaultEnv) ''
        mkdir $out
        cp -r ${styx-themes.showcase}/example/* $out/
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
