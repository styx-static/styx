{ pkgs ? import <nixpkgs> {}
, siteFile
, extraConf }:

pkgs.callPackage (import siteFile) { inherit extraConf; }
