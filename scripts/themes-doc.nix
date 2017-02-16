/* Expression to generate the themes documentation
*/
{ pkgs ? import ../nixpkgs }:

with pkgs.lib;

let
  styxLib = pkgs.callPackage pkgs.styx.lib {};
  mockSite = { data = {}; pages = {}; };
  themes = reverseList (attrValues (filterAttrs (k: v: isDerivation v) pkgs.styx-themes));
  themesData = (styxLib.themes.load {
    inherit styxLib themes;
    conf.extra = [ { siteUrl = "http://domain.org"; } ];
    templates.extraEnv = mockSite;
  }) // mockSite;


in pkgs.callPackage ../src/nix/site-doc.nix {
  site = {
    inherit (themesData) conf lib files templates;
    inherit (mockSite) data pages;
    inherit themes;
  };
}
