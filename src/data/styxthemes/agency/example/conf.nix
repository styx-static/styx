{ lib }:
with lib;
{
  # URL of the site, must be set to the url of the domain the site will be deployed
  siteUrl = "https://styx-static.github.io/styx-theme-agency";


  theme = {
    site.title = "Styx Agency";
    menu.append = [
      { url  = "https://styx-static.github.io/styx-site/";
        name = "Styx"; }
    ];

    services.items  = sortBy "index" "asc" (loadDir { dir = ./data/services; });
    portfolio.items = sortBy "date"  "dsc" (loadDir { dir = ./data/projects; });
    about.items     = sortBy "index" "asc" (loadDir { dir = ./data/events; });
    team.members    = import ./data/team.nix;
    clients         = import ./data/clients.nix;

    contact.enable = true;

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
