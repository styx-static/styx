pkgs:
let
  # nixpkgs lib
  nixLib = pkgs.lib // builtins;

  # Styx lib
  template   = import ./template.nix nixLib;
  utils      = import ./utils.nix nixLib;
  posts      = import ./posts.nix nixLib pkgs;
  generation = import ./generation.nix nixLib;

in
  {
    inherit nixLib template utils posts generation;
  }
  // nixLib
  // template // utils // posts // generation
