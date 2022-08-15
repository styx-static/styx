{
  description = "The purely functional static site generator in Nix expression language.";

  inputs.std.url = "github:divnix/std";
  inputs.std.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = {std, ...} @ inputs:
    std.growOn {
      inherit inputs;
      cellsFrom = ./src;
      organelles = with std.clades; [
        # ./app
        (installables "cli")
        (runnables "parsers")
        # ./renderers
        (functions "site")
        (functions "docs")
        (functions "styxlib")
        (functions "docslib")
        # ./data
        (functions "styxthemes")
        {
          name = "presets";
          clade = "paths";
        }
        # all ...
        (functions "types")
        # ./automation
        (devshells "devshells")
        (runnables "jobs")
      ];
    }
    # soil
    {
      bundlers = std.harvest inputs.self [["renderers" "site"] ["renderers" "docs"]];
      themes = std.harvest inputs.self ["data" "styxthemes"];
      templates = std.harvest inputs.self ["data" "presets"];
      hydraJobs = std.harvest inputs.self [["app" "cli"] ["app" "parsers"]];
      packages = std.harvest inputs.self ["automation" "jobs"];
      # checks = with (utils.lib.check-utils system);
      #   main-tests // {lib-tests = isEqual "lib-tests-${toString lib-tests.success}" "lib-tests-1";};
    };
}
