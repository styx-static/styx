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
  defaultEnvironment = { inherit conf templates data; lib = styxLib; };

  /* Custom environments for specific templates
  */
  customEnvironments = {
    partials.head = defaultEnvironment // { feed = pages.feed; };
  };


/*-----------------------------------------------------------------------------
   Data

   This section declares the data used by the site
   the data set is included in the default template environment
-----------------------------------------------------------------------------*/

  data = {
    # loading a single page
    about  = loadFile { dir = ./pages; file = "about.md"; };
    # loading a list of contents
    posts  = let
      postsList = loadDir { dir = ./posts; };
      # include drafts only when renderDrafts is true
      draftsList = optionals renderDrafts (loadDir { dir = ./drafts; isDraft = true; });
    in sortBy "date" "dsc" (postsList ++ draftsList);
    menus = [ pages.about ];
  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = rec {

    /* Index page
       Splitting a list of items through multiple pages
       For more complex needs, mkSplitCustom is available
    */
    index = mkSplit {
      title = "Home";
      baseHref = "index";
      itemsPerPage = conf.theme.index.itemsPerPage;
      template = templates.index;
      data = posts;
    };

    /* About page
       Example of generating a page from imported data
    */
    about = {
      href = "about.html";
      template = templates.generic.full;
    } // data.about;

    /* RSS feed page
    */
    feed = {
      href = "feed.xml";
      template = templates.feed;
      # Show the 10 most recent posts
      posts = take 10 posts;
      # Bypassing the layout
      layout = id;
    };

    /* 404 error page
    */
    e404 = { href = "404.html"; template = templates.e404; title = "404"; };

    /* Posts pages (as a list of pages)
    */
    posts = mkPageList {
      data = data.posts;
      hrefPrefix = "posts/";
      template = templates.post.full;
      # Template for multi page contents
      multipageTemplate = templates.post.full-multipage;
      breadcrumbs = [ (head pages.index) ];
    };

  };


/*-----------------------------------------------------------------------------
   generateSite arguments preparation

-----------------------------------------------------------------------------*/

  pagesList = let
    # converting pages attribute set to a list
    list = pagesToList pages;
    # setting a layout to pages without one
    in map (setDefaultLayout templates.layout) list;


/*-----------------------------------------------------------------------------
   Site rendering

-----------------------------------------------------------------------------*/

in generateSite { inherit files pagesList; }
