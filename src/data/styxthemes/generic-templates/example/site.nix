/*-----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------*/
{ lib, styx, runCommand, writeText
, styx-themes
, extraConf ? {}
}@args:

rec {

  /* Library loading
  */
  styxLib = import styx.lib args;


/*-----------------------------------------------------------------------------
   Themes setup

-----------------------------------------------------------------------------*/

  /* list the themes to load, paths or packages can be used
     items at the end of the list have higher priority
  */
  themes = [ ../. ];

  /* Loading the themes data
  */
  themesData = styxLib.themes.load {
    inherit styxLib themes;
    extraEnv  = { inherit data pages; };
    extraConf = [ ./conf.nix extraConf ];
  };

  /* Bringing the themes data to the scope
  */
  inherit (themesData) conf lib files templates;


/*-----------------------------------------------------------------------------
   Data

   This section declares the data used by the site
-----------------------------------------------------------------------------*/

  data = {
    navbar = with pages; [ theme basic starter ];
  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  /* http://getbootstrap.com/getting-started/#examples
  */

  pages = rec {

    basic = {
      layout   = templates.layout;
      template = templates.examples.basic;
      path     = "/basic.html";
      # example of adding extra css / js to a page
      #extraJS  = [ { src = "/pop.js"; crossorigin = "anonymous"; } ];
      #extraCSS = [ { href = "/pop.css"; } ];
      title    = "Bootstrap 101 Template";
      navbarTitle = "Basic";
    };

    starter = {
      layout   = templates.layout;
      template = templates.examples.starter;
      path     = "/starter.html";
      title    = "Starter Template for Bootstrap";
      navbarTitle = "Starter";
    };

    theme = {
      layout   = templates.layout;
      template = templates.examples.theme;
      path     = "/index.html";
      title    = "Theme Template for Bootstrap";
      navbarTitle = "Theme";
    };

  };


/*-----------------------------------------------------------------------------
   Site

-----------------------------------------------------------------------------*/

  /* Converting the pages attribute set to a list
  */
  pageList = lib.pagesToList { inherit pages; };

  /* Generating the site
  */
  site = lib.mkSite { inherit files pageList; };

}
