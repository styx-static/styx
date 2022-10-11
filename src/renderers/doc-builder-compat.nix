{
  sources ? import ../../nix/sources.nix {},
  nixpkgs ?
    import sources.nixpkgs {
      overlays = [
        (self: _: {
          styx.outPath = ../default.nix;
          styx.themes = ../data/styxthemes;
        })
      ];
    },
  siteFile,
}: let
  docslib = import ./docslib.nix {
    inputs = {
      inherit nixpkgs;
      self = ../..;
    };
    cell = {inherit docslib;};
  };
  docs = import ./docs/default.nix {
    inputs = {
      inherit nixpkgs;
      self = ../..;
    };
    cell = {inherit docslib;};
  };
in
  docs.theme siteFile {extraConf.siteUrl = "http://domain.org";}
