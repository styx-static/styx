pkgs:
let

  lib = {
    inherit base data generation template themes utils proplist pages conf initStyx;
  } // base // data // generation // template // themes // utils // proplist // pages // conf;

  # nixpkgs lib
  base = pkgs.lib // builtins;

  # Styx lib
  data       = import ./data.nix {inherit lib pkgs; conf = {};};
  generation = import ./generation.nix {inherit lib pkgs;};
  pages      = import ./pages.nix {inherit lib;};
  template   = import ./template.nix {inherit lib;};
  themes     = import ./themes.nix {inherit lib;};
  utils      = import ./utils.nix {inherit lib;};
  proplist   = import ./proplist.nix {inherit lib;};
  conf       = import ./conf.nix {inherit lib;};

  initStyx = {
    themes ? [],
    config ? [],
    env ? {}
  }: let
    decls = conf.mergeConfs ([ ./styx-config.nix ] ++ config);
    conf = conf.parseDecls { optionFn = o: o.default; inherit decls; };
    lib = let data = import ./data.nix {inherit conf lib pkgs;};
    in lib // {inherit data;} // data;
    themes = lib.themes.load {inherit themes lib env decls;};
  in {
    inherit themes; # legacy interface
    inherit (themes) docs files lib decls env conf templates;
  };

in lib
