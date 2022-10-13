inputs:
import inputs.nixpkgs.path {
  inherit (inputs.nixpkgs) system;
  overlays = [
    (self: _: {
      styx = inputs.nixpkgs.callPackage (inputs.self + /derivation.nix) {};
    })
  ];
}
