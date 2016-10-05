let
  # nixpkgs lib
  nixpkgsLib = import ./nixpkgs-lib.nix;

  # Styx lib
  template   = import ./template.nix;
  utils      = import ./utils.nix;
  posts      = import ./posts.nix;
  generation = import ./generation.nix;

in
  {
    inherit nixpkgsLib template utils posts generation; 
  }
  // nixpkgsLib
  // template // utils //posts // generation
