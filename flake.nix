{
  description = "The purely functional static site generator in Nix expression language.";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  inputs.std.url = "github:divnix/std";
  inputs.std.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    self,
    std,
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
      templates = std.pick self ["data" "presets"];
      lib = std.harvest self ["renderers" "styxlib"];
    };
}
