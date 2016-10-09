pkgs:
let
  # nixpkgs lib
  nixLib = pkgs.lib // builtins;

  # Styx lib
  content    = import ./content.nix nixLib pkgs;
  generation = import ./generation.nix nixLib pkgs;
  template   = import ./template.nix nixLib;
  themes     = import ./themes.nix nixLib;
  utils      = import ./utils.nix nixLib;

in
  {
    inherit nixLib content generation template themes utils;
  }
  // nixLib
  // content // generation // template // themes // utils
