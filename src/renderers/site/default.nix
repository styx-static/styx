{
  inputs,
  cell,
}: let
  inherit (cell) types library;

  l = inputs.nixpkgs.lib // builtins;
in
  l.mapAttrs (_: r: (types.site r).site) {
    default = siteFn: library.callStyxSite siteFn {};
    withDrafts = siteFn: library.callStyxSite siteFn {withDrafts = true;};
  }
