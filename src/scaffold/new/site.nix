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

     Set the themes used here
     paths and packages can be used

     themes = [ ./themes/my-site styx-themes.showcase ];
  */
  themes = [ ];


/*-----------------------------------------------------------------------------
   Template environments

-----------------------------------------------------------------------------*/

  /* Default template environment
  */
  defaultEnvironment = { inherit conf templates data pages; lib = styxLib; };

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

  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = rec {

  };


/*-----------------------------------------------------------------------------
   generateSite arguments preparation

-----------------------------------------------------------------------------*/

  /* Converting the pages attribute set to a list
  */
  pagesList = pagesToList pages;

  /* Substitutions
  */
  substitutions = {
    siteUrl = conf.siteUrl;
  };


/*-----------------------------------------------------------------------------
   Site rendering

-----------------------------------------------------------------------------*/

in generateSite { inherit files pagesList substitutions; }
