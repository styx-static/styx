{
  # URL of the site, must be set to the url of the domain the site will be deployed
  siteUrl = "https://styx-static.github.io/styx-theme-showcase";

  # Theme specific settings
  # it is possible to override any of the theme configuration settings in the 'theme' set
  theme = {
    lib.bootstrap.enable    = true;
    lib.jquery.enable       = true;
    lib.font-awesome.enable = true;
  };
}
