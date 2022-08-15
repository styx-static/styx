{
  inputs,
  cell,
}: let
  l = nixpkgs.lib // builtins;
  inherit (inputs) nixpkgs;
  inherit (inputs.std) std;
  inherit (inputs.cells) app;
in
  l.mapAttrs (_: std.lib.mkShell) {
    default = {
      name = "Styx";
      nixago = [
        (std.nixago.conform {configData = {inherit (inputs) cells;};})
        (std.nixago.treefmt {
          configData.formatter.py = {
            includes = ["*.py"];
            command = "black";
          };
          packages = [nixpkgs.black];
        })
        std.nixago.editorconfig
        # std.nixago.mdbook
        std.nixago.lefthook
        std.nixago.adrgen
      ];
      commands = [
        {
          category = "dev";
          package = app.cli.styx;
        }
        {
          category = "dev";
          package = app.parsers.markdown;
        }
        {
          category = "dev";
          package = app.parsers.asciidoc;
        }
        {
          category = "legal";
          package = nixpkgs.reuse;
        }
      ];
      imports = [std.devshellProfiles.default];
    };
  }
