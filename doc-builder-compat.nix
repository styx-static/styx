/*
Callers:
  - bin/styx
*/
{siteFile}: let
  inputs = {
    nixpkgs = import ./pkgs.nix;
    self = toString ./.;
  };
  cell = {inherit docslib;};

  docslib = import ./src/doc/docslib.nix {inherit inputs cell;};
  docs = import ./src/doc/docs/default.nix {inherit inputs cell;};
in
  docs.theme siteFile {extraConf.siteUrl = "http://domain.org";}
