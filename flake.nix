{
  description = "The purely functional static site generator in Nix expression language.";

  inputs.utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  inputs.std.url = "github:divnix/std";
  inputs.std.inputs.nixpkgs.follows = "nixpkgs";
  inputs.std.inputs.mdbook-kroki-preprocessor.follows = "std/blank";

  outputs = {
    self,
    std,
    utils,
    nixpkgs,
  } @ inputs:
    std.growOn {
      inherit inputs;
      cellsFrom = std.incl ./src [
        ./src/_automation
        ./src/data
        ./src/renderers
        ./src/app
      ];
      cellBlocks = with std.blockTypes; [
        # ./src/_automation
        (devshells "devshells")
        (runnables "tasks")
        (runnables "tests")
        {
          name = "libtests";
          type = "unspecified";
        }
        # ./src/data
        (functions "styxthemes")
        {
          name = "presets";
          type = "templates";
        }
        # ./src/renderers
        (functions "docs")
        (functions "docslib")
        (functions "styxlib")
        # ./src/app
        (installables "cli")
        (runnables "parsers")
      ];
    }
    # soil
    {
      formatter = std.harvest nixpkgs.legacyPackages ["alejandra"];
      devShells = std.harvest self ["_automation" "devshells"];
      packages = std.harvest self [["_automation" "tasks"] ["app" "cli"]];
      hydraJobs = std.winnow (n: _: n != "default") self ["app" "cli"];
      templates = (std.harvest inputs.self ["data" "presets"]).x86_64-linux; # picked one system; doesn't matter
    }
    (utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        inherit (self.packages.${system}) styx;
      in {
        lib = import ./src/lib {inherit pkgs styx;};
      }
    ));
}
