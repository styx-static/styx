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
  themes = [
    ../.
  ];

  /* Loading the themes data
  */
  themesData = styxLib.themes.load {
    inherit styxLib themes;
    extraEnv  = { inherit data pages; };
    extraConf = [ ./conf.nix extraConf ];
  };

  /* Bringing the themes data to the scope
  */
  inherit (themesData) conf lib files templates env;


/*-----------------------------------------------------------------------------
   Data

   This section declares the data used by the site
-----------------------------------------------------------------------------*/

  data = {
  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = {
    index = {
      path     = "/index.html";
      template = templates.index;
      layout   = lib.id;
    };
  };


/*-----------------------------------------------------------------------------
   Site rendering

-----------------------------------------------------------------------------*/

  site = lib.mkSite { inherit files;  pageList = [ pages.index ]; };

}