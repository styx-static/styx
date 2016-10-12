{ pkgs ? import <nixpkgs> {}
, styxLib
, renderDrafts ? false
, siteUrl ? null
, lastChange ? null
}@args:

#let lib = import styxLib pkgs;
let lib = import ../../../lib pkgs;
in with lib;

let


/* Basic setup

   This section is boilerplate code responsible for basic setup
*/

  themes = [ "agency" ];

  themesDir = ../..;

  conf = let
    conf       = import ./conf.nix;
    themesConf = lib.themes.loadConf { inherit themes themesDir; };
    mergedConf = recursiveUpdate themesConf conf;
  in
    overrideConf mergedConf args;

  state = { inherit lastChange; };

  templates = lib.themes.loadTemplates {
    inherit themes defaultEnvironment themesDir;
  };

  files = lib.themes.loadFiles {
    inherit themes themesDir;
  };


/* Template Environment

   This section declare template environments
*/

  # Default template environment, this set of variables will be available in every template
  defaultEnvironment = { inherit conf state lib templates data; };


/* Data

   This section loads dta used in the site
*/

  data = {
    # data in markdown format
    events   = sortBy "index" "asc" (lib.data.loadFolder { from = ./data/events; });
    projects = sortBy "date"  "dsc" (lib.data.loadFolder { from = ./data/projects; });
    services = sortBy "index" "asc" (lib.data.loadFolder { from = ./data/services; });
    # Data in nix format
    clients  = import ./data/clients.nix;
    team     = import ./data/team.nix;
  };


/* Pages

   This section declare the site pages
   Every page in this set will be generates
*/

  pages = rec {

    index = {
      href = "index.html";
      template = templates.index;
      layout = id;
    };

  };

  # This site is a single page
  pagesList = [ pages.index ];

/* Site rendering

   This section render the site, for custom needs it is possible to use the `preGen` and `postGen` hooks
*/

in generateSite { inherit files pagesList; }
