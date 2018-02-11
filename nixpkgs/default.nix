/*
  This file create a nixpkgs version having dev versions of styx and styx-themes

  It can be used to build dev versions of styx and styx-themes,

    nix-build nixpkgs -A styx
    nix-build nixpkgs -A styx-themes.showcase

  Or to use the dev packages when running a dev version styx command:

    $(nix-build ./nixpkgs --no-out-link -A styx)/bin/styx preview --in $(nix-build ./nixpkgs --no-out-link -A styx-themes.showcase)/example --arg pkgs "import ./nixpkgs"

*/


let
  pkgs = import (import ../nix/sources.nix {}).nixpkgs {};

  styx-pkgs = rec {
    # styx dev version
    styx = pkgs.callPackage ../derivation.nix {};

    # updating callPackage so styx builder use the dev versions
    #callPackage = pkgs.lib.callPackageWith (pkgs');
  };

in
  pkgs // styx-pkgs
