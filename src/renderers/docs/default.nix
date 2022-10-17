{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;

  l = inputs.nixpkgs.lib // builtins;

  callStyxSite = siteFnOrFile: let
    call = l.customisation.callPackageWith ({pkgs = nixpkgs;} // nixpkgs);
  in
    call siteFnOrFile;
in {
  site = siteFn: args: let
    site' = callStyxSite siteFn args;
  in
    import ./site.nix {
      inherit inputs cell;
      site = site' // {loaded = site'.loaded or site'.styx.themes;};
    };
  library = siteFn: args: let
    site' = callStyxSite siteFn args;
  in
    import ./library.nix {
      inherit inputs cell;
      site = site' // {loaded = site'.loaded or site'.styx.themes;};
    };
}
