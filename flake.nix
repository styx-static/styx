{
  description = "The purely functional static site generator in Nix expression language.";

  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { self, utils, nixpkgs, ... }: 
    utils.lib.eachDefaultSystem (system: 
      let
        pkgs = import nixpkgs { inherit system; };
        styx = pkgs.callPackage ./derivation.nix {};
      in
      {
        packages = { inherit styx; };
        defaultPackage = styx;

        lib = import ./src/lib { inherit pkgs styx; };
      }
    );

}
