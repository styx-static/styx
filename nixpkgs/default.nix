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

in with pkgs.lib;
let

  # dev folder
  styx-dev = ../../.;

  # generates a theme derivatoin from a theme folder
  mkTheme = themeName: pkgs.stdenv.mkDerivation {
    name = "styx-theme-${themeName}-dev";
    src  =  styx-dev + "/styx-themes/${themeName}";
    installPhase = ''mkdir $out && cp -r $src/* $out/'';
  };

  # extracting nixpkgs styx-themes list
  themes = attrNames (filterAttrs (k: v: isDerivation v) pkgs.styx-themes);

  # extra themes folders to add to the set, as a list of strings
  extraThemes = [
    "generic-templates"
  ];

  pkgs' = pkgs // styx-pkgs;

  styx-pkgs = {
    # styx dev version
    styx = pkgs.callPackage ../derivation.nix {};

    # styx-themes dev version
    styx-themes = fold (t: acc: acc // { "${t}" = mkTheme t; }) {} (themes ++ extraThemes);

    # updating callPackage so styx builder use the dev versions
    callPackage = pkgs.lib.callPackageWith (pkgs');
  };

in
  pkgs'
