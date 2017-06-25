{ lib }:
with lib;
{
  # URL of the site, must be set to the url of the domain the site will be deployed
  siteUrl = "https://styx-static.github.io/styx-theme-agency";


  theme = {
    site.title = "Styx Agency";

    footer = {
      social = [
        { icon = "fa-twitter";  link ="#"; }
        { icon = "fa-facebook"; link ="#"; }
        { icon = "fa-linkedin"; link ="#"; }
      ];
      quicklinks = [
        { text = "Privacy Policy"; link ="#"; }
        { text = "Terms of Use";   link ="#"; }
      ];
    };
  };
}
