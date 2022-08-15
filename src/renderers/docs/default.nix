{
  inputs,
  cell,
}: let
  inherit (cell) types styxlib;
in {
  theme = siteFn:
    import ./theme.nix {
      inherit inputs cell;
      site = types.site (styxlib.callStyxSite siteFn {});
    };
  library = siteFn:
    import ./library.nix {
      inherit inputs cell;
      site = types.site (styxlib.callStyxSite siteFn {});
    };
}
