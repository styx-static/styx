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
      ];
      cellBlocks = with std.blockTypes; [
        # ./_automation
        (devshells "devshells")
      ];
    }
    # soil
    {
      formatter = std.harvest nixpkgs.legacyPackages ["alejandra"];
      devShells = std.harvest self ["_automation" "devshells"];
    }
    (utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        styx = pkgs.callPackage ./derivation.nix {};
      in {
        packages = {inherit styx;};
        defaultPackage = styx;
        lib = import ./src/lib {inherit pkgs styx;};
      }
    ));
}
