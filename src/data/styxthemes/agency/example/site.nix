/*-----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------*/

{ pkgs ? import <nixpkgs> {}
, styxLib
, renderDrafts ? false
, siteUrl ? null
, lastChange ? null
}@args:

let lib = import styxLib pkgs;
in with lib;

let

  /* Configuration loading
  */
  conf = let
    conf       = import ./conf.nix;
    themesConf = lib.themes.loadConf { inherit themes themesDir; };
    mergedConf = recursiveUpdate themesConf conf;
  in
    overrideConf mergedConf args;

  /* Site state
  */
  state = { inherit lastChange; };

  /* Load themes templates
  */
  templates = lib.themes.loadTemplates {
    inherit themes defaultEnvironment customEnvironments themesDir;
  };

  /* Load themes static files
  */
  files = lib.themes.loadFiles {
    inherit themes themesDir;
  };


/*-----------------------------------------------------------------------------
   Themes setup

-----------------------------------------------------------------------------*/

  /* Themes location
  */
  themesDir = ../..;

  /* Themes used
  */
  themes = [ "agency" ];


/*-----------------------------------------------------------------------------
   Template environments

-----------------------------------------------------------------------------*/

  /* Default template environment
  */
  defaultEnvironment = { inherit conf state lib templates data; };

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
    events   = sortBy "index" "asc" (lib.data.loadDir { dir = ./data/events; });
    projects = sortBy "date"  "dsc" (lib.data.loadDir { dir = ./data/projects; });
    services = sortBy "index" "asc" (lib.data.loadDir { dir = ./data/services; });
    # Data in nix format
    clients  = import ./data/clients.nix;
    team     = import ./data/team.nix;
  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = rec {
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
