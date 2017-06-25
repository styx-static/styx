{ lib }:
with lib;
{
  
/* General settings
*/
  site = {
    title = mkOption {
      default = "The Agency";
      type = types.str;
      description = "Title of the site.";
    };
    author = mkOption {
      default = "Your name";
      type = types.str;
      description = "Content of the author `meta` tag.";
    };
    description = mkOption {
      default = "Your description";
      type = types.str;
      description = "Content of the description `meta` tag.";
    };
  };

/* Footer

   This section control the links and copyright in the footer
*/
  footer = {
    copyright = mkOption {
      default = "Published under the Apache License 2.0.";
      description = "Footer copyright text.";
      type = types.str;
    };
    social = mkOption {
      description = "Social media links to display in the footer.";
      type = with types; listOf attrs;
      default = [];
      example = [
        { icon = "fa-twitter";  link ="#"; }
        { icon = "fa-facebook"; link ="#"; }
        { icon = "fa-linkedin"; link ="#"; }
      ];
    };
    quicklinks = mkOption {
      description = "Footer links.";
      type = with types; listOf attrs;
      default = [];
      example = [
        { text = "Privacy Policy"; link ="#"; }
        { text = "Terms of Use";   link ="#"; }
      ];
    };
  };

  lib.jquery.enable = true;
  lib.bootstrap.enable = true;
  lib.font-awesome.enable = true;
  lib.googlefonts = [
    "Montserrat:400,700"
    "Kaushan Script"
    "Droid Serif:400,700,400italic,700italic"
    "Roboto Slab:400,100,300,700"
  ];
}
