/* Basic tests for Styx

   run all tests with:

     nix-build tests

   Open a theme example site in a browser with (many links will be broken):

     $BROWSER $(nix-build -A showcase-site ./tests)/index.html

*/
let pkgs = import ../nixpkgs;
in

with pkgs.lib;
let

  mkThemeTest = theme: (pkgs.callPackage (import "${pkgs.styx-themes."${theme}"}/example/site.nix") {
    inherit (pkgs) styx;
    extraConf = {
      siteUrl = ".";
      renderDrafts = true;
    };
  }).site;

  themes-sites = fold (a: acc: acc // { "${a}-site" = mkThemeTest a; }) {} themes;
 
  # extracting nixpkgs styx-themes list
  themes = attrNames (filterAttrs (k: v: isDerivation v) pkgs.styx-themes);

in

rec {

  inherit (pkgs) styx styx-themes;

  new = pkgs.runCommand "styx-new-site" {} ''
    mkdir $out
    ${styx}/bin/styx new site my-site --in $out
    ${styx}/bin/styx gen-sample-data  --in $out
  '';
  
  new-build = 
    let site = pkgs.runCommand "styx-new-site" { } ''
      mkdir $out
      ${styx}/bin/styx new site my-site --in $out
      sed -i 's/pages = rec {/pages = rec {\nindex = { path="\/index.html"; template = p: "<p>''${p.content}<\/p>"; content="test"; layout = t: "<html>''${t}<\/html>"; };/' $out/my-site/site.nix
    '';
    in (pkgs.callPackage (import "${site}/my-site/site.nix") { inherit styx; }).site;

  new-theme = pkgs.runCommand "styx-new-theme" {} ''
    mkdir $out
    ${styx}/bin/styx new site my-site --in $out
    ${styx}/bin/styx new theme my-theme --in $out/my-site/themes
  '';

  serve = pkgs.runCommand "styx-serve" { buildInputs = [ pkgs.curl ]; } ''
    mkdir $out
    ${styx}/bin/styx serve --build-path ${themes-sites.showcase-site} --detach
    sleep 3
    curl -I 127.0.0.1:8080/index.html > $out/result
  '';

  deploy-gh-pages = pkgs.runCommand "styx-deploy-gh" { buildInputs = [ pkgs.git pkgs.tree ]; } ''
    mkdir $out
    cp -r ${styx-themes.showcase}/example/* $out/
    export HOME=$out
    export GIT_CONFIG_NOSYSTEM=1
    git config --global user.name  "styx test"
    git config --global user.email "styx@test.styx"
    cd $out && git init && git add . && git commit -m "init repo"
    ${styx}/bin/styx deploy --init-gh-pages --in $out
    tree
    ${styx}/bin/styx deploy --gh-pages --in $out --build-path "${themes-sites.showcase-site}/"
  '';

} // themes-sites
