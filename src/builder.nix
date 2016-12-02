{ pkgs ? import <nixpkgs> {}
, siteUrl ? null
, siteFile }:

pkgs.callPackage (import siteFile) { inherit siteUrl; }
