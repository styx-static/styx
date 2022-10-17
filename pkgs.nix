let
  lock = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile (toString ./flake.lock)));

  inputs = {
    nixpkgs = import (builtins.fetchTree lock.nodes.nixpkgs.locked) {
      system =
        builtins.currentSystem
        # currently needed for (pure) tests -> only work on that platfrom
        or "x86_64-linux";
    };
    self = ./.;
  };

  cell = {};
in
  inputs.nixpkgs.extend (_: _: {
    inherit
      (import ./src/app/cli.nix {inherit inputs cell;})
      styx
      ;
  })
