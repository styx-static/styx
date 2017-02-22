{
  # URL of the site, must be set to the url of the domain the site will be deployed
  siteUrl = "https://styx-static.github.io/styx-theme-showcase";

  # Theme specific settings
  # it is possible to override any of the theme configuration settings in the 'theme' set
  theme = {
    site.title = "Showcase Example";
    lib = {
      bootstrap.enable    = true;
      jquery.enable       = true;
      font-awesome.enable = true;
      highlightjs = {
        enable = true;
        style = "github";
        extraLanguages = [ "nix" ];
      };
      mathjax.enable = true;
    };
  };
}
