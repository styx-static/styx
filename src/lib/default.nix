{ pkgs, conf }@args:
let

  # nixpkgs lib
  base = pkgs.lib // builtins;

  args' = args // { lib = base; };

  # Styx lib
  data       = import ./data.nix args';
  pages      = import ./pages.nix args';
  generation = import ./generation.nix args';
  template   = import ./template.nix args';
  themes     = import ./themes.nix args';
  utils      = import ./utils.nix args';
  proplist   = import ./proplist.nix args';
  conf       = import ./conf.nix args';

in
  {
    inherit base data generation template themes utils proplist pages conf;
  }
  // base
  // data // generation // template // themes // utils // proplist // pages // conf
