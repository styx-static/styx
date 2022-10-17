{
  inputs,
  cell,
}: let
  l = nixpkgs.lib // builtins;
  inherit (inputs) nixpkgs;
  inherit (inputs.std) lib presets;
in
  l.mapAttrs (_: lib.dev.mkShell) {
    default = {
      name = "Styx";
      nixago = [
        (presets.nixago.conform {configData = {inherit (inputs) cells;};})
        (presets.nixago.treefmt {
          configData.formatter = {
            py = {
              includes = ["*.py"];
              command = "black";
            };
            prettier = {
              excludes = ["*.min.js"];
            };
          };
          packages = [nixpkgs.black];
        })
        presets.nixago.editorconfig
        presets.nixago.lefthook
      ];
      commands = [
        {
          category = "dev";
          package = nixpkgs.pandoc;
        }
        {
          category = "dev";
          package = nixpkgs.asciidoctor;
        }
        {
          category = "dev";
          package = nixpkgs.statix;
        }
      ];
      imports = [];
    };
  }
