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
    styx-themes.generic-templates
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
    # loading a single page
    about  = loadFile { dir = ./data/pages; file = "about.md"; };
    # loading a list of contents
    posts  = let
      postsList = loadDir { dir = ./data/posts; };
      draftsList = optionals (extraConf ? renderDrafts) (loadDir { dir = ./data/drafts; isDraft = true; });
    in sortBy "date" "dsc" (postsList ++ draftsList);
    menu = [ pages.about ];
  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = with lib; rec {

    /* Index page
       Splitting a list of items through multiple pages
       For more complex needs, mkSplitCustom is available
    */
    index = mkSplit {
      title        = "Home";
      basePath     = "/index";
      itemsPerPage = conf.theme.index.itemsPerPage;
      template     = templates.index;
      data         = posts;
    };

    /* About page
       Example of generating a page from imported data
    */
    about = {
      path     = "/about.html";
      template = templates.page.full;
    } // data.about;

    /* Feed page
    */
    feed = {
      path     = "/feed.xml";
      template = templates.feed.atom;
      # Bypassing the layout
      layout   = id;
      items    = take 10 posts;
    };

    /* 404 error page
    */
    e404 = {
      path     = "/404.html";
      template = templates.e404;
    };

    /* Posts pages (as a list of pages)
    */
    posts = mkPageList {
      data        = data.posts;
      pathPrefix  = "/posts/";
      template    = templates.post.full;
      breadcrumbs = [ (head pages.index) ];
    };

    /* Multipages handling
    */
    postsMultiTail = mkMultiTail {
      data        = data.posts;
      pathPrefix  = "/posts/";
      template    = templates.post.full;
      breadcrumbs = [ (head pages.index) ];
    };

  };


/*-----------------------------------------------------------------------------
   Site rendering

-----------------------------------------------------------------------------*/

  # converting pages attribute set to a list
  pagesList = lib.pagesToList {
    inherit pages;
    default = { layout = templates.layout; };
  };

  site = lib.generateSite { inherit files pagesList; };

}
