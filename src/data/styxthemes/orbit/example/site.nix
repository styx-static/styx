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
    templates.extraEnv = { inherit data pages; };
    conf.extra = [ (import ./conf.nix) extraConf ];
  };

  /* Bringing the themes data to the scope
  */
  inherit (themesData) conf lib files templates;


/*-----------------------------------------------------------------------------
   Data

   This section declares the data used by the site
-----------------------------------------------------------------------------*/

  data = with lib; {
    # data in markdown format
    experiences = sortBy "index" "asc" (loadDir { dir = ./data/experiences; });
    projects    = sortBy "index" "asc" (loadDir { dir = ./data/projects; });
    summary     = loadFile { dir = ./data; file = "summary.md"; };
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
   generateSite arguments preparation

-----------------------------------------------------------------------------*/


/*-----------------------------------------------------------------------------
   Site rendering

-----------------------------------------------------------------------------*/

  pagesList = [ pages.index ];

  site = lib.generateSite { inherit files pagesList; };

}
