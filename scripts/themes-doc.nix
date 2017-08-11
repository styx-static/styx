/* Expression to generate the themes documentation
*/
{ pkgs ? import ../nixpkgs }:

with pkgs.lib;

let
  styxLib = with pkgs; callPackage styx.lib styx;

  mockSite = { data = {}; pages = {}; };

  themes = reverseList (attrValues (import pkgs.styx.themes));

  themesData = (styxLib.themes.load {
    inherit themes styxLib;
    extraConf = [ { siteUrl = "http://domain.org"; } ];
    extraEnv = mockSite;
  });
in pkgs.callPackage ../src/nix/site-doc.nix {
  site = {
    inherit (themesData) conf lib files templates;
    inherit (mockSite) data pages;
    inherit themes;
  };
}
