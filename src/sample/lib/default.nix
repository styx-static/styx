pkgs:
let
  # nixpkgs lib
  nixLib = pkgs.lib // builtins;

  # Styx lib
  template   = import ./template.nix nixLib;
  utils      = import ./utils.nix nixLib;
  content    = import ./content.nix nixLib pkgs;
  generation = import ./generation.nix nixLib pkgs;

in
  {
    inherit nixLib template utils content generation;
  }
  // nixLib
  // template // utils // content // generation
