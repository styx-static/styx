/*
Expression to generate the themes documentation
*/
{pkgs ? import ../nixpkgs}:
with pkgs.lib; let
  styx = import pkgs.styx {
    inherit pkgs;
    themes = reverseList (attrValues (import pkgs.styx.themes));
    env = {
      data = {};
      pages = {};
    };
    config = [{siteUrl = "http://domain.org";}];
  };

  inherit (styx.themes) conf files templates env lib;
in
  pkgs.callPackage ../src/nix/site-doc.nix {
    inherit styx;
    site = {
      inherit (styx.themes) conf lib files templates;
      inherit (styx.themes.env) data pages;
    };
  }
