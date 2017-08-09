/*
  This file can be used to build a styx site directly with nix-build.

    $ nix-build

  or

    $ nix-build /path/to/the/styx/site/

  WARNING: This file use the system wide installed nixpkgs, and will pass styx version matching <nixpkgs>.
  In case styx was installed directly with nix-env, you MUST explicitely set the styx version here.

*/
{ pkgs ? import <nixpkgs> {} }:

(pkgs.callPackage (import ./site.nix) {}).site
