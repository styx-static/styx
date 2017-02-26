{ lib }:
with lib;
{
  site = {
    title = mkOption {
      description = "Site title.";
      type = types.str;
      default = "Hyde";
    };
    description = mkOption {
      description = "Site description.";
      type = types.str;
      default = ''
        An elegant open source and mobile first theme for styx made by <a href="http://twitter.com/mdo">@mdo</a>. Originally made for Jekyll.
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

  colorScheme = mkOption {
    description = "Selects the color scheme. Set to `null` for default black scheme.";
    type = with types; nullOr (enum [ "08" "09" "0a" "0b" "0c" "0d" "0e" "0f" ]);
    default = null;
  };

  layout.reverse = mkEnableOption "reverse layout";

  itemsPerPage = mkOption {
    default = 3;
    description = "Number of posts per page.";
    type = types.int;
  };
}
