{
  # URL of the site, must be set to the url of the domain the site will be deployed
  siteUrl = "https://styx-static.github.io/styx-theme-hyde";

  theme = {
    site.title = "Styx Site";
    lib.highlightjs = {
      enable = true;
      style = "github";
      extraLanguages = [ "nix" ];
    };
  };
}
