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
  theme = siteFn:
    import ./theme.nix {
      inherit inputs cell;
      site = callStyxSite siteFn {};
    };
  library = siteFn:
    import ./library.nix {
      inherit inputs cell;
      site = callStyxSite siteFn {};
    };
}
