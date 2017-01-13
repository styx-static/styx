{
  /* URL of the site, must be set to the url of the domain the site will be deployed
  */
  siteUrl = "https://styx-static.github.io/styx-theme-generic-templates";

  /* Theme specific settings
     it is possible to override any of the used themes configuration in this set
  */
  theme = {
    lib.bootstrap.enable    = true;
    lib.jquery.enable       = true;
    lib.font-awesome.enable = true;
  };

}
