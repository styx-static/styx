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

  docslib = import ./src/renderers/docslib.nix {inherit inputs cell;};
  docs = import ./src/renderers/docs/default.nix {inherit inputs cell;};
in
  docs.site siteFile {extraConf.siteUrl = "http://domain.org";}
