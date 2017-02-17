/*
  This file create a nixpkgs version having dev versions of styx and styx-themes

  It can be used to build dev versions of styx and styx-themes,

    nix-build nixpkgs -A styx
    nix-build nixpkgs -A styx-themes.showcase

  Or to use the dev packages when running a dev version styx command:

    $(nix-build ./nixpkgs --no-out-link -A styx)/bin/styx preview --in $(nix-build ./nixpkgs --no-out-link -A styx-themes.showcase)/example --arg pkgs "import ./nixpkgs"

*/


let
  pkgs = import <nixpkgs> {};

in 
with pkgs.lib;
with builtins;
let

  themesDir = ../themes;

  # generates a theme derivation from a theme folder
  mkTheme = themeName: pkgs.stdenv.mkDerivation {
    name = "styx-theme-${themeName}-dev";
    src  =  themesDir + "/${themeName}";
    installPhase = ''mkdir $out && cp -r $src/* $out/'';
  };

  pkgs' = pkgs // styx-pkgs;

  styx-pkgs = {
    # styx dev version
    styx = pkgs.callPackage ../derivation.nix {};

    # styx-themes dev version
    styx-themes = mapAttrs (n: v:
      mkTheme n
    ) (readDir ../themes);

    # updating callPackage so styx builder use the dev versions
    callPackage = pkgs.lib.callPackageWith (pkgs');
  };

in
  pkgs'
