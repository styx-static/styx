{ lib, styx, runCommand, writeText, ... }:
let
  # nixpkgs lib
  base = lib // builtins;
  pkgs = { inherit styx runCommand writeText; };

  # Styx lib
  data       = (import ./data.nix) base pkgs;
  pages      = import ./pages.nix base;
  generation = (import ./generation.nix) base pkgs;
  template   = import ./template.nix base;
  themes     = import ./themes.nix base;
  utils      = import ./utils.nix base;
  proplist   = import ./proplist.nix base;
  conf       = import ./conf.nix base;

in
  {
    inherit base data generation template themes utils proplist pages conf;
  }
  // base
  // data // generation // template // themes // utils // proplist // pages // conf
