let
  inputs = {nixpkgs = import ./compat.nix;};
  cell = null;

  __functor = _: {
    inputs,
    cell,
  }: let
    inherit (inputs) nixpkgs;
    l = inputs.nixpkgs.lib // builtins;

    themesdirs = l.filterAttrs (_: v: v == "directory") (l.readDir ./.);
    themes = l.mapAttrs (k: _: ./. + "/${k}") themesdirs;
  in
    l.mapAttrs (_: v: nixpkgs.callPackage v {}) themes;
in
  {
    inherit __functor;
  }
  // (__functor null {inherit inputs cell;})
