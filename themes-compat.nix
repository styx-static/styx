/*
Callers:
  - site.nix (import pkgs.styx.themes) -- musn't be impure within this flake, e.g. tests
  - bin/styx
*/
let
  inputs = {nixpkgs = import ./pkgs.nix;};
  cell = null;

  call = {
    inputs,
    cell,
  }: let
    inherit (inputs) nixpkgs;
    l = inputs.nixpkgs.lib // builtins;

    themesdirs = l.filterAttrs (_: v: v == "directory") (l.readDir ./src/data/styxthemes);
    themes = l.mapAttrs (k: _: ./src/data/styxthemes + "/${k}") themesdirs;
  in
    l.mapAttrs (_: v: nixpkgs.callPackage v {}) themes;
in
  call {inherit inputs cell;}
