pkgs:
let
  # nixpkgs lib
  nixLib = pkgs.lib // builtins;

  # Styx lib
  data       = import ./data.nix nixLib pkgs;
  generation = import ./generation.nix nixLib pkgs;
  template   = import ./template.nix nixLib;
  themes     = import ./themes.nix nixLib;
  utils      = import ./utils.nix nixLib;
  proplist   = import ./proplist.nix nixLib;
  taxonomy   = import ./taxonomy.nix nixLib;

in
  {
    inherit nixLib data generation template themes utils proplist taxonomy;
  }
  // nixLib
  // data // generation // template // themes // utils // taxonomy
