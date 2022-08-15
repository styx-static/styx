{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  l = nixpkgs.lib // builtins;

  themesdirs = l.filterAttrs (_: v: v == "directory") (l.readDir ./styxthemes);
  themes = l.mapAttrs (k: _: ./styxthemes + "/${k}") themesdirs;
in
  l.mapAttrs (_: v: nixpkgs.callPackage v {}) themes
