{
  sources ? import ../../nix/sources.nix {},
  nixpkgs ? import sources.nixpkgs {},
  siteFile,
}: let
  site = (import siteFile) {extraConf.siteUrl = "http://domain.org";};
in
  pkgs.callPackage (import ./site-doc.nix) {
    inherit (site) styx;
    site = {
      inherit (styx.themes) conf lib files templates;
      inherit (styx.themes.env) data pages;
    };
  }
