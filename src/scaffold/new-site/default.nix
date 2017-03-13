/*
  This file can be used to build a styx site directly with nix-build.

    $ nix-build

  or

    $ nix-build /path/to/the/styx/site/

*/
{ pkgs ? import <nixpkgs> {} }:

(pkgs.callPackage (import ./site.nix) {}).site
