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
  themes = [ "showcase" ];


/*-----------------------------------------------------------------------------
   Template enviroments

-----------------------------------------------------------------------------*/


  /* Default template environment
  */
  defaultEnvironment = { inherit conf state lib templates data; };

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
      postsList = loadFolder { inherit substitutions; from = ./posts; };
      # include drafts only when renderDrafts is true
      draftsList = optionals renderDrafts (loadFolder { inherit substitutions; from = ./drafts; extraAttrs = { isDraft = true; }; });
    in sortBy "date" "dsc" (postsList ++ draftsList);
    # Navbar data
    navbar = [
      pages.about
      { title = "RSS";  href = "${conf.siteUrl}/${pages.feed.href}"; }
      { title = "Styx"; href = "https://styx-static.github.io/styx-site/"; }
    ];
    # content taxonomies
    taxonomies = mkTaxonomyData { pages = pages.posts; taxonomies = [ "tags" "level" ]; };
  };

  /* Substitutions used in data
  */
  substitutions = { inherit conf; };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/


  pages = rec {

    /* Index page
       Example of splitting a list of items through multiple pages
       For more complex needs, mkSplitCustom is available
    */
    index = mkSplit {
      title = "Home";
      baseHref = "index";
      itemsPerPage = conf.theme.index.itemsPerPage;
      template = templates.index;
      items = posts;
    };

    /* About page
       Example of generating a page from a piece of data
    */
    about = {
      href = "about.html";
      template = templates.generic.full;
      # setting breadcrumbs
      breadcrumbs = [ (head index) ];
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

       mkPageList is a convenience function to generate a list of page from a
       list of data
    */
    posts = mkPageList {
      dataList = data.posts;
      hrefPrefix = "posts/";
      template = templates.post.full;
      # Template for multi page contents
      multipageTemplate = templates.post.full-multipage;
      breadcrumbs = [ (head pages.index) ];
    };

    /* Subpages of multi-pages posts

       subpages are not included in posts because we do not want to have the
       subpages in the rss feed or posts list
    */
    postsSubpages = let
      multipagePosts = filter (p: (p ? subpages)) data.posts;
      generateSubpages = page: 
        mkMultipages {
          inherit page;
          template = templates.post.full-multipage;
          baseHref = "posts/${page.fileData.basename}";
          output   = "subpages";
          breadcrumbs = [ (head pages.index) ];
      };
    in flatten (map generateSubpages multipagePosts);

    /* Taxonomy related pages
    */
    taxonomies = mkTaxonomyPages {
      data = data.taxonomies;
      taxonomyTemplate = templates.taxonomy.full;
      termTemplate = templates.taxonomy.term.full;
    };

  };


/*-----------------------------------------------------------------------------
   generateSite arguments preparation

-----------------------------------------------------------------------------*/

  pagesList = let
    # converting pages attribute set to a list
    list = pagesToList pages;
    # setting a default layout
    in map (setDefaultLayout templates.layout) list;


/*-----------------------------------------------------------------------------
   Site rendering

-----------------------------------------------------------------------------*/

in generateSite { inherit files pagesList; }
