let
  pkgs = import <nixpkgs> {};
  themesdirs = pkgs.lib.filterAttrs (_: v: v == "directory") (builtins.readDir ./.);
  themes = pkgs.lib.mapAttrs (k: _: ./. + "/${k}") themesdirs;
in
  pkgs.lib.mapAttrs (_: v: pkgs.callPackage v {}) themes
