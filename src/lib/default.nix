{ lib, pkgs }:
let
  # nixpkgs lib
  base = lib // builtins;

  # Styx lib
  data       = (import ./data.nix) base pkgs;
  pages      = import ./pages.nix base;
  generation = (import ./generation.nix) base pkgs;
  template   = import ./template.nix base;
  themes     = import ./themes.nix base;
  utils      = import ./utils.nix base;
  proplist   = import ./proplist.nix base;

in
  {
    inherit base data generation template themes utils proplist pages;
  }
  // base
  // data // generation // template // themes // utils // proplist // pages
