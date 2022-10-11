{
  /*
  URL of the site, must be set to the url of the domain the site will be deployed
  */
  siteUrl = "https://styx-static.github.io/styx-theme-ghostwriter";

  /*
  Theme specific settings
  it is possible to override any of the used themes configuration in this set
  */
  theme = {
    lib.highlightjs = {
      enable = true;
      style = "github";
      extraLanguages = ["nix"];
    };
  };
}
