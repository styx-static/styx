{ lib }:
with lib;
{
  site = {
    title = mkOption {
      description = "Site title.";
      type = types.str;
      default = "styx@styx ~ $";
    };
    description = mkOption {
      description = "Site description.";
      type = types.str;
      default = ''
        Nix blog description
      '';
    };
    copyright = mkOption {
      description = "Site copyright.";
      type = types.str;
      default = ''
        &copy; 2017. All rights reserved. 
      '';
    };
  };

  # defaults
  lib.jquery.enable = true;
  lib.bootstrap.enable = true;
  lib.font-awesome.enable = true;
  lib.googlefonts = [
    "Inconsolata"
    "Open+Sans"
    "Roboto"
    "Montserrat"
    "Concert One"
  ];
}
