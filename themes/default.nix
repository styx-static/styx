let
  pkgs = import <nixpkgs> {};
in
  pkgs.lib.mapAttrs (n: v:
    pkgs.callPackage (pkgs.fetchFromGitHub v) {}
  ) (import ./versions.nix)
