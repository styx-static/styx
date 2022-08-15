{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  l = nixpkgs.lib // builtins;

  themes = l.filterAttrs (k: v: l.hasPrefix "styx-theme" k) inputs;
in
  l.mapAttrs (_: v: nixpkgs.callPackage v {}) themes
