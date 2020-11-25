{ sources ? import ../../nix/sources.nix {}
, nixpkgs ? import sources.nixpkgs {}
, siteFile }:

pkgs.callPackage (import ./site-doc.nix) {
  site = pkgs.callPackage (import siteFile) { extraConf.siteUrl = "http://domain.org"; };
}
