{ themes ? []
, config ? []
, env    ? {}
, pkgs   ? import <nixpkgs> {} }:

let
  # base library
  baseLib = pkgs.lib // builtins;

  # temporary library
  tempLib = {
    conf   = import ./lib/conf.nix   { lib = baseLib; };
    utils  = import ./lib/utils.nix  { lib = baseLib; };
    themes = import ./lib/themes.nix { lib = baseLib; };
  } // pkgs.lib // builtins;

  loadDecls = cs:
    let
      f = c:
        if   tempLib.utils.isPath c 
        then tempLib.utils.importApply c { inherit pkgs; lib = baseLib; }
        else c;
    in tempLib.utils.merge (map f cs);

  decls = loadDecls ([ ./styx-config.nix ] ++ config);

  # configuration set
  conf = tempLib.conf.parseDecls { optionFn = o: o.default; inherit decls; };
  lib  = import ./lib { inherit pkgs conf; };

  themes' = lib.themes.load {
    inherit themes lib env decls;
  };

in {
  inherit lib conf decls;
  themes = themes';
}
