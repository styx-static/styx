/*
This function sits at the root of the `styx` derivation for compatibility reasons
when styx is invoked with 'import pkgs.styx'

Therefore, the entire source tree is copied into the derivation.

Callers:
  - site.nix (import pkgs.styx) -- musn't be impure within this flake, e.g. tests
*/
{
  themes ? [],
  config ? [],
  env ? {},
  pkgs ? import ./pkgs.nix,
}: let
  # base library
  baseLib = pkgs.lib // builtins;

  # temporary library
  tempLib =
    {
      conf = import ./src/lib/conf.nix {lib = baseLib;};
      utils = import ./src/lib/utils.nix {lib = baseLib;};
      themes = import ./src/lib/themes.nix {lib = baseLib;};
    }
    // pkgs.lib
    // builtins;

  loadDecls = cs: let
    f = c:
      if tempLib.utils.isPath c
      then tempLib.utils.importApply c {inherit pkgs lib;}
      else c;
  in
    tempLib.utils.merge (map f cs);

  decls = loadDecls ([./styx-config.nix] ++ config);

  # configuration set
  conf = tempLib.conf.parseDecls {
    optionFn = o: o.default;
    inherit decls;
  };
  lib = import ./src/lib {inherit pkgs conf;};

  themes' = lib.themes.load {
    inherit themes lib env decls;
  };
in {
  inherit lib conf decls;
  themes = themes';
}
