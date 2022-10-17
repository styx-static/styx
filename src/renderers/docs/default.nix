{
  inputs,
  cell,
}: let
  inherit (inputs.cells.renderers) styxlib;
  inherit (inputs) nixpkgs;

  l = inputs.nixpkgs.lib // builtins;
in {
  site = siteFn: args: let
    site' = styxlib.callStyxSite siteFn args;
  in
    import ./site.nix {
      inherit inputs cell;
      site = site' // {loaded = site'.loaded or site'.styx.themes;};
    };
  library = siteFn: args: let
    site' = styxlib.callStyxSite siteFn args;
  in
    import ./library.nix {
      inherit inputs cell;
      site = site' // {loaded = site'.loaded or site'.styx.themes;};
    };
}
