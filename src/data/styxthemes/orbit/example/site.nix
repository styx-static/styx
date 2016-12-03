/*-----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------*/

{ lib, styx, styx-themes, runCommand, writeText
, renderDrafts ? false
, siteUrl ? null
}@args:

let styxLib = import "${styx}/share/styx/lib" {
  inherit lib;
  pkgs = { inherit styx runCommand writeText; };
};
in with styxLib;

let

  /* Configuration loading
  */
  conf = let
    conf       = import ./conf.nix;
    themesConf = styxLib.themes.loadConf themes;
    mergedConf = recursiveUpdate themesConf conf;
  in
    overrideConf mergedConf args;

  /* Load themes templates
  */
  templates = styxLib.themes.loadTemplates {
    inherit themes defaultEnvironment customEnvironments;
  };

  /* Load themes static files
  */
  files = styxLib.themes.loadFiles themes;


/*-----------------------------------------------------------------------------
   Themes setup

-----------------------------------------------------------------------------*/

  /* Themes used
  */
  themes = [ ../. ];


/*-----------------------------------------------------------------------------
   Template environments

-----------------------------------------------------------------------------*/

  /* Default template environment
  */
  defaultEnvironment = { inherit conf data templates; lib = styxLib; };

  /* Custom environments for specific templates
  */
  customEnvironments = {
  };


/*-----------------------------------------------------------------------------
   Data

   This section declares the data used by the site
   the data set is included in the default template environment
-----------------------------------------------------------------------------*/

  data = {
    # data in markdown format
    experiences = sortBy "index" "asc" (styxLib.data.loadDir { dir = ./data/experiences; });
    projects    = sortBy "index" "asc" (styxLib.data.loadDir { dir = ./data/projects; });
    summary     = styxLib.data.loadFile { dir = ./data; file = "summary.md"; };
  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = {
    index = {
      href = "index.html";
      template = templates.index;
      layout = id;
    };
  };


/*-----------------------------------------------------------------------------
   generateSite arguments preparation

-----------------------------------------------------------------------------*/

  pagesList = [ pages.index ];


/*-----------------------------------------------------------------------------
   Site rendering

-----------------------------------------------------------------------------*/

in generateSite { inherit files pagesList; }
