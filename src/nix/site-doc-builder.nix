{ pkgs ? import <nixpkgs> {}
, siteFile }:

pkgs.callPackage (import ./site-doc.nix) {
  site = pkgs.callPackage (import siteFile) { extraConf.siteUrl = "http://domain.org"; };
}
