{ pkgs ? import <nixpkgs> {} }:
let
  styx = import ./. { inherit pkgs; };
  styx-themes = pkgs.styx-themes;
in
{
  showcase = pkgs.callPackage (import "${styx-themes.showcase}/example/site.nix") {
    inherit styx;
  };
}
