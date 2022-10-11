# TODO: remove when ./styxtheme/default.nix satifies the std calling contract
# currently this file shadows it
{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  l = inputs.nixpkgs.lib // builtins;

  themesdirs = l.filterAttrs (_: v: v == "directory") (l.readDir ./styxthemes);
  themes = l.mapAttrs (k: _: ./styxthemes + "/${k}") themesdirs;
in
  l.mapAttrs (_: v: nixpkgs.callPackage v {}) themes
