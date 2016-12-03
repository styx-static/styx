{ pkgs ? import <nixpkgs> {} }:

with pkgs.lib;
let

  styx = import ./. { inherit pkgs; };

  styx-themes = pkgs.styx-themes;

  mkThemeTest = theme: pkgs.callPackage (import "${styx-themes."${theme}"}/example/site.nix") {
    inherit styx;
    # Overriding the siteUrl to make all the url relatives for browsing directly from the store
    siteUrl = ".";
  };

in

{

  /* Open a site in a browser with:

       $BROWSER $(nix-build -A themes.agency ./test.nix)/index.html

  */
  themes = fold (a: acc: acc // { "${a}" = mkThemeTest a; }) {} [ "agency" "hyde" "orbit" "showcase" ];

}
