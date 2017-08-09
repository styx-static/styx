let
  pkgs = import <nixpkgs> {};
in
  with pkgs.lib;
  with builtins;
  mapAttrs (themeName: v:
    import (./. + "/${themeName}") {}
  ) (filterAttrs (n: v: v == "directory") (readDir ./.))
