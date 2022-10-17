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
  # configuration set
  styxlib = import ./src/renderers/styxlib.nix {
    inputs = {
      nixpkgs = pkgs;
      cells = {
        data.styxthemes = import ./themes-compat.nix;
        app = {
          cli = {inherit (pkgs) styx;};
          parsers = import ./src/app/parsers.nix {
            inputs = {nixpkgs = pkgs;};
            cell = null;
          };
        };
      };
    };
    cell = null;
  };

  loaded = styxlib.themes.load {
    lib = styxlib;
    inherit themes env config;
  };
in
  pkgs.lib.trace "site config: ${pkgs.lib.generators.toPretty {} loaded.lib.config}" {
    inherit (loaded) lib conf decls;
    themes = loaded;
  }
