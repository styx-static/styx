/*
  -----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------
*/
{
  pkgs ? import <nixpkgs> {},
  extraConf ? {},
} @ args: rec {
  /*
    -----------------------------------------------------------------------------
     Setup

     This section setup required variables
  -----------------------------------------------------------------------------
  */

  styx = import pkgs.styx {
    # Used packages
    inherit pkgs;

    # Used configuration
    config = [./conf.nix extraConf];

    # Loaded themes
    themes = [../.];

    # Environment propagated to templates
    env = {inherit data pages;};
  };

  # Propagating initialized data
  inherit (styx.themes) conf files templates env lib;

  /*
    -----------------------------------------------------------------------------
     Data

     This section declares the data used by the site
  -----------------------------------------------------------------------------
  */

  data = {
    navbar = with pages; [theme basic starter];
  };

  /*
    -----------------------------------------------------------------------------
     Pages

     This section declares the pages that will be generated
  -----------------------------------------------------------------------------
  */

  /*
  http://getbootstrap.com/getting-started/#examples
  */

  pages = rec {
    basic = {
      inherit (templates) layout;
      template = templates.examples.basic;
      path = "/basic.html";
      # example of adding extra css / js to a page
      #extraJS  = [ { src = "/pop.js"; crossorigin = "anonymous"; } ];
      #extraCSS = [ { href = "/pop.css"; } ];
      title = "Bootstrap 101 Template";
      navbarTitle = "Basic";
    };

    starter = {
      inherit (templates) layout;
      template = templates.examples.starter;
      path = "/starter.html";
      title = "Starter Template for Bootstrap";
      navbarTitle = "Starter";
    };

    theme = {
      inherit (templates) layout;
      template = templates.examples.theme;
      path = "/index.html";
      title = "Theme Template for Bootstrap";
      navbarTitle = "Theme";
    };
  };

  /*
    -----------------------------------------------------------------------------
     Site

  -----------------------------------------------------------------------------
  */

  /*
  Converting the pages attribute set to a list
  */
  pageList = lib.generation.pagesToList {inherit pages;};

  /*
  Generating the site
  */
  site = lib.generation.mkSite {inherit files pageList;};
}
