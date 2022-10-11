let
  inputs = {nixpkgs = import ./compat.nix;};
  cell = null;

  call = {
    inputs,
    cell,
  }: let
    inherit (inputs) nixpkgs;
    l = inputs.nixpkgs.lib // builtins;

    themesdirs = l.filterAttrs (_: v: v == "directory") (l.readDir ./.);
    themes = l.mapAttrs (k: _: ./. + "/${k}") themesdirs;
  in
    l.mapAttrs (_: v: nixpkgs.callPackage v {}) themes;
in
  call {inherit inputs cell;}
